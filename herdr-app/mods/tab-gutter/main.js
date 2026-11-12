import { View, div } from "gpui-kit";
import { layout, run, settings, theme, window } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// Reserves the macOS traffic lights' corner for the shipped tabs mod.
// tabs pads itself by 10 when the sidebar is shown, and by the lights' whole
// room when it is hidden; this block fills the difference only when needed.
export default class TabGutter extends View {
  render() {
    const t = theme();
    const root = layout();
    const sidebar = find(root, "sidebar");
    const node = find(root, "tab-gutter");
    const w = window();
    const lights = root?.traffic_lights;
    const room = lights ? (lights[0] + 64) / settings().zoom : 0;
    const wantsGutter = w?.platform === "macos" && w.titlebar === "none" && !w.fullscreen
      && Boolean(lights) && !sidebar?.hidden;
    const want = wantsGutter
      ? Math.max(0, Math.min(sidebar?.size?.px ?? 0, room - 10))
      : 0;
    if (node && Math.abs((node.size?.px ?? 0) - want) > 0.5) {
      run("layout.resize", { id: "tab-gutter", px: Math.round(want * 10) / 10 });
    }
    return div().size_full().bg(t.chrome).border_b(1).border_color(t.border);
  }
}
