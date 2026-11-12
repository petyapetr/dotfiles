import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { layout, run, theme } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

export default class SidebarToggle extends View {
  render() {
    const t = theme();
    const folded = Boolean(find(layout(), "sidebar")?.hidden);
    return h_flex().size_full().bg(t.chrome).border_t(1).border_color(t.border).items_center().justify_center()
      .child(div().id("sidebar-toggle").size(22).flex_none().flex().items_center().justify_center().rounded(5)
        .text_color(t.dim).tooltip(folded ? "Show sidebar" : "Hide sidebar")
        .hover(s => s.bg(t.hover).text_color(t.foreground)).cursor_pointer()
        .on_click(() => run("layout.toggle", { id: "sidebar" }))
        .child(svg(`mods/workspace-chrome/chevron-${folded ? "left" : "right"}.svg`).size(14)));
  }
}
