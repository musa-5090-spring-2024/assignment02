- Question 8
--With a query, find out how many census block groups Penn's main campus fully contains. 
--Discuss which dataset you chose for defining Penn's campus.

--For my penn campus dataset, I use the multipolygon defining the campus boundary on open street maps. To achieve this, I download the first layer from https://overpass-turbo.eu/.
--This is not my final layer as it contains nodes instead of lines. I run it through R to first combine all these seperate elements into one single multipolygon. Then I export it and load it to the database using ogr2ogr.

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