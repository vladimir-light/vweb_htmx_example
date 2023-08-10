module main
import vweb
import os
import controllers
import db.sqlite



const (
	server_http_port  = 8081
	server_host       = 'localhost'
	assets_dir_name   = 'assets'
	assets_mount_path = os.join_path(@VMODROOT, 'src', assets_dir_name) // assets_mount_path == ./src/assets
	db_name = 'storage.db'
	db_file_path = os.join_path(@VMODROOT, 'data', db_name)
)

struct App {
	vweb.Context
	vweb.Controller
pub mut:
	db sqlite.DB [vweb_global]
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

fn db_conn(db_file string) !sqlite.DB {
	return sqlite.connect(db_file)!
}

fn new_app() &App {
	mut db := db_conn(db_file_path) or { panic(err) }
	db.synchronization_mode(sqlite.SyncMode.off) or { panic(err) }
	db.journal_mode(sqlite.JournalMode.memory) or { panic(err) }

	mut app := &App{
		db: db
		controllers: [
			vweb.controller('/greets', &controllers.GreetsController{db: db})
			vweb.controller('/ticks', &controllers.TicksController{db: db})
			vweb.controller('/predictions', &controllers.PredictionsController{db: db})
		]
	}
	// note: /assets/css and /assets/js as `mount_path` of mount_static_folder_at() must start with forward-slash (/)
	// all *.css in assets_mount_path/css -> /assets/css
	// all *.js in assets_mount_path/js -> /assets/js
	app.mount_static_folder_at(os.join_path(assets_mount_path, 'css'), '/assets/css')
	app.mount_static_folder_at(os.join_path(assets_mount_path, 'js'), '/assets/js')
	return app
}


['/'; get]
pub fn (mut app App) home_route() vweb.Result {
	page_title := 'Home, sweet home!'
	return app.html($tmpl('templates/index.html'))
}


/* ['/delayed']
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
} */
