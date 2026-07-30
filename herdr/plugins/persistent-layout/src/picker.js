"use strict";

const fs = require("fs");
const path = require("path");
const readline = require("readline");
const herdrCli = require("./herdr");
const { layoutsDir } = require("./apply");
const mod = require("./apply");

// Determine the cwd of the pane that opened this popup, so `cwd = "current"`
// in a layout resolves to the invoker's directory rather than the plugin root.
// The popup pane itself is launched inside the plugin; its own process.cwd() is
// the plugin root, not the invoker. We recover the invoker by listing panes in
// the picker's workspace and excluding this picker pane, preferring the focused
// neighbor; falling back to any non-picker pane's reported cwd.
function invokerCwd() {
  const ws = process.env.HERDR_WORKSPACE_ID;
  const self = process.env.HERDR_PANE_ID;
  if (!ws) return process.cwd();
  try {
    const res = herdrCli.run(["pane", "list", "--workspace", ws]);
    const panes = (res && res.panes) || [];
    const other = panes.filter((p) => p.pane_id !== self);
    if (!other.length) return process.cwd();
    const focused = other.find((p) => p.focused) || other[0];
    return focused.cwd || process.cwd();
  } catch (_) {
    return process.cwd();
  }
}

function listLayouts() {
  const dir = layoutsDir();
  let files;
  try {
    files = fs.readdirSync(dir);
  } catch (e) {
    return [];
  }
  return files
    .filter((f) => f.endsWith(".toml"))
    .map((f) => f.slice(0, -".toml".length))
    .map((name) => {
      let description = "";
      try {
        const layout = mod.parse(fs.readFileSync(path.join(dir, name + ".toml"), "utf8"));
        description = layout.description || "";
      } catch (_) { /* keep empty */ }
      return { name, description };
    })
    .sort((a, b) => a.name.localeCompare(b.name));
}

// --- inline interactive picker (Node stdlib only) ---------------------------

const HIDE_CURSOR = "\x1b[?25l";
const SHOW_CURSOR = "\x1b[?25h";
const CLEAR_LINE = "\x1b[2K";
const RESET = "\x1b[0m";
const BOLD = "\x1b[1m";
const DIM = "\x1b[2m";
const CYAN = "\x1b[36m";

