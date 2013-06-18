window.fbAsyncInit = ->
  FB.init
    appId      : window.gon.global.facebook.app_id
    channelUrl : window.location.protocol + '//' + window.location.hostname + '/channel.html'
    status     : true
    xfbml      : true
    cookie: true