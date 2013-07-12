FILEPICKER_API_KEY = "AaqPpE9LORQel03S9cCl7z"
IMAGE_SERVER = "http://i.meemoo.me/"

filepicker.setKey(FILEPICKER_API_KEY)


$c = $("#c")
canvas = $c[0]

generateDataUrl = ->
  canvas.shader.toDataURL()


lastimg = ""

publish = ->
  dataurl = generateDataUrl()
  if lastimg == dataurl
    return

  lastimg = dataurl

  split = dataurl.split(',', 2)
  type = split[0].split(':')[1].split(';')[0]
  ext = type.split('/')[1]
  b64 = split[1]

  fileinfo = {
    mimetype: type,
    location: 'S3',
    path: 'openart/meemoo/',
    filename: 'pixelshaders.refractor.'+ext,
    access: 'public',
    base64decode: true
  }

  # console.log "here fileinfo", fileinfo

  $("#publisher").text("Publishing...")
  $("#publisher").show()

  filepicker.store(
    b64,
    fileinfo,
    (file) ->
      # Public s3 URL
      s3url = IMAGE_SERVER + file.key

      console.log "got here", s3url

      data = {
        "_csrf": "Hkge_JRS92Kv_j97ADBHGzpT",
        "title": "Pixel Shaders Refractor",
        "description": "made with refractor.pixelshaders.com at Open(Art), Eyebeam NYC",
        "url": s3url,
        "image": s3url,
        "author": "author"
      }

      # Post to gallery
      $.ajax({
        type: "POST",
        url: "http://fast-crag-2176.herokuapp.com/post",
        data: data,
        success: (event) -> console.log(event)
      })

      $("#publisher").text("Find your image at openart.eyebeam.org/gallery")

      setTimeout(->
        $("#publisher").hide()
      , 2000)

      # // Info
      # self.$(".info").text('Find your image at openart.eyebeam.org/gallery ' + s3url);
    ,
    (error) ->
      console.log "error"
      lastimg = ""
      $("#publisher").hide()
    ,
    (percent) ->
      $("#publisher").text(percent + "% Uploaded")
      # self.$(".info").text(percent + "% uploaded.");
  )












module.exports = publish



# inputimg: function (dataurl) {
#   if (this.lastimg === dataurl) { return false; }
#   if (!window.filepicker){
#     this.$(".info").text("Offline or image service not available.");
#     return false;
#   }

#   this.lastimg = dataurl;
#   this.img.src = dataurl;
#   this.$(".info").text("Uploading...");



#   var self = this;
#   filepicker.store(
#     b64,
#     fileinfo,
#     function (file) {
#       // Public s3 URL
#       var s3url = IMAGE_SERVER + file.key;

#       var data = {
#         "_csrf": "Hkge_JRS92Kv_j97ADBHGzpT",
#         "title": "meemoo stopmotion",
#         "description": "made with meemoo.org at Open(Art), Eyebeam NYC",
#         "url": "http://meemoo.org/iframework/#example/cam2gif",
#         "image": s3url,
#         "author": "author"
#       };

#       // Post to gallery
#       $.ajax({
#         type: "POST",
#         url: "http://fast-crag-2176.herokuapp.com/post",
#         data: data,
#         success: function(event){ console.log(event) }
#       });

#       // Info
#       self.$(".info").text('Find your image at openart.eyebeam.org/gallery ' + s3url);
#     },
#     function (error) {
#       self.$(".info").text('Upload error :-(');
#       self.lastimg = "";
#     },
#     function (percent) {
#       self.$(".info").text(percent + "% uploaded.");
#     }
#   );

# },