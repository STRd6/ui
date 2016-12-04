notepadMenuParsed = require "../samples/demo"
WindowTemplate = require "../templates/window"

MenuBarView = require "./menu-bar"

{elementView} = require "../util"

# Drag Handling
activeDrag = null
dragStart = null
document.addEventListener "mousedown", (e) ->
  {target} = e

  if target.tagName is "TITLE-BAR"
    dragStart = e
    activeDrag = elementView target

document.addEventListener "mousemove", (e) ->
  if activeDrag
    {clientX:prevX, clientY:prevY} = dragStart
    {clientX:x, clientY:y} = e

    dx = x - prevX
    dy = y - prevY

    activeDrag.x activeDrag.x() + dx
    activeDrag.y activeDrag.y() + dy

    dragStart = e

document.addEventListener "mouseup", ->
  activeDrag = null

# TODO: Resize Handling
activeResize = null
resizeStart = null
document.addEventListener "mousedown", (e) ->
  {target} = e

  if target.tagName is "RESIZE"
    resizeStart = e
    activeResize = elementView target

document.addEventListener "mousemove", (e) ->
  if activeResize
    {clientX:prevX, clientY:prevY} = resizeStart
    {clientX:x, clientY:y} = e

    dx = x - prevX
    dy = y - prevY

document.addEventListener "mouseup", ->
  activeResize = null

Observable = require "observable"

module.exports = () ->
  x = Observable 50
  y = Observable 50

  element = WindowTemplate
    title: "Utitled"
    menuBar: MenuBarView(items: notepadMenuParsed, handlers: {}).element

  styleBindPx(y, element, "top")
  styleBindPx(x, element, "left")

  self =
    element: element
    x: x
    y: y

  element.view = self

  return self

styleBindPx = (observable, element, attr) ->
  update = (newValue) ->
    newValue = parseInt newValue

    if newValue?
      element.style[attr] = "#{newValue}px"

  observable.observe update

  update(observable())
