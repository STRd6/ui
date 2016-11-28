UI
===

Artisanal User Interface

Menus
-----

- Context Menu
- Menu Bar
- Nested submenus

Simple DSL for creating menus and binding to handlers.

```
{ContextMenu} = require "ui"

contextMenu = ContextMenu()
document.body.appendChild contextMenu.element
```

Modals
------

- Alert
- Confirm
- Prompt

Promise returning prompts, confirms, etc.

Actions
-------

Hotkeys, help text, icons, enabled/disabled states.

Z-Indexes
---------

Is there a sane way to do z-indexes? Right now I'm just listing them.

Modal: 1000
Context Menu: 2000
