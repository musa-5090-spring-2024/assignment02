WITH parcels_count AS (
    SELECT
        nhoods.mapname,
        COUNT(*) AS num_parcels
    FROM phl.pwd_parcels AS pwd
    FULL JOIN phl.neighborhoods AS nhoods
        ON ST_INTERSECTS(pwd.geog, nhoods.geog)
    GROUP BY nhoods.mapname
)

SELECT
    nhoods.mapname,
    ROUND(COUNT(CASE WHEN stops.wheelchair_boarding = '1' THEN 1 END))::numeric AS num_accessible,
    ROUND(COUNT(CASE WHEN stops.wheelchair_boarding != '1' THEN 1 END))::numeric AS num_inaccessible,
    ROUND(COUNT(CASE WHEN stops.wheelchair_boarding = '1' THEN 1 END)::numeric / parcels_count.num_parcels * 100, 1) AS normalized_pct_accessible,
    COUNT(stops.stop_id) AS num_stops
FROM phl.neighborhoods AS nhoods
FULL JOIN septa.bus_stops AS stops
    ON ST_INTERSECTS(nhoods.geog, stops.geog)
FULL JOIN
    parcels_count ON nhoods.mapname = parcels_count.mapname
GROUP BY
    nhoods.mapname, parcels_count.num_parcels
ORDER BY normalized_pct_accessible DESC;
