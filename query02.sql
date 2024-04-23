/*
  Which eight bus stops have the smallest population above 500 people inside of Philadelphia 
  within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of 42101 
  -- that's 42 for the state of PA, and 101 for Philadelphia county)?
*/

WITH philly_blockgroups AS (
    SELECT
        bg.geoid,
        bg.geog
    FROM census.blockgroups_2020 AS bg
    WHERE bg.geoid LIKE '42101%'
),
septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa.bus_stops AS stops
    JOIN philly_blockgroups AS bg
        ON ST_DWithin(stops.geog, bg.geog, 800)
    JOIN census.population_2020 AS pop
        ON '1500000US' || bg.geoid = pop.geoid
    GROUP BY stops.stop_id
    HAVING SUM(pop.total) > 500
)
SELECT
    stops.stop_name,
    sbg.estimated_pop_800m,
    stops.geog
FROM septa_bus_stop_blockgroups AS sbg
JOIN septa.bus_stops AS stops
    ON sbg.stop_id = stops.stop_id
ORDER BY sbg.estimated_pop_800m ASC
LIMIT 8;


