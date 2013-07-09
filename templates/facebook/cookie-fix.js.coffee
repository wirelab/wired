$ ->
  if document.cookie.indexOf("cookie_fix") == -1
    window.top.location = "#{window.location.protocol}//#{window.location.hostname}/cookie"
