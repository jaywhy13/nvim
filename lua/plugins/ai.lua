return {
  -- Render markdown nicely inside Neovim buffers, including CodeCompanion chat
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "codecompanion" },
    opts = {},
  },

  -- Clean inline diff view used by CodeCompanion's inline assistant and
  -- the @insert_edit_into_file tool. Disabled by default; CodeCompanion
  -- activates it when needed.
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require "mini.diff"
      diff.setup { source = diff.gen_source.none() }
    end,
  },

  -- Paste images from the system clipboard into a CodeCompanion chat buffer
  -- via :PasteImage
  {
    "HakonHarnes/img-clip.nvim",
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },

  {
    "olimorris/codecompanion.nvim",
    opts = {},
    event = "BufEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "<leader>aic", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Code Companion Chat Toggle" },
      { "<leader>aii", "<cmd>CodeCompanion<cr>",            mode = { "v" },       desc = "Code Companion Inline" },
      { "<leader>ain", "<cmd>CodeCompanionChat<cr>",        mode = { "n", "v" }, desc = "Code Companion Chat" },
      { "<leader>aia", "<cmd>CodeCompanionActions<cr>",     mode = "n",           desc = "Code Companion Actions" },
    },
    config = function()
    require("codecompanion").setup {
      prompt_library = {
        ["Generate a commit message"] = {
          strategy = "chat",
          description = "Generate a concise and descriptive git commit message based on the provided diff.",
          prompts = {
            {
              role = "system",
              content = "You are an expert communicator skilled at crafting clear and concise git commit messages based on code diffs. Your commit messages should accurately summarize the changes made in the code, following best practices for commit message formatting.",
            },
          },
          opts = {
            index = 9,
            is_default = true,
            is_slash_cmd = true,
            short_name = "generate_commit_message",
            auto_submit = false,
          },
        },
        ["Explain Concept"] = {
          strategy = "chat",
          description = "Explain something to me",
          prompts = {
            {
              role = "system",
              content = "You are a knowledgeable tutor. Explain the given concept in simple terms that a beginner can understand, using analogies and examples where appropriate. Start with a brief overview, then break things down step-by-step. Speak in concise, clear language, avoiding jargon. Encourage questions and provide additional resources for further learning.",
            },
          },
          opts = {
            index = 10,
            is_default = true,
            is_slash_cmd = true,
            short_name = "explain_concept",
            auto_submit = false,
          },
        },
        ["Code Feedback"] = {
          strategy = "chat",
          description = "Provide feedback on code quality and suggest improvements.",
          prompts = {
            {
              role = "system",
              content = function(context)
                return "You are an expert code review and seasoned Senior software engineer. Analyze the provided code for readability, maintainability, performance, and adherence to best practices. Provide constructive feedback and suggest specific improvements to enhance code quality. Focus on clarity, efficiency, and overall design. You are an expert in the semnatics of the "
                  .. context.filetype
                  .. " programming language."
              end,
            },
          },
          opts = {
            index = 10,
            is_default = true,
            is_slash_cmd = true,
            short_name = "code_feedback",
            auto_submit = true,
          },
        },
        ["Research & Reconnaissance"] = {
          strategy = "chat",
          description = "Analyze the codebase for a specific task using a read-only strategy.",
          prompts = {
            {
              role = "system",
              content = [[You are a Technical Strategist and Researcher. 

### YOUR OBJECTIVE
Review the user's task below and perform a thorough investigation of the repository to familiarize yourself with the relevant logic, patterns, and dependencies. Use your tools liberally to "look before you leap."

### CONSTRAINTS
- **Read-Only**: You are a researcher. You may suggest code changes in the chat, but you must NEVER attempt to edit files or execute system commands.
- **Communication**: Use extreme clarity and simplicity. If the architecture is complex, use an analogy to simplify it.
- **Tools**: Use 'file_search', 'read_file', and 'grep_search' to map the project. Use 'get_diagnostics' to identify potential friction points related to the task.

### RESPONSE STRUCTURE
1. **Overview**: A concise summary of your findings. Explain the "lay of the land" as it relates to the task.
2. **High-Level Checklist**: A bulleted list of the logical milestones that must be completed.
3. **Stop**: You must end your response immediately after the checklist. Do not offer to implement the code or ask follow-up questions.]],
            },
            {
              role = "user",
              content = "Review the following task and familiarize yourself with the codebase to prepare a plan:\n\n",
            },
          },
          opts = {
            index = 10,
            is_default = true,
            is_slash_cmd = true,
            short_name = "repository_research",
            auto_submit = false, -- Allows you to paste your task details before sending
            user_prompt = false,
          },
          -- Ensuring the agent only uses the requested read-only tools
          tools = {
            "ask_questions",
            "fetch_webpage",
            "file_search",
            "get_changed_files",
            "get_diagnostics",
            "grep_search",
            "memory",
            "read_file",
            "web_search",
          },
        },
      },
      interactions = {
        chat = {
          adapter = {
            name = "anthropic",
            model = "claude-sonnet-4.6",
          },
          auto_scroll = false,
          keymaps = {
            send = {
              modes = { n = "<C-s>", i = "<C-s>" },
              opts = {},
            },
            close = {
              modes = { n = "<S-x>", i = "<C-S-x>" },
              opts = {},
            },
            clear = false,
            -- Add further custom keymaps here
          },
          tools = {
            opts = {
              default_tools = {
                "file_search",
                "read_file",
              },
            },
            groups = {
              ["edit_file"] = {
                description = "Tools for editing files",
                system_prompt = "I'm giving you access to tools to help you perform coding tasks in #buffer",
                tools = {
                  "create_file",
                  "file_search",
                  "get_changed_files",
                  "grep_search",
                  "insert_edit_into_file",
                  "list_code_usages",
                  "read_file",
                },
              },
              ["strategist"] = {

                description = "Read-only researcher and architect for high-level planning.",

                system_prompt = function(group, ctx)
                  return string.format [[You are an elite Technical Strategist.
### YOUR ROLE

You are a "Thinker," not a "Doer." Your goal is deep research, analysis, and architectural planning. You are strictly READ-ONLY regarding the filesystem. You may suggest code blocks or logic changes within the chat to illustrate your points, but you must NEVER attempt to use tools to modify files or execute commands.

### COMMUNICATION STYLE

- **Clarity & Simplicity**: Explain complex ideas as if the user is a busy stakeholder who values precision.
- **Analogies**: Use relatable analogies to ground abstract technical concepts.
- **Tone**: Insightful, authoritative, and direct.

### RESPONSE STRUCTURE

1. **Short Overview**: A concise summary of your research or the answer to the user's inquiry. Use analogies here if they help simplify the "why" or "how."

2. **Implementation Strategy**: (Optional) If the user needs to see code, provide clear, concise snippets or pseudo-code to illustrate the plan.

3. **High-Level Checklist**: A bulleted list of logical milestones or requirements that must be met.

4. **Stop**: You must end your response immediately after the checklist. Do not offer to perform the work.

### TOOL USAGE

Use your tools liberally to gather context. Research the web for documentation, grep the codebase for patterns, and read files to understand current implementations. Use 'ask_questions' if the objective is ambiguous.]]
                end,
                tools = {
                  "ask_questions",
                  "fetch_webpage",
                  "file_search",
                  "get_changed_files",
                  "get_diagnostics",
                  "grep_search",
                  "read_file",
                  "web_search",
                },

                opts = {
                  collapse_tools = true,
                  ignore_system_prompt = true,
                  ignore_tool_system_prompt = true,
                },
              },
            },
            -- Auto-approve if the file is not hidden (does not start with a dot)
            ["read_file"] = {
              opts = {
                require_approval_before = function(params)
                  -- params.file should contain the file path
                  local filename = vim.fn.fnamemodify(params.file, ":t")
                  return vim.startswith(filename, ".")
                end,
              },
            },
            ["file_search"] = {
              opts = {
                require_approval_before = function(params)
                  local filename = vim.fn.fnamemodify(params.file, ":t")
                  return vim.startswith(filename, ".")
                end,
              },
            },
            ["grep_search"] = {
              opts = {
                require_approval_before = function(params)
                  local filename = vim.fn.fnamemodify(params.file, ":t")
                  return vim.startswith(filename, ".")
                end,
              },
            },
          },
        },
      },
      adapters = {
        acp = {
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              defaults = {
                auth_method = "oauth-personal", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
              },
            })
          end,
        },
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            -- MCP Tools
            make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
            show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
            add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
            show_result_in_chat = true, -- Show tool results directly in chat buffer
            format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
            -- MCP Resources
            -- Setting this to False temporarily until this issue is resolved:
            -- https://github.com/ravitemer/mcphub.nvim/issues/275
            make_vars = false, -- Convert MCP resources to #variables for prompts
            -- MCP Prompts
            make_slash_commands = true, -- Add MCP prompts as /slash commands
          },
        },
      },
    }
  end,
  },
}
