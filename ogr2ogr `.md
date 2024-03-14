ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5432 dbname=musa509a2 user=postgres password=981109Li." `
    -nln phl.landmark `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "C:\Users\jiahangl\OneDrive - PennO365\MUSA509\a2\landmark.geojson"


C:\Users\Public\MUSA509\bus\shapes.txt csvcut -C 1-4 shapes.txt > shapesclean.csv  

csvcut -c 1,2,3,4 C:\Users\Public\MUSA509\bus\shapes.txt > shapesclean.txt

csvcut -c 1,2,3,4 C:\Users\Public\MUSA509\bus\shapes.txt > C:\Users\Public\MUSA509\bus\shapesclean.txt
csvcut -c 1,2,3,4,6,7,8 C:\Users\Public\MUSA509\bus\trips.txt > C:\Users\Public\MUSA509\bus\tripsclean.txt

csvcut -c 1,2,4,6,8,9 C:\Users\Public\MUSA509\busnew\routes.txt > C:\Users\Public\MUSA509\bus\tripsclean.txt