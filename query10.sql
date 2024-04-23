/*
  You're tasked with giving more contextual information to rail stops to 
  fill the stop_desc field in a GTFS feed. Using any of the data sets above, 
  PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, 
  build a description (alias as stop_desc) for each stop. Feel free to supplement with 
  other datasets (must provide link to data used so it's reproducible), and other methods of 
  describing the relationships. SQL's CASE statements may be helpful for some operations.
*/


WITH BusStopsInfo AS (
    SELECT
        rs.stop_id,
        COUNT(bs.stop_id) AS nearby_bus_stops,
        SUM(CASE WHEN bs.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS accessible_bus_stops
    FROM
        septa.rail_stops AS rs
    LEFT JOIN
        septa.bus_stops AS bs
    ON ST_DWithin(bs.geog, rs.geog, 500)  -- Checks for bus stops within 500 meters
    GROUP BY rs.stop_id
)
SELECT
    rs.stop_id,
    rs.stop_name,
    'This stop has ' || bsi.nearby_bus_stops || ' nearby bus stops, including ' ||
    bsi.accessible_bus_stops || ' that are wheelchair accessible.' AS stop_desc,
    ST_X(rs.geog) AS stop_lon,
    ST_Y(rs.geog) AS stop_lat
FROM
    septa.rail_stops AS rs
JOIN
    BusStopsInfo AS bsi
ON rs.stop_id = bsi.stop_id;






