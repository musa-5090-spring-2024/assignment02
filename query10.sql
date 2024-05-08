/*
You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.

*/

WITH census_blocks AS (
    SELECT
        geog,
        '1500000US' || geoid AS geoid
    FROM census.blockgroups_2020
),

census_blocks AS (
    SELECT
        pop.total AS pop,
        census_blocks.geog,
        split_part(pop.geoname, ',', 1) AS block_group,
        split_part(pop.geoname, ',', 2) AS tract,
        split_part(pop.geoname, ',', 3) AS county,
        split_part(pop.geoname, ',', 4) AS state
    FROM census_blocks
    LEFT JOIN census.population_2020 AS pop
        ON (census_blocks.geoid = pop.geoid)
),

rail_stops AS (
    SELECT
        stop_id,
        stop_name,
        geog
    FROM septa.rail_stops
),

nearby_population AS (
    -- Aggregating population within 400 meters
    SELECT
        rail_stops.stop_id,
        SUM(census_blocks.pop) AS population_within_400m
    FROM rail_stops
    JOIN census_blocks
        ON st_dwithin(rail_stops.geog, census_blocks.geog, 400)
    GROUP BY rail_stops.stop_id
)

-- Final query returning the stop name and population within 400 meters that enjoy the TOD benefits
SELECT
    rail_stops.stop_name,
    nearby_population.population_within_400m
FROM rail_stops
JOIN nearby_population
    ON rail_stops.stop_id = nearby_population.stop_id;
