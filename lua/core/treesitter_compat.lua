local M = {}

local language_aliases = {
	ex = "elixir",
	pl = "perl",
	sh = "bash",
	ts = "typescript",
	uxn = "uxntal",
}

local function first_node(match, capture_id)
	local node = match[capture_id]
	if type(node) == "table" then
		node = node[1]
	end
	return node
end

local function language_from_info_string(alias)
	local filetype = vim.filetype.match({ filename = "a." .. alias })
	return filetype or language_aliases[alias] or alias
end

function M.setup()
	local query = require("vim.treesitter.query")
	local opts = { force = true }

	query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
		local node = first_node(match, pred[2])
		if not node then
			return
		end

		local alias = vim.treesitter.get_node_text(node, bufnr):lower()
		metadata["injection.language"] = language_from_info_string(alias)
	end, opts)

	query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
		local capture_id = pred[2]
		local node = first_node(match, capture_id)
		if not node then
			return
		end

		if not metadata[capture_id] then
			metadata[capture_id] = {}
		end

		local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[capture_id] }) or ""
		metadata[capture_id].text = text:lower()
	end, opts)
end

return M
