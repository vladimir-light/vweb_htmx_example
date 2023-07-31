module controllers
import vweb
import rand
import db.sqlite

pub struct GreetsController {
	vweb.Context
mut:
	db sqlite.DB [vweb_global]
}

['/']
pub fn (mut app GreetsController) index_action() vweb.Result {
	dump('Hello from ${@FN}')
	// all this constants can be accessed by src/templates/page/home.html file.
	page_title := 'HTMX with vweb Example'

	return app.html($tmpl('../templates/greets/index.html'))
}

['/random']
pub fn (mut app GreetsController) random_action() vweb.Result {
	dump('Hello from ${@FN}')
	// all this constants can be accessed by src/templates/page/home.html file.
	page_title := 'HTMX with vweb Example'

	greets := [
		'Hail and well met, weary traveler! I am Roderick Ironhelm, a mighty dwarven warrior, ready to cleave through any obstacle in our path!',
		'Greetings, mortal! I am Seraphina, a celestial being tasked with preserving the balance between light and darkness. May your days be filled with radiant joy!',
		'Salutations, good sir! I am Zephyrus Stormwind, an elven bard renowned for my enchanting melodies and captivating tales. May the winds carry you to new adventures!',
		'Ahoy there, matey! I be Captain Blackbeard, a feared pirate of the high seas. May ye find treasures aplenty and the wind forever at yer back!',
		'Greetings, kindred spirit! I am Luna Moonshadow, a mysterious tiefling sorceress who harnesses the powers of the arcane. May the stars guide you on your journey!',
	]

	random_greeting := rand.element(greets) or { return app.server_error(502) }

	return app.html($tmpl('../templates/greets/random.html'))
}
