package opado.todo

import opado.user
import opado.ui
import stdlib.web.client

type todo_item = {
    string value,
    bool done,
    string created_at
}

database stringmap(stringmap(todo_item)) /todo_items
database /todo_items[_][_]/done = false

module Todo {
    function update_counts() {
        num_done = Dom.length(Dom.select_class("done"));
        total = Dom.length(Dom.select_class("todo"));
        Dom.set_text(#number_done, Int.to_string(num_done));
        Dom.set_text(#number_left, Int.to_string(total - num_done))
    }

    function make_done(string id) {
        if(Dom.is_checked(Dom.select_inside(#{id}, Dom.select_raw("input")))) {
            db_make_done(id);
            Dom.add_class(#{id}, "done")
        } else {
            Dom.remove_class(#{id}, "done")
        };
        update_counts()
    }

    exposed @async function db_make_done(string id) {
        username = User.get_username();
        items = /todo_items[username];
        item = Option.get(StringMap.get(id, items));
        @/todo_items[username] <-
          StringMap.add(id, {item with done : true}, items)
    }

    function remove_item(string id) {
        db_remove_item(id);
        Dom.remove(Dom.select_parent_one(#{id}));
        update_counts()
    }

    exposed @async function db_remove_item(string id) {
        username = User.get_username();
        items = /todo_items[username];
        @/todo_items[username] <- StringMap.remove(id, items)
    }

    @async function remove_all_done() {
        Dom.iter((function(x){remove_item(Dom.get_id(x))}),
                  Dom.select_class("done"))
    }

    function add_todo(string x) {
        id = Dom.fresh_id();
        db_add_todo(id, x);
        add_todo_to_page(id, x, false)
    }

    exposed @async function db_add_todo(string id,string x) {
        username = User.get_username();
        items = /todo_items[username];
        @/todo_items[username] <-
        StringMap.add(id, { value : x, done : false, created_at : "" },
          items)
    }

    exposed function add_todos() {
        username = User.get_username();
        items = /todo_items[username];
        StringMap.iter((function(x,y){add_todo_to_page(x, y.value, y.done)}), items)
    }

    function add_todo_to_page(string id,string value,bool is_done) {
        line =
          <li><div class="todo {if (is_done) "done" else ""}" id={ id }>
            <div class="display">
              <span class="todo_destroy icon icon-remove" onclick={function(_){remove_item(id)}}></span>
              <input class="check" type="checkbox" onclick={function(_){make_done(id)}}/>
              <div class="todo_content">{ value }</div>
            </div>
            <div class="edit">
             <input class="todo-input xlarge" type="text" value="" />
            </div>
          </div></li>
        Dom.transform([#todo_list =+ line]);
        Dom.scroll_to_bottom(#todo_list);
        Dom.set_value(#new_todo, "");
        update_counts()
    }
    function todos(){
        if (User.is_logged()){
            mypage("Todos",todos_page())
        } else {
            mypage("Sign Up",User.new())
        }
    }
    function todos_page() {
        <div class="topbar">
           <div class="container">
             <a class="brand" href="#"></a>
             <a class="btn pull-right" onclick={function(_){User.logout()}}>Logout</a>
           </div>
        </div>
        <div class="container" id="todoapp">
         <div class="hero-unit">  
          <div id=#create_todo>
              <input id=#new_todo class="xlarge" placeholder="What needs to be done?" type="text"
                onnewline={function(_){add_todo(Dom.get_value(#new_todo))}} />
          </div>
          <span class="help-block">Note: This is beta version. No guarentee your data wont be lost.</span>
         </div>
         <div class="content">
            <div id=#todos>
              <ul id=#todo_list onready={function(_){add_todos()}} class="unstyled"></ul>
            </div>
             <div id="todo_stats" class="well">
              <p class="todo_clear pull-right">
                <a class="btn" href="#" onclick={function(_){remove_all_done()}}>
                  <span class="icon icon-white icon-trash"/> Clear 
                  <span id=#number_done class="number-done">0</span>
                  completed <span class="word-done">items</span>
                </a>
              </p>
              <p class="todo_count">
                <span id=#number_left class="number">0</span>
                <span class="word">items</span> left
              </p>
            </div>
          </div>
       </div> 
    }

   resource =
    (Parser.general_parser((http_request -> resource))) parser
      (.*) -> function(_req){todos()}
}
