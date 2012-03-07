import stdlib.web.client

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
        useref = User.get_username();
        /opado/todos[~{ id }] <- { done : true };
    }

    function remove_item(string id) {
        db_remove_item(id);
        Dom.remove(Dom.select_parent_one(#{id}));
        update_counts()
    }

    exposed @async function db_remove_item(string id) {
        useref = User.get_username();
        // Not implemented in Opa 9.0.0 for mongo backend
        // Db.remove(@/opado/todos[~{ id }]);
        void
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

    exposed @async function db_add_todo(string id, string value) {
        useref = User.get_username();
        /opado/todos[~{ id }] <- { id : id, useref : useref, value : value } // not necessary to specify default values
    }

    exposed function add_todos() {
        useref = User.get_username();
        dbset(Todo.t) items = /opado/todos[ useref == useref];
        items = DbSet.to_list(items);
        List.iter((function(item){add_todo_to_page(item.id, item.value, item.done)}), items)
    }

    function update_todo(string id, string value) {
        db_add_todo(id, value);
        update_todo_on_page(id, value);
        Dom.void_style(#{id^"_destroy"});
    }

    function update_todo_on_page(string id, string value) {
        line = <div id={id^"_todo"} class="todo_content" onclick={function(_){make_editable(id, value)}}>{ value }</div>
        _ = Dom.put_replace(#{id^"_input"}, Dom.of_xhtml(line));
        void
    }

    function make_editable(string id, string value) {
        line = <input id={id^"_input"} class="xlarge todo_content" onnewline={function(_){update_todo(id, Dom.get_value(#{id^"_input"}))}} value={ value } />
        Dom.show(#{id^"_destroy"});
        _ = Dom.put_replace(#{id^"_todo"}, Dom.of_xhtml(line));
        update_counts()
    }

    function add_todo_to_page(string id, string value, bool is_done) {
        line =
          <li><div class="todo {if (is_done) "done" else ""}" id={ id }>
            <div class="display">
              <span id={id^"_destroy"} class="todo_destroy icon icon-remove" onclick={function(_){remove_item(id)}}></span>
              <input class="check" type="checkbox" onclick={function(_){make_done(id)}}/>
              <div id={id^"_todo"} class="todo_content" onclick={function(_){make_editable(id, value)}}>{ value }</div>
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
        <div class="container hero-unit">
             <div id=#create_todo>
                  <input id=#new_todo class="xlarge" placeholder="What needs to be done?" type="text"
                  onnewline={function(_){add_todo(Dom.get_value(#new_todo))}} />
             </div>
        </div>
        <div class="container" id="todoapp">
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
                <span id=#number_left class="number bold">0</span>
                <span class="word">items</span> left
              </p>
            </div>
          </div>
          <div class="footer">Note: This is beta version. No guarentee your data wont be lost.</div>
       </div>
    }

   resource =
    (Parser.general_parser((http_request -> resource))) parser {
      (.*) : function(_req){todos()}
    }
      
}