function interactive(layouts) {
  const out = process.stdout;
  const stdin = process.stdin;
  const useColor = !!out.isTTY && !process.env.NO_COLOR;

  const c = (...seq) => (useColor ? seq.join("") : "");
  const header = "◇  Pick a layout";
  const hint = "└  ↑/↓ move · enter select · esc cancel";

  let cursor = 0;
  let lastLines = 0;

  function optionLine(entry, active) {
    const marker = active ? "❯ " : "  ";
    const name = entry.name;
    const desc = entry.description ? `  — ${entry.description}` : "";
    if (active) {
      return `│  ${c(BOLD, CYAN)}${marker}${name}${c(RESET)}${c(DIM)}${desc}${c(RESET)}`;
    }
    return `│  ${marker}${name}${c(DIM)}${desc}${c(RESET)}`;
  }

  function buildLines() {
    const rows = out.rows || 24;
    const fixed = 4; // header, sep, sep, hint
    const avail = Math.max(1, rows - fixed);
    let start = 0;
    let end = layouts.length;
    if (layouts.length > avail) {
      const half = Math.floor(avail / 2);
      start = cursor - half;
      if (start < 0) start = 0;
      end = start + avail;
      if (end > layouts.length) {
        end = layouts.length;
        start = end - avail;
      }
    }
    const lines = [header, "│"];
    if (start > 0) lines.push(`${c(DIM)}│  …${c(RESET)}`);
    for (let i = start; i < end; i++) {
      lines.push(optionLine(layouts[i], i === cursor));
    }
    if (end < layouts.length) lines.push(`${c(DIM)}│  …${c(RESET)}`);
    lines.push("│", hint);
    return lines;
  }

  function render() {
    const lines = buildLines();
    if (lastLines > 0) out.write(`\x1b[${lastLines}A`);
    for (const ln of lines) out.write(`\r${CLEAR_LINE}${ln}\n`);
    lastLines = lines.length;
  }

  function collapse(summary) {
    if (lastLines > 0) out.write(`\x1b[${lastLines}A`);
    out.write(`\r${CLEAR_LINE}\x1b[J${summary}\n`);
    lastLines = 0;
  }

  return new Promise((resolve, reject) => {
    let finished = false;
    function finish(action, value) {
      if (finished) return;
      finished = true;
      stdin.setRawMode(false);
      readline.emitKeypressEvents(stdin);
      stdin.pause();
      stdin.removeAllListeners("keypress");
      out.write(SHOW_CURSOR);
      if (action === "cancel") {
        collapse("◇  Cancelled");
        resolve(null);
      } else {
        collapse(`◇  Layout: ${value}`);
        resolve(value);
      }
    }

    function onKey(str, key) {
      if (!key) return;
      switch (key.name) {
        case "up":
        case "k":
          cursor = (cursor - 1 + layouts.length) % layouts.length;
          render();
          break;
        case "down":
        case "j":
          cursor = (cursor + 1) % layouts.length;
          render();
          break;
        case "return":
          finish("confirm", layouts[cursor].name);
          break;
        case "escape":
        case "c": // ctrl+c arrives as name 'c' with ctrl true
          if (key.name === "c" && !key.ctrl) break;
          finish("cancel");
          break;
        default:
          if (/^[0-9]$/.test(key.name || "")) {
            const idx = Number(key.name) - 1;
            if (idx >= 0 && idx < layouts.length) {
              cursor = idx;
              render();
            }
          }
      }
    }

    try {
      readline.emitKeypressEvents(stdin);
      stdin.setRawMode(true);
      stdin.resume();
    } catch (e) {
      return reject(e);
    }

    out.write(HIDE_CURSOR);
    stdin.on("keypress", onKey);
    render();

    const restore = () => {
      if (finished) return;
      out.write(SHOW_CURSOR);
      try { stdin.setRawMode(false); } catch (_) { /* already closed */ }
    };
    process.once("SIGINT", () => finish("cancel"));
    process.once("exit", restore);
  });
}

// --- non-TTY fallback: numbered-list prompt (unchanged behavior) ------------

async function numberedPrompt(layouts) {
  process.stdout.write("\npersistent-layout — pick a layout\n\n");
  layouts.forEach((l, i) => {
    const d = l.description ? `  — ${l.description}` : "";
    process.stdout.write(`  ${String(i + 1).padStart(2, " ")}. ${l.name}${d}\n`);
  });
  process.stdout.write("\nEnter number or name (blank to cancel): ");

  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  const answer = await new Promise((res) => rl.question("", (a) => res(a.trim())));
  rl.close();

  if (!answer) { process.stdout.write("cancelled\n"); return null; }

  if (/^\d+$/.test(answer)) {
    const idx = Number(answer) - 1;
    if (idx >= 0 && idx < layouts.length) return layouts[idx].name;
  }
  const byName = layouts.find((l) => l.name === answer);
  if (byName) return byName.name;

  process.stderr.write(`unknown layout: ${answer}\n`);
  process.exit(2);
}

// --- main -------------------------------------------------------------------

async function main() {
  const layouts = listLayouts();
  if (!layouts.length) {
    process.stderr.write("No layouts found. Add TOML files to layouts/.\n");
    process.exit(1);
  }

  let pick;
  if (process.stdin.isTTY && process.stdout.isTTY) {
    try {
      pick = await interactive(layouts);
    } catch (e) {
      // Raw mode unavailable (rare): fall back to the numbered prompt.
      pick = await numberedPrompt(layouts);
    }
  } else {
    pick = await numberedPrompt(layouts);
  }

  if (!pick) process.exit(0);

  try {
    const res = require("./apply").apply(pick, { invocationCwd: invokerCwd() });
    process.stdout.write(`Applied '${res.layout}' -> workspace ${res.workspace_id}\n`);
  } catch (e) {
    process.stderr.write(`apply failed: ${e.message}\n`);
    if (e.applySteps) process.stderr.write("steps: " + e.applySteps.join(" | ") + "\n");
    process.exit(1);
  }
}

main();