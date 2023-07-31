#!/usr/local/bin/v

// todo: fix src.models. v-analyzer removes `src.` prefix after each "format document"
import db.sqlite
import src.models
import rand

const (
	db_name      = 'storage.db'
	db_file_path = join_path(@VMODROOT, 'data', db_name)
)

fn init_predictions_no_orm(db sqlite.DB) ! {
	// still the quickes way to create table if not exists
	sql db {
		create table models.Prediction
	}!


	//1) check if there enough teams
	//2) check if there any existing predictions. if so, remove
	//3) create predictions with random teams

	//1)
	found_teams :=db.q_int("SELECT COUNT(*) FROM `teams`")
	if found_teams < 2
	{
		panic('Not enought teams...')
	}

	// 2) just delete everytime.
	db.exec_none('DELETE FROM `predictions`')

	//3) create
	// 3.1 - get list of all odd termas (randomly ordered)
	// 3.2 - get list of all even termas (randomly ordered)
	// 3.3 - create prediction with a odd and even teams-id


	// 3.1 and 3.2
	mut even_teams_ids, _ := db.exec('SELECT id FROM `teams` WHERE (id&1)=0 ORDER BY RANDOM()')
	mut odd_teams_ids, _ := db.exec('SELECT id FROM `teams` WHERE (id&1)<>0 ORDER BY RANDOM()')
	//
	for {
		if even_teams_ids.len < 1 || odd_teams_ids.len < 1 {
			// exit loop if there's no teams to process
			break
		}

		even_team := even_teams_ids.pop()
		home_team_id := even_team.vals[0].int()
		odd_team := odd_teams_ids.pop()
		away_team_id := odd_team.vals[0].int()

		// quick and dirty..but also risky. no escaping, no pram/value binding... feels wrong!
		_ := db.exec_none("INSERT INTO `predictions` (`home_team_id`, `away_team_id`, `home_goals`, `away_goals`) VALUES(${home_team_id}, ${away_team_id}, ${rand.u8()}, ${rand.u8()})")
	}
}

fn init_predictions_simplified(db sqlite.DB) ! {
	// Simplified version of init_predictions
	// We create only one prediction with specific team-ids

	sql db {
		create table models.Prediction
	}!

	// if there's no teams -> abbort!
	found_teams := db.q_int('SELECT COUNT(*) FROM `teams`')
	if found_teams < 2 {
		return error('not enough teams')
	}

	// remove all exsiting predictions
	existing_preds := sql db {
		select count from models.Prediction
	} or { 0 }

	if existing_preds > 0 {
		db.exec_none('DELETE FROM `predictions`')
	}

	// first Team
	home_team := sql db {
		select from models.Team where id == 2
	}!
	// second Team
	away_team	 := sql db {
		select from models.Team where id == 7
	}!

	//dump(home_team.first())
	//dump(away_team.first())

	// new Prediction with two Teams from obove and a random number for goals
	new_pred := models.Prediction{
		home_team: home_team.first()
		away_team: away_team.first()
		home_goals: rand.u8()
		away_goals: rand.u8()
	}

	// expected query here is `insert into "predictions" (id, home_team_id, away_team_id, home_goals, away_goals, created_at, updated_at) VALUES ( ... )`
	// but instead an `insert into "teams"` triggered...
	sql db {
		insert new_pred into models.Prediction
	}!
}

fn init_predictions(db sqlite.DB) ! {
	sql db {
		create table models.Prediction
	}!

	// if there's no teams -> abbort!
	found_teams := db.q_int('SELECT COUNT(*) FROM `teams`')
	if found_teams < 2 {
		return error('not enough teams')
	}

	// remove all exsiting predictions
	existing_preds := sql db {
		select count from models.Prediction
	} or { 0 }

	if existing_preds > 0 {
		db.exec_none('DELETE FROM `predictions`')
	}

	// so there are 14 teams and we want to create 7 random predicitons. In order to do that, we take all even and all odd teams randomly ordered and use them.
	// WHERE (id&1)=0 ORDER BY RAND helps to select only even teams.
	// unfortunately (id&1)= isn't possible with current state of ORM
	// odd_teams := sql db { select from Team where (id&1) == 0 order by name }!
	mut even_teams_ids, _ := db.exec('SELECT id FROM `teams` WHERE (id&1)=0 ORDER BY RANDOM()')
	mut odd_teams_ids, _ := db.exec('SELECT id FROM `teams` WHERE (id&1)<>0 ORDER BY RANDOM()')


	for {
		if even_teams_ids.len < 1 || odd_teams_ids.len < 1 {
			break
		}

		// get IDs to make a SELECT with ORM in order to get
		// first id of even teams
		h_team_row := even_teams_ids.pop()
		h_team_id := h_team_row.vals[0].int()

		// first ID of odd teams
		a_team_row := odd_teams_ids.pop()
		a_team_id := a_team_row.vals[0].int()

		home_team := sql db {
			select from models.Team where id == h_team_id limit 1
		}!

		away_team := sql db {
			select from models.Team where id == a_team_id limit 1
		}!

		dump(home_team.first())
		dump(away_team.first())

		new_pred := models.Prediction{
			home_team: home_team.first()
			away_team: away_team.first()
			home_goals: rand.u8()
			away_goals: rand.u8()
		}

		sql db {
			insert new_pred into models.Prediction
		}!
	}
}

fn init_teams(db sqlite.DB) ! {
	sql db {
		create table models.Team
	}!

	found_teams := sql db {
		select count from models.Team
	}!

	if found_teams > 0 {
		// sql db { delete from models.Team where id > 0}! // feels kinda hacky. just `delete from models.Team` doesn't work
		db.exec_none('DELETE FROM `teams`')
	}

	// FC team-name
	new_teams := [
		'Arsenal',
		'Chelsea',
		'Liverpool',
		'Manchester City',
		'Manchester United',
		'Tottenham Hotspur',
		'Real Madrid',
		'Barcelona',
		'Juventus',
		'Inter Milan',
		'Beyern Munich',
		'Ajax',
		'PSG',
		'Porto',
	]

	for _, team_name in new_teams {
		team := models.Team{
			name: team_name
		}
		sql db {
			insert team into models.Team
		}!
	}
}

mut db := sqlite.connect(db_file_path) or { panic(err) }

init_teams(db) or { panic(err) } // works as expected
init_predictions_no_orm(db) or { panic(err) } // works... but feels kinda wrong
// init_predictions_simplified(db) or { panic(err) } // fails... simple version with only one Predictions
//init_predictions(db) or { panic(err) } // fails ... original version with a loop for all Teams
