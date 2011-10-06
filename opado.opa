type todo_item = { id : string
                 ; value : string
                 }

db /todo_items : stringmap(todo_item)

/**
 * {1 User interface}
 */
update_counts() =
  num_done = Dom.length(Dom.select_class("done"))
  total = Dom.length(Dom.select_class("todo"))
  do Dom.set_text(#number_done, Int.to_string(num_done))
  Dom.set_text(#number_left, Int.to_string(total - num_done))

make_done(id: string) =
  do if Dom.is_checked(Dom.select_inside(#{id}, Dom.select_raw("input"))) then Dom.add_class(#{id}, "done")
  else
    Dom.remove_class(#{id}, "done")

  update_counts()

remove_item(id: string) =
  do Dom.remove(Dom.select_parent_one(#{id}))
  do Db.remove(@/todo_items[id])
  update_counts()

remove_all_done() =
  Dom.iter(x -> remove_item(Dom.get_id(x)), Dom.select_class("done"))

add_todo(x: string) =
  id = Random.string(8)
  do /todo_items[id] <- { id=id value=x }
  add_todo_to_page(id, x)

add_todos() =
  items = /todo_items
  StringMap.iter((x, y -> add_todo_to_page(x, y.value)), items)

add_todo_to_page(id: string, value: string) =
  line = <li><div class="todo" id={ id }>
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

start() =
  <div id="todoapp">
    <div class="title">
      <h1>Todos</h1>
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

/**
 * {1 Application}
 */

/**
 * Main entry point.
 */
server = Server.one_page_bundle("Todo",
       [@static_resource_directory("resources")],
       ["resources/todos.css"], start)
