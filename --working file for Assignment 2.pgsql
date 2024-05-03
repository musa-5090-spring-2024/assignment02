--working file for Assignment 2

--Let us first explore our database. We see that we have 4 schemas, each with a table that we loaded into (see data_downloadsteps for details)

--the first question asks us 
-- 1.  Which **eight** bus stop have the largest population within 800 meters? 
--As a rough estimation, consider any block group that intersects the buffer as being part of the 800 meter buffer.

--okay so for this assignment, we know that the tables of interest for us are our bus stop data in septa schema,
--the block group shapefiles from census schema, and the population data also in the census schema.

--lets take a look at how these tables are like

SELECT * FROM septa.bus_stops
LIMIT 5;

SELECT * FROM census.blockgroups_2020
LIMIT 5;

SELECT * FROM census.population_2020
LIMIT 5;

--Question 1
--in the example, prof first begins by creating a temporary group called septa_bus_stop_blockgroups 

with

septa_bus_stop_blockgroups as (
    select
        stops.stop_id,
        '1500000US' || bg.geoid as geoid
--here, we are selecting septa stop id, and creating a column called bg.geoid with the first few characters being 15000...
    from septa.bus_stops as stops --information is coming from septa.bus_stops
    inner join census.blockgroups_2020 as bg --now we are joining it to census block group information
        on st_dwithin(stops.geog, bg.geog, 800)
),
--based on geographic proximity, i.e. within the 800m buffer

--then he creates another placeholder for popoulation of surrounding blocks
septa_bus_stop_surrounding_population as (
    select
        stops.stop_id,
        sum(pop.total) as estimated_pop_800m
    from septa_bus_stop_blockgroups as stops
    inner join census.population_2020 as pop using (geoid)
    group by stops.stop_id
)

select
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
from septa_bus_stop_surrounding_population as pop
inner join septa.bus_stops as stops using (stop_id)
order by pop.estimated_pop_800m desc
limit 8


--Question 2
--Which eight bus stops have the smallest population above 500 people inside of Philadelphia within 800 meters of the stop 
--(Philadelphia county block groups have a geoid prefix of 42101 -- that's 42 for the state of PA, and 101 for Philadelphia county)?

with 

septa_bus_stop_blockgroups as (
    select
        stops.stop_id,
        '1500000US' || bg.geoid as geoid
    from septa.bus_stops as stops
    inner join census.blockgroups_2020 as bg
        on st_dwithin(stops.geog, bg.geog, 800) and geoid like '42101%'  -- Filter only Philadelphia county block groups
),

septa_bus_stop_surrounding_population as (
    select
        stops.stop_id,
        sum(pop.total) as estimated_pop_800m  -- Summing population to get total within 800m
    from septa_bus_stop_blockgroups as stops
    inner join census.population_2020 as pop using (geoid)
    group by stops.stop_id
    having sum(pop.total) > 500  -- Ensuring total population is greater than 500
)

--Selecting the bus stops with the smallest populations above 500 within 800 meters
select
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
from septa_bus_stop_surrounding_population as pop
inner join septa.bus_stops as stops using (stop_id)
order by pop.estimated_pop_800m asc  -- Order by ascending to find the smallest populations
limit 8;

--Question 3
--Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. 
--The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).
--the code should use the nearest neighbour function and the query should run in under two minutes 


--lets observe how PWD water dataset looks like

select * from phl.pwd_parcels
limit 5;


WITH closest_bus_stop AS (
    SELECT
        phl.address AS parcel_address,
        stops.stop_name,
        stops.stop_id,
        ROUND((ST_Distance(phl.geog, stops.geog))::numeric, 2) AS distance_meters
    FROM
        phl.pwd_parcels AS phl
    CROSS JOIN LATERAL (
        SELECT
            stop_id,
            stop_name,
            geog
        FROM
            septa.bus_stops
        ORDER BY
            phl.geog <-> septa.bus_stops.geog
        LIMIT 1
    ) AS stops
)
SELECT
    parcel_address,
    stop_name,
    distance_meters
FROM
    closest_bus_stop
ORDER BY
    distance_meters DESC
LIMIT 8;


--Question 4
--Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.

SELECT * FROM septa.bus_shapes
limit 5;

SELECT * FROM septa.bus_routes
limit 5;

SELECT * FROM septa.bus_trips
limit 5;

--need to join trip information to shapes first by shape_id, then to bus_routes by route.id
--structure: route short name, trip_headsign, shape_geog, shape_length

