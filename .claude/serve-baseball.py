import http.server
import os
import sys

PORT = 6551
ROOT = r'C:\Users\kobay\Downloads\AI-Engineer-claude-plan-solution-architecture-aHZVv 4'

os.chdir(ROOT)

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.path = '/baseball-team.html'
        return super().do_GET()
    def log_message(self, format, *args):
        pass

with http.server.HTTPServer(('localhost', PORT), Handler) as httpd:
    print(f'Server started on http://localhost:{PORT}', flush=True)
    httpd.serve_forever()
