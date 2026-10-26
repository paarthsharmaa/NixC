return {
{
  "akinsho/bufferline.nvim",
  event = "VeryLazy",

  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },

  keys = {
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
    { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
    { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
    { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
    { "<leader>bj", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
  },
  opts = {
    options = {
      -- stylua: ignore
      close_command = function(n) Snacks.bufdelete(n) end,
      -- stylua: ignore
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,

      -- LazyVim isn't installed, so don't reach into LazyVim.config.icons;
      -- define the glyphs locally instead.
      diagnostics_indicator = function(_, _, diag)
        local icons = {
          Error = "",
          Warn = "",
        }

        local ret = (diag.error and icons.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.Warn .. diag.warning or "")

        return vim.trim(ret)
      end,

      offsets = {
        {
          -- Snacks picker sidebars use a layout container split.
          filetype = "snacks_layout_box",
          text = "Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
}
}
