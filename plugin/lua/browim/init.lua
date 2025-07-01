local browim = {}

local function open_url(url)
  local tmp_file = vim.fn.tempname() .. ".md"
  vim.cmd([[silent !bun run ../engine/index.ts ]] .. url .. " " .. tmp_file)
  vim.cmd("view " .. tmp_file)
end

local function open(opts)
  local url = opts.fargs[1]
  open_url(url)
end

function browim.setup(opts)
  print("browim setup!")
  vim.api.nvim_create_user_command("Browim", open, {
    desc = "Open a link with Browim"
  })
end

return browim
