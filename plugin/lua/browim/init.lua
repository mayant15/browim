local browim = {}

local function open_url(url)
  local tmp_file = vim.fn.tempname() .. ".md"
  vim.cmd([[silent !bun run ../engine/index.ts ]] .. url .. " " .. tmp_file)
  vim.cmd("view " .. tmp_file)
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

function browim.setup(opts)
  print("browim setup!")
  vim.api.nvim_create_user_command("Browim", open, {
    desc = "Open a link with Browim"
  })
end

return browim
