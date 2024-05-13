WITH septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON ST_DWithin(stops.geog, bg.geog, 800)
    WHERE bg.geoid LIKE '42101%' -- Filter for Philadelphia county block groups
),

septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop USING (geoid)
    WHERE pop.total > 500 -- Filter for population above 500 people
    GROUP BY stops.stop_id
),

pop_with_row_number AS (
    SELECT
        stops.stop_name,
        pop.estimated_pop_800m AS estimated_pop_800m,
        stops.geog,
        ROW_NUMBER() OVER (ORDER BY pop.estimated_pop_800m ASC) AS rn -- Order by ascending population
    FROM septa_bus_stop_surrounding_population AS pop
    INNER JOIN septa.bus_stops AS stops USING (stop_id)
)

SELECT
    stop_name,
    estimated_pop_800m,
    ST_SetSRID(geog, 4326) AS geog
FROM pop_with_row_number
WHERE rn <= 8 -- Select top 8 bus stops with smallest population
ORDER BY estimated_pop_800m ASC; -- Order by ascending population
