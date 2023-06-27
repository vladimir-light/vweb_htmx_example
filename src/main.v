module main

import vweb
import os

const (
	assets_dir_name   = 'assets'
	assets_mount_path = os.join_path(os.resource_abs_path('.'), 'src', assets_dir_name) // assets_mount_path == ./src/assets
)

struct App {
	vweb.Context
}

struct Object {
	title       string
	description string
}

fn main() {
	vweb.run_at(new_app(), vweb.RunParams{
		port: 8081
	}) or { panic(err) }
}

fn new_app() &App {
	mut app := &App{}
	// note: /assets/css and /assets/js as `mount_path` of mount_static_folder_at() must start with forward-slash (/)
	// all *.css in assets_mount_path/css -> /assets/css
	// all *.js in assets_mount_path/css -> /assets/css
	app.mount_static_folder_at(os.join_path(assets_mount_path, 'css'), '/assets/css')
	app.mount_static_folder_at(os.join_path(assets_mount_path, 'js'), '/assets/js')
	return app
}

['/']
pub fn (mut app App) page_home() vweb.Result {
	// all this constants can be accessed by src/templates/page/home.html file.
	page_title := 'HTMX with vweb Example'
	v_url := 'https://github.com/vlang/v'

	list_of_object := [
		Object{
			title: 'One good title'
			description: 'this is the first'
		},
		Object{
			title: 'Other good title'
			description: 'more one'
		},
	]
	// $vweb.html() in `<folder>_<name> vweb.Result ()` like this
	// render the `<name>.html` in folder `./templates/<folder>`
	return $vweb.html()
}
