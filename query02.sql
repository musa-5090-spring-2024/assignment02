/*
  Which eight bus stops have the smallest population above 500 people _inside of Philadelphia_ within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of `42101` -- that's `42` for the state of PA, and `101` for Philadelphia county)?

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
        CONCAT('1500000US', bg.geoid) AS geoid  -- Using CONCAT for string operation
    FROM
        septa.bus_stops AS stops
    INNER JOIN
        census.blockgroups_2020 AS bg
    ON
        ST_DWithin(stops.geog, bg.geog, 800)
),
septa_bus_stop_surrounding_population AS (
    SELECT
        bg.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM
        septa_bus_stop_blockgroups AS bg
    INNER JOIN
        census.population_2020 AS pop
    ON
        bg.geoid = pop.geoid
    WHERE
        SUBSTR(pop.geoid, 10, 5) = '42101'  
    GROUP BY
        bg.stop_id
)

SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM
    septa.bus_stops AS stops
INNER JOIN
    septa_bus_stop_surrounding_population AS pop
ON
    stops.stop_id = pop.stop_id 
WHERE
    pop.estimated_pop_800m > 500
ORDER BY
    pop.estimated_pop_800m DESC, stops.geog  
LIMIT 8;
