video = null
streaming = false

module.exports = () ->
  window.URL = window.URL || window.webkitURL || window.mozURL || window.msURL
  navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia
  
  if !video
    video = document.createElement( 'video' )
    video.width = 640
    video.height = 480
    
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
  
  
  if streaming && video.readyState == 4
    return video
  else
    return false
