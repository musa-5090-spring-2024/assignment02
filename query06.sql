/*
What are the _top five_ neighborhoods according to your accessibility metric?

```sql
    (
      neighborhood_name text,  -- The name of the neighborhood
      accessibility_metric ...,  -- Your accessibility metric value
      num_bus_stops_accessible integer,
      num_bus_stops_inaccessible integer
    )
    ```
*/

select 
    hoods.listname::text as neighborhood_name,
    round((count(case stops.wheelchair_boarding when 1 then 1 else null end)::numeric/
    count(stops.stop_id)::numeric) *
    ((count(stops.stop_id)/hoods.shape_area)*1000000)::numeric,2) as accessibility_metric,
    count(case stops.wheelchair_boarding when 1 then 1 else null end)::integer as num_bus_stops_accessible,
    count(case stops.wheelchair_boarding when 2 then 1 else null end)::integer as num_bus_stops_inaccessible
from septa.bus_stops as stops
inner join azavea.neighborhoods as hoods
    on st_coveredby(stops.geog, hoods.geog)
group by neighborhood_name, hoods.shape_area
order by accessibility_metric desc
limit 5;