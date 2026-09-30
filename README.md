A lightweight, fast file manager plugin for Omarchy running in the shell.

![Omafile](preview.png)

## Features

* Real resizable window with tabs for multiple locations
* Dual pane layout with one-key copy and move between panes
* List, compact and grid views, with zoom from Ctrl+Scroll or the View menu
* Sort from the View menu in any view: A to Z, Z to A, last modified, size or type
* Quick preview with Space: images full size, text files such as `.yml` as plain text
* Mouse back and forward buttons move through folder history
* Can stand in for the GTK file chooser, so browser uploads and downloads open Omafile
* Live directory watching: external changes appear immediately
* Background copy and move with persistent progress tracking
* Freedesktop trash integration, compatible with GNOME Files, with Empty trash and Restore in the trash view
* Drag and drop: files to other apps such as Telegram, Discord or a browser upload, between folders and panes, onto the sidebar, and in from other apps
* Copy and cut to the system clipboard: paste files into Telegram, Discord, GNOME Files or a terminal, and paste files or images copied in other apps
* Recursive file search across directories
* Image previews in list, compact and grid view, plus thumbnails for videos, PDFs, office files and anything else your system has a thumbnailer for
* Recent files, and bookmarks for the folders you use most
* Connect to SMB, SFTP, WebDAV and other servers
* Settings inside the window, no config file editing
* Bar widget with places, drives, transfers, and trash overview
* Optional standalone trash can in the bar, placeable anywhere, with a live count
* Full keyboard control, following GNOME Files conventions
* Undo and redo for trash, rename, move, copy and new items

## Requirements

* Omarchy 4 (Quattro)
* Python 3 (included with Omarchy)
* util-linux `lsblk` and `findmnt` (included with Arch)
* Optional: `udisksctl` for ejecting removable drives
* Optional: `gvfs` and `gvfs-smb` for connecting to network servers
* Optional: PyGObject for Show in folder from other applications

## Install

```bash
omarchy plugin add https://github.com/chr0nzz/omarchy-omafile.git --enable --yes
```

Plugins run unsandboxed inside the shell process and have full access to your home directory.

## Keybinding and Window Rule

Add to `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + E", "Omafile", "omarchy-shell shell toggle xyzlab.omafile '{}'")
```

Add to `~/.config/hypr/windows.lua`:

```lua
o.window({ class = "^org.quickshell$", title = "^Omafile$" }, { float = true, size = { 1100, 720 }, center = true })
```

Omarchy makes every window slightly transparent, so your wallpaper shows faintly through Omafile the same way it does through every other app. If you would rather Omafile were solid, opt it out of that rule:

```lua
o.window({ class = "^org.quickshell$", title = "^Omafile$" }, { tag = "-default-opacity", opacity = "1 1" })
```

## Usage

Super+E toggles the window. If it is already open it comes to the front. Escape closes it.

