
/**
 * {1 Network infrastructure}
 */

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
  do Dom.remove(#{id})
  update_counts()

remove_all_done() =
  do Dom.remove(Dom.select_parent_one(Dom.select_class("done")))
  update_counts()

add_todo(x: string) =
  id = Random.string(8)
  li_id = Random.string(8)
  line = <li id={ li_id }><div class="todo" id={ id }>
           <div class="display">
             <input class="check" type="checkbox" onclick={_ -> make_done(id) } />
               <div class="todo_content">{ x }</div>
               <span class="todo_destroy" onclick={_ -> remove_item(li_id) }></span>
           </div>
           <div class="edit">
             <input class="todo-input" type="text" value="" />
           </div>
         </div></li>
  do Dom.transform([#todo_list +<- line ])
  do Dom.scroll_to_bottom(#todo_list)
  do Dom.set_value(#new_todo, "")
  update_counts()

start() =
  <body>
  <div id="todoapp">
    <div class="title">
      <h1>Todos</h1>
    </div>
    <div class="content">
      <div id=#create_todo>
        <input id=#new_todo placeholder="What needs to be done?" type="text" onnewline={_ -> add_todo(Dom.get_value(#new_todo)) } />
      </div>
      <div id=#todos>
        <ul id=#todo_list></ul>
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
  </body>

/**
 * {1 Application}
 */

/**
 * Main entry point.
 */
server = Server.one_page_bundle("Todo",
       [@static_resource_directory("resources")],
       ["resources/todos.css"], start)
