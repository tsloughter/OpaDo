package opado.admin

import opado.ui
import opado.todo
import opado.user

module Admin {
    function add_users() {
        users = /users;
        Map.iter((function(_, y){
            items = /todo_items[y.username];
            add_user_to_page(y.username, y.fullname, y.is_oauth, Map.size(items))
        }), users)
    }

    function add_user_to_page(string username, string fullname, bool is_oauth, int size) {
        line =
            <tr><td>{username}</td><td>{fullname}</td><td>{is_oauth}</td><td>{size}</td></tr>;
        Dom.transform([#user_list =+ line])
    }

    function admin() {
        <table class="zebra-striped"  id="user_list" onready={function(_){add_users()}}>
          <thead>
            <tr>
              <th>Username</th>         
              <th>Fullname</th>        
              <th>Is OAuth</th>        
              <th>Number Posts</th> 
            </tr>
          </thead>
        </table>
    }

    resource =
      (Parser.general_parser((http_request -> 'toto))) parser { (.*) : function(_req){
         mypage("Admin", admin())
          }
        }
}
