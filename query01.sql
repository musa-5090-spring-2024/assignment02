WITH septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM
        septa_bus_stops AS stops
    INNER JOIN
        census_blockgroups_2020 AS bg ON ST_DWithin(stops.geom, bg.geom, 800)
),

septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM
        septa_bus_stop_blockgroups AS stops
    INNER JOIN
        census_population_2020 AS pop ON stops.geoid = pop.geoid
    GROUP BY
        stops.stop_id
)

SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geom
FROM
    septa_bus_stop_surrounding_population AS pop
INNER JOIN
    septa_bus_stops AS stops ON pop.stop_id = stops.stop_id
ORDER BY
    pop.estimated_pop_800m DESC
LIMIT 8;

