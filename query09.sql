-- Find the geo_id of the block group containing Meyerson Hall using coordinates
SELECT
    blocks.geoid as geo_id
FROM
(
SELECT
	ogc_fid,
	address,
	owner1,
	geog
FROM phl.pwd_parcels
	WHERE address LIKE '%220-30 S 34TH ST%' AND owner1 like '%PENN%'
) AS meyerson_parcel

JOIN

(
	SELECT
		geoid,
		geog
FROM census.blockgroups_2020
) AS blocks

ON st_intersects (
meyerson_parcel.geog::geography,
blocks.geog::geography
);