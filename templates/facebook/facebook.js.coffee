window.fbAsyncInit = ->
  FB.init
    appId      : window.gon.global.facebook.app_id
    channelUrl : window.location.protocol + '//' + window.location.hostname + '/channel.html'
    status     : true
    xfbml      : true
    cookie: true

  # track facebook events with analytics
  FB.Event.subscribe "message.send", (href) ->
    _gaq.push(['_trackEvent', 'facebook', 'send', href]) if _gaq?
    _gaq.push(['_trackSocial', 'facebook', 'send', href]) if _gaq?

  FB.Event.subscribe "edge.create", (href, widget) ->
    _gaq.push(['_trackEvent', 'facebook', 'like', href]) if _gaq?
    _gaq.push(['_trackSocial', 'facebook', 'like', href]) if _gaq?

  FB.Event.subscribe "edge.remove", (href, widget) ->
    _gaq.push(['_trackEvent', 'facebook', 'unlike', href]) if _gaq?
    _gaq.push(['_trackSocial', 'facebook', 'unlike', href]) if _gaq?

$ ->
  # Share button
  # Usage: <a href="javascript: " rel="no-follow" data-fb-feed="http://your-link-to-share">share</a>
  # title, description, picture etc is read from og-metadata
  $('[data-fb-feed]').click (event) ->
    obj =
      method: 'feed'
      link: $(this).data('fb-feed')

    FB.ui obj, (resp) ->
      if resp
        _gaq.push(['_trackEvent', 'facebook', 'feed', window.location.protocol + '//' + window.location.hostname]) if _gaq?
        _gaq.push(['_trackSocial', 'facebook', 'feed', window.location.protocol + '//' + window.location.hostname]) if _gaq?

  # Login button
  # Usage: <a href="javascript: " rel="no-follow" data-fb-login>login</a>
  $('[data-fb-login]').click (event) ->
    $btn = $(this)
    event.preventDefault()
    unless $btn.hasClass 'disabled'
      $btn.addClass 'disabled'
      FB.login (response) ->
        if response.authResponse
          $.ajax '/users',
            type: 'POST'
            dataType: 'json'
            data:
              user:
                access_token: response.authResponse.accessToken
            success: (response) ->
              window.location = response.redirect
            error: (event) ->
              $btn.removeClass 'disabled'
              alert "Er is iets mis gegaan, probeer het later nog eens!"
      , scope: 'email'
      false