WITH bus_stop_shapes AS (
    SELECT
        shp.trip_id,
        shp.route_id,
        shp.trip_headsign,
        ST_MakeLine(ST_SetSRID(ST_MakePoint(bs.shape_pt_lon, bs.shape_pt_lat), 4326)) AS shape_geog
    FROM
        septa.bus_shapes bs
    INNER JOIN
        septa.bus_trips shp
    ON
        bs.shape_id = shp.shape_id
    GROUP BY
        shp.trip_id, shp.route_id, shp.trip_headsign
),

bus_route_length AS (
    SELECT
        br.route_short_name,
        bss.trip_headsign,
        bss.shape_geog,
        ROUND(ST_Length(bss.shape_geog::geography)) AS shape_length 
    FROM
        bus_stop_shapes bss
    INNER JOIN
        septa.bus_routes br
    ON
        bss.route_id = br.route_id
    ORDER BY
        bss.route_id, shape_length DESC  
)

-- Select only the longest trip for each route using DISTINCT ON
SELECT DISTINCT ON (route_short_name)
    route_short_name,
    trip_headsign,
    shape_length,
    shape_geog
FROM
    bus_route_length
ORDER BY
    route_short_name, shape_length DESC
LIMIT 2;


-- Question 5

--Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

--Discuss your accessibility metric and how you arrived at it below.

--here, my metric for accessibility is the minimum average distance a person in the neighbourhood will need to travel in order to get to any accessible bus stops
--I will multiply this with the density of accessible bus stop per square km

--for a neighbourhood to be considered accessible, any person with disability should not need to travel very far to get to a bus stop. These frequency will be measured best by these two metrics

--workflow: join bus stop information to neighbourhood shapes. Create a random grid layer that contains dots across all of the neighbourhood. Find the average nearest neighbour distance to any one bus route, also calculate accessible bus stop by sq meter in the neighbourhood.

Select * from septa.bus_stops
Limit 5;

Select * from azavea.neighborhoods
Limit 5;

WITH neighbourhood_stops AS (
    SELECT
        bs.stop_id,
        bs.stop_name,
        bs.wheelchair_boarding,
        n.mapname AS neighbourhood_name,
        n.shape_area,
        n.geog AS neighborhood_geog,
        bs.geog AS stop_geog
    FROM 
        septa.bus_stops bs
    INNER JOIN 
        azavea.neighborhoods n ON ST_Within(bs.geog::geometry, n.geog::geometry)
    GROUP BY
        bs.stop_id, bs.stop_name, bs.wheelchair_boarding, n.mapname, n.shape_area, n.geog, bs.geog
),

grid_points AS (
    SELECT
        n.mapname AS neighbourhood_name,
        (ST_Dump(ST_GeneratePoints(n.geog::geometry, 100))).geom AS grid_point
    FROM
        azavea.neighborhoods n
),

nearest_distances AS (
    SELECT
        gp.neighbourhood_name,
        gp.grid_point,
        MIN(distance) AS nearest_distance
    FROM 
        grid_points gp
    CROSS JOIN LATERAL (
        SELECT 
            ST_Distance(gp.grid_point::geography, ns.stop_geog) AS distance
        FROM 
            neighbourhood_stops ns
        WHERE 
            gp.neighbourhood_name = ns.neighbourhood_name
        ORDER BY 
            gp.grid_point <-> ns.stop_geog 
        LIMIT 1
    ) AS dist
    GROUP BY
        gp.neighbourhood_name, gp.grid_point
),

average_distance AS (
    SELECT
        neighbourhood_name,
        ROUND(AVG(nearest_distance)::numeric, 2) AS avg_nearest_distance
    FROM
        nearest_distances
    GROUP BY
        neighbourhood_name
),

accessible_stop_density AS (
    SELECT
        neighbourhood_name,
        COUNT(stop_id) AS stops,
        COUNT(*) FILTER (WHERE wheelchair_boarding = 1) AS accessible_stops,
        COUNT(*) FILTER (WHERE wheelchair_boarding = 0) AS inaccessible_stops,
        ROUND(COUNT(stop_id) / (shape_area / 1000000)::numeric, 2) AS density_per_sq_km
    FROM 
        neighbourhood_stops
    GROUP BY 
        neighbourhood_name, shape_area
),

final_index AS (
    SELECT
        ad.neighbourhood_name,
        ad.avg_nearest_distance,
        asd.density_per_sq_km,
        ROUND(
            ((1 / ad.avg_nearest_distance + 0.0001) * 100 / MAX((1 / ad.avg_nearest_distance + 0.0001) * 100) OVER ()) +
            (asd.density_per_sq_km * 100 / MAX(asd.density_per_sq_km * 100) OVER ()) / 2,
            2
        ) AS accessibility_index,
        asd.accessible_stops,
        asd.inaccessible_stops
    FROM
        average_distance ad
    JOIN
        accessible_stop_density asd ON ad.neighbourhood_name = asd.neighbourhood_name
)

