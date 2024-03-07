/*
2.  Which **eight** bus stops have the smallest population above 500 people _inside of Philadelphia_ within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of `42101` -- that's `42` for the state of PA, and `101` for Philadelphia county)?

    **The queries to #1 & #2 should generate results with a single row, with the following structure:**

    ```sql
    (
        stop_name text, -- The name of the station
        estimated_pop_800m integer, -- The population within 800 meters
        geog geography -- The geography of the bus stop
    )
    ```
*/

WITH septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON ST_DWithin(stops.geog, bg.geog, 800)
    WHERE bg.geoid LIKE '42101%'
), septa_bus_stop_surrounding_population AS (
    SELECT
        sbg.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS sbg
    INNER JOIN census.population_2020 AS pop
        ON sbg.geoid = pop.geoid
    GROUP BY sbg.stop_id
    HAVING SUM(pop.total) > 500
)
SELECT
    bs.stop_name,
    sp.estimated_pop_800m,
    bs.geog
FROM septa_bus_stop_surrounding_population AS sp
INNER JOIN septa.bus_stops AS bs
    ON sp.stop_id = bs.stop_id
ORDER BY sp.estimated_pop_800m ASC
LIMIT 8;
