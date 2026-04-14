# Neovim web config

Минималистичная конфигурация для Neovim 0.12+ под TypeScript, JavaScript, React, Node.js, HTML, CSS, JSON, Markdown, YAML, Docker и Prisma.

## Что внутри

- Встроенный пакетный менеджер Neovim 0.12: `vim.pack`.
- Встроенный LSP-клиент через `vim.lsp.config()` и `vim.lsp.enable()`.
- Встроенное LSP-дополнение через `vim.lsp.completion`.
- `nvim-lspconfig` для готовых LSP-конфигов.
- `nvim-treesitter` для подсветки синтаксиса и отступов.
- `conform.nvim` для форматирования при сохранении и ручного форматирования.
- `gitsigns.nvim` для Git-индикаторов в колонке знаков.
- `nvim-autopairs` для автозакрывания скобок и кавычек.
- `telescope.nvim` для поиска файлов, текста, буферов, help-тегов и LSP-символов.
- Встроенный файловый браузер `netrw` через `:Explore`.
- Системный clipboard через `clipboard=unnamedplus`.

## Первый запуск

Открой Neovim обычным способом:

```sh
nvim
```

При первом запуске `vim.pack.add()` установит плагины, перечисленные в `init.lua`.

Для Treesitter используется актуальный API `nvim-treesitter`, совместимый с Neovim 0.12. Недостающие парсеры устанавливаются асинхронно при старте.

## Внешние утилиты

Конфиг не устанавливает language server'ы и форматтеры сам. Он включает LSP-сервер только если его исполняемый файл есть в `$PATH`.

Рекомендуемый набор npm-утилит для веб-разработки:

```sh
npm i -g typescript typescript-language-server vscode-langservers-extracted prettier @tailwindcss/language-server @olrtg/emmet-language-server dockerfile-language-server-nodejs @microsoft/compose-language-service @prisma/language-server
```

Опционально для редактирования Lua-конфига:

```sh
# Установи через системный пакетный менеджер, Homebrew, Mason или другой удобный способ.
lua-language-server
stylua
```

Требования для Treesitter:

```sh
tree-sitter --version
cc --version
curl --version
tar --version
```

Рекомендуемые утилиты для Telescope:

```sh
rg --version
fd --version
```

`ripgrep` нужен для поиска по тексту. `fd` ускоряет и улучшает поиск файлов, но Telescope может работать и без него.

Clipboard provider:

- Linux Wayland: `wl-copy` и `wl-paste` из пакета `wl-clipboard`;
- Linux X11: `xclip` или `xsel`;
- WSL/Windows: `win32yank.exe`;
- macOS: `pbcopy` и `pbpaste`, обычно уже есть в системе.

## Горячие клавиши

Общие:

| Клавиши     | Действие                  |
| ----------- | ------------------------- |
| `<leader>w` | Сохранить файл            |
| `<leader>q` | Закрыть окно              |
| `<leader>h` | Очистить подсветку поиска |
| `<leader>e` | Открыть файловый браузер  |

`<leader>` в этом конфиге это пробел.

Telescope:

| Клавиши      | Действие                  |
| ------------ | ------------------------- |
| `<leader>ff` | Найти файл                |
| `<leader>fg` | Найти текст в проекте     |
| `<leader>fb` | Найти открытый буфер      |
| `<leader>fh` | Найти help-тег            |
| `<leader>fr` | Недавние файлы            |
| `<leader>fs` | Символы текущего документа |

Clipboard включен через `unnamedplus`, поэтому обычные команды Neovim работают с системным буфером:

| Клавиши           | Действие                                         |
| ----------------- | ------------------------------------------------ |
| `y` в visual mode | Скопировать выделение в системный clipboard      |
| `yy`              | Скопировать текущую строку в системный clipboard |
| `p`               | Вставить из системного clipboard                 |
| `P`               | Вставить из системного clipboard перед курсором  |

LSP-клавиши доступны после подключения language server'а к текущему буферу:

