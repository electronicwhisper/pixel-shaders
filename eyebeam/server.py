import BaseHTTPServer, SimpleHTTPServer
import ssl
import os

os.chdir('../')

httpd = BaseHTTPServer.HTTPServer(('localhost', 4443), SimpleHTTPServer.SimpleHTTPRequestHandler)
httpd.socket = ssl.wrap_socket (httpd.socket, certfile='eyebeam/server.pem', server_side=True)
httpd.serve_forever()