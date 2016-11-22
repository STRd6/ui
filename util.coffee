A = (attr) ->
  (x) -> x[attr]

F = (methodName) ->
  (x) -> x[methodName]()

# Handle events by preventing the default action
handle = (fn) ->
  (e) ->
    return if e?.defaultPrevented
    e?.preventDefault()
    fn.call(this, e)

# I hope I don't hate myself for this later
# S for Safe invoke, invoke the method of the object, if it exists and is a
# function, otherwise return the provided default value
S = (object, method, defaultValue) ->
  ->
    if typeof object?[method] is 'function'
      object[method]()
    else
      defaultValue

asElement = A('element')

accelerateItem = (items, key) ->
  [acceleratedItem] = items.filter (item) ->
    item.accelerator is key

  if acceleratedItem
    # TODO: should there be some kind of exec rather than click action?
    acceleratedItem.click()

isDescendant = (element, ancestor) ->
  return unless element

  while (parent = element.parentElement)
    return true if element is ancestor
    element = parent

advance = (list, amount) ->
  [currentItem] = list.filter (item) ->
    item.active()

  activeItemIndex = list.indexOf(currentItem) + amount

  if activeItemIndex < 0
    activeItemIndex = list.length - 1
  else if activeItemIndex >= list.length
    activeItemIndex = 0

  list[activeItemIndex]

module.exports =
  htmlEscape: (string) ->
    String(string).replace /[&<>"'\/]/g, (s) ->
      entityMap[s]

  A: A
  F: F
  S: S

  advance: advance
  asElement: asElement
  accelerateItem: accelerateItem
  handle: handle
  isDescendant: isDescendant

entityMap =
  "&": "&amp;"
  "<": "&lt;"
  ">": "&gt;"
  '"': '&quot;'
  "'": '&#39;'
  "/": '&#x2F;'

# Ideas

# Get the view associated with a dom element
# This will let us use the dom tree rather than manage a separate tree
# to dispatch events at the view level
# the assumption is that a .view property is written to the root element in the
# view when rendering a view's template element
elementView = (element) ->
  return unless element
  return element.view if element.view
  elementView element.parentElement
