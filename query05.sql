/* Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's 
neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the 
Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the 
metric you devise in rating neighborhoods.

NOTE: There is no automated test for this question, as there's no one right answer. 
With urban data analysis, this is frequently the case.

Discuss your accessibility metric and how you arrived at it below:

Description:

The metric I used to rate neighborhoods by their bus stop accessibility for wheelchairs 
is the ratio of accessible bus stops to the total number of bus stops in each 
neighborhood. This metric is calculated as the number of accessible bus stops divided 
by the sum of the number of accessible and inaccessible bus stops. The metric ranges from 
0 to 1, where 0 indicates that no bus stops in the neighborhood are accessible to people 
in wheelchairs and 1 indicates that all bus stops in the neighborhood are accessible to 
people in wheelchairs. 

*/
	