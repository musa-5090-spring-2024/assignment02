WITH philadelphia_bus_stops AS (
    SELECT
        stops.stop_name,
        stops.stop_lat,
        stops.stop_lon,
        SUM(pop.total) AS estimated_pop_800m,
        ST_SetSRID(ST_MakePoint(stops.stop_lon, stops.stop_lat), 4326) AS stop_geog
    FROM septa.bus_stops AS stops
    CROSS JOIN LATERAL (
        SELECT
            bg.intptlat,
            bg.intptlon,
            bg.geom
        FROM census_blockgroups_2020 AS bg
        WHERE bg.geoid LIKE '42101%' -- Filter for Philadelphia block groups
        AND ST_Intersects(
            ST_Buffer(
                ST_SetSRID(ST_MakePoint(stops.stop_lon, stops.stop_lat), 4326),
                800
            )::geography,
            bg.geom
        )
        LIMIT 1 
    ) AS bg
    INNER JOIN census_population_2020 AS pop ON ST_Intersects(
        ST_Buffer(
            ST_SetSRID(ST_MakePoint(stops.stop_lon, stops.stop_lat), 4326),
            800
        )::geography,
        bg.geom
    )
    GROUP BY stops.stop_name, stops.stop_lat, stops.stop_lon
    HAVING SUM(pop.total) > 500 
    ORDER BY SUM(pop.total) ASC 
    LIMIT 8 
SELECT
    stop_name,
    estimated_pop_800m,
    stop_geog AS geog
FROM philadelphia_bus_stops;

