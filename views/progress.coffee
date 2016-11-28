Template = require "../templates/progress"

Observable = require "observable"

module.exports = (params={}) ->
  {value, max} = params
  value = Observable value or 0
  max = Observable max

  element = Template
    value: value
    max: max

  element: element
  value: value
  max: max
