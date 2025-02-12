-- Add UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set timezone
-- For more information, please visit:
-- https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
-- Vietnam timezone: "Asia/Ho_Chi_Minh"
SET TIMEZONE="Asia/Ho_Chi_Minh";

-- Create users table
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4 () PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW (),
    updated_at TIMESTAMP NULL,
    email VARCHAR (255) NOT NULL UNIQUE,
    password_hash VARCHAR (255) NOT NULL,
    user_status INT NOT NULL,
    user_role VARCHAR (25) NOT NULL,
    register_type VARCHAR (25) NOT NULL
);

-- Add indexes
CREATE INDEX active_users ON users (id) WHERE user_status = 1;
