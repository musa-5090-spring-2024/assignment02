-- Active: 1708533345757@@127.0.0.1@5432@alyssafelix
/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/

CREATE TABLE septa.bus_stops (
            stop_id TEXT,
            stop_name TEXT,
            stop_lat DOUBLE PRECISION,
            stop_lon DOUBLE PRECISION,
            location_type TEXT,
            parent_station TEXT,
            zone_id TEXT,
            wheelchair_boarding INTEGER
        );
CREATE TABLE censusblock2020 (
    geoid VARCHAR(15) PRIMARY KEY,
    population INTEGER
);


    WITH septabus_censusblocks AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM
        septa.bus_stops AS stops
    INNER JOIN
        censusblock2020 AS bg
    ON
        ST_DWithin(stops.geog, bg.geog, 800)
), 
septabus_pop AS (
    SELECT
        stops.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM
        septabus_censusblocks AS stops
    INNER JOIN
        censusblock2020 AS pop USING (geoid)
    GROUP BY
        stops.stop_id
)

SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM
    septabus_pop AS pop
INNER JOIN
    septa.bus_stops AS stops USING (stop_id)
ORDER BY
    pop.estimated_pop_800m DESC
LIMIT 8;