local M = {}

local DEFAULT_PROJECTS_ROOT = vim.fn.expand("~/Documents/JMxShopify/Projects/active")

M.options = {
  projects_root = DEFAULT_PROJECTS_ROOT,
}

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function is_blank(value)
  return trim(value) == ""
end

local function normalize_title(title)
  local normalized = trim(title):lower()
  normalized = normalized:gsub("^%W+", "")
  normalized = normalized:gsub("%s+", " ")
  return normalized
end

local function strip_agent_annotation(task_text)
  local text_without_annotation, annotation = task_text:match("^(.-)%s+—%s+(.+)$")
  if not text_without_annotation then
    return trim(task_text), nil, nil, nil
  end

  local tab = annotation:match("tabs?:%s*([^;]+)") or annotation:match("tab/teammate:%s*([^,;]+)")
  local status = annotation:match("status:%s*([^;]+)")
  return trim(text_without_annotation), tab and trim(tab) or nil, status and trim(status) or nil, trim(annotation)
end

local function project_and_task_from_path(plan_path)
  local project, task = plan_path:match("/Projects/active/([^/]+)/tasks/active/([^/]+)/plan%.md$")
  return project, task
end

local function read_plan_lines(plan_path)
  local ok, lines = pcall(vim.fn.readfile, plan_path)
  if not ok then
    return {}
  end
  return lines
end

local function directory_name(path)
  return vim.fn.fnamemodify(path, ":h")
end

local function normalized_directory(path)
  if is_blank(path) or path == "none" then
    return nil
  end
  return vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
end

local function metadata_value(line, key)
  return line:match("^%s*%- %*%*" .. key .. "%*%*:%s*(.-)%s*$")
end

local function plan_files()
  local projects_root = M.options.projects_root or DEFAULT_PROJECTS_ROOT
  local glob_pattern = projects_root .. "/*/tasks/active/*/plan.md"
  local files = vim.fn.glob(glob_pattern, false, true)
  table.sort(files)
  return files
end

