with census_blocks as (
    select
        geog,
        '1500000US' || geoid as geoid
    from census.blockgroups_2020
),

census_blocks_detailed as (
    select
        pop.total as pop,
        census_blocks.geog,
        split_part(pop.geoname, ',', 1) as block_group,
        split_part(pop.geoname, ',', 2) as tract,
        split_part(pop.geoname, ',', 3) as county,
        split_part(pop.geoname, ',', 4) as state
    from census_blocks
    left join census.population_2020 as pop
        on (census_blocks.geoid = pop.geoid)
),

rail_tract as (
    select
        rail_stops.stop_id,
        rail_stops.stop_name,
        rail_stops.zone_id,
        rail_stops.stop_lat,
        rail_stops.stop_lon,
        census_blocks_detailed.state,
        census_blocks_detailed.county,
        census_blocks_detailed.tract,
        rail_stops.geog,
        round((st_distance(rail_stops.geog, st_makepoint(-75.181436, 39.965090)::geography) / 1000)::numeric, 2) as dist_art
    from septa.rail_stops
    inner join census_blocks_detailed
        on st_intersects(rail_stops.geog, census_blocks_detailed.geog)
),

census_pop as (
    select
        rail_stops.stop_id as stop_id,
        sum(census_blocks_detailed.pop) as km_pop
    from septa.rail_stops
    inner join census_blocks_detailed
        on (st_dwithin(rail_stops.geog, st_centroid(census_blocks_detailed.geog::geometry)::geography, 1000))
    group by stop_id
    order by km_pop desc
)

select
    rail_tract.stop_id,
    rail_tract.stop_name,
    rail_tract.stop_lon,
    rail_tract.stop_lat,
    'The ' || rail_tract.stop_name || ' commuter rail stop is found in Zone ' || rail_tract.zone_id
    || '. The stop is located in' || rail_tract.tract || ' in' || rail_tract.county || ',' || rail_tract.state
    || '. Approximately ' || census_pop.km_pop || ' people live within 1 kilometer of the stop and the stop is located '
    || rail_tract.dist_art || ' kilometers from the Philadelphia art museum. SQL is fun :)' as stop_desc
from rail_tract
left join census_pop
    on (rail_tract.stop_id = census_pop.stop_id)
