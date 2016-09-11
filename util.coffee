module.exports =
  htmlEscape: (string) ->
    String(string).replace /[&<>"'\/]/g, (s) ->
      entityMap[s]

entityMap =
  "&": "&amp;"
  "<": "&lt;"
  ">": "&gt;"
  '"': '&quot;'
  "'": '&#39;'
  "/": '&#x2F;'
