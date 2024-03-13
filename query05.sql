/*
Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood
dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed.
Use the
[GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the
metric you devise in rating neighborhoods.

    _NOTE: There is no automated test for this question, as there's no one right answer.
    With urban data analysis, this is frequently the case._

    Discuss your accessibility metric and how you arrived at it below:

    **Description:**

    I started by calculating a ratio of wheelchair "accessbile stops" (where wheelchair_boarding = 1)
    to all stops for each neighborhood (using an inner join between the bus_stops table and the
    neighborhoods table). Since the good majority of stops are considered "accessible", I needed an
    additional metric. I decided to calculate the density of stops per neighborhood (by land area),
    with the thinking that a higher stop density means less traveling for someone in a wheelchair to the
    nearest stop. I then multiplied the twp numbers together to get the final "access_score".

*/

select
    hoods.listname as neighborhood,
    round((
        count(case stops.wheelchair_boarding when 1 then 1 end)::numeric
        / count(stops.stop_id)::numeric
    )
    * ((count(stops.stop_id) / hoods.shape_area) * 1000000)::numeric, 2) as access_score
from septa.bus_stops as stops
inner join azavea.neighborhoods as hoods
    on st_coveredby(stops.geog, hoods.geog)
group by neighborhood, hoods.shape_area
order by access_score desc
