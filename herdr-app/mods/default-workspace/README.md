# Default workspace

Run `make herdr-app` to link the mod and merge custom key remappings.
`herdr-app/key-remappings.json` contains only custom bindings.
Run `make herdr-app-keys` to apply just those remappings. It requires Node.js,
preserves unrelated bindings, and backs up keys before changing them.
Removing a remapping from the file does not undo an already applied binding.

In a terminal, navigate to your project and press `Cmd+Shift+N`. This adds
four tabs to the current space, using that terminal's directory:

- `agent`: `opencode`
- `git`: bare shell
- `editor`: `micro`
- `terminal`: two bare shells side by side

Existing tabs stay open. The agent tab is selected when creation finishes.
Each invocation adds another set. `Cmd+N` still creates a bare space.
Remote spaces are supported; programs must be installed on that machine.

The mod runs the local `herdr-app` CLI to create tabs and their split. It
does not fetch URLs or read project files. On failure it leaves any created
tabs open and reports the error.
