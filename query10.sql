WITH geography_points AS (
    SELECT
        stop_id,
        ST_SETSRID(ST_MAKEPOINT(stop_lon, stop_lat), 4326)::geography AS stop_point
    FROM
        septa.rail_stops
),

neighborhood_directions AS (
    SELECT
        gp.stop_id,
        INITCAP(REPLACE(n.name, '_', ' ')) AS name1, -- Replace underscores and then apply title case
        ST_AZIMUTH(gp.stop_point::geometry, ST_CENTROID(n.geog)::geometry) AS azimuth,
        CASE
            WHEN ST_AZIMUTH(gp.stop_point::geometry, ST_CENTROID(n.geog)::geometry) BETWEEN RADIANS(0) AND RADIANS(22.5) OR ST_AZIMUTH(gp.stop_point::geometry, ST_CENTROID(n.geog)::geometry) BETWEEN RADIANS(337.5) AND RADIANS(360) THEN 'North'
            WHEN ST_AZIMUTH(gp.stop_point::geometry, ST_CENTROID(n.geog)::geometry) BETWEEN RADIANS(22.5) AND RADIANS(67.5) THEN 'Northeast'
            WHEN ST_AZIMUTH(gp.stop_point::geometry, ST_CENTROID(n.geog)::geometry) BETWEEN RADIANS(67.5) AND RADIANS(112.5) THEN 'East'
            WHEN ST_AZIMUTH(gp.stop_point::geometry, ST_CENTROID(n.geog)::geometry) BETWEEN RADIANS(112.5) AND RADIANS(157.5) THEN 'Southeast'
            WHEN ST_AZIMUTH(gp.stop_point::geometry, ST_CENTROID(n.geog)::geometry) BETWEEN RADIANS(157.5) AND RADIANS(202.5) THEN 'South'
            WHEN ST_AZIMUTH(gp.stop_point::geometry, ST_CENTROID(n.geog)::geometry) BETWEEN RADIANS(202.5) AND RADIANS(247.5) THEN 'Southwest'
            WHEN ST_AZIMUTH(gp.stop_point::geometry, ST_CENTROID(n.geog)::geometry) BETWEEN RADIANS(247.5) AND RADIANS(292.5) THEN 'West'
            WHEN ST_AZIMUTH(gp.stop_point::geometry, ST_CENTROID(n.geog)::geometry) BETWEEN RADIANS(292.5) AND RADIANS(337.5) THEN 'Northwest'
            ELSE 'Unknown'
        END AS direction
    FROM
        geography_points AS gp
    INNER JOIN
        azavea.neighborhoods AS n ON ST_CONTAINS(n.geog::geometry, gp.stop_point::geometry)
)

UPDATE septa.rail_stops
SET stop_desc = stop_name || ' Rail Stop in ' || nd.direction || ' ' || nd.name1 -- Using modified neighborhood name
FROM
    neighborhood_directions AS nd
WHERE
    septa.rail_stops.stop_id = nd.stop_id;

-- This SELECT query omits rows where `stop_desc` is NULL
SELECT
    stop_id,
    stop_name,
    stop_desc,
    stop_lon,
    stop_lat
FROM septa.rail_stops
WHERE stop_desc IS NOT NULL
ORDER BY stop_id ASC
LIMIT 100;
