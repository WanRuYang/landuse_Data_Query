California's pesticide use reporting database (http://www.cdpr.ca.gov/docs/pur/purmain.htm) provides continuous pesticide and agricultural land use data at 1-square mile resolution. Land parcel level sptial data is not publicly available, but the data were reported by each farmer for each land parcel.
I stored the dataset in a postgresql database. SQL scripts here are used to aggregate the farm-field-level data to predefined "sections" that assocated with a shapfile. Aggregated data can then be used for reserach or mapping. 


