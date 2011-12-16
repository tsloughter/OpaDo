## Install Opa: [http://opalang.org](http://opalang.org)

## Compile and Run:

```bash
19:05 (master) λ make
opa --parser js-like src/todo.opa src/user.opa src/admin.opa src/main.opa -o main.exe
Embedding file "/Users/tristan/Devel/opado/resources/destroy.png" as resource "resources/destroy.png" with mimetype "image/png"
Embedding file "/Users/tristan/Devel/opado/resources/js/bugherd.js" as resource "resources/js/bugherd.js" with mimetype "application/javascript"
Embedding file "/Users/tristan/Devel/opado/resources/js/google_analytics.js" as resource "resources/js/google_analytics.js" with mimetype "application/javascript"
Embedding file "/Users/tristan/Devel/opado/resources/todos.css" as resource "resources/todos.css" with mimetype "text/css"
[tristan@marx ~/Devel/opado]
19:05 (master) λ ./main.exe
Accesses logged to access.log
Messages logged to error.log
Http (OPA/1056) serving on http://marx.local:8080
```
