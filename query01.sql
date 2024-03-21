/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/

DROP TABLE IF EXISTS blockgroups_2020;
 
-- Create postGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create a view with buffers around bus stops
CREATE OR REPLACE VIEW septa.bus_stop_buffers AS
SELECT
    bs.stop_id AS stop_id,
    public.st_buffer(public.st_makepoint(bs.stop_lon::numeric, bs.stop_lat::numeric)::public.geography, 800) 
        AS buffer_geom
FROM
    septa.bus_stops bs;

-- Join census data to block groups to get spatial data 


-- Create a view with population within each buffer zone
CREATE OR REPLACE VIEW census.population_within_buffers AS
SELECT
    bsb.stop_id,
    SUM(p.total) AS total_population 
FROM
    septa.bus_stop_buffers bsb
JOIN
    census.population_2020 p
ON
    public.st_intersects(bsb.buffer_geom::public.geometry, p.geoname)
GROUP BY
    bsb.stop_id;

-- Find the bus stop with the largest population within 800 meters
SELECT
    bs.*,
    pb.total_population
FROM
    public.bus_stops bs
JOIN
    population_within_buffers pb
ON
    bs.id = pb.bus_stop_id
ORDER BY
    pb.total_population DESC
LIMIT 1;