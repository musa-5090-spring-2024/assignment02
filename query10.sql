--Question 10

--You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. 
--Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. 
--Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.

SELECT * FROM septa.rail_stops
LIMIT 5;

--for this task, I am using the City Landmarks Dataset from Open Data Philly. I downloaded the data, now I am going to load it into my database. This dataset contains major cultural, historical, and social landmarks within the city and is supplemented with feedback from philadelphians.
--My discription measure hence will take distance and direction to each railway station from the closest landmark.

create schema if not exists landmarks;
--ogr2ogr \-f "PostgreSQL" \-nln landmarks.points \-nlt MULTIPOLYGON \-t_srs EPSG:4326 \-lco GEOMETRY_NAME=geog \-lco GEOM_TYPE=GEOGRAPHY \-overwrite \PG:"host=localhost port=5432 dbname=musa509assign_2 user=avani password=sqlpassword" \Landmarks_AGOTrainingOnly.geojson

SELECT * FROM landmarks.points
LIMIT 5;

SELECT * FROM septa.rail_stops
LIMIT 5;


ALTER TABLE septa.rail_stops
ADD COLUMN geog geography(Point, 4326);
UPDATE septa.rail_stops
SET geog = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);



WITH nearest_landmarks AS (
    SELECT
        rs.stop_id,
        rs.stop_name,
        rs.stop_lon,
        rs.stop_lat,
        lp.name AS landmark_name,
        ST_Distance(rs.geog::geography, ST_Centroid(lp.geog)::geography) AS distance,
        ST_Azimuth(rs.geog::geometry, ST_Centroid(lp.geog)::geometry) AS azimuth
    FROM
        septa.rail_stops rs
    CROSS JOIN LATERAL
        (SELECT name, geog
         FROM landmarks.points
         WHERE feat_type NOT IN ('Transportation', 'Transportation/Transit', 'Airport Ground')
         ORDER BY rs.geog <-> geog LIMIT 1
        ) AS lp
),
final_table AS (
    SELECT
        stop_id,
        stop_name,
        'Approximately ' || ROUND(distance) || ' meters ' ||
        CASE
            WHEN azimuth < pi() / 8 OR azimuth >= 15 * pi() / 8 THEN 'E'
            WHEN azimuth < 3 * pi() / 8 THEN 'NE'
            WHEN azimuth < 5 * pi() / 8 THEN 'N'
            WHEN azimuth < 7 * pi() / 8 THEN 'NW'
            WHEN azimuth < 9 * pi() / 8 THEN 'W'
            WHEN azimuth < 11 * pi() / 8 THEN 'SW'
            WHEN azimuth < 13 * pi() / 8 THEN 'S'
            ELSE 'SE'
        END || ' of ' || landmark_name AS stop_desc,
        stop_lon,
        stop_lat
    FROM nearest_landmarks
)
SELECT *
FROM final_table
LIMIT 5;