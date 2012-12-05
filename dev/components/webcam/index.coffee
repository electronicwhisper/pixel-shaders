video = null
streaming = false

askForCam = () ->
  success = (stream) ->
    console.log "received stream"
    if (navigator.mozGetUserMedia != undefined )
      video.src = stream
    else
      video.src = window.URL.createObjectURL(stream)
    video.play()
    streaming = true
  
  error = (err) ->
    alert('Webcam required')
    console.log(err)
  
  navigator.getUserMedia({video: true}, success, error)

module.exports = () ->
  window.URL = window.URL || window.webkitURL || window.mozURL || window.msURL
  navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia
  
  if !video
    video = document.createElement( 'video' )
    video.width = 640
    video.height = 480
    
    # Sometimes the browser doesn't ask for the webcam if it happens too fast.. so there's this silly delay
    setTimeout(askForCam, 200)
  
  
  if streaming && video.readyState == 4
    return video
  else
    return false
