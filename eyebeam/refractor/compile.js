require("coffee-script");
var stitch = require('stitch');
var fs     = require('fs');

var package = stitch.createPackage({
  paths: [__dirname + '/src']
});

package.compile(function (err, source){
  if (err) throw err;
  fs.writeFile(__dirname + '/compiled/app.js', source, function (err) {
    if (err) throw err;
    console.log('Compiled compiled/app.js');
  })
})
