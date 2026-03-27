CREATE TABLE apns (
  apn_id bigint unsigned NOT NULL AUTO_INCREMENT,
  user_id bigint unsigned NOT NULL,
  creation datetime NOT NULL DEFAULT NOW(),
  prod bool NOT NULL DEFAULT 1,
  token text NOT NULL,
  CONSTRAINT apn_id PRIMARY KEY (apn_id)
);

CREATE TABLE credentials (
  credential_id bigint unsigned NOT NULL AUTO_INCREMENT,
  user_id bigint unsigned NOT NULL,
  name text NOT NULL DEFAULT Default,
  passkey blob NOT NULL,
  passkey_id text NOT NULL,
  counter bigint unsigned NOT NULL DEFAULT 0,
  CONSTRAINT credential_id PRIMARY KEY (credential_id)
);

CREATE TABLE game_states (
  game_state_id bigint unsigned NOT NULL AUTO_INCREMENT,
  game_id bigint unsigned NOT NULL,
  deck_id tinyint unsigned NOT NULL DEFAULT 0,
  deck blob,
  current_hider bigint unsigned,
  CONSTRAINT game_state_id PRIMARY KEY (game_state_id)
);

CREATE TABLE games (
  game_id bigint unsigned NOT NULL AUTO_INCREMENT,
  user_id bigint unsigned NOT NULL COMMENT 'For Leader',
  name text,
  location char(3) NOT NULL DEFAULT NYC COMMENT '3-letter location code if using a pre-defined zone, else XXX',
  map_size bit(2) DEFAULT 10 COMMENT '00, 01, 10 for the three sizes',
  time_zone bit(5) COMMENT 'Bit 1: 0 -, 1 +\nBits 2-5: Binary UTC offset\n',
  start date NOT NULL DEFAULT NOW(),
  end date NOT NULL DEFAULT NOW(),
  rest_start tinyint unsigned NOT NULL DEFAULT 21 COMMENT 'Hour to start rest period',
  rest_end tinyint unsigned DEFAULT 9 COMMENT 'Hour to end rest period',
  deck_id tinyint NOT NULL DEFAULT 0,
  deck blob,
  team_id bigint unsigned COMMENT 'Current runner',
  CONSTRAINT game_id PRIMARY KEY (game_id)
);

CREATE TABLE played_games (
  played_game_id bigint unsigned NOT NULL AUTO_INCREMENT,
  user_id bigint unsigned NOT NULL,
  name text,
  location char(3) NOT NULL DEFAULT NYC COMMENT '3-digit location code if predefined, else XXX',
  map_size bit(2) DEFAULT 10 COMMENT '00, 01, 10 for map sizes',
  time_zone bit(5) NOT NULL DEFAULT 00100 COMMENT 'Bit 1: 0 -, 1 +\nBits 2-5: Binary UTC offset\n',
  start date NOT NULL DEFAULT NOW(),
  end date NOT NULL DEFAULT NOW(),
  rest_start tinyint unsigned NOT NULL DEFAULT 21,
  rest_end tinyint unsigned NOT NULL DEFAULT 9,
  deck_id tinyint NOT NULL DEFAULT 0,
  user_team_id bigint unsigned NOT NULL,
  team_data blob COMMENT 'All team names, member names, scores at end of game',
  round_data blob COMMENT 'start, end times & scores. which teams round and team that defeated. all messages and timestamps.',
  CONSTRAINT played_game_id PRIMARY KEY (played_game_id)
);

CREATE TABLE round_events (
  round_event_id bigint unsigned NOT NULL AUTO_INCREMENT,
  team_id bigint unsigned NOT NULL COMMENT 'Sending team',
  user_id bigint unsigned NOT NULL COMMENT 'Sending user',
  round_log_id bigint unsigned NOT NULL,
  date datetime,
  reply_id bigint unsigned COMMENT 'ID of other round_event if this is a response (i.e., responding to question)',
  card_id tinyint unsigned COMMENT 'Card IDs are per-deck',
  image text COMMENT 'File name of image associated with message.',
  message text COMMENT 'Message text, if the response requires',
  CONSTRAINT round_event_id PRIMARY KEY (round_event_id)
);

CREATE TABLE round_logs (
  round_log_id bigint unsigned NOT NULL AUTO_INCREMENT,
  round_id bigint unsigned NOT NULL,
  closed bool NOT NULL DEFAULT false COMMENT 'Set to true when the round is over and the log should be closed.',
  CONSTRAINT round_log_id PRIMARY KEY (round_log_id)
);

CREATE TABLE rounds (
  round_id bigint unsigned NOT NULL AUTO_INCREMENT,
  game_id bigint unsigned NOT NULL,
  team_id bigint unsigned NOT NULL COMMENT 'Current runner',
  start datetime NOT NULL DEFAULT NOW(),
  start_score mediumint unsigned NOT NULL DEFAULT 0,
  end datetime,
  end_score mediumint unsigned,
  defeated_by bigint unsigned,
  sealed_log blob COMMENT 'Write a compressed version of the event log here. Should probably offload but will deal with that later.',
  CONSTRAINT round_id PRIMARY KEY (round_id)
);

CREATE TABLE teams (
  team_id bigint unsigned NOT NULL AUTO_INCREMENT,
  game_id bigint unsigned NOT NULL,
  name text NOT NULL DEFAULT Default,
  score mediumint unsigned NOT NULL DEFAULT 0,
  hand blob,
  questions blob,
  map blob,
  modifiers blob,
  CONSTRAINT team_id PRIMARY KEY (team_id)
);

CREATE TABLE users (
  user_id bigint unsigned NOT NULL AUTO_INCREMENT,
  username text NOT NULL,
  email text NOT NULL DEFAULT unknown,
  hash text NOT NULL,
  challenge text,
  created datetime NOT NULL,
  last_login datetime NOT NULL,
  flags integer unsigned NOT NULL DEFAULT 0,
  game_id bigint unsigned,
  team_id bigint unsigned,
  CONSTRAINT user_id PRIMARY KEY (user_id)
);

ALTER TABLE apns ADD CONSTRAINT fk_apns_user
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE credentials ADD CONSTRAINT fk_credentials_user
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE game_states ADD CONSTRAINT fk_game_states_
  FOREIGN KEY (game_id) REFERENCES games (game_id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE game_states ADD CONSTRAINT fk_game_states_hider
  FOREIGN KEY (current_hider) REFERENCES teams (team_id) ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE games ADD CONSTRAINT fk_games_user
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE played_games ADD CONSTRAINT fk_played_games_
  FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE round_events ADD CONSTRAINT fk_round_events_round_log
  FOREIGN KEY (round_log_id) REFERENCES round_logs (round_log_id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE round_logs ADD CONSTRAINT fk_round_logs_round
  FOREIGN KEY (round_id) REFERENCES rounds (round_id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE rounds ADD CONSTRAINT fk_rounds_game
  FOREIGN KEY (game_id) REFERENCES games (game_id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE teams ADD CONSTRAINT fk_teams_game
  FOREIGN KEY (game_id) REFERENCES games (game_id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE users ADD CONSTRAINT fk_users_game
  FOREIGN KEY (game_id) REFERENCES games (game_id) ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE users ADD CONSTRAINT fk_users_team
  FOREIGN KEY (team_id) REFERENCES teams (team_id) ON DELETE SET NULL ON UPDATE NO ACTION;

