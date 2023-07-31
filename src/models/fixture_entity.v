module models

import time

[table: 'fixtures']
pub struct Fixture {
	id         int       [primary; sql: serial]
	home_team  Team      [fkey: 'id'; nonull; sql: 'home_team'; sql_type: 'INTEGER']
	away_team  Team      [fkey: 'id'; nonull; sql: 'away_team'; sql_type: 'INTEGER']
	home_goals u8        [default: '0'; nonull; sql_type: 'INTEGER']
	away_goals u8        [default: '0'; nonull; sql_type: 'INTEGER']
	created_at time.Time [default: 'CURRENT_TIMESTAMP'; sql_type: 'DATETIME']
	updated_at time.Time [default: 'CURRENT_TIMESTAMP'; sql_type: 'DATETIME']
}