| Клавиши                   | Действие                           |
| ------------------------- | ---------------------------------- |
| `gd`                      | Перейти к определению              |
| `gr`                      | Найти references                   |
| `K`                       | Показать документацию под курсором |
| `<leader>rn`              | Переименовать символ               |
| `<leader>ca`              | Code action                        |
| `<leader>d`               | Диагностика текущей строки         |
| `[d`                      | Предыдущая диагностика             |
| `]d`                      | Следующая диагностика              |
| `<c-space>` в insert mode | Запустить LSP completion вручную   |

LSP completion всплывает автоматически при вводе после подключения language server'а. Для выбора пункта во встроенном меню completion используется стандартное управление Neovim. Главное: `<c-y>` принимает выбранный вариант.

## Автозакрывание

`nvim-autopairs` автоматически закрывает скобки и кавычки в insert mode:

- `(` -> `()`
- `[` -> `[]`
- `{` -> `{}`
- `'`, `"`, `` ` `` закрываются парой

При нажатии Enter внутри парных скобок плагин корректно переносит курсор на новую строку с учетом отступов.

## Форматирование

Отформатировать текущий буфер:

```vim
:Format
```

Отформатировать асинхронно:

```vim
:Format!
```

Форматирование при сохранении включено. Для веб-файлов используется Prettier, если он установлен:

- JavaScript
- TypeScript
- React JSX/TSX
- JSON/JSONC
- CSS/SCSS
- HTML
- Markdown
- YAML
- Docker Compose YAML

Для Lua используется `stylua`, если он установлен. Если `conform.nvim` недоступен, команда `:Format` откатится на `vim.lsp.buf.format()`.

## LSP

Сервер включается, если соответствующий executable есть в `$PATH`:

| LSP config              | Executable                      |
| ----------------------- | ------------------------------- |
| `ts_ls`                 | `typescript-language-server`    |
| `eslint`                | `vscode-eslint-language-server` |
| `html`                  | `vscode-html-language-server`   |
| `cssls`                 | `vscode-css-language-server`    |
| `jsonls`                | `vscode-json-language-server`   |
| `tailwindcss`           | `tailwindcss-language-server`   |
| `emmet_language_server` | `emmet-language-server`         |
| `lua_ls`                | `lua-language-server`           |
| `dockerls`              | `docker-langserver`             |
| `docker_compose_language_service` | `docker-compose-langserver` |
| `prismals`              | `prisma-language-server`        |

Полезные проверки:

```vim
:LspInfo
:checkhealth vim.lsp
```

Если LSP не подключается, проверь:

- executable установлен и доступен в `$PATH`;
- filetype определился, например через `:set filetype?`;
- в проекте есть root marker для нужного LSP, обычно `package.json`, `tsconfig.json`, `jsconfig.json`, Tailwind config, `Dockerfile`, `compose.yaml`, `docker-compose.yml` или `.git`.

Для Docker Compose конфиг явно выставляет filetype `yaml.docker-compose` для:

- `compose.yaml`
- `compose.yml`
- `docker-compose.yaml`
- `docker-compose.yml`
- `compose.override.yaml`
- `compose.override.yml`
- `docker-compose.*.yaml`
- `docker-compose.*.yml`

## Плагины

Lockfile для плагинов:

```text
nvim-pack-lock.json
```

Обновить плагины:

```vim
:lua vim.pack.update()
```

Показать установленные плагины:

```vim
:lua vim.print(vim.pack.get())
```

## Treesitter

Настроенные парсеры:

- `bash`
- `css`
- `dockerfile`
- `html`
- `javascript`
- `json`
- `lua`
- `markdown`
- `markdown_inline`
- `prisma`
- `tsx`
- `typescript`
- `vim`
- `vimdoc`
- `yaml`

Filetype `jsonc` использует Treesitter-парсер `json`.

Полезные команды:

```vim
:TSInstall javascript typescript tsx
:TSUpdate
```

## Файловый браузер

Конфиг использует встроенный `netrw`.

Открыть его можно командой:

```vim
:Explore
```

или горячей клавишей:

```text
<leader>e
```
