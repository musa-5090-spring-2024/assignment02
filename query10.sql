-- You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.

-- show which bus stop can people transfer in each rail station

WITH

rail_buffer AS (
    SELECT
        rail_stops.stop_name,
        ST_BUFFER(rail_stops.geog, 200) AS rail200
    FROM septa.rail_stops AS rail_stops
)

SELECT
    bf.stop_name AS rail_name,
    bus.stop_name AS bus_name
FROM rail_buffer AS bf
LEFT JOIN septa.bus_stops AS bus
    ON ST_COVERS(bf.rail200, bus.geog)
GROUP BY rail_name, bus_name
ORDER BY bus_name
