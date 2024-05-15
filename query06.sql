

'What are the _top five_ neighborhoods according to your accessibility metric?'


CREATE TABLE neighborhoods (
    neighborhood_id SERIAL PRIMARY KEY,
    neighborhood_name TEXT,
    geom GEOMETRY
);

WITH accessible_stops AS (
    SELECT
        neighborhoods.cartodb_id AS neighborhood_id,
        neighborhoods.listname AS neighborhood_name,
        COUNT(*) AS total_stops,
        SUM(CASE WHEN stops.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible
    FROM
        neighborhoods
    INNER JOIN
        septa.bus_stops stops ON ST_Intersects(neighborhoods.geom, stops.geog)
    GROUP BY
        neighborhoods.cartodb_id, neighborhoods.listname
),
neighborhood_accessibility AS (
    SELECT
        neighborhood_id,
        neighborhood_name,
        total_stops,
        num_bus_stops_accessible,
        ROUND((num_bus_stops_accessible::numeric / total_stops) * 100, 1) AS accessibility_metric,
        (total_stops - num_bus_stops_accessible) AS num_bus_stops_inaccessible
    FROM
        accessible_stops
), 
bottom_five_neighborhoods AS (
    SELECT
        neighborhood_name,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible,
        accessibility_metric
    FROM
        neighborhood_accessibility
    ORDER BY
        accessibility_metric ASC, num_bus_stops_accessible DESC
    LIMIT 5
)
SELECT * FROM bottom_five_neighborhoods;


