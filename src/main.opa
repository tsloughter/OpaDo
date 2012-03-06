package opado.main

import opado.user
import opado.admin
import opado.todo

function with_request(f){
  f(ThreadContext.get({current}).request ? error("no request"))
}

urls = parser {
    {Rule.debug_parse_string((function(s){Log.notice("URL", s)}))}
       Rule.fail -> error("")
    | "/todos?" result={Todo.resource} : with_request(result)
    | "/connect?" data=(.*)            : User.connect(Text.to_string(data)) 
    | "/user"  result={User.resource}  : with_request(result)
    | "/login" result={User.resource}  : with_request(result)
    | "/admin" result={Admin.resource} : with_request(result)
    | (.*)     result={Todo.resource}  : with_request(result)
    }

Server.start(Server.http,
        [{resources:@static_resource_directory("resources")},
         {register:["/resources/js/google_analytics.js"]},
         {custom:urls}]
)


