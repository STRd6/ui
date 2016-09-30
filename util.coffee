A = (attr) ->
  (x) -> x[attr]

F = (methodName) ->
  (x) -> x[methodName]()

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

module.exports =
  htmlEscape: (string) ->
    String(string).replace /[&<>"'\/]/g, (s) ->
      entityMap[s]

  A: A
  F: F
  S: S

  asElement: asElement

  accelerateItem: accelerateItem

  isDescendant: isDescendant

entityMap =
  "&": "&amp;"
  "<": "&lt;"
  ">": "&gt;"
  '"': '&quot;'
  "'": '&#39;'
  "/": '&#x2F;'
