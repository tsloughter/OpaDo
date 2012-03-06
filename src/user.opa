/*
 * USER.OPA
 *
 * @author Tristan Sloughter
 * @author Matthieu Guffroy
**/

package opado.user

import stdlib.crypto
import stdlib.web.client
import stdlib.core.web.core
import stdlib.widgets.core
import stdlib.widgets.loginbox
import stdlib.widgets.formbuilder
import stdlib.{themes.bootstrap, widgets.bootstrap}
import stdlib.apis.{facebook, facebook.auth, facebook.graph}

import opado.ui

// DATA

module OpaIntro1 {
  config =
    { app_id: ""
    , api_key: ""
    , app_secret: ""
    }
}

FBA = FbAuth(OpaIntro1.config)
FBG = FbGraph
redirect = "http://opado.org/connect"

abstract type User.password = string
abstract type User.ref = string

type User.t = { string username
              , string fullname
              , User.password password
              , bool is_oauth
              }

type User.status = {User.ref logged} or {unlogged}

type User.info = UserContext.t(User.status)
type User.map('a) = ordered_map(User.ref, 'a, String.order)

database User.map(User.t) /users
database /users[_]/is_oauth = false


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

    function create(username, password, is_oauth) {
        user_create(username, password, is_oauth);
        Client.goto("/login");
    }

    function user_create(username, password, is_oauth) {
        useref = User_data.mk_ref(username);
        user = User_data.get(useref);

        match (user) {
            case { none }:
              user =
                  (User.t) { username: useref
                           , fullname : ""
                           , password : Crypto.Hash.sha2(password)
                           , is_oauth : is_oauth };
              @/users[username] <- user
            default: void
        }
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

    function login(login, password) {
        useref = User_data.mk_ref(login);
        user = User_data.get(useref);
        match (user) {
          case { some : u }:
           if (u.is_oauth == false && u.password == Crypto.Hash.sha2(password)) {
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

    function footer() {
             <div class="footer">
                 <span>Implementation:
                 <a href="http://blog.erlware.org/2011/10/04/todomvc-in-opa/">Part 1</a> |
                 <a href="http://blog.erlware.org/2011/10/06/opado-data-storage/">Part 2</a> |
                 <a href="http://blog.erlware.org/2011/10/15/opado-personal-todo-lists/">Part 3</a> |
                 <a href="http://blog.erlware.org/2011/11/06/adding-js-to-all-opa-resources-use-case-google-analytics/">Google Analytics</a> |
                 <a href="http://blog.erlware.org/2011/11/06/major-opado-speed-up-with-publish/">Improving performance</a></span><br/>
                 <span>Fork on <a href="https://github.com/tsloughter/opado">GitHub</a></span> ·
                 <span>Built with <a href="http://opalang.org"><img src="/resources/opa-logo-small.png" alt="Opa"/></a></span>
              </>
    }

    function start() {
        if (User.is_logged()) {
            Resource.default_redirection_page("/todos")
        } else {
           login_url = FBA.user_login_url([], redirect);

            mypage("Login",
            <a href="http://github.com/tsloughter/opado" xmlns="http://www.w3.org/1999/xhtml">
            <img src="https://a248.e.akamai.net/assets.github.com/img/7afbc8b248c68eb468279e8c17986ad46549fb71/687474703a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67" alt="Fork me on GitHub" id="cfyzwpwbekcrcqccmvfnzflwwxddvqsz" style="position: absolute; top: 0em; right: 0em; border-top-width: 0em; border-right-width: 0em; border-bottom-width: 0em; border-left-width: 0em; border-style: initial; border-color: initial; border-image: initial; z-index:10001;"/>
            </a>
            <div class="topbar">
              <div class="container">
                <a class="brand" href="#"></a>
              </div>
            </div>
            <div class="container" id="todoapp">
                <div class="content">
                   <h1>Login</h1>
                   {loginbox()}
                   <div class="well">
                      <p class="pull-left">No account? <a href="/user/new"><strong>Sign Up</strong></a></p>
                      <a class="pull-right" href="{login_url}"><img src="/resources/fbconnect.png" /></a>
                   </div>
                </div>
                {footer()}
            </div>
            )
        }
    }

    function new(){
      login_url = FBA.user_login_url([], redirect);

      <a href="http://github.com/tsloughter/opado" xmlns="http://www.w3.org/1999/xhtml">
      <img src="https://a248.e.akamai.net/assets.github.com/img/7afbc8b248c68eb468279e8c17986ad46549fb71/687474703a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67" alt="Fork me on GitHub" id="cfyzwpwbekcrcqccmvfnzflwwxddvqsz" style="position: absolute; top: 0em; right: 0em; border-top-width: 0em; border-right-width: 0em; border-bottom-width: 0em; border-left-width: 0em; border-style: initial; border-color: initial; border-image: initial; z-index:10001;"/>
      </a>
      <div class="topbar">
         <div class="container">
            <a class="brand" href="#"></a>
         </div>
      </div>
      <div class="container" id="todoapp">
           <div class="content">
             <h1>Sign Up</h1>
             <form onsubmit={function(_){create(Dom.get_value(#username), Dom.get_value(#password), false)}}>
               <div id=#create_todo class="clearfix">
                 <input id=#username class="xlarge" placeholder="New Username..." type="text" />
               </div>

               <div id=#create_todo class="clearfix">
                 <input id=#password class="xlarge" placeholder="Password..." type="password" />
               </div>
               <button type=submit class="btn large" onclick={
                     function(_){
                         create(Dom.get_value(#username), Dom.get_value(#password), false);
                         login(Dom.get_value(#username), Dom.get_value(#password))
                     }}>Create</button>
             </form>
             <div class="well">
                  <p class="pull-left">Already user? <a href="/login"><strong>Login here</strong></a></p>
                  <a class="pull-right" href="{login_url}"><img src="/resources/fbconnect.png" /></a>
             </div>
           </div>
           {footer()}
       </>
    }

    function edit() {
        if(User.is_logged()) {
            mypage("User module",<><h1>Module User</h1>Under construction</>)
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
        ref = get_status();
        match (ref) {
        case { unlogged }:
             "error";
        case { logged : r }:
            user = Option.get(User_data.get(r));
            user.username
        }
    }

    function view(string login) {
        match (User_data.get(User_data.mk_ref(login))) {
        case { none }:
            mypage("User module", <h1>Module User</h1><>Error, the user {login} does'nt exist</>)
        case { some : _ }:
            mypage("User module", <h1>Module User</h1><>This the public profile of {login}, this page is under construction</>)
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
        config = {WLoginbox.default_config with
          stylers: {
            login_box: WStyler.empty,
            logged_box: WStyler.empty,
            unlogged_box: WStyler.empty,
            submit: {class:["btn large"]}
        }}
        WLoginbox.html(config,"login_box", login, user_opt)
    }

    function `<&>`(v, f) {
      match (v) {
        case {success: value}: f(value)
        case {failure: err}: {failure: err}
        }
    }

    function process(v) {
      match (v) {
        case {success: value}: value
        case {failure: err}: err
      }
    }

   function connect(data) {
      redirect_page = <></>
      response =
        match (WebUtils.web_response_of_code(200)) {
          case {some: code}: {success: code}
          default: {failure: Resource.default_redirection_page("/signup")}
        }

     function try_get_token(code) {
        match (FBA.get_token_raw(data, redirect)) {
          case {~token}: {success: ~{token, code}}
          default: {failure: Resource.redirection_page("Failed to Connect", redirect_page, code, 0, "/signup")}
        }
      }

      function try_get_name(~{token, code}) {
        match (get_name(token)) {
          case {some: name}: {success: ~{name, code}}
          default: {failure: Resource.redirection_page("Failed to Connect", redirect_page, code, 0, "/signup")}
        }
      }

      function try_check_user(~{name, code}) {
        useref = User_data.mk_ref(name);
        user = User_data.get(useref);

        match (user) {
          case {some: u}:
            if (u.is_oauth) {
              UserContext.change(function(_) {
                { logged : useref }
              }, state)

              {success: Resource.redirection_page("Successfully Connected", redirect_page, code, 0, "/todos")}
            } else {
              {failure: Resource.default_redirection_page("/signup")}
            }
          default:
            user_create(useref, "", true)
            UserContext.change(function(_) {
              { logged : useref }
            }, state)

            {success: Resource.redirection_page("Successfully Connected", redirect_page, code, 0, "/todos")}

       }
       }

     process(response <&> try_get_token <&> try_get_name <&> try_check_user)
   }
 
    function get_name(token) {
      opts = { FBG.Read.default_object with token:token.token }
      match (FBG.Read.object("me", opts)) {
        case {~object}:
          match (List.assoc("name", object.data)) {
            case {some: {String: v}}: some(v)
            default: none
          }
        default: none
      }
    }

    resource =
       (Parser.general_parser((http_request -> resource))) parser {
       | "/new" : function(_req) { mypage("New User",new()) }
       | "/edit" : function(_req) { edit() }
       | "/view/" login = (.*) : function(_req) { view(Text.to_string(login)) }
       | .* : function(_req) { start() }
       }
}

