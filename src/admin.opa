package opado.admin

import opado.todo
import opado.user
import stdlib.themes.bootstrap

Admin = {{
    add_users() =
      users = /users
      Map.iter(_, y -> items = /todo_items[y.username]
                       add_user_to_page(y.username, y.fullname, Map.size(items)), users)

    add_user_to_page(username: string, fullname: string, size: int) =
      line = <tr><td>{username}</td><td>{fullname}</td><td>{size}</td></tr>
      Dom.transform([#user_list +<- line])

   admin() =
     <table class="zebra-striped" id=#user_list onready={_ -> add_users() } >
       <thead><tr>
         <th>Username</th> 
         <th>Fullname</th> 
         <th>Number Posts</th> 
       </tr></thead>
     </table>

   resource : Parser.general_parser(http_request -> resource) =
      parser
       | (.*) ->
       _req -> Resource.styled_page("Admin", ["/resources/todos.css"], admin())
}}
