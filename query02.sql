/* Which eight bus stops have the smallest population above 500 people inside of Philadelphia within 
800 meters of the stop (Philadelphia county block groups have a geoid prefix of 42101 
-- that's 42 for the state of PA, and 101 for Philadelphia county)?

The queries to #1 & #2 should generate results with a single row, with the following structure:

(
    stop_name text, -- The name of the station
    estimated_pop_800m integer, -- The population within 800 meters
    geog geography -- The geography of the bus stop
) */

SELECT * FROM septa.bus_stops;

SELECT * FROM census.blockgroups_2020;

WITH
septa_bus_stop_blockgroups AS (
    SELECT
        bus_stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS bus_stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON st_dwithin(bus_stops.geog, st_transform(bg.geog::geometry, 4326)::geography, 800)
),
septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        sum(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop USING (geoid)
    GROUP BY stops.stop_id
)
SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM septa_bus_stop_surrounding_population AS pop
INNER JOIN septa.bus_stops AS stops USING (stop_id)
WHERE pop.estimated_pop_800m > 500 
ORDER BY pop.estimated_pop_800m ASC
LIMIT 8;