/*
4.  Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips.

    _Your query should run in under two minutes._

    >_**HINT**: The `ST_MakeLine` function is useful here. You can see an example of how you could use it at [this MobilityData walkthrough](https://docs.mobilitydb.com/MobilityDB-workshop/master/ch04.html#:~:text=INSERT%20INTO%20shape_geoms) on using GTFS data. If you find other good examples, please share them in Slack._

    >_**HINT**: Use the query planner (`EXPLAIN`) to see if there might be opportunities to speed up your query with indexes. For reference, I got this query to run in about 15 seconds._

    >_**HINT**: The `row_number` window function could also be useful here. You can read more about window functions [in the PostgreSQL documentation](https://www.postgresql.org/docs/9.1/tutorial-window.html). That documentation page uses the `rank` function, which is very similar to `row_number`. For more info about window functions you can check out:_
    >*   📑 [_An Easy Guide to Advanced SQL Window Functions_](https://towardsdatascience.com/a-guide-to-advanced-sql-window-functions-f63f2642cbf9) in Towards Data Science, by Julia Kho
    >*   🎥 [_SQL Window Functions for Data Scientists_](https://www.youtube.com/watch?v=e-EL-6Vnkbg) (and a [follow up](https://www.youtube.com/watch?v=W_NBnkLLh7M) with examples) on YouTube, by Emma Ding

    **Structure:**
    ```sql
    (
        route_short_name text,  -- The short name of the route
        trip_headsign text,  -- Headsign of the trip
        shape_geog geography,  -- The shape of the trip
        shape_length double precision  -- Length of the trip in meters
    )
    ```
*/


WITH trip_shapes AS (
    SELECT
        r.route_short_name,
        t.trip_headsign,
        ST_MakeLine(s.geog::geometry ORDER BY s.shape_pt_sequence)::geography AS shape_geog
    FROM
        septa.bus_shapes AS s
    JOIN septa.bus_trips AS t ON s.shape_id = t.shape_id
    JOIN septa.bus_routes AS r ON t.route_id = r.route_id
    GROUP BY r.route_short_name, t.trip_headsign, t.shape_id
),
shape_lengths AS (
    SELECT
        route_short_name,
        trip_headsign,
        shape_geog,
        ST_Length(shape_geog) AS shape_length
    FROM trip_shapes
)
SELECT
    route_short_name,
    trip_headsign,
    shape_geog,
    shape_length
FROM shape_lengths
ORDER BY shape_length DESC
LIMIT 2;

