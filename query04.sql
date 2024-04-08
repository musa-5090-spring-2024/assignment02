WITH
shapes AS (
    SELECT
        shape_id,
        ST_MAKELINE(
            ARRAY_AGG(
                ST_MAKEPOINT(
                    shape_pt_lon, shape_pt_lat
                ) ORDER BY shape_pt_sequence
            )
        )::geography AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
)

SELECT
    routes.route_short_name,
    routes.trip_headsign,
    routes.shape_geog,
    ROUND(ST_LENGTH(routes.shape_geog)::numeric) AS shape_length
FROM septa.bus_routes AS routes
FULL JOIN shapes ON shapes.shape_id = trips.shape_id
FULL JOIN septa.bus_trips AS trips ON routes.route_id = trips.route_id
GROUP BY routes.route_short_name, routes.trip_headsign, routes.shape_geog
ORDER BY shape_length DESC
LIMIT 2;
