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
        auto_submit = true,
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
  },
  strategies = {
    chat = {
      auto_scroll = false,
      keymaps = {
        send = {
          modes = { n = "<C-s>", i = "<C-s>" },
          opts = {},
        },
        close = {
          modes = { n = "<Esc>", i = "<Esc>" },
          opts = {},
        },
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
        make_vars = true, -- Convert MCP resources to #variables for prompts
        -- MCP Prompts
        make_slash_commands = true, -- Add MCP prompts as /slash commands
      },
    },
  },
}
