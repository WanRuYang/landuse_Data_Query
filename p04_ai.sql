DROP TABLE IF EXISTS ca_pest.pur_comtrs_ai;

CREATE TABLE ca_pest.pur_comtrs_ai
(
  year integer,
  comtrs character varying(11),
  crop text,
  herbicide_aikg double precision,
  insecticide_aikg double precision,
  fungicide_aikg double precision,
  fumigant_aikg double precision
)
WITH (
  OIDS=FALSE
);
ALTER TABLE ca_pest.pur_comtrs_ai
  OWNER TO wanru;


WITH a AS (
	SELECT year, comtrs, crop, (SUM(lbs_chm_used))*0.454 AS herbicide_aikg
	FROM ca_pest.udc_fld_grp_area
	WHERE use_type='HERBICIDE'
	GROUP BY year, comtrs, crop, use_type),
    b  AS (
	SELECT year, comtrs, crop, (SUM(lbs_chm_used))*0.454 AS insecticide_aikg
	FROM ca_pest.udc_fld_grp_area
	WHERE use_type='INSECTICIDE'
	GROUP BY year, comtrs, crop, use_type),
    c  AS (
	SELECT year, comtrs, crop, (SUM(lbs_chm_used))*0.454 AS fungicide_aikg
	FROM ca_pest.udc_fld_grp_area
	WHERE use_type='FUNGICIDE'
	GROUP BY year, comtrs, crop, use_type),
    d  AS (
	SELECT year, comtrs, crop, (SUM(lbs_chm_used))*0.454 AS fumigant_aikg
	FROM ca_pest.udc_fld_grp_area
	WHERE use_type='FUMIGANT'
	GROUP BY year, comtrs, crop, use_type)
INSERT INTO ca_pest.pur_comtrs_ai(
	SELECT a.*, insecticide_aikg, fungicide_aikg, fumigant_aikg 
		--INTO ca_pest.pur_comtrs_ai
	FROM a
	FULL JOIN b ON a.year=b.year AND a.comtrs=b.comtrs AND a.crop=b.crop
	FULL JOIN c ON a.year=c.year AND a.comtrs=c.comtrs AND a.crop=c.crop
	FULL JOIN d ON a.year=d.year AND a.comtrs=d.comtrs AND a.crop=d.crop);


