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


['/']
pub fn (mut app TicksController) index_action() vweb.Result {
	dump(@FN)
	dump('${templates_dir}/ticks/index.html')
	page_greetings :='Hello from ${@FN}'

	return app.html($tmpl('../templates/ticks/index.html'))
}

['/ticks'; get]
pub fn (mut app TicksController) ticks_action() vweb.Result {
	dump(@FN)
	dump(os.resource_abs_path('.'))

	ctx_time := time.now().format_ss()
	page_greetings :='Hello from ${@FN}'

	//return app.html('<p>hello from ticks controller</p>')
	return app.html($tmpl('../templates/ticks/ticks.html'))
}
