DROP TABLE IF EXISTS ca_pest.pur_fld_acres;
DROP TABLE IF EXISTS ca_pest.pur_comtrs_acres;

CREATE TABLE ca_pest.pur_fld_acres(
        year int NOT NULL,
        field_id text NOT NULL,
        comtrs text NOT NULL,
        crop TEXT NOT NULL,
        acre_planted numeric,
        acre_max numeric,
        acre_treated numeric,
        acre_t_max numeric,
        com_acre numeric
        );

CREATE INDEX comkeyf ON ca_pest.pur_fld_acres (comtrs);
INSERT INTO ca_pest.pur_fld_acres (
        SELECT year, field_id, comtrs, crop,
                MEDIAN(acre_planted) AS acre_planted,
                MAX(acre_planted) AS acre_max,
                AVG(acre_treated) AS acre_treated,
                MAX(acre_treated) AS acre_t_max,
                com_area AS com_acre
        FROM ca_pest.udc_fld_grp_area
        WHERE acre_planted IS NOT NULL AND acre_treated IS NOT NULL AND crop IS NOT NULL 
        GROUP BY field_id, year, comtrs, com_acre, crop
        ORDER BY field_id, crop);

DROP TABLE IF EXISTS ca_pest.pur_comtrs_acres;
CREATE TABLE ca_pest.pur_comtrs_acres(
        year int NOT NULL,
        comtrs text NOT NULL,
        crop TEXT NOT NULL,
        acre_planted numeric,
        acre_max numeric,
        acre_treated numeric,
        acre_t_max numeric,
        com_acre numeric 
        
        );

CREATE INDEX comkeyc ON ca_pest.pur_comtrs_acres (comtrs);

INSERT INTO ca_pest.pur_comtrs_acres(
        SELECT year, comtrs, crop,
                SUM(acre_planted) AS acre_planted, 
                SUM(acre_max) AS max_planted,
                SUM(acre_treated) AS acre_treated,
                SUM(acre_treated) AS max_treated, 
                com_acre

        FROM ca_pest.pur_fld_acres
        GROUP BY year, comtrs, crop, com_acre
        ORDER BY year, comtrs, crop, com_acre);
