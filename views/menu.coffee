Observable = require "observable"

{advance, accelerateItem, asElement, F, S, htmlEscape, handle, isDescendant} = require "../util"

MenuTemplate = require "../templates/menu"
MenuItemTemplate = require "../templates/menu-item"

SeparatorView = require "./menu-separator"
MenuItemView = require "./menu-item"

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

  classes ?= -> ["options"]

  {activeItem} = contextRoot

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

  # TODO: This gets called per menu item when the state changes
  # Could we shift it a little to only be called for the relevant subtree?
  active = ->
    isDescendant activeItem()?.element, self.element

  Object.assign self,
    accelerate: (key) ->
      accelerateItem(items, key)
    cursor: (direction) ->
      switch direction
        when "Up"
          self.advance(-1)
        when "Down"
          self.advance(1)
        else
          parent.parent?.cursor(direction)
    parent: parent
    items: items
    advance: (n) ->
      activeItem advance(navigableItems, n)
    navigableItems: navigableItems
    element: MenuTemplate
      class: ->
        [
          "active" if active()
        ].concat classes()
      click: handle (e) ->
        activeItem self
      items: items.map asElement

  return self
