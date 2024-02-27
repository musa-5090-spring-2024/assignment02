WITH septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON ST_DWithin(stops.geog, bg.geog, 800)
), septa_bus_stop_surrounding_population AS (
    SELECT
        sbg.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS sbg
    INNER JOIN census.population_2020 AS pop
        ON sbg.geoid = pop.geoid
    GROUP BY sbg.stop_id
)
SELECT
    bs.stop_name,
    sp.estimated_pop_800m,
    bs.geog
FROM septa_bus_stop_surrounding_population AS sp
INNER JOIN septa.bus_stops AS bs
    ON sp.stop_id = bs.stop_id
ORDER BY sp.estimated_pop_800m DESC
LIMIT 8;
