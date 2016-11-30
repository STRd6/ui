Modal = require "./modal"

FormTemplate = require "./samples/test-form"

module.exports = ->
  Modal.form FormTemplate()
  .then console.log