local function preview_for_item(item, lines)
  local preview_lines = {
    "# " .. item.task_title,
    "",
    "- Project: " .. item.project,
    "- Type: " .. item.task_type,
    "- Cmux workspace: " .. (item.workspace_title or "unknown"),
    "- Plan: " .. item.file .. ":" .. item.line,
  }

  if item.agent_tab then
    preview_lines[#preview_lines + 1] = "- Agent tab: " .. item.agent_tab
  end

  if item.agent_status then
    preview_lines[#preview_lines + 1] = "- Agent status: " .. item.agent_status
  end

  preview_lines[#preview_lines + 1] = ""
  preview_lines[#preview_lines + 1] = "## Active task"
  preview_lines[#preview_lines + 1] = ""
  preview_lines[#preview_lines + 1] = "- [ ] " .. item.task_text
  preview_lines[#preview_lines + 1] = ""
  preview_lines[#preview_lines + 1] = "## Plan context"
  preview_lines[#preview_lines + 1] = ""

  local first_context_line = math.max(item.line - 3, 1)
  local last_context_line = math.min(item.line + 3, #lines)
  for line_number = first_context_line, last_context_line do
    local prefix = line_number == item.line and "> " or "  "
    preview_lines[#preview_lines + 1] = prefix .. lines[line_number]
  end

  return table.concat(preview_lines, "\n")
end

local function parse_plan(plan_path)
  local lines = read_plan_lines(plan_path)
  if vim.tbl_isempty(lines) then
    return {}
  end

  local path_project, path_task = project_and_task_from_path(plan_path)
  local project = path_project or "unknown"
  local task_title = path_task or vim.fn.fnamemodify(vim.fn.fnamemodify(plan_path, ":h"), ":t")
  local workspace_title = nil
  local worktree = nil
  local current_section = nil
  local current_task_type = nil
  local tasks = {}

  for line_number, line in ipairs(lines) do
    project = metadata_value(line, "Project") or project
    task_title = metadata_value(line, "Task title") or task_title
    workspace_title = metadata_value(line, "Cmux workspace") or workspace_title
    worktree = metadata_value(line, "Worktree") or worktree

    local top_level_heading = line:match("^##%s+(.+)%s*$")
    if top_level_heading then
      current_section = trim(top_level_heading):lower()
      current_task_type = current_section == "todos" and "Human" or nil
    end

    local task_type_heading = line:match("^###%s+(.+)%s*$")
    if task_type_heading and current_section == "task list" then
      local normalized_task_type_heading = trim(task_type_heading):lower()
      if normalized_task_type_heading == "human" then
        current_task_type = "Human"
      elseif normalized_task_type_heading == "agent" then
        current_task_type = "Agent"
      else
        current_task_type = nil
      end
    end

    local checkbox, raw_task_text = line:match("^%s*%- %[(.)%]%s*(.*)$")
    local section_has_tasks = current_section == "task list" or current_section == "todos"
    if checkbox == " " and section_has_tasks and current_task_type and not is_blank(raw_task_text) then
      local task_text, agent_tab, agent_status, agent_annotation = strip_agent_annotation(raw_task_text)
      if not is_blank(task_text) then
        local item = {
          file = plan_path,
          line = line_number,
          project = project,
          task_title = task_title,
          task_type = current_task_type,
          workspace_title = workspace_title or task_title,
          task_text = task_text,
          agent_tab = agent_tab,
          agent_status = agent_status,
          agent_annotation = agent_annotation,
          task_directory = directory_name(plan_path),
          project_directory = normalized_directory(plan_path):match("^(.-)/tasks/active/"),
          worktree = worktree,
          text = table.concat({ project, task_title, current_task_type, task_text, agent_tab or "", agent_status or "" }, " "),
        }
        item.preview = {
          text = preview_for_item(item, lines),
          ft = "markdown",
        }
        tasks[#tasks + 1] = item
      end
    end
  end

  return tasks
end

local function active_tasks()
  local tasks = {}
  for _, plan_path in ipairs(plan_files()) do
    vim.list_extend(tasks, parse_plan(plan_path))
  end
  return tasks
end

local function cmux_workspaces()
  if vim.fn.executable("cmux") ~= 1 then
    return {}
  end

  local output = vim.fn.system({ "cmux", "workspace", "list", "--json" })
  if vim.v.shell_error ~= 0 or is_blank(output) then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, output)
  if not ok or type(decoded) ~= "table" or type(decoded.workspaces) ~= "table" then
    return {}
  end

  return decoded.workspaces
end

local function workspace_lookup()
  local lookup = {
    by_title = {},
    by_directory = {},
  }

  for _, workspace in ipairs(cmux_workspaces()) do
    if workspace.title then
      lookup.by_title[workspace.title] = workspace
      lookup.by_title[normalize_title(workspace.title)] = workspace
    end
    if workspace.custom_title then
      lookup.by_title[workspace.custom_title] = workspace
      lookup.by_title[normalize_title(workspace.custom_title)] = workspace
    end
    if workspace.current_directory then
      lookup.by_directory[normalized_directory(workspace.current_directory)] = workspace
    end
  end
  return lookup
end

local function find_workspace_for_task(lookup, task)
  return lookup.by_title[task.workspace_title]
    or lookup.by_title[task.task_title]
    or lookup.by_title[normalize_title(task.workspace_title)]
    or lookup.by_title[normalize_title(task.task_title)]
    or lookup.by_directory[normalized_directory(task.task_directory)]
    or lookup.by_directory[normalized_directory(task.worktree)]
    or lookup.by_directory[normalized_directory(task.project_directory)]
end

local function attach_workspace_refs(tasks)
  local lookup = workspace_lookup()
  for _, task in ipairs(tasks) do
    local workspace = find_workspace_for_task(lookup, task)

    if workspace then
      task.workspace_ref = workspace.ref
      task.workspace_is_active = true
    else
      task.workspace_ref = nil
      task.workspace_is_active = false
    end
  end
  return tasks
end

local function open_plan_at_task(item)
  if not item then
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(item.file))
  vim.api.nvim_win_set_cursor(0, { item.line, 0 })
end

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", M.options, options or {})
end

function M.find_active_tasks()
  return attach_workspace_refs(active_tasks())
end

function M.jump_to_workspace(item)
  if not item then
    return
  end

  local lookup = workspace_lookup()
  local workspace = item.workspace_ref and { ref = item.workspace_ref } or find_workspace_for_task(lookup, item)

  if not workspace or not workspace.ref then
    vim.notify("No active Cmux workspace found for " .. item.workspace_title, vim.log.levels.WARN)
    return
  end

  local output = vim.fn.system({ "cmux", "workspace", "select", workspace.ref })
  if vim.v.shell_error ~= 0 then
    vim.notify("Could not switch Cmux workspace: " .. trim(output), vim.log.levels.ERROR)
  end
end

function M.format(item, _picker)
  local Snacks = _G.Snacks or require("snacks")
  local align = Snacks.picker.util.align
  local type_highlight = item.task_type == "Agent" and "DiagnosticInfo" or "DiagnosticWarn"
  local workspace_highlight = item.workspace_is_active and "DiagnosticOk" or "DiagnosticError"

  return {
    { align(item.project, 20, { truncate = true }), "Directory" },
    { " " },
    { align(item.task_type, 7), type_highlight },
    { " " },
    { align(item.task_title, 34, { truncate = true }), "Title" },
    { " " },
    { item.workspace_is_active and "●" or "○", workspace_highlight },
    { " " },
    { item.task_text },
  }
end

function M.pick()
  local Snacks = _G.Snacks or require("snacks")
  local tasks = M.find_active_tasks()

  if vim.tbl_isempty(tasks) then
    vim.notify("No active scratchpad tasks found", vim.log.levels.INFO)
    return
  end

  Snacks.picker.pick({
    source = "cmux_tasks",
    title = "Scratchpad tasks",
    finder = function()
      return tasks
    end,
    format = M.format,
    preview = "preview",
    layout = { preset = "telescope" },
    matcher = {
      fuzzy = true,
      sort_empty = true,
    },
    confirm = function(picker, item)
      picker:close()
      M.jump_to_workspace(item)
    end,
    actions = {
      open_plan = function(picker, item)
        picker:close()
        open_plan_at_task(item)
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-o>"] = { "open_plan", mode = { "n", "i" } },
        },
      },
      list = {
        keys = {
          ["<c-o>"] = "open_plan",
        },
      },
    },
  })
end

return M
