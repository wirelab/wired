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
        ga 'send', 'event', 'facebook', 'feed', window.location.protocol + '//' + window.location.hostname]) if ga?
        ga 'send', 'social', 'facebook', 'feed', window.location.protocol + '//' + window.location.hostname]) if ga?

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
