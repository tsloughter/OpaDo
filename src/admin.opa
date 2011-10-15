package opado.admin

import opado.user

Admin = {{
    add_users() =
      users = /users
      Map.iter((_, y -> add_user_to_page(y.username, y.fullname)), users)

    add_user_to_page(username: string, fullname: string) =
      line = <li>{username} {fullname}</li>
      Dom.transform([#user_list +<- line])

   admin() =
     <div>
       <ul id=#user_list onready={_ -> add_users() } ></ul> 
     </div>

   resource : Parser.general_parser(http_request -> resource) =
      parser
       | (.*) ->
       _req -> Resource.styled_page("Admin", ["/resources/todos.css"], admin())
}}
