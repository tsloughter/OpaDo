package opado.todo

import opado.user
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
              <input class="check" type="checkbox" onclick={function(_){make_done(id)}} />
              <div class="todo_content">{ value }</div>
              <span class="todo_destroy" onclick={function(_){remove_item(id)}}></span>
            </div>
            <div class="edit">
             <input class="todo-input" type="text" value="" />
            </div>
          </div></li>
        Dom.transform([#todo_list =+ line]);
        Dom.scroll_to_bottom(#todo_list);
        Dom.set_value(#new_todo, "");
        update_counts()
    }

    function todos() {
        if (User.is_logged()) {
            Resource.styled_page("Todos",["/resources/todos.css"],todos_page())
        } else {
            Resource.styled_page("Sign Up",["/resources/todos.css"],User.new())
        }
    }

    function todos_page() {
        <a onclick={function(_){User.logout()}}>Logout</a>
        <div id="todoapp">
          <div class="title">
            <h1>OpaDo Beta</h1>
            <span style="font-size=10px">Note: No guarentee your data will not be lost. This is just a demo for now.</span>
          </div>
          <div class="content">
            <div id=#create_todo>
              <input id=#new_todo placeholder="What needs to be done?" type="text"
                onnewline={function(_){add_todo(Dom.get_value(#new_todo))}} />
            </div>
            <div id=#todos>
              <ul id=#todo_list onready={function(_){add_todos()}} ></ul>
            </div>
             <div id="todo_stats">
              <span class="todo_count">
                <span id=#number_left class="number">0</span>
                <span class="word">items</span> left.
              </span>
              <span class="todo_clear">
                <a href="#" onclick={function(_){remove_all_done()}}>
                  Clear <span id=#number_done class="number-done">0</span>
                  completed <span class="word-done">items</span>
                </a>
              </span>
            </div>
          </div>
        </div>
    }

   resource =
    (Parser.general_parser((http_request -> resource))) parser
      (.*) -> function(_req){todos()}
}
