## Create database and table
#DROP DATABASE IF EXISTS test;
#CREATE DATABASE test;
#USE test;
USE defaultdb;
CREATE TABLE IF NOT EXISTS hpi (
    hpi_type VARCHAR(100),
    hpi_flavor VARCHAR(100),
    frequency VARCHAR(100),
    level VARCHAR(100),
    place_name VARCHAR(100),
    place_id VARCHAR(100),
    yr VARCHAR(4),
    quarter_period VARCHAR(4),
    index_nsa REAL,
    index_sa REAL
        );
DESC hpi;
SELECT * FROM hpi;
SELECT COUNT(*) FROM hpi;
TRUNCATE TABLE hpi;
