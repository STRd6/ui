# The MenuBar is a list MenuItems arranged in a bar across the top of a page or
# window.

Observable = require "observable"

MenuView = require "./menu"

{isDescendant, advance} = require "../util"

module.exports = ({items, handlers}) ->
  acceleratorActive = Observable false
  # Track active menus and item for navigation
  activeItem = Observable null
  previouslyFocusedElement = null

  contextRoot =
    activeItem: activeItem
    handlers: handlers

  self = MenuView
    classes: ->
      [
        "menu-bar"
        "accelerator-active" if acceleratorActive()
      ]
    items: items
    contextRoot: contextRoot

  element = self.element

  # Redefine cursor movement
  # TODO: Need to also redefine expand to down and not right on menu items
  self.cursor = (direction) ->
    switch direction
      when "Right"
        self.advance(1)
      when "Left"
        self.advance(-1)

  self.items.forEach (item) ->
    item.cursor = (direction) ->
      if direction is "Down"
        # Activate first submenu item
        activeItem item.submenu?.items[0]
      else
        item.parent.cursor direction

  deactivate = ->
    activeItem null
    acceleratorActive false
    # De-activate menu and focus previously focused element
    previouslyFocusedElement?.focus()

  document.addEventListener "mousedown", (e) ->
    unless isDescendant(e.target, element)
      acceleratorActive false
      activeItem null

  document.addEventListener "keydown", (e) ->
    {key} = e
    switch key
      when "Enter"
        activeItem()?.click()
      when "Alt"
        menuIsActive = false
        if acceleratorActive() or menuIsActive
          deactivate()
        else
          # Store previously focused element
          # Get menu ready for accelerating!
          previouslyFocusedElement = document.activeElement
          element.focus()
          activeItem self unless activeItem()
          acceleratorActive true

  # Dispatch the key to the active menu element
  accelerateIfActive = (key) ->
    if acceleratorActive()
      activeItem()?.accelerate(key)

  # We need to be able to focus the menu to receive keyboard events on it
  element.setAttribute("tabindex", "-1")
  element.addEventListener "keydown", (e) ->
    {key} = e

    switch key
      when "ArrowLeft", "ArrowUp", "ArrowRight", "ArrowDown"
        e.preventDefault()
        direction = key.replace("Arrow", "")

        currentItem = activeItem()

        if currentItem
          currentItem.cursor(direction)

      when "Escape"
        deactivate()
      else
        accelerateIfActive key.toLowerCase()

  return self
