import { View, div } from "gpui-kit";
import { appHome, checking, closeOverlay, exec, focused, notify, props } from "herdr";
import { createWorkspace } from "./workspace.js";

export default class DefaultWorkspace extends View {
  init(_props, cx) {
    if (checking()) return;
    const context = focused();
    const overlay = props().overlay;
    const home = appHome();
    cx.spawn(async () => {
      try {
        await createWorkspace(context, async (args) => {
          const result = await exec("env", [`HERDR_APP_HOME=${home}`, "herdr-app", ...args]);
          if (result.code !== 0) throw new Error(result.stderr || result.stdout || "herdr-app failed");
          const value = JSON.parse(result.stdout);
          if (value.error) throw new Error(value.error);
          return value;
        });
      } catch (error) {
        notify({
          title: "Could not create default workspace",
          body: `${error.message}. Any tabs already created were left open.`,
          level: "error",
        });
      } finally {
        closeOverlay(overlay);
      }
    });
  }

  render() {
    return div().p(12).child("Creating workspace…");
  }
}
