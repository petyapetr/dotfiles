// Use CLI replies for IDs: run() does not return created tabs or panes.
export async function createWorkspace(context, call) {
  if (!context?.space || !context.cwd) {
    throw new Error("Focus a terminal in the target directory first");
  }
  const { space, cwd: folder } = context;
  const command = (name, args) => call(["do", name, JSON.stringify(args)]);
  const tab = (name, argv) => command("tab.new", {
    space, folder, name, focus: false, ...(argv ? { argv } : {}),
  });

  const agent = await tab("agent", ["opencode"]);
  await tab("git");
  await tab("editor", ["micro"]);
  const terminal = await tab("terminal");
  const world = await call(["ls"]);
  const pane = world.spaces.find(s => s.id === space)
    ?.tabs.find(t => t.id === terminal.tab)?.terminals.find(t => t.pane)?.pane;
  if (!pane) throw new Error("Could not find the new terminal pane");
  await command("pane.split", { pane, direction: "right" });
  await command("space.select", { id: space });
  await command("tab.select", { id: agent.tab });
}
