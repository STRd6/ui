{advance, asElement, F, S, htmlEscape, handle, isDescendant} = require "../util"

MenuTemplate = require "../templates/menu"
MenuItemTemplate = require "../templates/menu-item"

SeparatorView = require "./menu-separator"
# MenuItem = require "./menu-item"

# MenuView
# 
# items is an array of item data
# An item datum is either a string
# or a pair of [label:string, items...]
#
# ex. [
#   "Cool"
#   ["Submenu", [
#     "Yo",
#     "Wat"
#   ]]
# ]
#
module.exports = MenuView = ({items, classes, contextRoot, parent}) ->
  console.log "MenuView", items
  self = {}

  console.log classes
  classes ?= ["menu"]

  {activeItem} = contextRoot

  # TODO: This gets called per menu item when the state changes
  # Could we shift it a little to only be called for the relevant subtree?
  active = ->
    isDescendant activeItem()?.element, self.element

  # Promote item data to MenuItemViews
  items = items.map (item) ->
    switch
      when item is "-"
        SeparatorView()
      when Array.isArray(item)
        assert item.length is 2
        [label, submenuItems] = item
        MenuItemView
          label: label
          items: submenuItems
          MenuView: MenuView
          contextRoot: contextRoot
          parent: self
      else
        MenuItemView
          label: item
          contextRoot: contextRoot
          parent: self

  navigableItems = items.filter (item) ->
    !item.separator

  self.accelerate = (key) ->
    accelerateItem(items, key)

  self.cursor = (direction) ->
    console.log "Menu Cursor", direction
    switch direction
      when "Up"
        self.advance(-1)
      when "Down"
        self.advance(1)

  self.parent = parent
  self.items = items
  self.advance = (n) ->
    activeItem advance(navigableItems, n)
  self.navigableItems = navigableItems

  self.element = MenuTemplate
    class: ->
      [
        "active" if active()
      ].concat classes
    click: handle (e) ->
      activeItem self
    items: items.map asElement
  
  console.log self

  return self

MenuItemView = ({label, MenuView, items, contextRoot, parent}) ->
  self = {}
  console.log "MenuItem", label

  {activeItem, handlers} = contextRoot
  # TODO: This gets called per menu item when the state changes
  # Could we shift it a little to only be called for the relevant subtree?
  active = ->
    isDescendant activeItem()?.element, element

  self.active = active

  if items
    submenu = MenuView({
      items
      contextRoot
      parent: self
    })
    content = submenu.element

  [title, accelerator] = formatLabel label

  # Hook in to Action objects so we can display hotkeys
  # and enabled/disabled statuses.
  actionName = formatAction label
  action = handlers[actionName]
  disabled = S(action, "disabled", false)
  hotkey = S(action, "hotkey", "")

  element = MenuItemTemplate
    class: ->
      [
        "menu" if items
        "active" if active()
      ]
    # TODO: Don't handle click on disabled
    click: (e) ->
      return if disabled()
      return if e?.defaultPrevented
      e?.preventDefault()

      if submenu
        activeItem self
        return

      console.log "Handling", actionName

      action?.call?(handler)

      # TODO: More cleanup than just clearing the active item, like also we
      # should clear accelerator state, and maybe return focus to previously
      # focused element.
      # contextRoot.finish?
      activeItem null

    mousemove: (e) ->
      # Click to activate top level menus unless a menu is already active
      # then hover to show.
      return unless activeItem()

      if !e.defaultPrevented and isDescendant(e.target, element)
        # Note: We're using preventDefault to prevent handling the
        # activation above the first element that handles it
        e.preventDefault()

        activeItem self

    title: title
    content: content
    decoration: "▸" if items
    hotkey: hotkey
    disabled: disabled

  self.parent = parent
  self.element = element
  self.cursor = (direction) ->
    console.log "Item Cursor", direction
    if submenu and direction is "Right"
      # Select the first navigable item of the submenu
      activeItem submenu.navigableItems[0]
    else if parent.parent and direction is "Left"
      # parent is the menu,
      # parent.parent is the item in the menu containing the parent
      activeItem parent.parent
    else
      parent.cursor(direction)

  return self

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
