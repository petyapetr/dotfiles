-- Install as plug/mlsp/z-local.lua so this runs after upstream main.lua.
local ts = {
    cmd = "tsc",
    args = {"--lsp", "--stdio"},
    filetypes = {"typescript", "javascript"},
}

for _, filetype in ipairs(ts.filetypes) do
    settings.defaultLanguageServer[filetype] = ts
end

-- Start the default server when a matching buffer opens, including fzf tabs.
for filetype, server in pairs(settings.defaultLanguageServer) do
    settings.autostart[filetype] = settings.autostart[filetype] or {server}
end

settings.tabAutocomplete = true
settings.showDiagnostics.error = true
settings.showDiagnostics.warning = true
