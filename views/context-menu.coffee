Observable = require "observable"

MenuView = require "./menu"

module.exports = (params={}) ->
  params.contextRoot ?=
    activeItem: Observable null

  activeItem = params.contextRoot.activeItem

  self = MenuView params
  element = self.element

  self.display = ({inElement, x, y}) ->
    element.style.top = "#{y}px"
    element.style.left = "#{x}px"
    activeItem self

    inElement.appendChild element

  return self
