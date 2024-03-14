/*
  Which eight bus stops have the smallest population above 500 people inside of 
  Philadelphia within 800 meters of the stop (Philadelphia county block groups have
   a geoid prefix of 42101 -- that's 42 for the state of PA, and 101 for Philadelphia
    county)?
*/

WITH 

septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM
        septa.bus_stops AS stops
    INNER JOIN
        census.blockgroups_2020 AS bg
        ON ST_DWithin(stops.geog, bg.geog, 800) -- Checks if the block group is within 800 meters of a bus stop
),

septa_bus_stop_surrounding_population AS (
    SELECT
        sbg.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS sbg
    INNER JOIN census.population_2020 AS pop using (geoid)
    GROUP BY
        sbg.stop_id
    HAVING
        SUM(pop.total) > 500 -- Ensures total population within 800 meters is above 500
)

SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM
    septa_bus_stop_surrounding_population AS pop
INNER JOIN septa.bus_stops AS stops using (stop_id)
ORDER BY
    pop.estimated_pop_800m ASC -- Change from DESC to ASC for smallest populations
LIMIT 8;


















