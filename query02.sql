/*
Which eight bus stops have the smallest population above 500 people inside of Philadelphia within 800 meters of the stop
(Philadelphia county block groups have a geoid prefix of 42101 -- that's 42 for the state of PA,
and 101 for Philadelphia county)?
*/

with

philly_blocks as (
    select
        geoid,
        geog
    from census.blockgroups_2020
    where countyfp = '101'
),

septa_bus_stop_blockgroups as (
    select
        stops.stop_id,
        stops.stop_name,
        stops.geog,
        '1500000US' || bg.geoid as geoid
    from septa.bus_stops as stops
    inner join philly_blocks as bg
        on st_dwithin(stops.geog, bg.geog, 800)
)

select
    septa_bus_stop_blockgroups.stop_name as stop_name,
    septa_bus_stop_blockgroups.geog as geog,
    sum(census.total) as estimated_pop_800m
from septa_bus_stop_blockgroups
inner join census.population_2020 as census
    on (septa_bus_stop_blockgroups.geoid = census.geoid)
group by stop_name, geog
having sum(census.total) > 500
order by estimated_pop_800m asc
limit 8
