# Fieldbook

A floating field notebook for Omarchy: draw with a mouse or tablet, type notes, keep
chapters with ordered pages, and export a page as an image. Fieldbook is a downstream
fork of [OldJobobo's Field Notes](https://github.com/OldJobobo/field-notes), keeping its
paper, pen, text, undo, autosave, export, and layer-shell behavior while adding notebook
organization.

Fieldbook is independently maintained and is not an official Field Notes release.

## Requirements

- Omarchy with the Quattro shell plugin system (`omarchy plugin`)
- `wl-clipboard` (`wl-copy` and `wl-paste`) for exporting and pasting images
- `gio` or `xdg-open` to open the export folder from Fieldbook

The plugin runs inside the Omarchy shell with your user permissions. It stores notebook
state locally and does not use a network service.

## Install

```sh
omarchy plugin add https://github.com/5d0tal1gat0r/omarchy-fieldbook.git
omarchy plugin enable io.github.5d0tal1gat0r.fieldbook
```

## Remove

```sh
omarchy plugin remove io.github.5d0tal1gat0r.fieldbook
```

Removing the plugin does not delete your notebook or pasted images. Delete them separately
only if you no longer need them:

```text
~/.local/state/fieldbook/
~/.config/omarchy/fieldbook-assets/
~/Pictures/fieldbook/
```

To bind it in `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + SHIFT + N", "Fieldbook", { panel = "io.github.5d0tal1gat0r.fieldbook" })
```

## Notebook workflow

Open the bar icon or your keybinding. The paper opens in the foreground; close it with
`Esc` or the close button and it returns to the desktop without losing the page.

- **Chapters** are the project-level groups in the rail beside the paper.
- The chapter rail is hidden by default so it does not float beside every page.
- Press `C` or use **Show chapters** in the toolbar to toggle it.
- Click **+** beside `CHAPTERS` to create a chapter.
- Click **+** beside a chapter to create a page inside that chapter.
- Click a chapter or page to switch to it.
- Double-click a chapter title to rename it.
- Each page keeps its own paper style, size, title, drawing, text, and undo history.

## Paper tools

| Tool | Action | Key |
| --- | --- | --- |
| Select | Select, move, or delete a stroke or typed note | `V` |
| Pen | Draw with the mouse or pressure-capable tablet | `P` or `B` |
| Erase | Erase part of a stroke or remove a note | `E` |
| Text | Click the page and type | `T` |
| Sticky note | Add an editable colored note to the page | toolbar |
| Paste image | Add an image from the Wayland clipboard | toolbar |
| Pin to desktop | Hide the editor chrome and place the page behind normal windows | `D` |
| Undo / Redo | Move through page history | `Ctrl+Z` / `Ctrl+Y` |
| New page | Add a page to the current chapter | `N` |
| Copy | Export the current page as a PNG | `Ctrl+C` |
| Settings | Open settings | `Ctrl+,` |
| Close | Put the notebook away | `Esc` |

The paper header lets you rename a page, cycle graph/dots/ruled/plain paper, and cycle
small/medium/large sizes. `F2`, `G`, and `S` trigger those actions from the keyboard.
The footer reads `FIELD BOOK v0.2.0` and shows the save status.

`PgUp` and `PgDn` switch pages, `Home` centers the board, and the arrow keys move it
(`Shift` makes larger steps). `Ctrl+Shift+Z` redoes an action.
`[` and `]` cycle pen width.
`C` toggles the chapter rail.
With Select active, `Delete` or `Backspace` removes the selected object.
Press `D` or use **Pin to desktop** to leave the page on the desktop. Click the bar icon
again to bring it back into the editor.
When pinned, the small `‹ 1/3 ›` pager at the bottom-right of the page switches between
pages without showing the editor tools.

## Sharing

`Ctrl+C` exports the current page to `~/Pictures/fieldbook/` and copies its path. In
Settings, choose image mode to copy the PNG itself; `Ctrl+Shift+C` copies the other mode.
The export is a fresh file each time, so previous captures remain valid.

## Scripting

The panel is exposed through Quattro shell IPC:

```sh
omarchy-shell io.github.5d0tal1gat0r.fieldbook open
omarchy-shell io.github.5d0tal1gat0r.fieldbook newSheet
omarchy-shell io.github.5d0tal1gat0r.fieldbook setPaper dots
omarchy-shell io.github.5d0tal1gat0r.fieldbook draw '60 80  200 80  200 160' 900
omarchy-shell io.github.5d0tal1gat0r.fieldbook copy path
```

The existing Field Notes methods remain available: `status`, `open`, `close`, `toggle`,
`pin`, `unpin`, `togglePin`, `toggleChapters`, `openOn`, `newSheet`, `selectSheet`, `nextPage`, `previousPage`, `setTitle`, `setPaper`, `setSize`, `setTool`,
`setPenWidth`, `draw`, `stopDrawing`, `addNote`, `undo`, `redo`, `clear`, `center`, and
`copy`.

While pinned, navigate without reopening the editor with:

```sh
omarchy-shell io.github.5d0tal1gat0r.fieldbook previousPage
omarchy-shell io.github.5d0tal1gat0r.fieldbook nextPage
```

These commands can also be assigned to global desktop keybindings.

## Saved data

Fieldbook stores its local notebook at:

```text
~/.local/state/fieldbook/notes.json
```

The file contains version 3 notebook metadata: pages, chapter membership, titles, layout,
settings, and the drawing/text objects. Saving is automatic and uses the same safety checks
and corrupt/trimmed backups as the upstream Field Notes implementation.

## Development

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for the local development workflow. The
fork keeps the original Field Notes implementation and tests in place so changes to the
organization layer can be verified independently.

## Attribution and license

Fieldbook is MIT licensed; see [LICENSE](LICENSE). It is based on OldJobobo's Field Notes,
also MIT licensed. The upstream source and attribution are preserved in this repository;
see [UPSTREAM.md](UPSTREAM.md) for the base version and the main differences.
