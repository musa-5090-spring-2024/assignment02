CREATE INDEX neighborhoods_geog_idx ON azavea.neighborhoods USING GIST(geog);

-- Create a new table to store the results
CREATE TABLE neighborhood_bus_stop_counts_with_metric AS
SELECT n.ogc_fid,
       n.name,
       COUNT(bs.stop_id) AS total_bus_stops_with_wheelchair_boarding,
	   CASE
                WHEN COUNT(bs.stop_id) <= 5 THEN 1  -- Range 1: 1-5 bus stops with wheelchair boarding
                WHEN COUNT(bs.stop_id) <= 12 THEN 2  -- Range 2: 6-12 bus stops with wheelchair boarding
                WHEN COUNT(bs.stop_id) <= 20 THEN 3  -- Range 3: 13-20 bus stops with wheelchair boarding
                WHEN COUNT(bs.stop_id) <= 30 THEN 4  -- Range 4: 21-30 bus stops with wheelchair boarding
                ELSE 5                                -- Range 5: More than 30 bus stops with wheelchair boarding
       END AS accessibility_metric
FROM azavea.neighborhoods n
LEFT JOIN septa.bus_stops bs ON ST_Intersects(ST_GeogFromText(ST_AsText(n.geog)), bs.geog)
                               AND (bs.wheelchair_boarding = 2)
GROUP BY n.ogc_fid, n.name;

-- Check the contents of the new table
SELECT * FROM neighborhood_bus_stop_counts_with_metric;