/*
You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed.
Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions,
build a description (alias as stop_desc) for each stop.
*/

WITH stop_info AS (
    SELECT
        rs.stop_id,
        rs.stop_name,
        rs.stop_lat,
        rs.stop_lon,
        COUNT(bs.stop_id)::integer AS stops_w_500m,
        SUM(CASE WHEN bs.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS stops_accessible
    FROM
        septa.rail_stops AS rs
    LEFT JOIN
        septa.bus_stops AS bs ON ST_DWITHIN(bs.geog, rs.geog, 500)
    GROUP BY
        rs.stop_id, rs.stop_name, rs.stop_lat, rs.stop_lon
)

SELECT
    stop_id,
    stop_name,
    stop_lat,
    stop_lon,
    'There are ' || stops_w_500m || ' bus stops within 500 meters from this station and among which ' || stops_accessible || ' are wheelchair friendly.' AS stop_desc
FROM stop_info
ORDER BY stops_w_500m DESC
