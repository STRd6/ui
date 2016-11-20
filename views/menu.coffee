MenuTemplate = require "../templates/menu"

# MenuItem = require "./menu-item"

{asElement, F, htmlEscape, handle, isDescendant} = require "../util"

# MenuView


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
module.exports = MenuView = ({items, contextRoot}) ->
  console.log "MenuView", items
  self = {}

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
      else
        MenuItemView
          label: item
          contextRoot: contextRoot

  navigableItems = items.filter (item) ->
    !item.separator

  self.accelerate = (key) ->
    accelerateItem(items, key)

  self.cursor = (direction) ->
    switch direction
      when "Up"
        self.advance(-1)
      when "Down"
        self.advance(1)

  self.items = items
  self.advance = (n) ->
    activeItem advance(navigableItems, n)
  self.navigableItems = navigableItems

  self.element = MenuTemplate
    class: ->
      [
        "menu"
        "active" if active()
      ]
    click: handle (e) ->
      activeItem self
    items: items.map asElement
  
  console.log self

  return self

MenuItemView = ({label, MenuView, items, contextRoot}) ->
  self = {}
  console.log "MenuItem", label

  {activeItem} = contextRoot
  # TODO: This gets called per menu item when the state changes
  # Could we shift it a little to only be called for the relevant subtree?
  active = ->
    isDescendant activeItem()?.element, element

  if items
    content = MenuView({items, contextRoot}).element

  [title, accelerator] = formatLabel label

  element = MenuItemTemplate
    class: ->
      [
        "menu" if items
        "active" if active()
      ]
    # TODO: Don't handle click on disabled
    click: handle (e) ->
      unless disabled()
        console.log "Handled", actionName

        action?.call?(handler)

        # TODO: More cleanup than just clearing the active item, like also we
        # should clear accelerator state, and maybe return focus to previously
        # focused element.
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
    caret: "▸" if items
    # hotkey: hotkey
    # disabled: disabled

  self.element = element

  return self

MenuSeparatorTemplate = require "../templates/menu-separator"
SeparatorView = ->
  element: MenuSeparatorTemplate()
  separator: true

Observable = require "observable"

MenuTemplate = require "../templates/menu"
MenuItemTemplate = require "../templates/menu-item"

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
