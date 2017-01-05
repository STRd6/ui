WindowTemplate = require "../templates/window"

{elementView} = require "../util"

# We need an invisible full screen overlay to keep iframes from eating our
# mousemove events
frameGuard = document.createElement "frame-guard"
document.body.appendChild frameGuard

topIndex = 0
raiseToTop = (view) ->
  return unless typeof view.zIndex is 'function'
  zIndex = view.zIndex()
  return if zIndex is topIndex
  topIndex += 1

  view.zIndex(topIndex)

# Drag Handling
activeDrag = null
dragStart = null
document.addEventListener "mousedown", (e) ->
  {target} = e

  view = elementView target
  if view
    # TODO: only raise widows?
    raiseToTop view

  if target.tagName is "TITLE-BAR"
    frameGuard.classList.add("active")
    dragStart = e
    activeDrag = view

document.addEventListener "mousemove", (e) ->
  if activeDrag
    {clientX:prevX, clientY:prevY} = dragStart
    {clientX:x, clientY:y} = e

    dx = x - prevX
    dy = y - prevY

    activeDrag.x activeDrag.x() + dx
    activeDrag.y activeDrag.y() + dy

    dragStart = e

# Resize Handling
activeResize = null
resizeStart = null
resizeInitial = null
document.addEventListener "mousedown", (e) ->
  {target} = e

  if target.tagName is "RESIZE"
    frameGuard.classList.add("active")
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

    width = Math.max(width, 200)
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

    view.trigger "resize"

document.addEventListener "mouseup", ->
  activeDrag = null
  activeResize = null
  frameGuard.classList.remove("active")

Bindable = require "bindable"
Observable = require "observable"

module.exports = (params) ->
  self = Bindable()

  x = Observable params.x ? 50
  y = Observable params.y ? 50
  width = Observable params.width ? 400
  height = Observable params.height ? 300
  title = Observable params.title ? "Untitled"

  topIndex += 1
  zIndex = Observable params.zIndex ? topIndex

  element = WindowTemplate
    title: title
    menuBar: params.menuBar
    content: params.content
    close: ->
      self.close()

  styleBind(y, element, "top", "px")
  styleBind(x, element, "left", "px")
  styleBind(height, element, "height", "px")
  styleBind(width, element, "width", "px")
  styleBind(zIndex, element, "zIndex")

  Object.assign self,
    element: element
    title: title
    x: x
    y: y
    width: width
    height: height
    zIndex: zIndex
    close: ->
      # TODO: Allow prompt to cancel
      # Maybe we count on people to override this method if they want
      element.remove()

  element.view = self

  return self

styleBind = (observable, element, attr, suffix="") ->
  update = (newValue) ->
    newValue = parseInt newValue

    if newValue?
      element.style[attr] = "#{newValue}#{suffix}"

  observable.observe update

  update(observable())
