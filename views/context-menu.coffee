###
ContextMenu

Display a context menu!

Questions:

Should we be able to update the options in the menu after creation?

###


Observable = require "observable"

MenuView = require "./menu"

{isDescendant} = require "../util"

module.exports = ({items, classes, handlers}) ->
  activeItem = Observable null
  classes ?= []
  top = Observable ""
  left = Observable ""

  contextRoot =
    activeItem: activeItem
    handlers: handlers

  self = MenuView
    items: items
    contextRoot: contextRoot
    classes: -> ["context", "options"].concat(classes)
    style: ->
      "top: #{top()}px; left: #{left()}px"

  element = self.element
  element.view = self

  self.contextRoot = contextRoot
  self.display = ({inElement, x, y}) ->
    top(y)
    left(x)

    # The element must be added to the dom before it can be activated
    # it must be visible before it can be focused
    (inElement or document.body).appendChild element
    activeItem self
    element.focus()

  # This must be attached to the document body so we can de-activate when
  # a person presses the mouse outside of our menu
  # TODO: How should we clean up this global listener?
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
