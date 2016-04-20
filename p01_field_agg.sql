-- CREATE INDEX ai_idx ON pur.ai_use_type_larry(ai_cd);
-- CREATE INDEX type_idx ON pur.ai_use_type_larry(use_type);
-- CREATE INDEX typepest_idx ON pur.type_pesticide(typepest_cd);

-- create field id table
DROP TABLE IF EXISTS pur_fld.fields CASCADE;
 
CREATE TABLE pur_fld.fields (
    year int NOT NULL,
    field_id text NOT NULL,
    site_code int NOT NULL
    );

INSERT INTO pur_fld.fields(
SELECT DISTINCT u.year, 
  u.grower_id||'_'||u.site_loc_id||'_'||CAST(u.site_code AS text) AS field_id,
  u.site_code

FROM pur.udc u
WHERE  u.year BETWEEN 2000 AND 2014 
  AND  u.unit_planted = 'A' AND u.unit_treated='A'
	AND u.site_loc_id IS NOT NULL
	AND u.grower_id IS NOT NULL 
  AND u.grower_id NOT IN ('.','?')
	AND u.comtrs IS NOT NULL
	AND u.comtrs ~ '^[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}$'
  AND length(u.site_code::text)>3 AND substring(u.site_code::text, 1, 2)::int < 40
 );


ALTER TABLE pur_fld ADD CONSTRAINT field_pkey PRIMARY KEY (field_id);


-- group to field_id -- crop type will be dealt later  -- use foreign key 
DROP TABLE IF EXISTS pur_fld.udc_fld_grp;
CREATE TABLE pur_fld.udc_fld_grp(
  year integer NOT NULL,
  field_id text NOT NULL,
  comtrs character varying(11) NOT NULL,
  township integer,
  prodno integer,
  chem_code integer,
  use_type character varying(30),
  prodchem_pct real, 
  lbs_chm_used real,
  lbs_prd_used real,
  unit_of_meas text,
  site_code integer,
  acre_planted real,
  unit_planted text,
  acre_treated real,
  unit_treated text,
  applic_dt date 
  );

WITH  com_area AS (
        SELECT co_mtrs AS comtrs, SUM(area) AS area
        FROM pur_fld.purlayer
        GROUP BY co_mtrs)

INSERT INTO pur_fld.udc_fld_grp(
SELECT DISTINCT u.year, 
  u.grower_id||'_'||u.site_loc_id||'_'||u.site_code AS field_id, 
  u.comtrs, 
	u.township::integer, --get use_type from a
	u.prodno, u.chem_code, a.use_type, u.prodchem_pct, u.lbs_chm_used, 
	u.lbs_prd_used, u.unit_of_meas, u.site_code, u.acre_planted,
	u.unit_planted, u.acre_treated, u.unit_treated, u.applic_dt, 
  b.area*0.000247105 AS com_acre
FROM pur.udc u
 -- left join bebase not every record has a chem_code
	LEFT JOIN pur.ai_use_type_larry a ON chem_code=a.ai_cd
  INNER JOIN com_area b ON u.comtrs = b.comtrs

WHERE --county_cd In ('04','06','07','10','11','13','15','16','20','24','25','27',
	--	'28','34','39','40','42','44','48','49','50','51','54','56','57','58') AND
		u.year BETWEEN 2000 AND 2014 
	AND u.site_loc_id IS NOT NULL
	AND u.grower_id IS NOT NULL
	AND u.comtrs IS NOT NULL 
	AND u.comtrs ~ '^[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}$' -- EXCLUDE DATA WITH INCOMPLETE INFO
	AND length(u.site_code::text)>3 AND substring(u.site_code::text, 1, 2)::int < 40
ORDER BY u.year, field_id, comtrs, applic_dt, use_type);

ALTER TABLE pur_fld ADD CONSTRAINT fk_fld 
        FOREIGN KEY (field_id) REFERENCES pur_fld.fields (field_id) MATCH SIMPLE 
        ON UPDATE CASCADE ON DELETE CASCADE;

/***UPDATE MISSING ACRE_PLANTED DATA***/
-- UPDATE  pur_fld.udc_fld_grp_area SET acre_planted=acre_treated 
--  	WHERE acre_planted IS NULL AND field_id IN ('2512253443A_4417_28012','40124021264_00010001_29143');
 
-- UPDATE pur_fld.udc_fld_grp_area SET acre_planted=270
--  	WHERE acre_planted IS NULL AND field_id IN ('561156X0023_06_13031');
 
-- UPDATE pur_fld.udc_fld_grp_area SET acre_planted=32
--  	WHERE acre_planted IS NULL AND field_id IN ('4313430758R_KR2_29119');


UPDATE pur_fld.udc_fld_grp SET acre_treated = acre_planted WHERE acre_treated > acre_planted + 0.1;