SELECT
    neighbourhood_name,
    avg_nearest_distance,
    density_per_sq_km,
    accessibility_index,
    inaccessible_stops,
    accessible_stops
FROM
    final_index
ORDER BY
    accessibility_index DESC
LIMIT 5;




--question 6

WITH neighbourhood_stops AS (
    SELECT
        bs.stop_id,
        bs.stop_name,
        bs.wheelchair_boarding,
        n.mapname AS neighbourhood_name,
        n.shape_area,
        n.geog AS neighborhood_geog,
        bs.geog AS stop_geog
    FROM 
        septa.bus_stops bs
    INNER JOIN 
        azavea.neighborhoods n ON ST_Within(bs.geog::geometry, n.geog::geometry)
    GROUP BY
        bs.stop_id, bs.stop_name, bs.wheelchair_boarding, n.mapname, n.shape_area, n.geog, bs.geog
),

grid_points AS (
    SELECT
        n.mapname AS neighbourhood_name,
        (ST_Dump(ST_GeneratePoints(n.geog::geometry, 100))).geom AS grid_point
    FROM
        azavea.neighborhoods n
),

nearest_distances AS (
    SELECT
        gp.neighbourhood_name,
        gp.grid_point,
        MIN(distance) AS nearest_distance
    FROM 
        grid_points gp
    CROSS JOIN LATERAL (
        SELECT 
            ST_Distance(gp.grid_point::geography, ns.stop_geog) AS distance
        FROM 
            neighbourhood_stops ns
        WHERE 
            gp.neighbourhood_name = ns.neighbourhood_name
        ORDER BY 
            gp.grid_point <-> ns.stop_geog 
        LIMIT 1
    ) AS dist
    GROUP BY
        gp.neighbourhood_name, gp.grid_point
),

average_distance AS (
    SELECT
        neighbourhood_name,
        ROUND(AVG(nearest_distance)::numeric, 2) AS avg_nearest_distance
    FROM
        nearest_distances
    GROUP BY
        neighbourhood_name
),

accessible_stop_density AS (
    SELECT
        neighbourhood_name,
        COUNT(stop_id) AS stops,
        COUNT(*) FILTER (WHERE wheelchair_boarding = 1) AS accessible_stops,
        COUNT(*) FILTER (WHERE wheelchair_boarding = 0) AS inaccessible_stops,
        ROUND(COUNT(stop_id) / (shape_area / 1000000)::numeric, 2) AS density_per_sq_km
    FROM 
        neighbourhood_stops
    GROUP BY 
        neighbourhood_name, shape_area
),

final_index AS (
    SELECT
        ad.neighbourhood_name,
        ad.avg_nearest_distance,
        asd.density_per_sq_km,
        ROUND(
            ((1 / ad.avg_nearest_distance + 0.0001) * 100 / MAX((1 / ad.avg_nearest_distance + 0.0001) * 100) OVER ()) +
            (asd.density_per_sq_km * 100 / MAX(asd.density_per_sq_km * 100) OVER ()) / 2,
            2
        ) AS accessibility_index,
        asd.accessible_stops,
        asd.inaccessible_stops
    FROM
        average_distance ad
    JOIN
        accessible_stop_density asd ON ad.neighbourhood_name = asd.neighbourhood_name
)
SELECT 
    neighbourhood_name,
    accessibility_index AS accessibility_metric,
    accessible_stops AS num_bus_stops_accessible,
    inaccessible_stops AS num_bus_stops_inaccessible
FROM
    final_index
ORDER BY
    accessibility_index DESC
LIMIT 5;


--Question 7

WITH neighbourhood_stops AS (
    SELECT
        bs.stop_id,
        bs.stop_name,
        bs.wheelchair_boarding,
        n.mapname AS neighbourhood_name,
        n.shape_area,
        n.geog AS neighborhood_geog,
        bs.geog AS stop_geog
    FROM 
        septa.bus_stops bs
    INNER JOIN 
        azavea.neighborhoods n ON ST_Within(bs.geog::geometry, n.geog::geometry)
    GROUP BY
        bs.stop_id, bs.stop_name, bs.wheelchair_boarding, n.mapname, n.shape_area, n.geog, bs.geog
),

