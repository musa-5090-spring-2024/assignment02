-- Active: 1708112526321@@127.0.0.1@5432@assignment02
ALTER DATABASE assignment02 SET search_path = 'public';

ALTER TABLE septa.bus_stops ADD COLUMN geog geography(Point, 4326);
UPDATE septa.bus_stops SET geog = ST_SetSRID(ST_MakePoint(stop_lon::FLOAT, stop_lat::FLOAT), 4326);

-- Update the new geography column with data from the existing geometry column
UPDATE census.blockgroups_2020 SET geography_column = ST_Transform(geog, 4326)::geography;

SHOW search_path;
SET search_path='public';  

/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/

SELECT * FROM septa.bus_stops;

SELECT * FROM census.blockgroups_2020;

WITH
septa_bus_stop_blockgroups AS (
    SELECT
        bus_stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS bus_stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON st_dwithin(bus_stops.geog, st_transform(bg.geog::geometry, 4326)::geography, 800)
),
septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        sum(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop USING (geoid)
    GROUP BY stops.stop_id
)
SELECT
    stops.stop_id,
    pop.estimated_pop_800m,
    stops.geog
FROM septa_bus_stop_surrounding_population AS pop
INNER JOIN septa.bus_stops AS stops USING (stop_id)
ORDER BY pop.estimated_pop_800m DESC
LIMIT 8;