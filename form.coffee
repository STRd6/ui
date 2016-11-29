Modal = require "./modal"

FormTemplate = require "./samples/test-form"

module.exports = ->
  form = FormTemplate
    submit: (e) ->
      formData = new FormData(e.target)

      result = Array.from(formData.entries()).reduce (object, [key, value]) ->
        # TODO: Nested objects
        # TODO: Convert keys ending in [] to array entries
        # *or* just keep it even simpler and don't allow multi-names at all
        if object[key]?
          unless object[key].push
            object[key] = [object[key]]

          object[key].push value
        else
          object[key] = value

        object
      , {}

      console.log result

      e.preventDefault()
      Modal.hide()

  Modal.show form
