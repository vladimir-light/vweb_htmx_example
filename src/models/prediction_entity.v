module models
import time

[table: 'predictions']
pub struct Prediction {
	id         int       [primary; sql: serial]
	home_team  Team      [fkey: 'id'; nonull; sql_type: 'INTEGER'; unique: 'teams']
	away_team  Team      [fkey: 'id'; nonull; sql_type: 'INTEGER'; unique: 'teams']
	home_goals u8        [default: '0'; nonull; sql_type: 'INTEGER']
	away_goals u8        [default: '0'; nonull; sql_type: 'INTEGER']
	created_at time.Time [default: 'CURRENT_TIMESTAMP'; sql_type: 'DATETIME']
	updated_at time.Time [default: 'CURRENT_TIMESTAMP'; sql_type: 'DATETIME']
}


pub fn (this Prediction) home_team_name() string {
	//return this.home_team.name or { '-unknown-home-team-' }
	return this.home_team.name
}

pub fn (this Prediction) away_team_name() string {
	//return this.away_team.name or { '-unknown-away-team-' }
	return this.away_team.name
}
