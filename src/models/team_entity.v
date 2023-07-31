module models

import time

[table: 'teams']
pub struct Team {
	id         int       [primary; sql: serial]
	name       string    [nonull; required]
	created_at time.Time [default: 'CURRENT_TIMESTAMP'; sql_type: 'DATETIME']
	updated_at time.Time [default: 'CURRENT_TIMESTAMP'; sql_type: 'DATETIME']
}
