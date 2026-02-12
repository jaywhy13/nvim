-- Option 2: nvim lsp as LSP client
-- Tell the server the capability of foldingRange,
-- Neovim hasn't added foldingRange to default capabilities, users must add it manually
-- I added this configuration directly in lspconfig.lua since
-- there is already a capabilities variable being set up for lsp servers
-- I didn't want to risk replacing that setup
-- UFO seems to work fine regardless
require("ufo").setup()
