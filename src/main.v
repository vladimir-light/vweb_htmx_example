module main

import vweb
import os
import time
import rand
import controllers
// import db.sqlite
// import config

const (
	server_http_port  = 8081
	server_host       = 'localhost'
	assets_dir_name   = 'assets'
	assets_mount_path = os.join_path(os.resource_abs_path('.'), 'src', assets_dir_name) // assets_mount_path == ./src/assets
)

struct App {
	vweb.Context
	vweb.Controller
}

struct Object {
	title       string
	description string
}

fn main() {
	vweb.run_at(new_app(), vweb.RunParams{
		host: server_host
		port: server_http_port
		family: .ip
	}) or { panic(err) }
}

fn new_app() &App {
	mut app := &App{
		controllers: [
			vweb.controller('/t', &controllers.TicksController{}),
		]
	}
	// note: /assets/css and /assets/js as `mount_path` of mount_static_folder_at() must start with forward-slash (/)
	// all *.css in assets_mount_path/css -> /assets/css
	// all *.js in assets_mount_path/js -> /assets/js
	app.mount_static_folder_at(os.join_path(assets_mount_path, 'css'), '/assets/css')
	app.mount_static_folder_at(os.join_path(assets_mount_path, 'js'), '/assets/js')
	return app
}

['/']
pub fn (mut app App) index() vweb.Result {
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



['/delayed']
pub fn (mut app App) delayed_action() vweb.Result {
	time.sleep(5 * time.second)

	return app.html($tmpl('templates/_fragments/button.html'))
}

['/greet'; post]
pub fn (mut app App) greet_handler() vweb.Result {
	greets := [
		'Hail and well met, weary traveler! I am Roderick Ironhelm, a mighty dwarven warrior, ready to cleave through any obstacle in our path!',
		'Greetings, mortal! I am Seraphina, a celestial being tasked with preserving the balance between light and darkness. May your days be filled with radiant joy!',
		'Salutations, good sir! I am Zephyrus Stormwind, an elven bard renowned for my enchanting melodies and captivating tales. May the winds carry you to new adventures!',
		'Ahoy there, matey! I be Captain Blackbeard, a feared pirate of the high seas. May ye find treasures aplenty and the wind forever at yer back!',
		'Greetings, kindred spirit! I am Luna Moonshadow, a mysterious tiefling sorceress who harnesses the powers of the arcane. May the stars guide you on your journey!',
	]

	tpl_greet := rand.element(greets) or { return app.server_error(502) }

	return app.html($tmpl('templates/_fragments/greetings.html'))
}
