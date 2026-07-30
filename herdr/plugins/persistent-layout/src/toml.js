"use strict";

// Minimal TOML parser covering only the persistent-layout layout schema:
// - bare key = value where value is a double-quoted string, integer, or float
// - comments via `#`
// - array-of-tables headers `[[tabs]]` and `[[tabs.panes]]`
// Nothing else is supported; unknown input throws.

function stripComment(line) {
  let out = "";
  let inStr = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"' && line[i - 1] !== "\\") inStr = !inStr;
    if (ch === "#" && !inStr) break;
    out += ch;
  }
  return out.trim();
}

function parseValue(raw) {
  raw = raw.trim();
  if (raw === "") throw new Error("empty value");
  if (raw[0] === '"') {
    if (raw[raw.length - 1] !== '"') throw new Error("unterminated string: " + raw);
    let s = raw.slice(1, -1);
    s = s.replace(/\\n/g, "\n").replace(/\\t/g, "\t").replace(/\\"/g, '"').replace(/\\\\/g, "\\");
    return s;
  }
  const n = Number(raw);
  if (!Number.isNaN(n) && raw !== "") return n;
  throw new Error("unsupported value: " + raw);
}

function parseKeyValue(line) {
  const eq = line.indexOf("=");
  if (eq < 0) throw new Error("missing '=' in: " + line);
  const key = line.slice(0, eq).trim();
  const val = parseValue(line.slice(eq + 1));
  if (!key) throw new Error("empty key in: " + line);
  return [key, val];
}

function parse(toml) {
  const root = {};
  let tabsLastPanes = null;

  for (const original of toml.split(/\r?\n/)) {
    const line = stripComment(original);
    if (line === "") continue;

    if (line.startsWith("[[")) {
      if (!line.endsWith("]]")) throw new Error("bad header: " + line);
      const name = line.slice(2, -2).trim();
      if (name === "tabs") {
        const tabs = root.tabs || (root.tabs = []);
        const tab = { panes: [] };
        tabs.push(tab);
        tabsLastPanes = tab.panes;
      } else if (name === "tabs.panes") {
        if (!root.tabs || !root.tabs.length) throw new Error("[[tabs.panes]] without [[tabs]]");
        const pane = {};
        root.tabs[root.tabs.length - 1].panes.push(pane);
      } else {
        throw new Error("unsupported header: " + line);
      }
      continue;
    }

    const [key, val] = parseKeyValue(line);
    assignToContext(root, key, val);
  }
  return root;
}

function assignToContext(root, key, val) {
  if (!root.tabs) { root[key] = val; return; }
  const lastTab = root.tabs[root.tabs.length - 1];
  const panes = lastTab.panes;
  if (panes.length) panes[panes.length - 1][key] = val;
  else lastTab[key] = val;
}

module.exports = { parse };