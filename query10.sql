' Youre tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. Feel free to supplement with other datasets (must provide link to data used so its reproducible), and other methods of describing the relationships. SQLs CASE statements may be helpful for some operations.'

CREATE TABLE google_rail (
    stop_id INTEGER PRIMARY KEY,
    stop_name TEXT,
    geog GEOGRAPHY(Point, 4326),  
    stop_lon DOUBLE PRECISION,    
    stop_lat DOUBLE PRECISION    
);

WITH nearest_parcels AS (
    SELECT
        gr.stop_id,
        gr.stop_name,
        gr.stop_lon,
        gr.stop_lat,
        p.address,
        ST_Distance(gr.geog, p.geog) AS distance
    FROM
        google_rail AS gr
    JOIN
        phl_water_dpt AS p
    ON
        ST_DWithin(gr.geog, p.geog, 200) 
    ORDER BY
        gr.stop_id,
        ST_Distance(gr.geog, p.geog)
)
SELECT
    stop_id,
    stop_name,
    'Approximately ' || ROUND(distance) || ' meters from ' || address AS stop_desc,
    stop_lon,
    stop_lat
FROM (
    SELECT
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        address,
        distance,
        ROW_NUMBER() OVER (PARTITION BY stop_id ORDER BY distance) AS rnk
    FROM
        nearest_parcels
) AS ranked_stops
WHERE
    rnk = 1;
