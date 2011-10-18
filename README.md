## Install Opa: [http://opalang.org](http://opalang.org)

## Compile and Run:

```bash
[tristan@marx ~/Devel/opado]
15:45 (master) λ make
opa src/todo.opa src/user.opa src/admin.opa src/main.opa
Embedding file "/Users/tristan/Devel/opado/resources/destroy.png" as resource "resources/destroy.png" with mimetype "image/png"
Embedding file "/Users/tristan/Devel/opado/resources/todos.css" as resource "resources/todos.css" with mimetype "text/css"
[tristan@marx ~/Devel/opado]
15:47 (master) λ ./src/main.exe 
Accesses logged to access.log
Messages logged to error.log
Opa-server (OPA/652) serving on http://marx.local:8080
```
