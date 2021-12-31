## Aggregating PUR data 

[California's pesticide use reporting database] (http://www.cdpr.ca.gov/docs/pur/purmain.htm) provides continuous pesticide and agricultural land use data at 1-square mile resolution. The data were downloaded, cleaned, and imported into a PostgreSQL database.
Each row in the table is a record of one pesticide application, which includes the pesticide product name, chemical type, amount of chemical used, time treated, acre of land treated, and crop planted. 

SQL scripts here are used to aggregate the farm-field-level data to predefined "sections" that assocated with a shapfile. Aggregated data can then be used for research or mapping. 


