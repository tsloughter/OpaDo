/*
 * @author Ida Swarczewskaja
**/

package opado.ui

import stdlib.themes.bootstrap.core

/*module Desktop {
  custom_css = {
    custom_body: none,
    custom_headers: none,
    custom_css: ["/resources/bootstrap.min.css", "/resources/style.css"],
    custom_js: [],
  }
}

module IPhone {
  custom_css = {
    custom_body: none,
    custom_headers: none,
    custom_css: ["/resources/bootstrap.min.css", "/resources/style.css", "/resources/mobile.css"],
    custom_js: [],
  }
  custom_css_funs =  [ function(_){some(IPhone.custom_css)}]
}

custom_css_funs = [
    function(ua) {
    match( ua ){
    | { environment : { iPhone }, renderer:_ } : some(IPhone.custom_css)
    | _ :  some(Desktop.custom_css)
     }
    }
  ]
*/

function mypage(title,body){
 Resource.full_page(title, body,
                 <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                 <link href="/resources/bootstrap.min.css" rel="stylesheet" type="text/css"/>
                 <link href="/resources/style.css" rel="stylesheet" type="text/css"/>,
                 web_response {success},
                 Resource_private.default_customizers //++ custom_css_funs 
                 )
}
