"use strict";

const fs = require("fs");
const path = require("path");
const { parse } = require("./toml");
const herdr = require("./herdr");

function expandCwd(p, invocationCwd) {
  if (!p) return undefined;
  if (p === "current") return invocationCwd || process.cwd();
  if (p === "~") return process.env.HOME || "~";
  if (p.startsWith("~/")) return path.join(process.env.HOME || "", p.slice(2));
  return p;
}

function cwdOf(invocationCwd, ...cands) {
  return expandCwd(cands.find(Boolean), invocationCwd);
}

function layoutsDir() {
  if (process.env.HERDR_PLUGIN_CONFIG_DIR) {
    return path.join(process.env.HERDR_PLUGIN_CONFIG_DIR, "layouts");
  }
  // CLI fallback: dotfiles/herdr/layouts relative to this src dir.
  return path.join(__dirname, "..", "..", "layouts");
}

function validate(layout, file) {
  const where = `in ${file}`;
  if (!layout.name || typeof layout.name !== "string") throw new Error(`missing 'name' ${where}`);
  if (!Array.isArray(layout.tabs) || !layout.tabs.length) throw new Error(`no [[tabs]] ${where}`);
  for (const [ti, tab] of layout.tabs.entries()) {
    const tw = `${where} tabs[${ti}]`;
    if (!tab.name || typeof tab.name !== "string") throw new Error(`missing 'name' ${tw}`);
    const seen = new Set();
    for (const [pi, pane] of (tab.panes || []).entries()) {
      const pw = `${tw} panes[${pi}]`;
      if (pane.name) {
        if (seen.has(pane.name)) throw new Error(`duplicate pane name '${pane.name}' ${pw}`);
        seen.add(pane.name);
      }
      const from = pane.from || "root";
      if (from !== "root" && !seen.has(from) && from !== tab._rootName) {
        throw new Error(`pane 'from=${from}' refers to no earlier pane ${pw}`);
      }
    }
    // 'root' is implicitly known; record its label so 'from="root"' validates.
    tab._rootName = "root"; // sentinel; resolved at apply time, not by name lookup
  }
}

function resolveFromPane(from, rootPaneId, paneNames) {
  if (!from || from === "root") return rootPaneId;
  const p = paneNames.get(from);
  if (!p) throw new Error(`pane 'from=${from}' not found (resolved too early?)`);
  return p;
}

function apply(layoutName, opts) {
  opts = opts || {};
  const invocationCwd = opts.invocationCwd || process.cwd();
  if (typeof invocationCwd !== "string" || !invocationCwd) {
    throw new Error("invocationCwd must be a non-empty string");
  }
  const dir = layoutsDir();
  const file = path.join(dir, layoutName + ".toml");
  let raw;
  try {
    raw = fs.readFileSync(file, "utf8");
  } catch (e) {
    throw new Error(`layout '${layoutName}' not found at ${file}: ${e.message}`);
  }
  const layout = parse(raw);
  validate(layout, path.basename(file));

  // Resolve a workspace name of "current" to the basename of the invoker's
  // cwd, mirroring `cwd = "current"`. Literal names are used as-is.
  const resolvedName =
    layout.name === "current" ? path.basename(invocationCwd) : layout.name;

  const steps = [];
  let createdWorkspaceId = null;

  const cleanup = () => { /* leave partial workspace for manual inspection */ };

  let rootWorkspaceId = null;

  // Step 1: workspace.
  const wsArgs = ["workspace", "create", "--label", resolvedName, "--no-focus"];
  const wc = layout.cwd ? cwdOf(invocationCwd, layout.cwd) : undefined;
  if (wc) wsArgs.push("--cwd", wc);
  const cr = herdr.run(wsArgs);
  const ws = cr.workspace;
  const rootTab = cr.tab;
  const rootPane = cr.root_pane;
  rootWorkspaceId = ws.workspace_id;
  createdWorkspaceId = ws.workspace_id;
  steps.push("workspace create " + ws.workspace_id);

  try {
    for (const [ti, tab] of layout.tabs.entries()) {
      let tabId;
      let rootPaneId;
      if (ti === 0) {
        tabId = rootTab.tab_id;
        rootPaneId = rootPane.pane_id;
        herdr.run(["tab", "rename", tabId, tab.name]);
        steps.push(`tab[0] rename ${tabId} -> ${tab.name}`);
      } else {
        const tArgs = ["tab", "create", "--workspace", createdWorkspaceId, "--label", tab.name, "--no-focus"];
        const tabCwd = cwdOf(invocationCwd, tab.cwd, layout.cwd);
        if (tabCwd && tabCwd !== wc) tArgs.push("--cwd", tabCwd);
        const tr = herdr.run(tArgs);
        tabId = tr.tab.tab_id;
        rootPaneId = tr.root_pane.pane_id;
        steps.push(`tab[${ti}] create ${tabId}`);
      }

      // root pane command
      if (tab.command) {
        herdr.run(["pane", "run", rootPaneId, tab.command]);
        steps.push(`tab[${ti}] root run: ${tab.command}`);
      }

      const paneNames = new Map(); // name -> pane_id, populated in file order
      for (const pane of (tab.panes || [])) {
        const base = resolveFromPane(pane.from, rootPaneId, paneNames);
        const splitArgs = ["pane", "split", base, "--direction", pane.direction || "right", "--no-focus"];
        if (typeof pane.ratio === "number") splitArgs.push("--ratio", String(pane.ratio));
        const paneCwd = cwdOf(invocationCwd, pane.cwd, tab.cwd, layout.cwd);
        if (paneCwd && paneCwd !== wc) splitArgs.push("--cwd", paneCwd);
        const split = herdr.run(splitArgs);
        const paneId = split.pane.pane_id;
        if (pane.name) {
          paneNames.set(pane.name, paneId);
          herdr.run(["pane", "rename", paneId, pane.name]);
        }
        if (pane.command) {
          herdr.run(["pane", "run", paneId, pane.command]);
        }
        steps.push(`tab[${ti}] pane ${pane.name || paneId} ready`);
      }
    }

    if (!opts.noFocus) {
      herdr.run(["workspace", "focus", createdWorkspaceId]);
      steps.push("workspace focus " + createdWorkspaceId);
    }

    return { workspace_id: createdWorkspaceId, layout: resolvedName, steps };
  } catch (e) {
    e.applySteps = steps;
    e.partialWorkspace = createdWorkspaceId;
    cleanup();
    throw e;
  }
}

module.exports = { apply, parse: parse, layoutsDir, validate };

if (require.main === module) {
  const layoutName = process.argv[2];
  if (!layoutName) {
    process.stderr.write("usage: node src/apply.js <layout-name>\n");
    process.exit(2);
  }
  try {
    const res = apply(layoutName, { invocationCwd: process.cwd() });
    process.stdout.write(`Applied '${res.layout}' -> workspace ${res.workspace_id}\n`);
  } catch (e) {
    process.stderr.write(`apply failed: ${e.message}\n`);
    if (e.applySteps) process.stderr.write("steps: " + e.applySteps.join(" | ") + "\n");
    if (e.partialWorkspace) process.stderr.write(`partial workspace left: ${e.partialWorkspace}\n`);
    process.exit(1);
  }
}