grid_points AS (
    SELECT
        n.mapname AS neighbourhood_name,
        (ST_Dump(ST_GeneratePoints(n.geog::geometry, 100))).geom AS grid_point
    FROM
        azavea.neighborhoods n
),

nearest_distances AS (
    SELECT
        gp.neighbourhood_name,
        gp.grid_point,
        MIN(distance) AS nearest_distance
    FROM 
        grid_points gp
    CROSS JOIN LATERAL (
        SELECT 
            ST_Distance(gp.grid_point::geography, ns.stop_geog) AS distance
        FROM 
            neighbourhood_stops ns
        WHERE 
            gp.neighbourhood_name = ns.neighbourhood_name
        ORDER BY 
            gp.grid_point <-> ns.stop_geog 
        LIMIT 1
    ) AS dist
    GROUP BY
        gp.neighbourhood_name, gp.grid_point
),

average_distance AS (
    SELECT
        neighbourhood_name,
        ROUND(AVG(nearest_distance)::numeric, 2) AS avg_nearest_distance
    FROM
        nearest_distances
    GROUP BY
        neighbourhood_name
),

accessible_stop_density AS (
    SELECT
        neighbourhood_name,
        COUNT(stop_id) AS stops,
        COUNT(*) FILTER (WHERE wheelchair_boarding = 1) AS accessible_stops,
        COUNT(*) FILTER (WHERE wheelchair_boarding = 0) AS inaccessible_stops,
        ROUND(COUNT(stop_id) / (shape_area / 1000000)::numeric, 2) AS density_per_sq_km
    FROM 
        neighbourhood_stops
    GROUP BY 
        neighbourhood_name, shape_area
),

final_index AS (
    SELECT
        ad.neighbourhood_name,
        ad.avg_nearest_distance,
        asd.density_per_sq_km,
        ROUND(
            ((1 / ad.avg_nearest_distance + 0.0001) * 100 / MAX((1 / ad.avg_nearest_distance + 0.0001) * 100) OVER ()) +
            (asd.density_per_sq_km * 100 / MAX(asd.density_per_sq_km * 100) OVER ()) / 2,
            2
        ) AS accessibility_index,
        asd.accessible_stops,
        asd.inaccessible_stops
    FROM
        average_distance ad
    JOIN
        accessible_stop_density asd ON ad.neighbourhood_name = asd.neighbourhood_name
)
SELECT 
    neighbourhood_name,
    accessibility_index AS accessibility_metric,
    accessible_stops AS num_bus_stops_accessible,
    inaccessible_stops AS num_bus_stops_inaccessible
FROM
    final_index
ORDER BY
    accessibility_index
LIMIT 5;


-- Question 8
--With a query, find out how many census block groups Penn's main campus fully contains. 
--Discuss which dataset you chose for defining Penn's campus.

--I extracted Upenn's shape using osmdata package in R. Now I am going to load it into my database using ogr2ogr

create schema if not exists upenn;

select * from census.blockgroups_2020
limit 5;

--ogr2ogr \-f "PostgreSQL" \-nln upenn.boundary \-nlt MULTIPOLYGON \-t_srs EPSG:4326 \-lco GEOMETRY_NAME=geog \-lco GEOM_TYPE=GEOGRAPHY \-overwrite \PG:"host=localhost port=5432 dbname=musa509assign_2 user=avani password=sqlpassword" \upenn.shp

--now that our datasets are loaded, we begin working on our query

WITH penn_blocks AS (
    SELECT
        b.geoid,
    FROM
        census.blockgroups_2020 AS b,
        upenn.boundary AS p
    WHERE
        ST_Within(b.geog::geometry, p.geog::geometry)  
)
SELECT COUNT(*) AS count_block_groups FROM penn_blocks;


--Question 9
--With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

--To do this, I will find the parcel ID of the parcel containing Meyerson Hall, and then I will find out which block group contains this parcel IDENTITY
--from looking at the dataset in ARCGIS, we find that the parcel ID for meyerson hall is 263,026
--the object ID is 	533508

WITH meyerson_parcel AS (
    SELECT
        b.geoid
    FROM
        census.blockgroups_2020 AS b
    JOIN
        phl.pwd_parcels AS p ON ST_Within(p.geog::geometry, b.geog::geometry)
    WHERE
        p.parcelid = '263026'  
)
SELECT geoid FROM meyerson_parcel;


--Question 10

--You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. 
--Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. 
--Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.

SELECT * FROM septa.rail_stops
LIMIT 5;

--for this task, I am using the City Landmarks Dataset from Open Data Philly. I downloaded the data, now I am going to load it into my database

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


