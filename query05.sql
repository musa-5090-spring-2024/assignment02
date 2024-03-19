Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case.

Discuss your accessibility metric and how you arrived at it below:

Description:
WITH accessible_stops AS (
    SELECT
        stop_id,
        stop_name,
        geog,
        wheelchair_boarding
    FROM septa.bus_stops
    WHERE wheelchair_boarding = 1
),
neighborhood_areas AS (
    SELECT
        neighborhood_name,
        ST_Area(geog::geography) / 1000000 AS area_sq_km -- Convert area from sq meters to sq kilometers
    FROM azavea.neighborhoods
),
stops_per_neighborhood AS (
    SELECT
        n.neighborhood_name,
        COUNT(a.stop_id) AS accessible_stops,
        n.area_sq_km
    FROM accessible_stops a
    JOIN azavea.neighborhoods n ON ST_Contains(n.geog, a.geog)
    GROUP BY n.neighborhood_name, n.area_sq_km
)
SELECT
    neighborhood_name,
    accessible_stops,
    area_sq_km,
    (accessible_stops / NULLIF(area_sq_km, 0)) AS wfbs_density -- Density of wheelchair-friendly bus stops per sq km
FROM stops_per_neighborhood
ORDER BY wfbs_density DESC;