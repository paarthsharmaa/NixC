return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.lsp.config("rust-analyzer", {})
      vim.lsp.enable("rust_analyzer")
    end,
  },
}
