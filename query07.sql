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