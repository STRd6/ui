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

# Resize Handling
activeResize = null
resizeStart = null
resizeInitial = null
document.addEventListener "mousedown", (e) ->
  {target} = e

  if target.tagName is "RESIZE"
    resizeStart = e
    activeResize = target
    {width, height, x, y} = elementView activeResize
    resizeInitial =
      width: width()
      height: height()
      x: x()
      y: y()

document.addEventListener "mousemove", (e) ->
  if activeResize
    {clientX:startX, clientY:startY} = resizeStart
    {clientX:x, clientY:y} = e

    dx = x - startX
    dy = y - startY

    width = resizeInitial.width
    height = resizeInitial.height

    if activeResize.classList.contains("e")
      width += dx

    if activeResize.classList.contains("w")
      width -= dx

    if activeResize.classList.contains("s")
      height += dy

    if activeResize.classList.contains("n")
      height -= dy

    width = Math.max(width, 50)
    height = Math.max(height, 50)

    actualDeltaX = width - resizeInitial.width
    actualDeltaY = height - resizeInitial.height

    view = elementView activeResize
    if activeResize.classList.contains("n")
      view.y resizeInitial.y- actualDeltaY

    if activeResize.classList.contains("w")
      view.x resizeInitial.x- actualDeltaX

    view.width width
    view.height height

document.addEventListener "mouseup", ->
  activeResize = null

Observable = require "observable"

module.exports = () ->
  x = Observable 50
  y = Observable 50
  width = Observable 400
  height = Observable 300

  element = WindowTemplate
    title: "Utitled"
    menuBar: MenuBarView(items: notepadMenuParsed, handlers: {}).element

  styleBindPx(y, element, "top")
  styleBindPx(x, element, "left")
  styleBindPx(height, element, "height")
  styleBindPx(width, element, "width")

  self =
    element: element
    x: x
    y: y
    width: width
    height: height

  element.view = self

  return self

styleBindPx = (observable, element, attr) ->
  update = (newValue) ->
    newValue = parseInt newValue

    if newValue?
      element.style[attr] = "#{newValue}px"

  observable.observe update

  update(observable())
