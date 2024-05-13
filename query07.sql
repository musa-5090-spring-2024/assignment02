CREATE TABLE bottom_five_neighborhoods AS
SELECT
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM
    neighborhood_accessibility_stats
ORDER BY
    accessibility_metric ASC  -- Order by accessibility metric in ascending order
LIMIT
    5;