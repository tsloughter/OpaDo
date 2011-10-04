
/**
 * {1 Network infrastructure}
 */

done = 0

/**
 * {1 User interface}
 */

make_done(id: string) =
  do Dom.add_class(#{id}, "done")
  do Dom.set_text(#number_done, Int.to_string(String.to_int(Dom.get_text(#number_done)) + 1))
  Dom.set_text(#number_left, Int.to_string(String.to_int(Dom.get_text(#number_left)) - 1))

remove_item(id: string) =
  Dom.remove(#{id})

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
  do Dom.set_text(#number_left, Int.to_string(String.to_int(Dom.get_text(#number_left)) + 1))
  do Dom.scroll_to_bottom(#todo_list)
  Dom.transform([#todo_list +<- line ])

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
          <a href="#">
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
