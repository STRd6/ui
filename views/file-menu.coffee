Observable = require "observable"

MenuTemplate = require "../templates/menu"
MenuItemView = require "./menu-item"

{asElement, accelerateItem, isDescendant} = require "../util"

# TODO: Can this be combined with MenuItemView to reduce some redundancy at the
# top level?
module.exports = (data, handler) ->
  acceleratorActive = Observable false
  # Track active menus and item for navigation
  activeItem = Observable null
  previouslyFocusedElement = null

  self =
    element: null
    accelerate: (key) ->
      accelerateItem menuItems, key
    items: null
    cursor: ->
      activeItem menuItems[0]

  self.items = menuItems = data.map (item) ->
    MenuItemView(item, handler, self, self, activeItem)

  # Dispatch the key to the active menu element
  accelerate = (key) ->
    activeItem()?.accelerate(key)

  element = MenuTemplate
    items: menuItems.map asElement
    log: (e) ->
      console.log e
    class: ->
      [
        "menu-bar"
        "accelerator-active" if acceleratorActive()
      ]

  deactivate = ->
    activeItem null
    acceleratorActive false
    # De-activate menu and focus previously focused element
    previouslyFocusedElement?.focus()

  # TODO: Handle mouseout

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

  # We need to be able to focus the menu to receive keyboard events on it
  element.setAttribute("tabindex", "0")
  element.addEventListener "keydown", (e) ->
    {key} = e

    switch key
      when "ArrowLeft", "ArrowUp", "ArrowRight", "ArrowDown"
        e.preventDefault()
        
        currentItem = activeItem()
        direction = key.replace("Arrow", "")
        currentItem.cursor(direction)

      when "Escape"
        deactivate()
      else
        accelerate key.toLowerCase() if acceleratorActive()

  self.element = element

  return self
