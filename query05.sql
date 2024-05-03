-- Question 5

--Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

--Discuss your accessibility metric and how you arrived at it below.

--Here, my final index for accessibility is comprised of two different metrics—the average distance from any given point in the neighbourhood to the closest accessible bus stop, and the density of accessible bus stops per km2 within the neighbourhood.
--Accessibility here to me means that a person with disability would not need to travel very far to reach a bus stop with accessible options.
--To create my index, I first calculate the average distance and density measure. To calculate my average distance, I first create a grid of randomly distributed points using the st_generatepoints function.
--these grid points will be my starting distance for the average distance calculation.
--My measurement for density measured the total number of accessible bus stops over the entire area of the neighbourhood. I use density rather than proportion here because distance is my most important value to reduce in an accessible neighbourhood.
--I normalize my measures so they can be situated around 1.

--workflow: join bus stop information to neighbourhood shapes. Create a random grid layer that contains dots across all of the neighbourhood. Find the average nearest neighbour distance to any one bus stop, also calculate accessible bus stop by sq meter in the neighbourhood.

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