# via https://github.com/mrdoob/glsl-sandbox/blob/master/static/js/helpers.js
`function convertHexToBytes( text ) {
  var tmpHex, array = [];
  for ( var i = 0; i < text.length; i += 2 ) {
    tmpHex = text.substring( i, i + 2 );
    array.push( parseInt( tmpHex, 16 ) );
  }
  return array;
}

function convertBytesToHex( byteArray ) {
  var tmpHex, hex = "";
  for ( var i = 0, il = byteArray.length; i < il; i ++ ) {
    if ( byteArray[ i ] < 0 ) {
      byteArray[ i ] = byteArray[ i ] + 256;
    }
    tmpHex = byteArray[ i ].toString( 16 );
    // add leading zero
    if ( tmpHex.length == 1 ) tmpHex = "0" + tmpHex;
    hex += tmpHex;
  }
  return hex;
}`

lzma = new LZMA("../vendor/lzma/lzma_worker.js") # TODO get rid of path dependency


module.exports = {
  loadLast: () ->
    localStorage["last"]
  saveLast: (src) ->
    localStorage["last"] = src
  serialize: (src, callback) ->
    lzma.compress src, 1, (bytes) ->
      compressed = convertBytesToHex(bytes)
      callback(compressed)
  unserialize: (blob, callback) ->
    bytes = convertHexToBytes(blob)
    lzma.decompress bytes, (src) ->
      callback(src)
}