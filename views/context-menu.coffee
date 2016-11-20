Observable = require "observable"

MenuView = require "./menu"

module.exports = (params={}) ->
  params.contextRoot ?=
    activeItem: Observable null

  contextRoot = params.contextRoot
  activeItem = contextRoot.activeItem

  self = MenuView params

  element = self.element
  element.view = self

  self.contextRoot = contextRoot
  self.display = ({inElement, x, y}) ->
    element.style.top = "#{y}px"
    element.style.left = "#{x}px"

    inElement.appendChild element

    activeItem self

  return self
