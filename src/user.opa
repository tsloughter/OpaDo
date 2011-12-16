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

type User.t = {string username, string fullname, User.password password}

type User.status = {User.ref logged} or {unlogged}

type User.info = UserContext.t(User.status)
type User.map('a) = ordered_map(User.ref, 'a, String.order)

database User.map(User.t) /users

module User_data {
    function User.ref mk_ref(string login){
        String.to_lower(login)
    }

    function string ref_to_string(User.ref login){
        login
    }

    function void save(User.ref ref,User.t user){
        @/users[ref] <- user
    }

    function option(User.t) get(User.ref ref){
        ?/users[ref]
    }
}

module User {
    private state = UserContext.make((User.status) { unlogged })

    function create(username,password) {
        match (?/users[username]) {
            case { none }:
              user =
                  (User.t) { ~username,
                           fullname : "",
                           password : Crypto.Hash.sha2(password) };
              @/users[username] <- user
            default: void
            };
        Client.goto("/login")
    }

    function get_status() {
        UserContext.execute((function(a){a}), state)
    }

    function is_logged() {
        match (get_status()) {
        case { logged : _ }: true
        case { unlogged }: false
        }
    }

    function login(login,password) {
        useref = User_data.mk_ref(login);
        user = User_data.get(useref);
        match (user) {
        case { some : u }:
           if (u.password == Crypto.Hash.sha2(password)) {
               UserContext.change(function(_){
                   { logged :User_data.mk_ref(login) }
                 },state)
           }
        default: void
        };
        Client.goto("/todos")
    }

    function logout() {
        UserContext.change((function(_){{ unlogged }}), state);
        Client.reload()
    }

    function start() {
        if (User.is_logged()) {
            Resource.default_redirection_page("/todos")
        } else {
            Resource.styled_page("Login", ["/resources/style.css"],
            <div class="topbar">
              <div class="container">
                <a class="brand" href="#"></a>
              </div>
            </div>
            <div class="container" id="todoapp">
                <div class="content">
                   <h1>Login</h1>
                   {loginbox()}
                   <div class="well">No account? 
                      <a href="/user/new" class="btn">Sign Up</a>
                   </div>
                </div>
            </div>
            )
        }
    }

    function new(){
      <div class="topbar">
         <div class="container">
            <a class="brand" href="#"></a>
         </div>
      </div>
      <div class="container" id="todoapp">
           <div class="content">
             <h1>Sign Up</h1>
             <form onsubmit={function(_){create(Dom.get_value(#username),Dom.get_value(#password))}}>
               <div id=#create_todo class="clearfix">
                 <input id=#username class="xlarge" placeholder="New Username..." type="text" />
               </div>

               <div id=#create_todo class="clearfix">
                 <input id=#password class="xlarge" placeholder="Password..." type="password" />
               </div>
               <button type=submit class="btn large" onclick={
                     function(_){
                         create(Dom.get_value(#username),Dom.get_value(#password));
                         login(Dom.get_value(#username), Dom.get_value(#password))
                     }}>Create</button>
                      or <a href="/login">Login here</a>
             </form>
           </div>
           <div class="footer">
             Get the source <a href="https://github.com/tsloughter/opado">here</a>. 
             And read about the implementation at 
             <a href="http://blog.erlware.org/2011/10/04/todomvc-in-opa/">Part 1</a>, 
             <a href="http://blog.erlware.org/2011/10/06/opado-data-storage/">Part 2</a>, 
             <a href="http://blog.erlware.org/2011/10/15/opado-personal-todo-lists/">Part 3</a>, 
             <a href="http://blog.erlware.org/2011/11/06/adding-js-to-all-opa-resources-use-case-google-analytics/">on adding Googlel Analytics</a>, 
             <a href="http://blog.erlware.org/2011/11/06/major-opado-speed-up-with-publish/">on vastling improving performance.</a>
           </div>
       </div>
    }

    function process(_) {
        Log.notice("form", "user added")
    }

    function edit() {
        if(User.is_logged()) {
            Resource.html("User module",<><h1>Module User</h1>Under construction</>)
        } else {
            start()
        }
    }

    function admin() {
        if(User.is_logged()){
            username_id = Dom.fresh_id();
            fullname_id = Dom.fresh_id();
            ref = get_status();
            match (ref) {
            case { unlogged }: <>Error...</>
            case { logged : r }:
                user = Option.get(User_data.get(r));
                <p>
                  Username : <input id=#{username_id}
                           onchange={function(_){
                              User_data.save(r, {user with username : Dom.get_value(#{username_id})})
                           }}
                           value={user.username} /><br />
                  Fullname   :  <input id=#{fullname_id}
                           onchange={function(_){ User_data.save(r, {user with fullname : Dom.get_value(#{fullname_id})})
                           }}
                           value={user.fullname} />
                </p>
            }
        } else {
            loginbox()
        }
    }

    function get_username() {
        ref = User.get_status();
        match (ref) {
        case { unlogged }: "error"
        case { logged : r }:
            user = Option.get(User_data.get(r));
            user.username
        }
    }

    function view(string login) {
        match (User_data.get(User_data.mk_ref(login))) {
        case { none }:
            Resource.html("User module", <h1>Module User</h1><>Error, the user {login} does'nt exist</>)
        case { some : _ }:
            Resource.html("User module", <h1>Module User</h1><>This the public profil of {login}, this page is under construction</>)
        }
    }

    function xhtml loginbox() {
        user_opt = match (get_status()) {
        case { logged : u }:
            Option.some(<>{User_data.ref_to_string(u)} =>
               <a class="btn" onclick={(function(_){logout()})}>Logout</a></>
            )
        default: Option.none
        };
        WLoginbox.html(WLoginbox.default_config,"login_box", login, user_opt)
    }

    resource =
       (Parser.general_parser((http_request -> resource))) parser
       | "/new" -> function(_req){
           Resource.styled_page("New User",["/resources/style.css"],new())
       }
       | "/edit" -> function(_req){edit()}
       | "/view/" login = (.*) -> function(_req) { view(Text.to_string(login)) }
       | .* -> function(_req){start()}
}
