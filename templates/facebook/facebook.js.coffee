((d) ->
  js = undefined
  id = "facebook-jssdk"
  ref = d.getElementsByTagName("script")[0]
  return  if d.getElementById(id)
  js = d.createElement("script")
  js.id = id
  js.async = true
  js.src = "//connect.facebook.net/en_US/all.js"
  ref.parentNode.insertBefore js, ref
) document

window.fbAsyncInit = ->
  FB.init
    appId      : window.gon.global.facebook.app_id
    channelUrl : window.location.protocol + '//' + window.location.hostname + '/channel.html'
    status     : true
    xfbml      : true
    cookie: true