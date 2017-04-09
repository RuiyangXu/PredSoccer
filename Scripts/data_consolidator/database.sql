-------------------------------------------
-- Database Schema
-- Group: Kishan KC, Danielle Gonzallez, Joanna Santos, Ruyiang
-------------------------------------------

CREATE TABLE "Team"(
	 	id 	INTEGER PRIMARY KEY,
		country VARCHAR(50)	NOT NULL,	
);

CREATE TABLE "MatchLocation"(
		id INTEGER PRIMARY KEY,
		name VARCHAR(100) NOT NULL,
		latitude DOUBLE PRECISION,
		longitude DOUBLE PRECISION
);


CREATE TABLE "Player"(
		id INTEGER PRIMARY KEY,
-- 		position VARCHAR(20),
		name VARCHAR(50) NOT NULL
);


-- CREATE TYPE match_type_enum as ENUM ('friendly', 'group', 'quarter', 'final','semi','qualifiers');
CREATE TABLE "Match"(
		id INTEGER PRIMARY KEY,
		home_team_id		INTEGER REFERENCES "Team"(id) NOT NULL,
		away_team_id		INTEGER REFERENCES "Team"(id) NOT NULL,
		match_date 			DATE  NOT NULL,
		location_id  		INTEGER REFERENCES "MatchLocation"(id),
--		match_type 			match_type_enum,
		competition  		VARCHAR(80),
		winning_team_id  	INTEGER REFERENCES "Team"(id),
		home_team_score  	INTEGER NOT NULL,
		away_team_score  	INTEGER NOT NULL
);








CREATE TABLE "PlayerRating"(
		player_id INTEGER REFERENCES "Player"(id) NOT NULL,
		year INTEGER NOT NULL,
		position INTEGER,
		rating INTEGER,
		pace INTEGER,
		shoot INTEGER,
		pass INTEGER,
		dribble INTEGER,
		defend INTEGER,
		physical INTEGER,
		PRIMARY KEY(player_id,year)
);




CREATE TABLE "MatchPlayerRelation"(
		player_id INTEGER REFERENCES "Player"(id),
		match_id INTEGER REFERENCES "Match"(id),
		is_substitute BOOLEAN,
		num_goals INTEGER, 
		team_id INTEGER REFERENCES "Team"(id),
		PRIMARY KEY (player_id,match_id)

);


CREATE TABLE "Squad"(
		player_id INTEGER REFERENCES "Player"(id),
		team_id INTEGER REFERENCES "Team"(id),
		num_goals INTEGER, 
		PRIMARY KEY (player_id,team_id)
);

-- This function computes the total wons,losses and draws of a pair of  teams (home and away)
CREATE OR REPLACE FUNCTION team_statistics(home_team_id INTEGER, away_team_id INTEGER) 
RETURNS TABLE(home_team_wons BIGINT, home_team_draws BIGINT, home_team_loss BIGINT,away_team_wons BIGINT, away_team_draws BIGINT, away_team_loss BIGINT) AS $$
BEGIN
RETURN QUERY 
	SELECT
    	(SELECT COUNT(*) FROM "Match" WHERE 
        ("Match".home_team_id = $1 AND "Match".home_team_score > "Match".away_team_score) OR 
        ("Match".away_team_id = $1 AND "Match".away_team_score > "Match".home_team_score)) AS home_team_wons,
        (SELECT COUNT(*) FROM "Match" WHERE 
        ("Match".home_team_id = $1 AND "Match".home_team_score = "Match".away_team_score) OR 
        ("Match".away_team_id = $1 AND "Match".away_team_score = "Match".home_team_score)) AS home_team_draws,
        (SELECT COUNT(*) FROM "Match" WHERE 
        ("Match".home_team_id = $1 AND "Match".home_team_score < "Match".away_team_score) OR 
        ("Match".away_team_id = $1 AND "Match".away_team_score < "Match".home_team_score)) AS home_team_loss,
        (SELECT COUNT(*) FROM "Match" WHERE 
        ("Match".home_team_id = $2 AND "Match".home_team_score > "Match".away_team_score) OR 
        ("Match".away_team_id = $2 AND "Match".away_team_score > "Match".home_team_score)) AS away_team_wons,
        (SELECT COUNT(*) FROM "Match" WHERE 
        ("Match".home_team_id = $2 AND "Match".home_team_score = "Match".away_team_score) OR 
        ("Match".away_team_id = $2 AND "Match".away_team_score = "Match".home_team_score)) AS away_team_draws,
        (SELECT COUNT(*) FROM "Match" WHERE 
        ("Match".home_team_id = $2 AND "Match".home_team_score < "Match".away_team_score) OR 
        ("Match".away_team_id = $2 AND "Match".away_team_score < "Match".home_team_score)) AS away_team_loss
    ;
END; $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION team_statistics(home_team_id INTEGER, away_team_id INTEGER) 
RETURNS TABLE(home_team_wons TEXT, away_team_wons TEXT) AS $$
DECLARE
	teamATotalMatches DOUBLE PRECISION;
	teamBTotalMatches DOUBLE PRECISION;
BEGIN
	SELECT COUNT(*) INTO teamATotalMatches FROM "Match" WHERE "Match".home_team_id = $1 OR "Match".away_team_id = $1;
	SELECT COUNT(*) INTO teamBTotalMatches FROM "Match" WHERE "Match".home_team_id = $2 OR "Match".away_team_id = $2;
RETURN QUERY 
	SELECT
    	(SELECT TO_CHAR(COUNT(*)/teamATotalMatches,'0.99') FROM "Match" WHERE 
        ("Match".home_team_id = $1 AND "Match".home_team_score > "Match".away_team_score) OR 
        ("Match".away_team_id = $1 AND "Match".away_team_score > "Match".home_team_score)) AS home_team_wons,
        (SELECT TO_CHAR(COUNT(*)/teamBTotalMatches,'0.99') FROM "Match" WHERE 
        ("Match".home_team_id = $2 AND "Match".home_team_score > "Match".away_team_score) OR 
        ("Match".away_team_id = $2 AND "Match".away_team_score > "Match".home_team_score)) AS away_team_wons
    ;
END; $$ LANGUAGE plpgsql;




--- The code below is from removed tables:
-- CREATE TABLE "Tournament"(
-- 		id INTEGER PRIMARY KEY,
-- 		name VARCHAR(100),
--     	location VARCHAR(100)
-- );

-- CREATE TABLE "Coach"(
-- 		id INTEGER PRIMARY KEY,
-- 		name VARCHAR(50)
-- );

-- CREATE TABLE "Weather"(
-- 		id INTEGER PRIMARY KEY,
-- 		temperature	FLOAT NOT NULL,
-- 		pressure FLOAT NOT NULL,
-- 	 	humidty  FLOAT NOT NULL,
-- 		windspeed  FLOAT NOT NULL
-- );