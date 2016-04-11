DROP TABLE IF EXISTS ca_pest.fieldspre;
DROP TABLE IF EXISTS ca_pest.fields CASCADE;
CREATE TABLE ca_pest.fieldspre (
    field_id text NOT NULL,
    site_code int NOT NULL);

-- CREATE INDEX field_comtrs_idx 
--   ON ca_pest.fields
--   USING btree
--   (comtrs COLLATE pg_catalog."default");

INSERT INTO ca_pest.fieldspre(
SELECT DISTINCT u.grower_id||'_'||u.site_loc_id||'_'||u.site_code AS field_id, u.site_code
FROM pur.udc u
--INNER JOIN pur.site_code s ON s.site_code = u.site_code
WHERE  year BETWEEN 2000 AND 2013 
	AND site_loc_id IS NOT NULL
	AND grower_id IS NOT NULL
	AND comtrs IS NOT NULL
	AND comtrs ~ '^[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}$');


CREATE TABLE ca_pest.fields (
    field_id text NOT NULL,
    site_code int NOT NULL,
    site_sub_grp int,
      crop text,
    CONSTRAINT field_pkey PRIMARY KEY (field_id));
INSERT INTO ca_pest.fields(
 SELECT DISTINCT field_id, p.site_code, s.site_sub_grp, s.crop
 FROM ca_pest.fieldspre p
 INNER JOIN ca_pest.site_code s ON s.site_code = p.site_code
 WHERE length(cast(s.site_code as text))>= 4  
	AND (s.site_sub_grp < 43)
 ORDER BY field_id);

DROP TABLE IF EXISTS ca_pest.udc_fld_grp;
CREATE TABLE ca_pest.udc_fld_grp(
  year integer NOT NULL,
  field_id text NOT NULL REFERENCES ca_pest.fields ON DELETE CASCADE ON UPDATE CASCADE,
  comtrs character varying(11) NOT NULL,
  township integer,
  crop text,
  prodno integer,
  chem_code integer,
  use_type character varying(30),
  prodchem_pct real, 
  lbs_chm_used real,
  lbs_prd_used real,
  unit_of_meas text,
  acre_planted real,
  unit_planted text,
  acre_treated real,
  unit_treated text,
  applic_dt date,
  FOREIGN KEY(field_id) REFERENCES ca_pest.fields (field_id)
);

INSERT INTO ca_pest.udc_fld_grp(
SELECT DISTINCT u.year, u.grower_id||'_'||u.site_loc_id||'_'||u.site_code AS field_id, u.comtrs, 
	u.township::integer, 
	s.crop, u.prodno, u.chem_code, a.use_type, u.prodchem_pct, u.lbs_chm_used, 
	u.lbs_prd_used, u.unit_of_meas, u.acre_planted,
	u.unit_planted, u.acre_treated, u.unit_treated, u.applic_dt
FROM pur.udc u
	LEFT JOIN pur.ai_use_type_larry a ON chem_code=a.ai_cd
	INNER JOIN ca_pest.fields s ON u.grower_id||'_'||u.site_loc_id||'_'||u.site_code =  s.field_id

WHERE --county_cd In ('04','06','07','10','11','13','15','16','20','24','25','27',
	--	'28','34','39','40','42','44','48','49','50','51','54','56','57','58') AND
		u.year BETWEEN 2000 AND 2013 
	AND u.site_loc_id IS NOT NULL
	AND u.grower_id IS NOT NULL
	AND u.comtrs IS NOT NULL 
	AND u.comtrs ~ '^[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{2}$' -- EXCLUDE DATA WITH INCOMPLETE INFO
	AND length(cast(u.site_code as text))>= 4 AND s.site_sub_grp < 43
ORDER BY u.year, field_id, comtrs, applic_dt, use_type);


DROP TABLE IF EXISTS ca_pest.udc_fld_grp_BK;
SELECT * INTO ca_pest.udc_fld_grp_BK FROM ca_pest.udc_fld_grp;

DROP TABLE IF EXISTS ca_pest.udc_fld_grp_area;

WITH
        --get duplicated comtrs and get the sum value 
    com_area AS (
        SELECT co_mtrs AS comtrs, SUM(area) AS area
        FROM ca_pestt.purlayer
        GROUP BY co_mtrs),
    
--    SELECT * FROM com_area;

SELECT a.*, b.area*0.000247105
        INTO ca_pest.udc_fld_grp_area
        FROM ca_pest.udc_fld_grp a
        INNER JOIN com_area b ON a.comtrs = b.comtrs
        ORDER BY a.year, a.comtrs;
          

/***UPDATE MISSING ACRE_PLANTED DATA***/
UPDATE  ca_pest.udc_fld_grp_area SET acre_planted=acre_treated 
 	WHERE acre_planted IS NULL AND field_id IN ('2512253443A_4417_28012','40124021264_00010001_29143');
 
UPDATE ca_pest.udc_fld_grp_area SET acre_planted=270
 	WHERE acre_planted IS NULL AND field_id IN ('561156X0023_06_13031');
 
UPDATE ca_pest.udc_fld_grp_area SET acre_planted=32
 	WHERE acre_planted IS NULL AND field_id IN ('4313430758R_KR2_29119');


UPDATE ca_pest.udc_fld_grp_area SET acre_treated = acre_planted WHERE acre_treated > acre_planted + 0.1;
