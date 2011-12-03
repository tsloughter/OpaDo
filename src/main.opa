package opado.main

import opado.user
import opado.admin
import opado.todo

Parser.general_parser((http_request -> resource)) urls =
    parser
    {Rule.debug_parse_string((function(s){Log.notice("URL", s)}))}
       Rule.fail -> error("")
    | "/todos" result={Todo.resource}  -> result
    | "/user"  result={User.resource}  -> result
    | "/login" result={User.resource}  -> result
    | "/admin" result={Admin.resource} -> result
    | (.*)     result={Todo.resource}  -> result

Resource.register_external_js("/resources/js/google_analytics.js");

`server` = Server.of_bundle([@static_resource_directory("resources")])
`server` = Server.make(urls)

/* Server.start(Server.http,
        [{custom:urls},{bundle:@static_resource_directory("resources")}]
) */
