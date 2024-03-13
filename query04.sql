/*
Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed,
find the **two** routes with the longest trips.

    _Your query should run in under two minutes._

    >_**HINT**: The `ST_MakeLine` function is useful here. You can see an example
    of how you could use it at [this MobilityData walkthrough]
    (https://docs.mobilitydb.com/MobilityDB-workshop/master/ch04.html#:~:text=INSERT%20INTO%20shape_geoms)
    on using GTFS data. If you find other good examples, please share them in Slack._

    >_**HINT**: Use the query planner (`EXPLAIN`) to see if there might be opportunities to s
    peed up your query with indexes. For reference, I got this query to run in about 15 seconds._

    >_**HINT**: The `row_number` window function could also be useful here. You can read more
    about window functions [in the PostgreSQL documentation]
    (https://www.postgresql.org/docs/9.1/tutorial-window.html). That documentation page
    uses the `rank` function, which is very similar to `row_number`. For more info about window functions you can check out:_
    >*   📑 [_An Easy Guide to Advanced SQL Window Functions_]
    (https://towardsdatascience.com/a-guide-to-advanced-sql-window-functions-f63f2642cbf9)
    in Towards Data Science, by Julia Kho
    >*   🎥 [_SQL Window Functions for Data Scientists_]
    (https://www.youtube.com/watch?v=e-EL-6Vnkbg) (and a [follow up]
    (https://www.youtube.com/watch?v=W_NBnkLLh7M) with examples) on YouTube, by Emma Ding

    **Structure:**
    ```sql
    (
        route_short_name text,  -- The short name of the route
        trip_headsign text,  -- Headsign of the trip
        shape_geog geography,  -- The shape of the trip
        shape_length numeric  -- Length of the trip in meters, rounded to the nearest whole number
    )
    ```
*/

select
    trips.route_id as route_short_name,
    trips.trip_headsign,
    shapes.shape_geom as shape_geog,
    round(st_length(shapes.shape_geom))::numeric as shape_length
from septa.bus_trips as trips
inner join septa.shape_geoms as shapes
    on trips.shape_id like shapes.shape_id
group by route_short_name, trips.trip_headsign, shape_geog
order by shape_length desc
limit 2;