-- aggregate data to fld , comtrs, comtrs by crop
DROP TABLE IF EXISTS pur_fld.pur_fld_acres;
DROP TABLE IF EXISTS pur_fld.pur_comtrs_acres;

CREATE TABLE pur_fld.pur_fld_acres(
        year int NOT NULL,
        field_id text NOT NULL,
        comtrs text NOT NULL,
        site_code int, 
        acre_planted numeric,
        acre_max numeric,
        acre_treated numeric,
        acre_t_max numeric,
        com_acre numeric
        );

-- ALREADY HAS A COMTRS 
INSERT INTO pur_fld.pur_fld_acres (
        SELECT f.year, f.field_id, f.comtrs, f.site_code
                MEDIAN(f.acre_planted) AS acre_planted,
                MAX(f.acre_planted) AS acre_max,
                AVG(f.acre_treated) AS acre_treated,
                MAX(f.acre_treated) AS acre_t_max,
                com_acre
        FROM pur_fld.udc_fld_grp f
          WHERE acre_planted IS NOT NULL AND acre_treated IS NOT NULL 
        GROUP BY field_id, year, comtrs, com_acre, site_code
        ORDER BY field_id, site_code);


CREATE TABLE pur_fld.pur_comtrs_acres(
        year int NOT NULL,
        comtrs text NOT NULL,
        site_code text NOT NULL,
        acre_planted numeric,
        acre_max numeric,
        acre_treated numeric,
        acre_t_max numeric,
        com_acre numeric 
        );

INSERT INTO pur_fld.pur_comtrs_acres(
        SELECT year, comtrs, site_code,
                SUM(acre_planted) AS acre_planted, 
                SUM(acre_max) AS max_planted,
                SUM(acre_treated) AS acre_treated,
                SUM(acre_treated) AS max_treated, 
                com_acre

        FROM pur_fld.pur_fld_acres
        GROUP BY year, comtrs, site_code, com_acre
        ORDER BY year, comtrs, site_code, com_acre);


ALTER TABLE pur_fld.pur_comtrs_acres ADD COLUMN crop text;
ALTER TABLE pur_fld.pur_comtrs_acres ADD COLUMN dwr_crop text;
ALTER TABLE pur_fld.pur_comtrs_acres ADD COLUMN seg_crop text;


EXPLAIN ANALYZE UPDATE pur_fld.pur_comtrs_acres c 
 SET crop = s.crop
FROM pur.sites s
WHERE c.site_code = s.site_code::text;

UPDATE pur_fld.pur_comtrs_acres c 
 SET dwr_crop = s.dwr_crop
FROM pur.sites s
WHERE c.site_code = s.site_code::text;

UPDATE pur_fld.pur_comtrs_acres c 
 SET seg_crop = s.seg_crop
FROM pur.sites s
WHERE c.site_code = s.site_code::text;

-- change site_code column type -- chekc the code to avoid duplicate columns and index, set index after insert 

DROP TABLE IF EXISTS pur_fld.comtrs_dwrcrop;
CREATE TABLE pur_fld.comtrs_dwrcrop(
  year int, 
  comtrs varchar(11), 
  acre_planted numeric, 
  acre_max numeric, 
  com_acre numeric, 
  dwr_crop text
);
INSERT INTO pur_fld.comtrs_dwrcrop (
  SELECT year, comtrs, SUM(acre_planted) AS acre_planted , SUM(acre_max) AS acre_max, com_acre, dwr_crop FROM pur_fld.pur_comtrs_acres GROUP BY year, comtrs,com_acre, dwr_crop);

DROP TABLE IF EXISTS pur_fld.comtrs_allcrop;
CREATE TABLE pur_fld.comtrs_crop(
  year int, 
  comtrs varchar(11), 
  acre_planted numeric, 
  acre_max numeric, 
  com_acre numeric, 
  dwr_crop text
);
INSERT INTO pur_fld.comtrs_segcrop (
  SELECT year, comtrs, SUM(acre_planted) AS acre_planted , SUM(acre_max) AS acre_max, com_acre, dwr_crop FROM pur_fld.pur_comtrs_acres GROUP BY year, comtrs,com_acre, dwr_crop);

DROP TABLE IF EXISTS pur_fld.comtrs_segcrop;
CREATE TABLE pur_fld.comtrs_segcrop(
  year int, 
  comtrs varchar(11), 
  acre_planted numeric, 
  acre_max numeric, 
  com_acre numeric, 
  dwr_crop text
);
INSERT INTO pur_fld.comtrs_segcrop (
  SELECT year, comtrs, SUM(acre_planted) AS acre_planted , SUM(acre_max) AS acre_max, com_acre, dwr_crop FROM pur_fld.pur_comtrs_acres GROUP BY year, comtrs,com_acre, dwr_crop);
