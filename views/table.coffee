{empty} = require "../util"

InputTemplate = require "../templates/input"

RowElement = (datum) ->
  tr = document.createElement "tr"
  Object.keys(datum).forEach (key) ->
    td = document.createElement "td"
    td.appendChild InputTemplate datum[key]

    tr.appendChild td

  return tr

TableTemplate = require "../templates/table"

# Focus same cell in next row
advanceRow = (path, prev) ->
  [td] = path.filter (element) ->
    element.tagName is "TD"
  return unless td

  tr = td.parentElement
  cellIndex = Array::indexOf.call(tr.children, td)
  if prev
    nextRowElement = tr.previousSibling
  else
    nextRowElement = tr.nextSibling

  if nextRowElement
    input = nextRowElement.children[cellIndex].querySelector('input')
    input?.focus()

# TableView takes an observale array of data and returns an object with a container element
# displaying the table data that can be inserted into the DOM.

# When the data observable changes the entire table is rerendered.
# Individual items can change their properties without rerendering the entire table.

# The view will have the ability to filter/sort the data.

TableView = (observableData) ->
  data = observableData()

  containerElement = TableTemplate
    headers: Object.keys data[0]
    keydown: (event) ->
      {key, path} = event
      switch key
        when "Enter", "ArrowDown"
          event.preventDefault()
          advanceRow path
        when "ArrowUp"
          event.preventDefault()
          advanceRow path, true
        # TODO: Left and Right
        # Left and Right are trickier because you may want to navigate within a text input
        # ... actually up and down get trickier too if we imagine text areas or
        # even fancier inputs that may have their own controls...

  tableBody = containerElement.children[0].children[1]

  filterFn = (datum) ->
    true

  sortFn = (a, b) ->
    a.id() - b.id()

  filterAndSort = (data, filterFn, sortFn) ->
    filterFn ?= -> true
    filteredData = data.filter(filterFn)

    if sortFn
      filteredData.sort(sortFn)
    else
      filteredData

  rowElements = ->
    filterAndSort(data, filterFn, sortFn).map RowElement

  update = ->
    empty tableBody
    rowElements().forEach (element) ->
      tableBody.appendChild element

  observableData.observe (newData) ->
    data = newData
    update()

  update()

  element: containerElement

module.exports = TableView
