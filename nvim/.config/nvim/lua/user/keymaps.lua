local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.keymap.set

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
keymap("", "-", "<Nop>", opts)
vim.g.mapleader = "-"
vim.g.maplocalleader = "-"

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal mode mappings --
keymap("n", ",", '"s', opts)
keymap("v", ",", '"s', opts)
keymap("n", ";", ":", { noremap = true, silent = false })
keymap("n", "<F2>", "<cmd>w<CR>", opts)
keymap("n", "<F4>", "<cmd>q<CR><cmd>q<CR>", opts)
keymap("n", "<leader>ee", "<cmd>NvimTreeToggle<CR><C-w>l", opts) -- toggle NvimTree
keymap("n", "<leader>ea", "<cmd>NvimTreeFocus<CR><C-w>|", opts) -- Maximize NvimTree
keymap("n", "<leader>es", "<cmd>NvimTreeFocus<CR>200<C-w>< 29<C-w>>", opts) -- Resize NvimTree to normal
keymap("n", "<leader>cc", "<cmd>silent! cclose<CR><cmd>lclose<CR>", opts) -- close quick fix window
keymap("n", "<leader>r", "<cmd>silent! edit<CR>", opts) -- close quick fix window

keymap("n", "<C-j>", "2j", opts)
keymap("n", "<C-k>", "2k", opts)

-- Map buffer navigation
keymap("n", "<leader>n", ":enew<CR>", opts)
keymap("n", "<leader>u", ":b#<CR>", opts)
keymap("n", "<leader>j", ":bprev<CR>", opts)
keymap("n", "<leader>k", ":bnext<CR>", opts)

-- Telescope
-- keymap("n", "<C-p>", ":Telescope find_files<CR>", opts)
keymap("n", "<C-p>", function() require('fzf-lua').files({}) end, opts)
keymap("n", "<leader>0", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>f", ":Telescope live_grep<CR>", opts)

-- Close buffer
-- Define the custom function to close buffer and switch
function CLOSE_AND_SWITCH_BUFFER()
  -- Get the current buffer number
  local current_buf = vim.api.nvim_get_current_buf()

  -- Get the list of buffers before deletion
  local buffers_before = vim.fn.getbufinfo({ buflisted = 1 })
  local previous_buf = vim.fn.bufnr('#')

  -- Attempt to delete the buffer
  vim.cmd("bdelete")

  -- Get the list of buffers after deletion
  local buffers_after = vim.fn.getbufinfo({ buflisted = 1 })

  -- Check if the buffer was successfully deleted
  local buffer_deleted = true
  for _, buf in ipairs(buffers_after) do
    if buf.bufnr == current_buf then
      buffer_deleted = false
      break
    end
  end

  if buffer_deleted then
    -- Switch to the next buffer if the buffer was closed
    vim.cmd("buffer " .. previous_buf)
  else
    -- Notify the user that the buffer was not closed
    print("Buffer close command was canceled.")
  end
end

-- Map <leader>q to the custom function
keymap("n", "<leader>q", ":lua CLOSE_AND_SWITCH_BUFFER()<CR>", opts)

-- Move text up and down
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)


-- Insert mode mappings --
keymap("i", "<F2>", "<ESC><cmd>w<CR>a", opts)
keymap("i", "<F4>", "<cmd>q<CR><cmd>q<CR>", opts)
-- Press jk fast to exit insert mode
-- keymap("i", "jk", "<ESC>", opts)


-- Visual mode mappings --

-- Move text up and down
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
keymap("v", "<C-r>", '"hy:%s/<C-r>h//gc<left><left><left>', { noremap = true, silent = false })

keymap("v", "<leader>a", "<cmd>EasyAlign<CR>", opts) -- toggle NvimTree

keymap("v", "<C-j>", "2j", opts)
keymap("v", "<C-k>", "2k", opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":m '>+1<CR>gv=gv", opts)
keymap("x", "K", ":m '<-2<CR>gv=gv", opts)
keymap("x", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("x", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Terminal --
-- Better terminal navigation
-- keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
-- keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
-- keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
-- keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

