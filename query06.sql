/*
What are the top five neighborhoods according to your accessibility metric?
*/

WITH
bg_w_pop AS (
    SELECT
        pop.total,
        bg.geog,
        SUBSTRING(pop.geoid, 10) AS geoid
    FROM census.population_2020 AS pop
    INNER JOIN census.blockgroups_2020 AS bg ON SUBSTRING(pop.geoid, 10) = bg.geoid
),

n_w_pop AS (
    SELECT
        n.name,
        n.geog,
        SUM(bg.total) AS population
    FROM
        azavea.neighborhoods AS n
    INNER JOIN
        bg_w_pop AS bg
        ON
            ST_INTERSECTS(n.geog, bg.geog)
    GROUP BY n.name, n.geog
),

n_conditions AS (
    SELECT
        n.name,
        n.population,
        n.geog,
        SUM(CASE WHEN stops.wheelchair_boarding = 2 THEN 1 ELSE 0 END) AS num_bus_stops_inaccessible,
        SUM(CASE WHEN stops.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible
    FROM septa.bus_stops AS stops
    INNER JOIN n_w_pop AS n ON ST_INTERSECTS(n.geog, stops.geog)
    GROUP BY n.name, n.geog, n.population
),

metric_table AS (
    SELECT
        con.name::text AS neighborhood_name,
        con.num_bus_stops_inaccessible::integer,
        con.num_bus_stops_accessible::integer,
        con.population,
        (con.num_bus_stops_accessible / (con.population * 1.0)) * 100 AS m1,
        ((con.num_bus_stops_inaccessible + con.num_bus_stops_accessible) / (con.population * 1.0)) * 100 AS m2,
        (con.num_bus_stops_accessible / (con.population * 1.0)) * 100 * 0.6 + ((con.num_bus_stops_inaccessible + con.num_bus_stops_accessible) / (con.population * 1.0)) * 100 * 0.4 AS m3
    FROM n_conditions AS con
    WHERE con.population > 100
)

SELECT
    neighborhood_name,
    m3 AS accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM metric_table
ORDER BY accessibility_metric DESC
LIMIT 5
