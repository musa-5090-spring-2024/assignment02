/* Which eight bus stops have the smallest population above 500 people inside of Philadelphia within 
800 meters of the stop (Philadelphia county block groups have a geoid prefix of 42101 
-- that's 42 for the state of PA, and 101 for Philadelphia county)?

The queries to #1 & #2 should generate results with a single row, with the following structure:

(
    stop_name text, -- The name of the station
    estimated_pop_800m integer, -- The population within 800 meters
    geog geography -- The geography of the bus stop
) */

-- Create a view with buffers around bus stops within Philadelphia county
CREATE OR REPLACE VIEW philly_bus_stop_buffers AS
SELECT
    bs.stop_id,
    ST_Buffer(ST_MakePoint(bs.longitude, bs.latitude)::geography, 800) AS buffer_geom
FROM
    septa.bus_stops bs
WHERE
    SUBSTRING(bs.geoid, 1, 5) = '42101'; -- Filter stops within Philadelphia county

-- Create a view with population within each buffer zone
CREATE OR REPLACE VIEW philly_population_within_buffers AS
SELECT
    pb.buffer_id,
    SUM(p.population) AS total_population
FROM
    philly_bus_stop_buffers pb
JOIN
    census.population_data p
ON
    ST_Intersects(pb.buffer_geom::geometry, p.geom)
GROUP BY
    pb.buffer_id;

-- Find the bus stops with the smallest population above 500 people within 800 meters
SELECT
    bs.*,
    pb.total_population
FROM
    septa.bus_stops bs
JOIN
    philly_population_within_buffers pb
ON
    bs.stop_id = pb.buffer_id
WHERE
    pb.total_population > 500
ORDER BY
    pb.total_population ASC
LIMIT 8;
