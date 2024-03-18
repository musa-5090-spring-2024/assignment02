/*
You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.

Structure:

(
    stop_id integer,
    stop_name text,
    stop_desc text,
    stop_lon double precision,
    stop_lat double precision
)
As an example, your stop_desc for a station stop may be something like "37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)

Tip when experimenting: Use subqueries to limit your query to just a few rows to keep query times faster. Once your query is giving you answers you want, scale it up. E.g., instead of FROM tablename, use FROM (SELECT * FROM tablename limit 10) as t.

*/

with block_pop as (
select
	population_2020.geoid as geoid,
	population_2020.total || ' people in this blockgroup' as population,
	blockgroups_2020.geog as geog
from
census.population_2020
join
census.blockgroups_2020
on population_2020.geoid = blockgroups_2020.geoid
)

select
	stop_id,
	stop_name,
	block_pop.population as stop_desc,
	stop_lon,
	stop_lat
from
	septa.rail_stops
join
	block_pop
on
st_contains(
	block_pop.geog::geometry, 
	st_setsrid(st_makepoint(
			rail_stops.stop_lon,
			rail_stops.stop_lat),4326)::geometry);
