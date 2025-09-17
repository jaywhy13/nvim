-- Function to check if ~/wave is a parent directory of the current path
local function is_wave_in_path()
  local handle = io.popen "pwd"
  local current_path = handle:read "*a"
  handle:close()

  -- Get the home directory path
  local home_wave_path = os.getenv "HOME" .. "/wave"

  -- Check if ~/wave is a substring of the current path
  return string.find(current_path, home_wave_path) ~= nil
end

-- Determine the provider based on the presence of ~/wave in the current path
local provider
if is_wave_in_path() then
  provider = "copilot"
else
  provider = "claude"
end

require("avante").setup {
  provider = provider,
  auto_suggestions_provider = provider,
  -- copilot = {
  --   model = "claude-3.7-sonnet",
  -- },
  -- -- behaviour = {
  --   auto_apply_diff_after_generation = false,
  --   enable_cursor_planning_mode = true,
  -- },
  -- diff = {
  --   autojump = false,
  -- },
  -- Make some changes to enable MCPHub: https://ravitemer.github.io/mcphub.nvim/extensions/avante.html#add-tools-to-avante
  -- system_prompt as function ensures LLM always has latest MCP server state
  -- This is evaluated for every message, even in existing chats
  system_prompt = function()
    local hub = require("mcphub").get_hub_instance()
    return hub and hub:get_active_servers_prompt() or ""
  end,
  -- Using function prevents requiring mcphub before it's loaded
  custom_tools = function()
    return {
      require("mcphub.extensions.avante").mcp_tool(),
    }
  end,
  windows = {
    width = 50,
  },
}
