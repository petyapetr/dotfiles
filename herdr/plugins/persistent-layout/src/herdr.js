"use strict";

const { spawnSync } = require("child_process");

const DEFAULT_BIN = process.env.HERDR_BIN_PATH || "herdr";

// Run a herdr command and return the `.result` object from its JSON output.
// Throws on non-zero exit; stderr lines are surfaced on the error.
function run(args) {
  const bin = DEFAULT_BIN;
  const res = spawnSync(bin, args, { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
  if (res.status !== 0) {
    let detail = (res.stderr || "").trim();
    try {
      const j = JSON.parse(res.stdout || "");
      if (j && j.error && j.error.message) detail = j.error.message;
    } catch (_) { /* keep stderr */ }
    const err = new Error(`\`herdr ${args.join(" ")}\` exited ${res.status}${detail ? ": " + detail : ""}`);
    err.exitStatus = res.status;
    err.stderr = res.stderr;
    err.stdout = res.stdout;
    err.args = args;
    throw err;
  }
  let json;
  if (res.stdout.trim() === "") {
    // Some herdr commands (e.g. `pane run`) return success with no stdout.
    return {};
  }
  try {
    json = JSON.parse(res.stdout);
  } catch (e) {
    const err = new Error(`\`herdr ${args.join(" ")}\` did not return JSON: ${e.message}`);
    err.stdout = res.stdout;
    throw err;
  }
  if (json.error) {
    const err = new Error(`herdr error (${json.error.code || "?"}): ${json.error.message || ""}`);
    err.code = json.error.code;
    throw err;
  }
  return json.result || {};
}

module.exports = { run };