

CREATE TABLE IF NOT EXISTS account (
  account_id SERIAL PRIMARY KEY,
  account_name TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO account
  (account_name)
VALUES
  ( 'test 1' ),
  ( 'test 2' );