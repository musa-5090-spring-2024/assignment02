WITH
septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON ST_DWithin(stops.geog, bg.geog, 800)
    WHERE bg.geoid LIKE '42101%'
),

septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop USING (geoid)
    GROUP BY stops.stop_id
),

pop_with_row_number AS (
    SELECT
        stops.stop_name AS stop_name,
        pop.estimated_pop_800m / 2 AS estimated_pop_800m,
        ROW_NUMBER() OVER (PARTITION BY stops.stop_id ORDER BY pop.estimated_pop_800m DESC) AS rn -- noqa: LT05
    FROM septa_bus_stop_surrounding_population AS pop
    INNER JOIN septa.bus_stops AS stops USING (stop_id)
    WHERE pop.estimated_pop_800m >= 500
)

SELECT DISTINCT
    pop_with_row_number.stop_name,
    estimated_pop_800m,
    ST_SetSRID(stops.geog, 4326) AS geog
FROM pop_with_row_number

JOIN septa.bus_stops AS stops ON pop_with_row_number.stop_name = stops.stop_name -- noqa: AM05
WHERE rn = 1
ORDER BY estimated_pop_800m ASC
LIMIT 8;
