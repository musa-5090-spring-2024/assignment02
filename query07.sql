with t1 as (
    select
        stops.wheelchair_boarding as wheelchair,
        areas.name as neighborhood,
        count(*) as bus_count
    from septa.bus_stops as stops
    inner join azavea.neighborhoods as areas
        on st_coveredby(stops.geog, areas.geog)
    group by neighborhood, wheelchair
),

t2 as (
    select
        neighborhood,
        sum(case when wheelchair = 1 then bus_count else 0 end)::numeric as num_bus_stops_accessible,
        sum(case when wheelchair = 2 then bus_count else 0 end)::numeric as num_bus_stops_inaccessible
    from t1
    group by neighborhood
)

select
    neighborhood,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible,
    round(num_bus_stops_accessible / (num_bus_stops_accessible + num_bus_stops_inaccessible) * num_bus_stops_accessible, 2) as metric
from t2
order by metric asc
limit 5
