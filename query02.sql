2.  Which **eight** bus stops have the smallest population above 500 people _inside of Philadelphia_ within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of `42101` -- that's `42` for the state of PA, and `101` for Philadelphia county)?

    **The queries to #1 & #2 should generate results with a single row, with the following structure:**

    ```sql
    (
        stop_name text, -- The name of the station
        estimated_pop_800m integer, -- The population within 800 meters
        geog geography -- The geography of the bus stop
    )


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
    WHERE
        SUBSTRING(pop.geoid, 1, 5) = '42101' 
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
WHERE
    pop.estimated_pop_800m > 500 -- Filter for population above 500
ORDER BY
    pop.estimated_pop_800m ASC
LIMIT 8;

        