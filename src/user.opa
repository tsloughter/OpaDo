/*
 * USER.OPA
 *
 * @author Tristan Sloughter
 * @author Matthieu Guffroy
**/

package opado.user
import stdlib.widgets.loginbox
import stdlib.crypto
import stdlib.web.client
import stdlib.core.web.core
import stdlib.widgets.formbuilder
import stdlib.themes.bootstrap

// DATA

@abstract type User.password = string
@abstract type User.ref = string

type User.t =
  {
    username : string
    fullname : string
    password : User.password
  }

type User.status = { logged : User.ref } / { unlogged }
type User.info = UserContext.t(User.status)
type User.map('a) = ordered_map(User.ref, 'a, String.order)

db /users : User.map(User.t)

User_data = {{
  mk_ref( login : string ) : User.ref =
    String.to_lower(login)

  ref_to_string( login : User.ref ) : string =
    login

  save( ref : User.ref, user : User.t ) : void =
    /users[ref] <- user

  get( ref : User.ref ) : option(User.t) =
    ?/users[ref]
}}

User = {{

  @private state = UserContext.make({ unlogged } : User.status)

  create(username, password) =
    do match ?/users[username] with
      | {none} ->
          user : User.t =
            { username=username ;
              fullname="" ;
              password = Crypto.Hash.sha2(password) }
          /users[username] <- user

      | _ -> void
    Client.goto("/login")

  get_status() =
    UserContext.execute((a -> a), state)

  is_logged() =
    match get_status() with
     | { logged = _ } -> true
     | { unlogged } -> false

  login(login, password) =
    useref = User_data.mk_ref(login)
    user = User_data.get(useref)
    do match user with
     | {some = u} -> if u.password == Crypto.Hash.sha2(password) then
                       UserContext.change(( _ -> { logged = User_data.mk_ref(login) }), state)

     | _ -> void
     Client.goto("/todos")

  logout() =
    do UserContext.change(( _ -> { unlogged }), state)
    Client.reload()

  start() =
    if User.is_logged() then
      Resource.default_redirection_page("/todos")
    else
      Resource.styled_page("Login", ["/resources/todos.css"], <div id="todoapp"><div class="title"><h1>Login</h1></div><div class="content">{loginbox()}</div><div id="todo_stats">No account? <a href="/user/new" class="btn large primary">Sign Up</a></div></div>)

   new() =
     <div id="todoapp">
       <div class="title">
         <h1>Sign Up</h1>
       </div>
       <div class="content">
         <form onsubmit={_ -> create(Dom.get_value(#username), Dom.get_value(#password)) }>
         <div id=#create_todo>
           <input id=#username class="login_input" placeholder="New Username..." type="text" />
         </div>

         <div id=#create_todo>
           <input id=#password class="login_input" placeholder="Password..." type="password" />
         </div>

         <button type=submit class="btn large primary" onclick={_ -> do create(Dom.get_value(#username), Dom.get_value(#password))
                                                                	login(Dom.get_value(#username), Dom.get_value(#password)) }>Create</button> or <a href="/login">Login here</a>
	 </form>
       </div>
       <div style="margin-top:10px;">Get the source <a href="https://github.com/tsloughter/opado">here</a>. And read about the implementation at <a href="http://blog.erlware.org/2011/10/04/todomvc-in-opa/">Part 1</a>, <a href="http://blog.erlware.org/2011/10/06/opado-data-storage/">Part 2</a>, <a href="http://blog.erlware.org/2011/10/15/opado-personal-todo-lists/">Part 3</a></div>
     </div>

  process(_) =
        Log.notice("form", "user added")

  new2() =
    username = WFormBuilder.mk_field("Username:", WFormBuilder.text_field)
    passwd1  = WFormBuilder.mk_field("Password:", WFormBuilder.passwd_field)
    passwd2  = WFormBuilder.mk_field("Password again:", WFormBuilder.passwd_field)

    fields = <div id="todoapp">
        <div class="title">
          <h1>Sign Up</h1>
        </div>
        <div class="content">
        {WFormBuilder.field_html(WFormBuilder.add_validator(username, WFormBuilder.empty_validator), WFormBuilder.default_field_builder, WFormBuilder.empty_style)}
        {WFormBuilder.field_html(passwd1, WFormBuilder.default_field_builder, WFormBuilder.empty_style)}
        {WFormBuilder.field_html(passwd2, WFormBuilder.default_field_builder, WFormBuilder.empty_style)}
        <input type="submit" value="Register" />
      </div>
      </div>

    WFormBuilder.form_html("register", {Basic}, fields, process)

  edit() =
    if User.is_logged() then
      Resource.html("User module", <h1>Module User</h1><>Under construction</>)
    else
      start()

  admin() =
    if User.is_logged() then
      username_id = Dom.fresh_id()
      fullname_id = Dom.fresh_id()
      ref = get_status()
      match ref with
         | {unlogged} -> <>Error...</>
         | {logged=r} -> user = Option.get(User_data.get(r))
      <p>
        Username : <input id=#{username_id}
                           onchange={_ -> User_data.save(r, {user with username = Dom.get_value(#{username_id})})}
                           value={user.username} /><br />
        Fullname   :  <input id=#{fullname_id}
                           onchange={_ -> User_data.save(r, {user with fullname = Dom.get_value(#{fullname_id})})}
                        value={user.fullname} />
      </p>
    else
      loginbox()

  get_username() =
    ref = User.get_status()
    match ref with
      | {unlogged} -> "error"
      | {logged=r} -> user = Option.get(User_data.get(r))
                      user.username

  view(login : string) =
    match User_data.get(User_data.mk_ref(login)) with
     | { none } -> Resource.html("User module", <h1>Module User</h1><>Error, the user {login} does'nt exist</>)
     | { some = _ } -> Resource.html("User module", <h1>Module User</h1><>This the public profil of {login}, this page is under construction</>)

  loginbox() : xhtml =
    user_opt =
       match get_status() with
         | { logged = u } -> Option.some(<>{User_data.ref_to_string(u)} => <a onclick={_ -> logout()}>Logout</a></>)
         | _ -> Option.none

    WLoginbox.html(WLoginbox.default_config, "login_box", login, user_opt)

  resource : Parser.general_parser(http_request -> resource) =
    parser
    | "/new" ->
      _req -> Resource.styled_page("New User", ["/resources/todos.css"], new())
    | "/edit" ->
      _req -> edit()
    | "/view/" login=(.*) ->
      _req -> view(Text.to_string(login))
    | .* ->
      _req -> start()

}}

