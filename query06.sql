CREATE TABLE neighborhood_accessibility_stats AS
SELECT
    n.name AS neighborhood_name,
    accessibility_metric,
    COUNT(CASE WHEN bs.wheelchair_boarding = 2 THEN 1 END) AS num_bus_stops_accessible,
    COUNT(CASE WHEN bs.wheelchair_boarding = 1 OR bs.wheelchair_boarding = 0 THEN 1 END) AS num_bus_stops_inaccessible
FROM
    azavea.neighborhoods n
LEFT JOIN
    (
        SELECT
            ogc_fid,
            name,
            COUNT(bs.stop_id) AS total_bus_stops_with_wheelchair_boarding,
            CASE
                WHEN COUNT(bs.stop_id) <= 5 THEN 1  -- Range 1: 1-5 bus stops with wheelchair boarding
                WHEN COUNT(bs.stop_id) <= 12 THEN 2  -- Range 2: 6-12 bus stops with wheelchair boarding
                WHEN COUNT(bs.stop_id) <= 20 THEN 3  -- Range 3: 13-20 bus stops with wheelchair boarding
                WHEN COUNT(bs.stop_id) <= 30 THEN 4  -- Range 4: 21-30 bus stops with wheelchair boarding
                ELSE 5                                -- Range 5: More than 30 bus stops with wheelchair boarding
       END AS accessibility_metric
        FROM
            azavea.neighborhoods n
        LEFT JOIN
            septa.bus_stops bs ON ST_Intersects(ST_GeogFromText(ST_AsText(n.geog)), bs.geog)
                               AND (bs.wheelchair_boarding = 2)
        GROUP BY
            n.ogc_fid, n.name
    ) AS accessibility_metrics ON n.name = accessibility_metrics.name
LEFT JOIN
    septa.bus_stops bs ON ST_Intersects(ST_GeogFromText(ST_AsText(n.geog)), bs.geog)
GROUP BY
    n.name, accessibility_metric;
	
CREATE TABLE top_five_neighborhoods AS
SELECT
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM
    neighborhood_accessibility_stats
ORDER BY
    accessibility_metric DESC  -- Order by accessibility metric in descending order
LIMIT
    5;