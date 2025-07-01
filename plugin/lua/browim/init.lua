local M = {}

local function get_engine_path()
  local this_script = debug.getinfo(1).source:sub(2)
  local engine_dir = vim.fs.root(this_script, "engine")
  return vim.fs.joinpath(engine_dir, "engine", "index.ts")
end

local function open_url(url)
  local engine = get_engine_path()
  local tmp_file = vim.fn.tempname() .. ".md"

  vim.system({
    "bun", "run", engine, url, tmp_file
  }):wait()
  vim.cmd ("view " .. tmp_file)
end

local function open_from_cursor()
  local parser = vim.treesitter.get_parser(0, "markdown_inline")
  local tree = parser:parse()[1]

  local query = vim.treesitter.query.parse("markdown_inline",
    [[
      (inline_link
        (link_text)
        (link_destination) @url)
    ]]
  )

  local cursor_row, _ = table.unpack(vim.api.nvim_win_get_cursor(0))

  for _, node, _ in query:iter_captures(tree:root(), 0, 0, -1) do
    local start_row, _, _ = node:range()
    if cursor_row == start_row + 1 then
      local url = vim.treesitter.get_node_text(node, 0)
      open_url(url)
      return
    end
  end

  print("Not on a Markdown link")
end

local function open(opts)
  if #opts.fargs > 0 then
    local url = opts.fargs[1]
    open_url(url)
  else
    open_from_cursor()
  end
end

function M.setup(opts)
  vim.api.nvim_create_user_command("Browim", open, {
    desc = "Open a link with Browim",
    nargs= "?",
  })
  vim.keymap.set('n', '<CR>', open_from_cursor, { desc = "Open the link under the cursor" })
end

return M