Moving around is covered in [Keyboard](#keyboard); F1 shows the same list inside the window.

### Finding things

Click any part of the address bar to type a path, or press Ctrl+L. Click a breadcrumb to jump to that folder.

The magnifier at the end of the address bar filters the folder you are in. Ctrl+F searches that folder and everything inside it instead. Escape clears the text, then leaves the results.

### Sorting

The Sort by section of the View menu sorts by A to Z, Z to A, last modified, first modified, largest, smallest or type, in every view. In list view you can also click Name, Size, Type or Modified. Click the same column again to reverse its order.

### Views

The View button in the toolbar opens one menu for the layout, zoom, sorting and hidden files. It switches between list, compact and grid. Compact packs names into columns. Ctrl+1 to Ctrl+3 pick them from the keyboard.

Grid view can show captions under each name, like GNOME Files: pick up to three from Size (item count for folders), Type, Modified and Permissions under Settings, View, or with Grid captions in the View menu. The first shows at any size, the second from 90 percent zoom and the third from 130 percent.

Zoom scales rows, icons and grid cells from 50 to 300 percent. Use the minus and plus buttons in the View menu, Ctrl with the scroll wheel over a pane, or Ctrl+Plus, Ctrl+Minus and Ctrl+0. Click the percentage to go back to 100 percent. Grid at a high zoom level replaces the old gallery view.

### Preview

Press Space on a file to preview it without opening another app. Images are shown full size. Text files such as `.yml`, `.json`, `.md` or scripts are shown as text, up to the first 256 KB. Arrow keys move to the next file while the preview stays open. Enter opens the file, and Space or Escape closes the preview. Preview is also in the right click menu.

### Copy, cut and paste

Ctrl+C and Ctrl+X put files on the system clipboard, so Ctrl+V works in other apps too: a chat app attaches the files, GNOME Files copies or moves them, a terminal gets the paths. Cut items fade and show a scissors mark until you paste them or copy something else. Ctrl+V in Omafile pastes files copied in GNOME Files, Dolphin or a browser, and an image on the clipboard, such as a screenshot, is saved as `Pasted image.png`. The clipboard is kept by a small `bin/omafile-clipboard` process for as long as it holds your copy, using the Wayland data control protocol.

### Transfers

Copies and moves run in the background. Quick ones finish silently. Anything still running after about a second opens a small Transfers panel in the bottom right with progress, speed and time left. Click a transfer to see where it goes, how many files are done and any errors. Minimize the panel into the status bar and it stays there, with a progress bar, until you click it again. Finished transfers stay in the list so you can check them later: clear them one by one, or all at once with Clear completed.

### Drag and drop

Drag files or folders out of Omafile into any app that accepts files, such as Telegram, Discord, a browser upload field or a terminal. Pressing on an item that is already part of a selection drags the whole selection.

Inside Omafile, drop onto a folder, onto the empty part of a pane, onto the other pane, onto a place, bookmark or drive in the sidebar, or onto any folder in the path bar at the top, for example the parent folder. The spot that will receive the drop lights up. Within the same drive the items are moved, onto another drive they are copied, the way GNOME Files does it. Hold Ctrl while dropping to copy instead. Dropping onto Trash in the sidebar moves the items to the trash. Files dragged in from other apps are always copied, never moved. Dropping a folder into itself, or items into the folder they are already in, does nothing.

### Thumbnails

Videos, PDFs, office documents and other files get a thumbnail from the thumbnailers your system already has, the same ones GNOME Files uses. Omarchy ships ffmpegthumbnailer for video and Evince for PDF. Thumbnails are stored in `~/.cache/thumbnails` and shared with GNOME Files, so anything it has already thumbnailed shows up straight away. The cache only holds copies you can read yourself, but it keeps them after the original moves, so clear it if a folder is private. Turn thumbnails off with the `thumbnails` setting.

### The sidebar

Places, then your bookmarks, then drives, then Network, then Trash.

Bookmarks are shared with GNOME Files and the GTK file chooser: Omafile reads and writes `~/.config/gtk-3.0/bookmarks`, so a bookmark added in either place shows up in the other straight away. To add one, right click a folder and choose Bookmark this folder, press Ctrl+D, or drag folders onto the Bookmarks heading in the sidebar. While you drag, an empty sidebar shows a Bookmarks drop spot. Right click a bookmark to rename it or remove it, or use the cross beside it. Bookmarks from earlier Omafile versions are merged in once.

Right click anything in the sidebar for a menu: open it here, in a new tab or in the other pane, copy its path, or see its properties, including capacity and free space for drives. Depending on the entry the menu also offers Remove bookmark, Unmount, Eject for removable drives, Disconnect for network shares, Hide from the sidebar, or Empty trash. System mounts such as `/`, `/boot` or `/var/log` are never offered for unmounting.

Recent lists the files you opened most recently, newest first, from the same history the rest of the desktop uses. Opening one goes straight to the file. There is no folder above it, so leave by picking a place or a bookmark.

Hover a drive and click the eye to hide it. Hidden drives come back from Settings.

### Network drives

Connect to a server mounts an SMB share, an SFTP host, FTP or WebDAV. Servers you have used before are listed so one click reconnects, and any server the network advertises appears alongside them. Each server shows once under Network, dimmed while it is not connected. Click a server you used before to connect straight away with the address, user name, domain and anonymous choice you used last time. Passwords are never stored: SSH keys and your keyring cover most servers, and if the server still wants a password the Connect dialog opens filled in. Right click a server for Connect, Edit to change its details, or Forget this server. Right click a connected share, or use the eject button beside it, to disconnect.

This uses GVFS and needs no root. Install `gvfs-smb` for Windows shares if it is missing.

### Settings

Ctrl+Comma, or Settings in the menu at the right end of the toolbar. Hidden files, folders-first ordering, image previews, trash behaviour, the drive list, and the trash can in the bar.

Settings also picks whether Omafile is a normal window or a popup panel centred over the desktop that closes when you click away. The change applies immediately, even while Omafile is open.

### Opening folders from other apps

Turn on Default file manager in Settings. Folders opened from anywhere else then land in Omafile, and Show in folder opens the containing folder with the file selected. It also puts Omafile in your application launcher, using the same folder icon as the bar widget. Turning it off restores the handler you had before.

Two separate mechanisms are involved, which is why some apps can follow it and others not:

| Mechanism | Used by |
|-----------|---------|
| `inode/directory` pointed at a desktop entry in `~/.local/share/applications/` | `xdg-open`, `gio open`, most desktop apps |
| `org.freedesktop.FileManager1` claimed through a user D-Bus service file | browsers and editors, for Show in folder |

The D-Bus half needs PyGObject, which Omarchy ships. Without it the desktop entry still works and Show in folder keeps going to your previous file manager.

The desktop entry half from a terminal:

```bash
xdg-mime default xyzlab.omafile.desktop inode/directory
xdg-mime query default inode/directory
```

### Picking files for other apps

Turn on Pick files for other apps in Settings, under Opening. When a browser or another app asks you to choose a file, for example Upload file in Chrome or Firefox, Omafile opens instead of the GTK file chooser. The same goes for Save as and download locations. A bar along the bottom of the window shows what the app asked for, with a name box when saving and the app's file type filters. Pick a file and press Enter or the Select button, or press `Escape` to cancel.

It works through the desktop portal, the same route every app uses to ask for a file. Omafile registers a small D-Bus service in your home directory and tells the portal to send file chooser requests to it. Other portals, such as screen sharing, are left alone.

The portal only reads its list of backends from `/usr/share/xdg-desktop-portal/portals`, so enabling asks for your password once to install one file there, `omafile.portal`. Nothing else outside your home directory changes.

Turning it off sends file chooser requests back to the GTK portal. The file in `/usr/share` stays behind. It does nothing on its own, and you can remove it with `sudo rm /usr/share/xdg-desktop-portal/portals/omafile.portal`.

This needs PyGObject, which Omarchy ships. Apps that are already open may keep the old file chooser until you restart them.

The same from a terminal:

```bash
~/.config/omarchy/plugins/xyzlab.omafile/bin/omafile-portal-setup enable
~/.config/omarchy/plugins/xyzlab.omafile/bin/omafile-portal-setup status
~/.config/omarchy/plugins/xyzlab.omafile/bin/omafile-portal-setup disable
```

`enable` adds `org.freedesktop.impl.portal.FileChooser=omafile` to `~/.config/xdg-desktop-portal/hyprland-portals.conf` and keeps anything else you have in that file. `disable` removes only that line.

### Copying over something that exists

Omafile asks what to do. Choose with the mouse, or with the keys under [Keyboard](#when-a-file-already-exists).

## Keyboard

Omafile follows GNOME Files conventions, so shortcuts you already know work here.

### Navigation

| Keys | Action |
|------|--------|
| `Enter` | Open the selected item |
| `Backspace` / `Alt+Up` | Go to the parent folder |
| `Alt+Left` / `Alt+Right` | Back and forward |
| Mouse back / forward | Back and forward |
| `Alt+Home` | Go to your home folder |
| `Ctrl+L` | Type a path |
| `/` or `~` | Type a path, starting from root or home |
| `Home` / `End` | First and last item |
| `F5` / `Ctrl+R` | Refresh |

### Moving around without a mouse

Focus starts in the file list. Tab moves it to the sidebar, or to the other pane when the window is split. Escape or Right returns focus to the file list.

| Keys | Action |
|------|--------|
| `Tab` | Sidebar, or the other pane when split |
| `Shift+Tab` | Jump to the sidebar |
| `Arrows`, `Enter` | Move and open, once in the sidebar |
| `Ctrl+Enter` | Open a sidebar place in a new tab |
| `Delete` | Remove a bookmark or hide a drive, in the sidebar |
| `Escape` | Leave the sidebar |
| `Shift+F10` / `Menu` | Open the context menu on the current item |

The context menu is a real focus target: arrows move through it, Enter or Space runs the highlighted entry, Escape closes it. Anything Omafile can do to a file is in there, so no action needs the mouse.

### Selection

| Keys | Action |
|------|--------|
| `Ctrl+Click` | Add one item to the selection |
| `Ctrl+Space` | Add the item under the cursor |
| `Shift+Click`, `Shift+Arrows` | Select a range |
| `Ctrl+A` | Select everything |
| `Ctrl+Shift+I` | Invert the selection |
| `Escape` | Clear the selection |

### Files

| Keys | Action |
|------|--------|
| `Ctrl+C` / `Ctrl+X` / `Ctrl+V` | Copy, cut and paste |
| `Ctrl+Z` / `Ctrl+Shift+Z` | Undo and redo |
| `F2` | Rename |
| `Ctrl+Shift+N` | New folder |
| `Ctrl+N` | New file |
| `Delete` | Move to trash, or delete permanently when already in the trash |
| `Shift+Delete` | Delete permanently |
| `Ctrl+I` / `Alt+Enter` | Properties |
| `Ctrl+D` | Bookmark this folder |

Inside the trash, a bar above the files shows how many items it holds and has an **Empty trash** button, which asks before deleting everything for good. The right click menu there offers **Restore**, which puts items back where they came from, and **Delete permanently** in place of Move to trash.

Undo covers trash, rename, move, copy and new file or folder. Undoing a trash puts the items back where they were, and undoing a copy trashes what the copy created.

### Panes and tabs

| Keys | Action |
|------|--------|
| `Ctrl+T` / `Ctrl+W` | New tab with the same view, sort and hidden files setting, and close tab |
| `Ctrl+PageUp` / `Ctrl+PageDown` | Previous and next tab |
| `Ctrl+Enter` | Open the folder under the cursor in a new tab |
| `F6` | Split into two panes |
| `Tab` | Switch the active pane, while split |
| `Ctrl+Shift+C` / `Ctrl+Shift+M` | Copy and move to the other pane |

### View

| Keys | Action |
|------|--------|
| `Ctrl+1` / `Ctrl+2` / `Ctrl+3` | List, grid and compact |
| `Ctrl+Plus` / `Ctrl+Minus`, or `Ctrl` + scroll | Zoom in and out |
| `Ctrl+0` | Reset the zoom to 100 percent |
| `Space` | Preview the item under the cursor |
| `Ctrl+H` | Show hidden files |
| `Ctrl+B` | Show or hide the sidebar |
| `Ctrl+F`, or just type | Search in this folder |
| `Ctrl+Comma` | Settings |
| `F1` | The shortcut list |
| `Ctrl+Q` / `Escape` | Close the window |

Typing an ordinary character opens the search box with that character already typed, the way GNOME Files does.

### When a file already exists

| Keys | Action |
|------|--------|
| `R` / `K` / `S` / `A` | Replace, keep both, skip, skip all |

Escape skips the file.

Super+C, Super+V and Super+X are Omarchy's universal clipboard shortcuts. Omarchy translates them to Ctrl+C, Ctrl+V and Ctrl+X before they reach the window, so they copy, paste and cut files in Omafile too.

## Trash in the Bar

Turn on **Trash can in the bar** in Settings. Omafile adds a trash can to your bar as its own widget, so you can drag it anywhere from the Omarchy bar settings, including the other side of the bar from the file manager icon. Turning the setting off removes it again.

The icon is outlined when the trash is empty and solid when it is not, with the number of items beside it. The count updates on its own as things are deleted or restored from anywhere, not only from Omafile, and it covers every trash directory on the system, so a removable drive with its own trash is included.

Left click opens the trash. Right click empties it: the first right click turns it red for four seconds, and a second right click within that window empties it, so a stray click cannot wipe anything. Turn off **Ask before emptying** if you want the first right click to empty it outright.

## Settings

Configure these keys through the Omarchy bar widget settings:

| Key | Purpose |
|-----|---------|
| `homePath` | Default directory when opening Omafile |
| `showHidden` | Show hidden files and folders by default |
| `sortBy` | Sort by `name`, `size`, `modified` or `type` |
| `sortDirsFirst` | List directories before files |
| `confirmDelete` | Prompt before deleting items |
| `useTrash` | Send deleted items to trash (vs. permanent deletion) |
| `defaultView` | Start in `list`, `compact` or `grid` view |
| `terminal` | Terminal command to open in the current directory |
| `editor` | Text editor command to open selected files |
| `showTransferBadge` | Show a progress ring on the bar icon while a transfer runs |
| `showDrives` | Show the Drives section in the sidebar |
| `thumbnails` | Show image previews and thumbnails |
| `glyph` | Custom icon for the bar widget |
| `mode` | `files` for the file manager icon, `trash` for a trash can |
| `trashConfirm` | Ask before a right click empties the trash |

## Command Line

Open a specific directory or reveal a file:

```bash
omarchy-shell omafile open /path/to/directory
omarchy-shell omafile reveal /path/to/file
```

Move a file or folder to trash:

```bash
omarchy-shell omafile trash /path/to/item
```

Open the keyboard shortcut list:

```bash
omarchy-shell omafile shortcuts
```

Switch between a window and a popup:

```bash
omarchy-shell omafile windowmode window
omarchy-shell omafile windowmode popup
```

Add or remove the trash can in the bar:

```bash
omarchy-shell omafile trashicon on
omarchy-shell omafile trashicon off
omarchy-shell omafile trashicon status
```

Toggle the window from a keybinding or script:

```bash
omarchy-shell omafile toggle
```

Check the helper, running transfers, drives and trash:

```bash
omarchy-shell omafile status
```

## Removal

```bash
omarchy plugin remove xyzlab.omafile
```

Removal leaves one file behind, `~/.local/state/omarchy/omafile/state.json`, which remembers open tabs and recent folders. Delete it if you do not want to keep it.

## License

MIT, Copyright (c) 2026 chr0nzz
