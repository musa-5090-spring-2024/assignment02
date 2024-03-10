-- Which eight bus stops have the smallest population above 500 people inside of Philadelphia within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of 42101 -- that's 42 for the state of PA, and 101 for Philadelphia county)?

WITH

-- select philly blockgroup
philly_blockgroup AS (
    SELECT *
    FROM census.blockgroups_2020
    WHERE geoid LIKE '42101%'
),

-- join philly blockgroup and bus stops, 800 meters
septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS stops
    INNER JOIN philly_blockgroup AS bg
        ON st_dwithin(stops.geog, bg.geog, 800)
),

-- get population
septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        cast(sum(pop.total) AS INTEGER) AS estimated_pop_800m
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
ORDER BY pop.estimated_pop_800m
LIMIT 8


-- WITH
-- bg_w_pop AS (

--     SELECT
--         pop.total,
--         bg.geog,
--         SUBSTRING(pop.geoid, 10) AS geoid
--     FROM census.population_2020 AS pop
--     INNER JOIN census.blockgroups_2020 AS bg ON SUBSTRING(pop.geoid, 10) = bg.geoid
--     WHERE SUBSTRING(pop.geoid, 10) LIKE '42101%'

-- ),

-- stop_pop AS (

--     SELECT
--         stops.stop_id,
--         SUM(bg.total) AS estimated_pop_800m
--     FROM septa.bus_stops AS stops
--     INNER JOIN bg_w_pop AS bg ON ST_DWITHIN(stops.geog, bg.geog, 800)
--     GROUP BY stops.stop_id
-- )

-- SELECT
--     stops.stop_name,
--     pop.estimated_pop_800m,
--     stops.geog
-- FROM stop_pop AS pop
-- INNER JOIN septa.bus_stops AS stops USING (stop_id)
-- WHERE pop.estimated_pop_800m > 500
-- ORDER BY pop.estimated_pop_800m ASC, stops.geog ASC
-- LIMIT 8
