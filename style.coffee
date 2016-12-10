styles = {}

all = """
  main
  loader
  menu
  modal
  window
""".split("\n").map (stylePath) ->
  content = require "./style/#{stylePath}"
  styles[stylePath] = content

  return content
.join("\n")

styles.all = all

module.exports = styles
