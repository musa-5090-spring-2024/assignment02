ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=hw02 user=postgres password=Chiesaditotti10" `
    -nln census.blockgroups_2020 `
    -t_srs EPSG:4326 `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "C:\Users\richa\GitHub\musa_5090_assignment02\data\pa_census\tl_2020_42_bg.shp"