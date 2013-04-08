$ ->
  if !/msie/.test(navigator.userAgent.toLowerCase())
    if document.cookie.indexOf("safari_cookie_fix") == -1
      top.window.location = "/cookie"