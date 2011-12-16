package opado.admin

import opado.todo
import opado.user

import stdlib.themes.bootstrap

module Admin {
    function add_users() {
        users = /users;
        Map.iter((function(_, y){
            items = /todo_items[y.username];
            add_user_to_page(y.username, y.fullname,
            Map.size(items))
        }), users)
    }

    function add_user_to_page(string username,string fullname,int size) {
        line =
            <tr><td>{username}</td><td>{fullname}</td><td>{size}</td></tr>;
        Dom.transform([#user_list =+ line])
    }

    function admin() {
        <table class="zebra-striped"  id="user_list" onready={function(_){add_users()}}>
          <thead>
            <tr>
              <th>Username</th>         
              <th>Fullname</th>        
              <th>Number Posts</th> 
            </tr>
          </thead>
        </table>
    }

    resource =
      (Parser.general_parser((http_request -> resource))) parser (.*) -> function(_req){
          Resource.styled_page("Admin",
          ["/resources/todos.css"],
          admin())}
}
