module controllers

import vweb
import db.sqlite
import models

pub struct PredictionsController {
	vweb.Context
mut:
	db sqlite.DB [vweb_global]
}

['/'; get]
pub fn (mut app PredictionsController) index_action() vweb.Result {
	page_title := 'Predictions'

	found_preds := sql app.db {
		select from models.Prediction order by id desc
	} or { []models.Prediction{} }


	return app.html($tmpl('../templates/predictions/simple.html'))
}

['/add']
pub fn (mut app PredictionsController) add_action() vweb.Result {
	return app.html('<p>${@METHOD}</p>')
}

['/remove/:id']
pub fn (mut app PredictionsController) remove_action(id int) vweb.Result {
	dump(id)
	return app.html('<p>${@METHOD}</p>')
}
