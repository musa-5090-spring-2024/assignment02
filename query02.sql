/* Which eight bus stops have the smallest population above 500 people inside of Philadelphia within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of 42101 -- that's 42 for the state of PA, and 101 for Philadelphia county)?
*/
WITH
    septa_bus_stop_blockgroups AS
    (SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
        FROM septa.bus_stops AS stops
        INNER JOIN census.blockgroups_2020 AS bg 
        on ST_dwithin(stops.geog,bg.geog,800)
    ),
    septa_bus_stop_blockgroups_population AS
    (SELECT
        stop_id,
        SUM(pop.total) as estimated_pop_800m
        FROM septa_bus_stop_blockgroups
        inner join census.population_2020 as pop
        on septa_bus_stop_blockgroups.geoid = pop.geoid
        GROUP BY septa_bus_stop_blockgroups.stop_id
        having SUM(pop.total) > 500)
        SELECT
        stops.stop_name,
        estimated_pop_800m,
        stops.geog
        from septa_bus_stop_blockgroups_population
        inner join septa.bus_stops as stops
        on septa_bus_stop_blockgroups_population.stop_id = stops.stop_id
        order by estimated_pop_800m ASC
        limit 8

