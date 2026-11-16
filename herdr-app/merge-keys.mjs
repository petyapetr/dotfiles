import { randomUUID } from "node:crypto";
import { isDeepStrictEqual } from "node:util";
import { lstat, mkdir, readFile, rename, rm, writeFile } from "node:fs/promises";
import { dirname } from "node:path";

function load(text) {
  const value = JSON.parse(text);
  const object = value => value !== null && typeof value === "object" && !Array.isArray(value);
  if (!object(value) || !Object.values(value).every(object)) {
    throw new Error("Key bindings must be an object of section objects");
  }
  return value;
}

async function merge(remappings, target) {
  const custom = load(await readFile(remappings, "utf8"));
  const stat = await lstat(target).catch(error => {
    if (error.code !== "ENOENT") throw error;
    return null;
  });
  // Reading before replacing also preserves the contents of an existing symlink.
  const original = stat ? await readFile(target, "utf8") : null;
  const keys = original === null ? {} : load(original);
  const merged = Object.fromEntries(Object.entries(keys).map(([section, bindings]) => [section, { ...bindings }]));
  for (const [section, bindings] of Object.entries(custom)) {
    Object.defineProperty(merged, section, {
      value: { ...(Object.hasOwn(merged, section) ? merged[section] : {}), ...bindings },
      enumerable: true, configurable: true, writable: true,
    });
  }
  if (isDeepStrictEqual(merged, keys) && !stat?.isSymbolicLink()) {
    console.log(`Key remappings already applied: ${target}`);
    return;
  }

  await mkdir(dirname(target), { recursive: true });
  if (original !== null) {
    const backup = `${target}.backup.${randomUUID()}`;
    await writeFile(backup, original, { flag: "wx", mode: 0o600 });
    console.log(`Backed up ${target} to ${backup}`);
  }
  const temporary = `${target}.${randomUUID()}`;
  try {
    await writeFile(temporary, JSON.stringify(merged, null, 2) + "\n", { flag: "wx", mode: 0o600 });
    // Replace the directory entry, not the file a previous symlink points to.
    await rename(temporary, target);
  } finally {
    await rm(temporary, { force: true });
  }
  console.log(`Merged key remappings into ${target}`);
}

try {
  const [remappings, target] = process.argv.slice(2);
  if (!remappings || !target) throw new Error("Usage: node merge-keys.mjs <remappings.json> <keys.json>");
  await merge(remappings, target);
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
