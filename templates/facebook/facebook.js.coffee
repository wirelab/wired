window.fbAsyncInit = ->
  FB.init
    appId      : window.gon.global.facebook.app_id
    channelUrl : window.location.protocol + '//' + window.location.hostname + '/channel.html'
    status     : true
    xfbml      : true
    cookie: true

$ ->
  $('a#facebook-login').click (event) ->
    event.preventDefault()
    unless $('a#facebook-login').hasClass 'submitting'
      $('a#facebook-login').addClass 'submitting'
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
              $('a#facebook-login').removeClass 'submitting'
              alert "Er is iets mis gegaan, probeer het later nog eens!"
      , scope: 'email'
      false
