###
ContextMenu

Display a context menu!


###


Observable = require "observable"

MenuView = require "./menu"

{isDescendant} = require "../util"

module.exports = ({items, handlers}) ->
  activeItem = Observable null

  contextRoot =
    activeItem: activeItem
    handlers: handlers

  self = MenuView
    items: items
    contextRoot: contextRoot

  element = self.element
  element.view = self

  self.contextRoot = contextRoot
  self.display = ({inElement, x, y}) ->
    element.style.top = "#{y}px"
    element.style.left = "#{x}px"

    # The element must be added to the dom before it can be activated
    # it must be visible before it can be focused
    inElement.appendChild element
    activeItem self
    element.focus()

  # TODO: Find out if there is a way to avoid leaking
  # document listeners when creating/destroying many context menus
  document.addEventListener "mousedown", (e) ->
    unless isDescendant(e.target, element)
      activeItem null

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
        activeItem null

  return self
