local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
--local rep = require("luasnip.extras").rep
local fmta = require("luasnip.extras.fmt").fmta

return {
	s({trig = "hw"}, { t("Hello, World !!!") }),
	s(
		{ trig = "article" },
		fmta(
			[[
	  \documentclass[12pt]{article}

	  \title{<>}
	  \author{<>}
	  \date{}

	  \begin{document}
	  \maketitle

		 <>

	  \end{document}
	  ]], { i(1), i(2), i(3) }
		)
	),
}
