import stdlib.database.mongo

module Admin {
    function add_users() {
        dbset(User.t) users = /opado/users; 
        // dbset(User.t) users = /opado/users; // with Opa 9.0.1
        users = DbSet.to_list(users)
        // it = DbSet.iterator(users); // with Opa 9.0.1
        List.iter((function(user){
            useref = user.ref;
            dbset(Todo.t) items = /opado/todos[ useref == useref ];
            items = DbSet.to_list(items);
            add_user_to_page(user.username, user.fullname, user.is_oauth, List.length(items))
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
