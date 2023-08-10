#!/usr/local/bin/v

// todo: fix src.models. v-analyzer removes `src.` prefix after each "format document"
import db.sqlite
import src.models
import rand

const (
	db_name      = 'storage.db'
	db_file_path = join_path(@VMODROOT, 'data', db_name)
)



fn init_tables(db sqlite.DB) ! {
	sql db {
			create table models.Team
			create table models.Prediction
		}!
}

fn init_predictions(db sqlite.DB) ! {
	//1) check if there enough teams
	//2) check if there any existing predictions. if so, remove
	//3) create predictions with random teams

	//1)
	found_teams := db.q_int("SELECT COUNT(*) FROM `teams`")!
	if found_teams < 2
	{
		panic('Not enought teams...')
	}

	// 2) just delete everytime.
	_ := db.exec_none('DELETE FROM `predictions`')

	//3) create
	// 3.1 - get list of all odd teams (randomly ordered)
	// 3.2 - get list of all even teams (randomly ordered)
	// 3.3 - create prediction with a odd and even teams-id


	// 3.1 and 3.2
	mut even_teams_ids:= db.exec('SELECT id FROM `teams` WHERE (id&1)=0 ORDER BY RANDOM()')!
	mut odd_teams_ids:= db.exec('SELECT id FROM `teams` WHERE (id&1)<>0 ORDER BY RANDOM()')!
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

		_ := db.exec_param_many("INSERT INTO `predictions` (`home_team_id`, `away_team_id`, `home_goals`, `away_goals`) VALUES(?, ?, ?, ?)", [
			home_team_id.str(),
			away_team_id.str(),
			rand.u8().str(),
			rand.u8().str()
		])!
	}
}

fn init_teams(db sqlite.DB) ! {
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

init_tables(db) or { panic(err) }
init_teams(db) or { panic(err) } // works as expected
init_predictions(db) or { panic(err) } // works... but feels kinda wrong
