local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local in_mathzone = function() return vim.fn['vimtex#syntax#in_mathzone']() == 1 end
local in_comment = function() return vim.fn['vimtex#syntax#in_comment']() == 1 end

return {
  s({trig="template", snippetType="autosnippet"}, fmt([[
    \documentclass[a4paper]{{article}}
    \usepackage[utf8]{{inputenc}}
    \usepackage[T1]{{fontenc}}
    \usepackage{{textcomp}}
    \usepackage[english]{{babel}}
    \usepackage{{amsmath, amssymb}}

    % figure support
    % \pdfsuppresswarningpagegroup=1
    \usepackage{{import}}
    \usepackage{{xifthen}}
    \usepackage{{pdfpages}}
    \usepackage{{transparent}}
    \newcommand{{\imfig}}[1]{{%
        \def\svgwidth{{\columnwidth}}
        \import{{./figures/}}{{#1.pdf_tex}}
    }}

    \begin{{document}}
        {}
    \end{{document}}
  ]], { i(0) })),

  s({trig="beg", snippetType="autosnippet"}, fmt([[
    \begin{{{}}}
        {}
    \end{{{}}}
  ]], { i(1), i(0), rep(1) })),

  s({trig="table", snippetType="autosnippet"}, fmt([[
    \begin{{table}}[{}]
        \centering
        \caption{{{}}}
        \label{{tab:{}}}
        \begin{{tabular}}{{{}}}
        {}
        \end{{tabular}}
    \end{{table}}
  ]], { i(1, "htpb"), i(2, "caption"), i(3, "label"), i(4, "c"), i(0) })),

  s({trig="fig", snippetType="autosnippet"}, fmt([[
    \begin{{figure}}[{}]
        \centering
        \includegraphics[width=0.8\textwidth]{{{}}}
        \caption{{{}}}
        \label{{fig:{}}}
    \end{{figure}}
  ]], { i(1, "htpb"), i(2), i(3), i(4) })),

  s({trig="enum", snippetType="autosnippet"}, fmt([[
    \begin{{enumerate}}
        \item {}
    \end{{enumerate}}
  ]], { i(0) })),

  s({trig="item", snippetType="autosnippet"}, fmt([[
    \begin{{itemize}}
        \item {}
    \end{{itemize}}
  ]], { i(0) })),

  s({trig="mk", snippetType="autosnippet"}, fmt("${}${}", { i(1), i(0) })),
  s({trig="dm", snippetType="autosnippet"}, fmt([[
    \[
        {}
    .\] {}
  ]], { i(1), i(0) })),
  s({trig="ali", snippetType="autosnippet"}, fmt([[
    \begin{{align*}}
        {}
    .\end{{align*}}
  ]], { i(1) })),

  s({trig="//", snippetType="autosnippet"}, fmt("\\frac{{{}}}{{{}}}{}", { i(1), i(2), i(0) }), {condition = in_mathzone}),
  
  s({trig = "(%d+)/", regTrig = true, snippetType="autosnippet"}, {
    f(function(_, snip) return "\\frac{" .. snip.captures[1] .. "}{" end), i(1), t("}")
  }, {condition = in_mathzone}),

  s({trig="=>", snippetType="autosnippet"}, { t("\\implies ") }),
  s({trig="=<", snippetType="autosnippet"}, { t("\\impliedby ") }),
  s({trig="iff", snippetType="autosnippet"}, { t("\\iff ") }, {condition = in_mathzone}),
  s({trig="!=", snippetType="autosnippet"}, { t("\\neq ") }, {condition = in_mathzone}),
  s({trig="<=", snippetType="autosnippet"}, { t("\\le ") }),
  s({trig=">=", snippetType="autosnippet"}, { t("\\ge ") }),
  s({trig="EE", snippetType="autosnippet"}, { t("\\exists ") }, {condition = in_mathzone}),
  s({trig="AA", snippetType="autosnippet"}, { t("\\forall ") }, {condition = in_mathzone}),

  s({trig = "([%a])(%d)", regTrig = true, wordTrig = false, snippetType="autosnippet"}, {
    f(function(_, snip) return snip.captures[1] .. "_" .. snip.captures[2] end)
  }, {condition = in_mathzone}),

  s({trig = "([%a])_(%d%d)", regTrig = true, wordTrig = false, snippetType="autosnippet"}, {
    f(function(_, snip) return snip.captures[1] .. "_{" .. snip.captures[2] .. "}" end)
  }, {condition = in_mathzone}),

  s({trig="sr", snippetType="autosnippet"}, { t("^2") }, {condition = in_mathzone}),
  s({trig="cb", snippetType="autosnippet"}, { t("^3") }, {condition = in_mathzone}),
  s({trig="td", snippetType="autosnippet"}, fmt("^{{{}}}{}", { i(1), i(0) }), {condition = in_mathzone}),
  s({trig="__", snippetType="autosnippet"}, fmt("_{{{}}}{}", { i(1), i(0) })),

  s({trig="()", snippetType="autosnippet"}, fmt("\\left( {} \\right) {}", { i(1), i(0) }), {condition = in_mathzone}),
  s({trig="lr|", snippetType="autosnippet"}, fmt("\\left| {} \\right| {}", { i(1), i(0) })),
  s({trig="lr{", snippetType="autosnippet"}, fmt("\\left\\{{ {} \\right\\}} {}", { i(1), i(0) })),
  s({trig="pmat", snippetType="autosnippet"}, fmt("\\begin{{pmatrix}} {} \\end{{pmatrix}} {}", { i(1), i(0) })),
  s({trig="bmat", snippetType="autosnippet"}, fmt("\\begin{{bmatrix}} {} \\end{{bmatrix}} {}", { i(1), i(0) })),

  s({trig="sum", snippetType="autosnippet"}, fmt("\\sum_{{n={}}}^{{{}}} {}", { i(1, "1"), i(2, "\\infty"), i(3, "a_n z^n") })),
  s({trig="lim", snippetType="autosnippet"}, fmt("\\lim_{{{} \to {}}} ", { i(1, "n"), i(2, "\\infty") })),
  s({trig="prod", snippetType="autosnippet"}, fmt("\\prod_{{n={}}}^{{{}}} {}", { i(1, "1"), i(2, "\\infty"), i(0) })),
  s({trig="dint", snippetType="autosnippet"}, fmt("\\int_{{{}}}^{{{}}} {} ", { i(1, "-\\infty"), i(2, "\\infty"), i(0) }), {condition = in_mathzone}),

  s({trig="ooo", snippetType="autosnippet"}, { t("\\infty") }),
  s({trig="RR", snippetType="autosnippet"}, { t("\\mathbb{R}") }),
  s({trig="ZZ", snippetType="autosnippet"}, { t("\\mathbb{Z}") }),
  s({trig="NN", snippetType="autosnippet"}, { t("\\mathbb{N}") }),
  s({trig="QQ", snippetType="autosnippet"}, { t("\\mathbb{Q}") }),
  s({trig="CC", snippetType="autosnippet"}, { t("\\mathbb{C}") }),

  s({trig = "([%a])bar", regTrig = true, snippetType="autosnippet"}, {
    f(function(_, snip) return "\\overline{" .. snip.captures[1] .. "}" end)
  }, {condition = in_mathzone}),

  s({trig = "([%a])hat", regTrig = true, snippetType="autosnippet"}, {
    f(function(_, snip) return "\\hat{" .. snip.captures[1] .. "}" end)
  }, {condition = in_mathzone}),

  s({trig="->", snippetType="autosnippet"}, { t("\\to ") }, {condition = in_mathzone}),
  s({trig="!>", snippetType="autosnippet"}, { t("\\mapsto ") }, {condition = in_mathzone}),
  s({trig="<->", snippetType="autosnippet"}, { t("\\leftrightarrow ") }, {condition = in_mathzone}),

  s({trig="tt", snippetType="autosnippet"}, fmt("\\text{{{}}}{}", { i(1), i(0) }), {condition = in_mathzone}),
  s({trig="case", snippetType="autosnippet"}, fmt("\\begin{{cases}}\n\t{}\n\\end{{cases}}", { i(1) }), {condition = in_mathzone}),
  s({trig="xx", snippetType="autosnippet"}, { t("\\times ") }, {condition = in_mathzone}),
  s({trig="**", snippetType="autosnippet"}, { t("\\cdot ") }),
}
