DROP TABLE IF EXISTS df_users;

CREATE TABLE df_users (
	id INTEGER PRIMARY KEY, 
	first_name TEXT DEFAULT NULL, 
	last_name TEXT DEFAULT NULL, 
	pin TEXT default NULL
);