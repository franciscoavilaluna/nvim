local opt = vim.opt
local hl = vim.api.nvim_set_hl

if os.getenv("VIM_EINK") == "1" then
    opt.background = "light"
    vim.cmd.colorscheme("quiet")

    hl(0, "Normal", { ctermbg = "White", ctermfg = "Black", bg = "White", fg = "Black" })
    hl(0, "StatusLine", { ctermbg = "Black", ctermfg = "White" })
else
    vim.cmd("syntax on")
    opt.termguicolors = false
    opt.laststatus = 1
    vim.g.base16colorspace = 256


    vim.api.nvim_create_autocmd({"VimEnter", "ColorScheme"}, {
        callback = function()
            -- 1. Fondo y Estructura (Transparentes)
            hl(0, "Normal", { ctermbg = "NONE" })
            hl(0, "NonText", { ctermbg = "NONE", ctermfg = 8 }) -- Caracteres invisibles
            hl(0, "NormalFloat", { ctermbg = "NONE" })
            hl(0, "FloatBorder", { ctermfg = 7, ctermbg = "NONE" })

            -- 2. Sintaxis de Programación (Usando la paleta de Pywal)
            -- ctermfg corresponde a los colores 0-15 de tu terminal
            
            hl(0, "Comment", { ctermfg = 8, italic = true })   -- Gris (Comentarios)
            hl(0, "Constant", { ctermfg = 3 })                -- Amarillo/Naranja (Strings, Números)
            hl(0, "String", { ctermfg = 2 })                  -- Verde (Texto)
            hl(0, "Identifier", { ctermfg = 1 })              -- Rojo (Variables)
            hl(0, "Function", { ctermfg = 4 })                -- Azul (Funciones/Métodos)
            hl(0, "Statement", { ctermfg = 5 })               -- Magenta (if, else, return)
            hl(0, "PreProc", { ctermfg = 6 })                 -- Cian (Includes, Macros)
            hl(0, "Type", { ctermfg = 3 })                    -- Amarillo (int, class, struct)
            hl(0, "Special", { ctermfg = 6 })                 -- Cian (Caracteres especiales)
            hl(0, "Underlined", { underline = true })
            hl(0, "Error", { ctermfg = 1, ctermbg = "NONE", bold = true })
            hl(0, "Todo", { ctermfg = 0, ctermbg = 3, bold = true })

            hl(0, "LineNr", { ctermfg = 8 })                  -- Números de línea (Gris)
            hl(0, "CursorLineNr", { ctermfg = 4, bold = true }) -- Número de línea actual (Azul)
            hl(0, "Visual", { ctermbg = 8, ctermfg = 15 })    -- Selección (Fondo gris, texto blanco)
            hl(0, "Pmenu", { ctermbg = 0, ctermfg = 7 })      -- Menú autocompletado
            hl(0, "Search", { ctermbg = 3, ctermfg = 0 })     -- Búsqueda
        end,
    })

end
