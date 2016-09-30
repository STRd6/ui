{htmlEscape, asElement, F, S, isDescendant, accelerateItem} = require "../util"

Observable = require "observable"

MenuTemplate = require "../templates/menu"
MenuItemTemplate = require "../templates/menu-item"
MenuSeparator = require "../templates/menu-separator"

advance = (list, amount) ->
  [currentItem] = list.filter (item) ->
    item.active()

  activeItemIndex = list.indexOf(currentItem) + amount

  if activeItemIndex < 0
    activeItemIndex = list.length - 1
  else if activeItemIndex >= list.length
    activeItemIndex = 0

  list[activeItemIndex]

# Parse out custom action symbol from entries like:
#
#     [F]ont... -> showFont
#
# Falling back to formatting the action title
formatAction = (labelText) ->
  [title, action] = labelText.split("->").map F("trim")

  action ?= title

  str = action.replace(/[^A-Za-z0-9]/g, "")
  str.charAt(0).toLowerCase() + str.substring(1)

formatLabel = (labelText) ->
  accelerator = undefined
  # Parse out accelerator keys for underlining when alt is pressed
  titleHTML = htmlEscape(labelText).replace /\[([^\]]+)\]/, (match, $1) ->
    accelerator = $1.toLowerCase()
    "<span class=\"accelerator\">#{$1}</span>"

  span = document.createElement "span"
  span.innerHTML = titleHTML

  return [span, accelerator]

SeparatorView = ->
  element: MenuSeparator()
  separator: true

module.exports = MenuItemView = (item, handler, parent, top, activeItem) ->
  return SeparatorView() if item is "-" # separator

  self =
    accelerate: null
    element: null
    active: null
    cursor: null
    click: null
    items: null
    parent: null
    navigableItems: null

  # TODO: This gets called per menu item when the state changes
  # Could we shift it a little to only be called for the relevant subtree?
  active = ->
    isDescendant activeItem()?.element, element

  if Array.isArray(item) # Submenu
    [label, items] = item

    self.accelerate = (key) ->
      accelerateItem(items, key)

    self.cursor = (direction) ->
      # TODO: Can we refactor out all the special case != top stuff?
      switch direction
        when "Up"
          if self is activeItem() and parent != top
            activeItem advance(parent.navigableItems, -1)
          else
            activeItem advance(navigableItems, -1)
        when "Down"
          if self is activeItem() and parent != top
            activeItem advance(parent.navigableItems, 1)
          else
            activeItem advance(navigableItems, 1)
        when "Left"
          console.log "Left!", self, activeItem()
          # If we are at a top level menu select the adjacent menu
          if parent is top or parent.parent is top
            if self != activeItem()
              activeItem self
            else
              activeItem advance(top.items, -1)
          else # If we are in a submenu select self in the parent's items
            if self != activeItem()
              activeItem self
            else
              activeItem parent
        when "Right"
          if parent is top
            activeItem advance(top.items, 1)
          else # we have submenu items open that submenu and select the first one
            activeItem navigableItems[0]

    items = items.map (item) ->
      MenuItemView(item, handler, self, top, activeItem)

    navigableItems = items.filter (item) ->
      !item.separator

    self.items = items
    self.navigableItems = navigableItems
    click = (e) ->
      return if e?.defaultPrevented
      e.preventDefault()

      activeItem self
    content = MenuTemplate
      class: "menu-options"
      items: items.map (item) ->
        item.element
      log: console.log

  else
    label = item

    # Hook in to Action objects so we can display hotkeys
    # and enabled/disabled statuses.
    actionName = formatAction label
    action = handler[actionName]
    disabled = S(action, "disabled", false)
    hotkey = S(action, "hotkey", "")

    click = (e) ->
      e?.preventDefault()

      unless disabled()
        console.log "Handled", actionName

        action?.call?(handler)

        # TODO: More cleanup than just clearing the active item, like also we
        # should clear accelerator state, and maybe return focus to previously
        # focused element.
        activeItem null

    self.cursor = (direction) ->
      switch direction
        when "Right"
          # Select the next dropdown list from the top menu
          activeItem advance(top.items, 1)
        when "Left"
          if parent.parent is top
            activeItem advance(top.items, -1)
          else
            parent.cursor(direction)
        else
          parent.cursor(direction)
    self.accelerate = parent.accelerate

  [title, accelerator] = formatLabel label

  element = MenuItemTemplate
    class: ->
      [
        "menu" if items
        "active" if active()
      ]
    click: click
    mousemove: (e) ->
      # Click to activate top level menus unless a menu is already active
      # then hover to show.
      currentItem = activeItem()
      return unless currentItem

      if isDescendant(e.target, element) and !e.defaultPrevented
        # Note: We're just using preventDefault to prevent handling the
        # activation above the first element that handles it
        e.preventDefault()

        activeItem self

    title: title
    content: content
    hotkey: hotkey
    disabled: disabled

  self.click = click
  self.accelerator = accelerator
  self.element = element
  self.active = active
  self.parent = parent

  return self
