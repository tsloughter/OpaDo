
/**
 * {1 Network infrastructure}
 */

/**
 * {1 User interface}
 */

add_todo(x: string) =
  id = Random.string(8)
  li_id = Random.string(8)
  line = <li id={ li_id }><div class="todo" id={ id }>
           <div class="display">
             <input class="check" type="checkbox" onclick={_ -> Dom.add_class(#{id}, "done") } />
               <div class="todo_content">{ x }</div>
               <span class="todo_destroy" onclick={_ -> Dom.remove(#{li_id}) }></span>
           </div>
           <div class="edit">
             <input class="todo-input" type="text" value="" />
           </div>
         </div></li>
  do Dom.transform([#todo_list +<- line ])
  Dom.scroll_to_bottom(#todo_list)

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
        <div id="todo-stats"></div>
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
