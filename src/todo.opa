package opado.todo

import opado.user
import stdlib.web.client

type todo_item = { value : string
                 ; done : bool
                 ; created_at : string
                 }


db /todo_items : stringmap(stringmap(todo_item))
db /todo_items[_][_]/done = false

Todo = {{
   update_counts() =
     num_done = Dom.length(Dom.select_class("done"))
     total = Dom.length(Dom.select_class("todo"))
     do Dom.set_text(#number_done, Int.to_string(num_done))
     Dom.set_text(#number_left, Int.to_string(total - num_done))

   make_done(id: string) =
     do if Dom.is_checked(Dom.select_inside(#{id}, Dom.select_raw("input"))) then
       do db_make_done(id)
       Dom.add_class(#{id}, "done")
     else
       Dom.remove_class(#{id}, "done")

     update_counts()

   @publish @async
   db_make_done(id: string) =
       username = User.get_username()
       items = /todo_items[username]
       item = Option.get(StringMap.get(id, items))
       /todo_items[username] <- StringMap.add(id, {item with done=true}, items)

   remove_item(id: string) =
     do db_remove_item(id)
     do Dom.remove(Dom.select_parent_one(#{id}))
     update_counts()

   @publish @async
   db_remove_item(id: string) =
     username = User.get_username()
     items = /todo_items[username]
     /todo_items[username] <- StringMap.remove(id, items)

   @async
   remove_all_done() =
     Dom.iter(x -> remove_item(Dom.get_id(x)), Dom.select_class("done"))

   add_todo(x: string) =
     id = Dom.fresh_id()
     do db_add_todo(id, x)
     add_todo_to_page(id, x, false)

   @publish @async
   db_add_todo(id: string, x: string) =
     username = User.get_username()
     items = /todo_items[username]
     /todo_items[username] <- StringMap.add(id, { value=x done=false created_at="" }, items)

   @publish
   add_todos() =
     username = User.get_username()
     items = /todo_items[username]
     StringMap.iter((x, y -> add_todo_to_page(x, y.value, y.done)), items)

   add_todo_to_page(id: string, value: string, is_done: bool) =
     line = <li><div class="todo { if is_done then "done" else "" }" id={ id }>
              <div class="display">
                <input class="check" type="checkbox" onclick={_ -> make_done(id) } />
                  <div class="todo_content">{ value }</div>
                  <span class="todo_destroy" onclick={_ -> remove_item(id) }></span>
              </div>
              <div class="edit">
                <input class="todo-input" type="text" value="" />
              </div>
            </div></li>
     do Dom.transform([#todo_list +<- line])
     do Dom.scroll_to_bottom(#todo_list)
     do Dom.set_value(#new_todo, "")

     update_counts()

   todos() =
     if User.is_logged() then
       Resource.styled_page("Todos", ["/resources/todos.css"], todos_page())
     else
       Resource.styled_page("Sign Up", ["/resources/todos.css"], User.new())

   todos_page() =
       <a onclick={_ -> User.logout()}>Logout</a>
       <div id="todoapp">
         <div class="title">
           <h1>OpaDo Beta</h1>
           <span style="font-size=10px">Note: No guarentee your data will not be lost. This is just a demo for now.</span>
         </div>
         <div class="content">
           <div id=#create_todo>
             <input id=#new_todo placeholder="What needs to be done?" type="text" onnewline={_ -> add_todo(Dom.get_value(#new_todo)) } />
           </div>
           <div id=#todos>
             <ul id=#todo_list onready={_ -> add_todos() } ></ul>
           </div>

           <div id="todo_stats">
             <span class="todo_count">
               <span id=#number_left class="number">0</span>
               <span class="word">items</span> left.
             </span>
             <span class="todo_clear">
               <a href="#" onclick={_ -> remove_all_done() }>
                 Clear <span id=#number_done class="number-done">0</span>
                 completed <span class="word-done">items</span>
               </a>
             </span>
           </div>
         </div>
       </div>

   resource : Parser.general_parser(http_request -> resource) =
     parser
     | (.*) ->
     _req -> todos()
}}
