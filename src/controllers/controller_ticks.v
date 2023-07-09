module controllers

import vweb
import os
import time


pub struct TicksController {
	vweb.Context
}

const (
	root_dir = os.join_path(os.resource_abs_path('.'), 'src')
	templates_dir = os.join_path(root_dir, 'templates')
)


['/'; get]
pub fn (mut app TicksController) index_action() vweb.Result {
	dump('Hello from ${@FN}')
	ctx_time := time.now().format_ss()
	page_greetings :='Hello from ${@FN}'
	//page_title := 'ticks->index_action()'

	return app.html($tmpl('../templates/ticks/index.html'))
}
['/:name'; get]
pub fn (mut app TicksController) name_action(name string) vweb.Result {
	dump('Hello from ${@FN}')
	dump('Hello, ${name}! Nice to see you')

	return app.html('<h1>Hello, ${name}</h1>')
}
