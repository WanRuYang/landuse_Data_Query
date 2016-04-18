DROP TABLE pur.udc;

CREATE TABLE pur.udc
(
  year integer,
  use_no integer,
  prodno integer,
  chem_code integer,
  prodchem_pct real,
  lbs_chm_used real,
  lbs_prd_used real,
  amt_prd_used real,
  unit_of_meas character(2),
  acre_planted real,
  unit_planted character(1),
  acre_treated real,
  unit_treated character(1),
  applic_cnt integer,
  applic_dt date,
  applic_time integer,
  county_cd character(2),
  base_ln_mer character(1),
  township character(2),
  tship_dir character(1),
  range character(2),
  range_dir character(1),
  section character(2),
  site_loc_id character varying(8),
  grower_id character varying(11),
  license_no character varying(13),
  planting_seq integer,
  aer_gnd_ind character(1),
  site_code integer,
  qualify_cd integer,
  batch_no integer,
  document_no character varying(8),
  summary_cd integer,
  record_id character(1),
  comtrs character varying(11),
  error_flag character varying(11)
);

-- Index: pur.udc_chem_code
-- DROP INDEX pur.udc_chem_code;

CREATE INDEX udc_chem_code
  ON pur.udc
  USING btree
  (chem_code);

-- Index: pur.udc_comtrs
-- DROP INDEX pur.udc_comtrs;

CREATE INDEX udc_comtrs
  ON pur.udc
  USING btree
  (comtrs COLLATE pg_catalog."default");

-- Index: pur.udc_county_cd
-- DROP INDEX pur.udc_county_cd;

CREATE INDEX udc_county_cd
  ON pur.udc
  USING btree
  (county_cd COLLATE pg_catalog."default");

-- Index: pur.udc_grower_id
-- DROP INDEX pur.udc_grower_id;

CREATE INDEX udc_grower_id
  ON pur.udc
  USING btree
  (grower_id COLLATE pg_catalog."default");

-- Index: pur.udc_prodno
-- DROP INDEX pur.udc_prodno;

CREATE INDEX udc_prodno
  ON pur.udc
  USING btree
  (prodno);

-- Index: pur.udc_site_code
-- DROP INDEX pur.udc_site_code;

CREATE INDEX udc_site_code
  ON pur.udc
  USING btree
  (site_code);

-- Index: pur.udc_site_loc_id
--DROP INDEX pur.udc_site_loc_id;

CREATE INDEX udc_site_loc_id
  ON pur.udc
  USING btree
  (site_loc_id COLLATE pg_catalog."default");


--!/bin/sh
-- execute before run clean_lco_len.py/clean_pur_uudc.py
# dangling quotation mark in the range_dir of some udc10_* files
--find . -name "udc2010*.txt" -exec sed -i "s/,\([NSEW]\),\([0-9][0-9]\)\",\"/,\1,\2,\"/g" '{}' \;
--find . -name "udc2010*.txt" -exec sed -i "s/\",\"\",\"\([0-9]\),\([AGO]\),/\",\"\",\1,\2,/g" '{}' \; 
 
-- cropy table from stdin 

--'s' is the only 'non-acre' unit that is area and can be comverted 
UPDATE pur.udc SET (acre_treated, unit_treated) = (acre_treated / 43560, 'A') WHERE unit_treated = 'S';
UPDATE pur.udc SET (acre_planted, unit_planted) = (acre_planted / 43560, 'A') WHERE unit_planted = 'S';
UPDATE pur.udc SET grower_id = REPLACE(grower_id, substring(grower_id,3,2), substring(year::text,3,2)) WHERE substring(grower_id,3,2)!=substring(year::text,3,2);



-- 
-- combine 'site.txt' extracted from zip file of each year

-- drop table if exists pur.sites;
-- SELECT distinct * INTO pur.sites FROM pur.sites;
-- drop table pur.sites;
-- SELECT distinct * INTO pur.sites FROM pur.sites;
-- drop table pur.sites2;

DELETE FROM pur.sites WHERE site_name = 'BRUSSEL SPROUT';
DELETE FROM pur.sites WHERE site_name = 'ALFALFA-GRASS MIXTURE ';

-- add new column and set to desired crop types for specific analysis 
ALTER TABLE pur.sites DROP COLUMN grp;
ALTER TABLE pur.sites DROP COLUMN crop;
ALTER TABLE pur.sites DROP COLUMN IF EXISTS dwr_crop;
ALTER TABLE pur.sites DROP COLUMN IF EXISTS seg_crop;

ALTER TABLE pur.sites ADD COLUMN grp int;
ALTER TABLE pur.sites ADD COLUMN crop text;
ALTER TABLE pur.sites ADD COLUMN dwr_crop text;
ALTER TABLE pur.sites ADD COLUMN seg_crop text;

UPDATE pur.sites SET grp=0 WHERE length(site_code::text)<4;
UPDATE pur.sites SET grp=substring(site_code::text, 1, 1)::int WHERE length(site_code::text)=4;
UPDATE pur.sites SET grp=substring(site_code::text, 1, 2)::int WHERE length(site_code::text)=5;

UPDATE pur.sites SET crop='BUSHBERRY' WHERE grp=1;
UPDATE pur.sites SET crop='CITRUS' WHERE grp=2;
UPDATE pur.sites SET crop='NUT' WHERE grp=3;
UPDATE pur.sites SET crop='EDCIDUOUS' WHERE grp IN (4,5);
UPDATE pur.sites SET crop='SUBTROPICAL' WHERE grp IN (6,7);
UPDATE pur.sites SET crop='SPICE' WHERE grp=8;
UPDATE pur.sites SET crop='MELON' WHERE grp=10;
UPDATE pur.sites SET crop='VEG, FRUIT' WHERE grp=11;
UPDATE pur.sites SET crop='VEG, LEAFY' WHERE grp=13;
UPDATE pur.sites SET crop='ROOT' WHERE grp=14;
UPDATE pur.sites SET crop='SEED' WHERE grp=15;
UPDATE pur.sites SET crop='ONION' WHERE site_name ~ 'ONION';
UPDATE pur.sites SET crop='MUSHROOM' WHERE site_name ~ 'MUSHROOM';
UPDATE pur.sites SET crop='ASPARAGUS' WHERE site_name ~ 'ASPARAGUS';
UPDATE pur.sites SET crop='FIELD' WHERE grp BETWEEN 21 AND 27;

UPDATE pur.sites SET crop='TRUCK' WHERE grp = 28;

UPDATE pur.sites SET crop='XMAS TREE' WHERE site_code = 30005;
UPDATE pur.sites SET crop='NURSERY' WHERE grp IN (30,31,32,33,34,35,39);
UPDATE pur.sites SET crop='TURF' WHERE site_name ~ 'TURF';
UPDATE pur.sites SET crop='BERMUDA' WHERE site_name ~ 'BERMUDAGRASS';
UPDATE pur.sites SET crop='NONAG' WHERE grp > 39 OR grp=0;

UPDATE pur.sites SET dwr_crop=crop;
UPDATE pur.sites SET seg_crop=crop;


UPDATE pur.sites SET crop='GRAIN' WHERE site_name ~ 'GRAIN';
UPDATE pur.sites SET crop='ALFALFA' WHERE site_name ~ 'ALFALFA';
UPDATE pur.sites SET crop='BARLEY' WHERE site_name ~ 'BARLEY';
UPDATE pur.sites SET crop='GRASS' WHERE site_name ~ 'ALFALFA-GRASS MIXTURE|BARLEY-LEGUME MIXTURE';
UPDATE pur.sites SET crop='ALMOND' WHERE site_name ~ 'ALMOND';
UPDATE pur.sites SET crop='FLOWER' WHERE site_name ~ 'AFRICAN DAISY/GAZANIA/GAZANIA LONGISCARA';
UPDATE pur.sites SET crop='ALOE' WHERE site_name ~ 'ALOE';
UPDATE pur.sites SET crop='APPLE' WHERE site_name ~ 'APPLE' AND site_name !~ 'PINE';
UPDATE pur.sites SET crop='APRICOT' WHERE site_name ~ 'APRICOT';
UPDATE pur.sites SET crop='PEAR' WHERE site_name ~ 'PEAR' AND site_name !~ 'CACTUS';
UPDATE pur.sites SET crop='ASPARAGUS' WHERE site_name ~ 'ASPARAGUS' AND grp=16;
UPDATE pur.sites SET crop='ARTICHOKE' WHERE site_name ~ 'ARTICHOKE';
UPDATE pur.sites SET crop='AVOCADO' WHERE site_name ~ 'AVOCADO';
UPDATE pur.sites SET crop='BANANA' WHERE site_name ~ 'BANANA';
-- bean -- group to one type
UPDATE pur.sites SET crop='BEAN' WHERE site_name ~ 'BEAN';
UPDATE pur.sites SET crop='SOYBEAN' WHERE site_name ~ 'SOYBEAN';
UPDATE pur.sites SET crop='COCOA' WHERE site_name ~ 'COCOA';
UPDATE pur.sites SET crop='CASTOR BEAN' WHERE site_name ~ 'CASTORBEAN';
UPDATE pur.sites SET crop='BEET' WHERE site_name ~ 'BEET' AND site_name !~ 'SUGAR';
UPDATE pur.sites SET crop='SUGARBEET' WHERE site_name ~ 'SUGARBEET';
UPDATE pur.sites SET crop='GRASS' WHERE site_name ~ 'BENTGRASS';
UPDATE pur.sites SET crop='BROCCOLI' WHERE site_name ~ 'BROCCOLI';
UPDATE pur.sites SET crop='BITTER MELON' WHERE site_name ~ 'BITTER MELON';
UPDATE pur.sites SET crop='BLACKBERRY' WHERE site_name ~ 'BLACKBERRY';
UPDATE pur.sites SET crop='BLUEBERRY' WHERE site_name ~ 'BLUEBERRY';
UPDATE pur.sites SET crop='BOYSENBERRY' WHERE site_name ~ 'BOYSENBERRY';
UPDATE pur.sites SET crop='BURDOCK' WHERE site_name ~ 'BURDOCK';
UPDATE pur.sites SET crop='PEA' WHERE site_name ~ 'PEA' AND site_name !~ 'PEAR|PEANUT|PEACH' ;
UPDATE pur.sites SET crop='PEANUT' WHERE site_name ~ 'PEANUT';
UPDATE pur.sites SET crop='CABBAGE' WHERE site_name ~ 'CABBAGE';
UPDATE pur.sites SET crop='CACTUS' WHERE site_name ~ 'CACTUS';
UPDATE pur.sites SET crop='RAPE' WHERE site_name ~ 'RAPE' AND site_name !~ 'GRAPE';
UPDATE pur.sites SET crop='CARROT' WHERE site_name ~ 'CARROT';
UPDATE pur.sites SET crop='CAULIFLOWER' WHERE site_name ~ 'CAULIFLOWER';
UPDATE pur.sites SET crop='CELERY' WHERE site_name ~ 'CELERY';
UPDATE pur.sites SET crop='CHERRY' WHERE site_name ~ 'CHERRY';
UPDATE pur.sites SET crop='VEG, LEAFY' WHERE site_name ~ 'CHICORY';
UPDATE pur.sites SET crop='CHIVE' WHERE site_name ~ 'CHIVE';
UPDATE pur.sites SET crop='XMAS TREE' WHERE site_name ~ 'CHRISTMAS TREE';
UPDATE pur.sites SET crop='CLOVER' WHERE site_name ~ 'CLOVER';
UPDATE pur.sites SET crop='COCONUT' WHERE site_name ~ 'COCONUT';
UPDATE pur.sites SET crop='CORN' WHERE site_name ~ 'CORN';
UPDATE pur.sites SET crop='COTTON' WHERE site_name ~ 'COTTON';
UPDATE pur.sites SET crop='CUCUMBER' WHERE site_name ~ 'CUCUMBER';
UPDATE pur.sites SET crop='FENNEL' WHERE site_name ~ 'FENNEL';
UPDATE pur.sites SET crop='FOREST' WHERE site_name ~ 'FOREST TREES';
UPDATE pur.sites SET crop='SORGHUM' WHERE site_name ~ 'SORGHUM';
UPDATE pur.sites SET crop='FLAX' WHERE site_name ~ 'FLAX';
UPDATE pur.sites SET crop='VINYARD' WHERE site_name ~ 'GRAPE' AND site_name !~ 'GRAPEFRUIT';
UPDATE pur.sites SET crop='GREENHOUSE' WHERE site_name ~ 'GREENHOUSE';
UPDATE pur.sites SET crop='HOP' WHERE site_name ~ 'HOP';
UPDATE pur.sites SET crop='LEMON' WHERE site_name ~ 'LEMON';
UPDATE pur.sites SET crop='LETTUCE' WHERE site_name ~ 'LETTUCE';
UPDATE pur.sites SET crop='ORANGE' WHERE site_name ~ 'ORANGE';
UPDATE pur.sites SET crop='DATE' WHERE site_name ~ 'DATE';
UPDATE pur.sites SET crop='FIG' WHERE site_name ~ 'FIG';
UPDATE pur.sites SET crop='MELON' WHERE site_name ~ 'MELON';
UPDATE pur.sites SET crop='MANGO' WHERE site_name ~ 'MANGO';
UPDATE pur.sites SET crop='PEPPER' WHERE site_name ~ 'PEPPER' AND site_name !~ 'MINT';
UPDATE pur.sites SET crop='SPICE' WHERE site_name ~ 'MINT';
UPDATE pur.sites SET crop='OAT' WHERE site_name ~ 'OAT' AND site_name !~ 'GOAT|BOAT|COAT|FLOAT';
UPDATE pur.sites SET crop='STRAWBERRY' WHERE site_name ~ 'STRAWBERRY' AND site_name !~'CLOVER';
UPDATE pur.sites SET crop='PASTURE' WHERE site_name ~ 'PASTURE';
UPDATE pur.sites SET crop='PEACH' WHERE site_name ~ 'PEACH';
UPDATE pur.sites SET crop='NECTARINE' WHERE site_name ~ 'NECTARINE';
UPDATE pur.sites SET crop='POTATO' WHERE site_name ~ 'POTATO';
UPDATE pur.sites SET crop='SWEET POTATO' WHERE site_name ~ 'SWEET POTATO';
UPDATE pur.sites SET crop='WHEAT' WHERE site_name ~ 'WHEAT' AND site_name !~ 'BUCKWHEAT';
UPDATE pur.sites SET crop='WATERMELON'  WHERE site_name ~ 'WATERMELON';
UPDATE pur.sites SET crop='TURNIP' WHERE site_name ~ 'TURNIP';
UPDATE pur.sites SET crop='TARO' WHERE site_name ~ 'TARO';
UPDATE pur.sites SET crop='TOMATO' WHERE site_name ~ 'TOMATO';
UPDATE pur.sites SET crop='TRUCK' WHERE site_name ~ 'VEGETABLE';
UPDATE pur.sites SET crop='SUNFLOWER' WHERE site_name ~ 'SUNFLOWER';
UPDATE pur.sites SET crop='SUDAN' WHERE site_name ~ 'SUDAN';
UPDATE pur.sites SET crop='SUGARBEET' WHERE site_name ~ 'SUGARBEET';
UPDATE pur.sites SET crop='SPINACH' WHERE site_name ~ 'SPINACH';
UPDATE pur.sites SET crop='LEGUME' WHERE site_code=28039;
UPDATE pur.sites SET crop='SESAME' WHERE site_name ~ 'SESAME';
UPDATE pur.sites SET crop='SAFFLOWER' WHERE site_name ~ 'SAFFLOWER';
UPDATE pur.sites SET crop='ROOT' WHERE site_name ~ 'SALSIFY';
UPDATE pur.sites SET crop='RYE' WHERE site_name ~ 'RYE';
UPDATE pur.sites SET crop='RICE' WHERE site_name ~ 'RICE';
UPDATE pur.sites SET crop='RICE, WILD' WHERE site_name ~ 'RICE, WILD';
UPDATE pur.sites SET crop='PUMPKIN' WHERE site_name ~ 'PUMPKIN';
UPDATE pur.sites SET crop='PEA' WHERE site_code IN (15510);
UPDATE pur.sites SET crop='OLIVE' WHERE site_name ~ 'OLIVE';
UPDATE pur.sites SET crop='LOVEGRASS' WHERE site_name ~ 'LOVEGRASS';
UPDATE pur.sites SET crop='MUSTARD' WHERE site_name ~ 'MUSTARD' AND site_name !~ 'CABBAGE';
UPDATE pur.sites SET crop='ROOT' WHERE site_name ~ 'HORSERADISH';
UPDATE pur.sites SET crop='GRASS' WHERE site_name ~  'GRASS, SEED';
UPDATE pur.sites SET crop='GARLIC' WHERE site_name ~ 'GARLIC';
UPDATE pur.sites SET crop='BEET' WHERE site_name =  'BEETS, TABLE, RED, OR GARDEN (LEAFY VEGETABLE)';
UPDATE pur.sites SET crop='COLE' WHERE site_name ~ 'COLE';
UPDATE pur.sites SET crop='BRUSSELS SPROUT' WHERE site_name ~ 'BRUSSELS SPROUT';
UPDATE pur.sites SET crop='PEA' WHERE site_name ~ 'GARBANZO';
UPDATE pur.sites SET crop='MILLET' WHERE site_name ~ 'MILLET';
UPDATE pur.sites SET dwr_crop='PEA' WHERE site_name ~ 'GARBANZO';
UPDATE pur.sites SET dwr_crop='MILLET' WHERE site_name ~ 'MILLET';
UPDATE pur.sites SET seg_crop='PEA' WHERE site_name ~ 'GARBANZO';
UPDATE pur.sites SET seg_crop='MILLET' WHERE site_name ~ 'MILLET';
-------------------------------------------------------------
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE crop ~ 'VEG';
UPDATE pur.sites SET dwr_crop='ALFALFA' WHERE site_name ~ 'ALFALFA';
UPDATE pur.sites SET dwr_crop='ALMOND' WHERE site_name ~ 'ALMOND';
UPDATE pur.sites SET dwr_crop='APPLE' WHERE site_name ~ 'APPLE' AND site_name !~ 'PINE';
UPDATE pur.sites SET dwr_crop='APRICOT' WHERE site_name ~ 'APRICOT';
UPDATE pur.sites SET dwr_crop='PEAR' WHERE site_name ~ 'PEAR' AND site_name !~ 'CACTUS';
UPDATE pur.sites SET dwr_crop='ASPARAGUS' WHERE site_name ~ 'ASPARAGUS' AND grp=16;
UPDATE pur.sites SET dwr_crop='ARTICHOKE' WHERE site_name ~ 'ARTICHOKE';
UPDATE pur.sites SET dwr_crop='AVOCADO' WHERE site_name ~ 'AVOCADO';
UPDATE pur.sites SET dwr_crop='GRAIN_HAY' WHERE site_name ~ 'BARLEY-LEGUME MIXTURE|BEANS (FORAGE - FODDER)|PEANUTS (FORAGE - FODDER)|GRAIN';
UPDATE pur.sites SET dwr_crop='BARLEY' WHERE site_name ~ 'BARLEY';
UPDATE pur.sites SET dwr_crop='BEAN, GREEN' WHERE site_name ~ 'BEAN';
UPDATE pur.sites SET dwr_crop='BEAN, DRY' WHERE site_name ~ 'BEAN, DRIED';
UPDATE pur.sites SET dwr_crop='BEAN, DRY' WHERE site_name ~ 'BEAN' AND site_name ~ 'FORAGE';
UPDATE pur.sites SET dwr_crop='CASTOR BEAN' WHERE site_name ~ 'CASTORBEAN';
UPDATE pur.sites SET dwr_crop='SUBTROPICAL' WHERE site_name ~ 'COCOA';
UPDATE pur.sites SET dwr_crop='FIELD' WHERE site_name ~ 'BEET' AND site_name !~ 'SUGAR';
UPDATE pur.sites SET dwr_crop='SUGARBEET' WHERE site_name ~ 'SUGARBEET';
UPDATE pur.sites SET dwr_crop='GRASS' WHERE site_name ~ 'BENTGRASS';
UPDATE pur.sites SET dwr_crop='BROCCOLI' WHERE site_name ~ 'BROCCOLI';
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'BURDOCK';
UPDATE pur.sites SET dwr_crop='PEA' WHERE site_name ~ 'PEA' AND site_name !~ 'PEAR|PEANUT|PEACH' ;
UPDATE pur.sites SET dwr_crop='FIELD' WHERE site_name ~ 'PEANUT';
UPDATE pur.sites SET dwr_crop='CABBAGE' WHERE site_name ~ 'CABBAGE';
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'CACTUS';
UPDATE pur.sites SET dwr_crop='FIELD' WHERE site_name ~ 'RAPE' AND site_name !~ 'GRAPE';
UPDATE pur.sites SET dwr_crop='CARROT' WHERE site_name ~ 'CARROT';
UPDATE pur.sites SET dwr_crop='CAULIFLOWER' WHERE site_name ~ 'CAULIFLOWER';
UPDATE pur.sites SET dwr_crop='CELERY' WHERE site_name ~ 'CELERY';
UPDATE pur.sites SET dwr_crop='CHERRY' WHERE site_name ~ 'CHERRY';
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'CHICORY|CHIVE';
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'CHIVE';
UPDATE pur.sites SET dwr_crop='XMAS TREE' WHERE site_name ~ 'CHRISTMAS TREE';
UPDATE pur.sites SET dwr_crop='CLOVER' WHERE site_name ~ 'CLOVER';
UPDATE pur.sites SET dwr_crop='SUBTROPICAL' WHERE site_name ~ 'COCONUT';
UPDATE pur.sites SET dwr_crop='COFFEE' WHERE site_name ~ 'COFFEE';
UPDATE pur.sites SET dwr_crop='CORN' WHERE site_name ~ 'CORN';
UPDATE pur.sites SET dwr_crop='COTTON' WHERE site_name ~ 'COTTON';
UPDATE pur.sites SET dwr_crop='EGGPLANT' WHERE site_name ~ 'EGGPLANT';
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'FENNEL';
UPDATE pur.sites SET dwr_crop='DECIDUOUS' WHERE site_name ~ 'FOREST TREES';
UPDATE pur.sites SET dwr_crop='SORGHUM' WHERE site_name ~ 'SORGHUM';
UPDATE pur.sites SET dwr_crop='FLAX' WHERE site_name ~ 'FLAX';
UPDATE pur.sites SET dwr_crop='VINYARD' WHERE site_name ~ 'GRAPE' AND site_name !~ 'GRAPEFRUIT';
UPDATE pur.sites SET dwr_crop='GREENHOUSE' WHERE site_name ~ 'GREENHOUSE';
UPDATE pur.sites SET dwr_crop='HOP' WHERE site_name ~ 'HOP';
UPDATE pur.sites SET dwr_crop='FIELD' WHERE site_name ~ 'HAYLAGE';
UPDATE pur.sites SET dwr_crop='LEMON' WHERE site_name ~ 'LEMON';
UPDATE pur.sites SET dwr_crop='ORANGE' WHERE site_name ~ 'ORANGE';
UPDATE pur.sites SET dwr_crop='LETTUCE' WHERE site_name ~ 'LETTUCE';
UPDATE pur.sites SET dwr_crop='DATE' WHERE site_name ~ 'DATE';
UPDATE pur.sites SET dwr_crop='FIG' WHERE site_name ~ 'FIG';
UPDATE pur.sites SET dwr_crop='PEPPER' WHERE site_name ~ 'PEPPER' AND site_name !~ 'MINT';
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'MINT';
UPDATE pur.sites SET dwr_crop='MELON' WHERE site_name ~ 'MELON';
UPDATE pur.sites SET dwr_crop='OAT' WHERE site_name ~ 'OAT' AND site_name !~ 'GOAT|BOAT|COAT|FLOAT';
UPDATE pur.sites SET dwr_crop='STRAWBERRY' WHERE site_name ~ 'STRAWBERRY' AND site_name !~'CLOVER';
UPDATE pur.sites SET dwr_crop='PASTURE' WHERE site_name ~ 'PASTURE';
UPDATE pur.sites SET dwr_crop='PEACH' WHERE site_name ~ 'PEACH|NECTARINE';
UPDATE pur.sites SET dwr_crop='POTATO' WHERE site_name ~ 'POTATO';
UPDATE pur.sites SET dwr_crop='SWEET POTATO' WHERE site_name ~ 'SWEET POTATO';
UPDATE pur.sites SET dwr_crop='WHEAT' WHERE site_name ~ 'WHEAT' AND site_name !~ 'BUCKWHEAT';
UPDATE pur.sites SET dwr_crop='WATERMELON'  WHERE site_name ~ 'WATERMELON';
UPDATE pur.sites SET dwr_crop='WALNUT' WHERE site_name ~ 'WALNUT';
UPDATE pur.sites SET dwr_crop='TURNIP' WHERE site_name ~ 'TURNIP';
UPDATE pur.sites SET dwr_crop='TURNIP' WHERE site_name ~ 'TURNIP (FORAGE - FODDER)';
UPDATE pur.sites SET dwr_crop='TOMATO' WHERE site_name ~ 'TOMATO';
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'VEGETABLE';
UPDATE pur.sites SET dwr_crop='SUNFLOWER' WHERE site_name ~ 'UNFLOWER';
UPDATE pur.sites SET dwr_crop='SUDAN' WHERE site_name ~ 'SUDAN';
UPDATE pur.sites SET dwr_crop='SUGARBEET' WHERE site_name ~ 'SUGARBEET';
UPDATE pur.sites SET dwr_crop='FIELD' WHERE site_name ~ 'SOYBEAN';
UPDATE pur.sites SET dwr_crop='SPINACH' WHERE site_name ~ 'SPINACH';
UPDATE pur.sites SET dwr_crop='GRAIN_HAY' WHERE site_code=28039;
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'SESAME';
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'SALSIFY';
UPDATE pur.sites SET dwr_crop='SAFFLOWER' WHERE site_name ~ 'SAFFLOWER';
UPDATE pur.sites SET dwr_crop='RYE' WHERE site_name ~ 'RYE';
UPDATE pur.sites SET dwr_crop='RICE' WHERE site_name ~ 'RICE';
UPDATE pur.sites SET dwr_crop='RICE, WILD' WHERE site_name ~ 'RICE, WILD';
UPDATE pur.sites SET dwr_crop='PEA' WHERE site_code IN (15510);
UPDATE pur.sites SET dwr_crop='OLIVE' WHERE site_name ~ 'OLIVE';
UPDATE pur.sites SET dwr_crop='GRASS' WHERE site_name ~ 'LOVEGRASS|ORCHARDGRASS|RANGELAND';
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'MUSTARD' AND site_name !~ 'CABBAGE';
UPDATE pur.sites SET dwr_crop='TRUCK' WHERE site_name ~ 'MUSHROOM|HORSERADISH';
UPDATE pur.sites SET dwr_crop='GRASS' WHERE site_name ~  'GRASS, SEED';
UPDATE pur.sites SET dwr_crop='ONION' WHERE site_name ~ 'GARLIC|ONION';
UPDATE pur.sites SET dwr_crop='BRUSSELS SPROUT' WHERE site_name ~ 'BRUSSELS SPROUT';
UPDATE pur.sites SET dwr_crop='COLE' WHERE site_name ~ 'COLE';
-----------------------------------------------------------------

UPDATE pur.sites SET seg_crop='GRAIN' WHERE site_name ~ 'GRAIN';
UPDATE pur.sites SET seg_crop='ALFALFA' WHERE site_name ~ 'ALFALFA';
UPDATE pur.sites SET seg_crop='GRASS' WHERE site_name ~ 'ALFALFA-GRASS MIXTURE|BARLEY-LEGUME MIXTURE';
UPDATE pur.sites SET seg_crop='ALMOND' WHERE site_name ~ 'ALMOND';
UPDATE pur.sites SET seg_crop='FIELD' WHERE site_name ~ 'ALOE';
UPDATE pur.sites SET seg_crop='APPLE' WHERE site_name ~ 'APPLE' AND site_name !~ 'PINE';
UPDATE pur.sites SET seg_crop='APRICOT' WHERE site_name ~ 'APRICOT';
UPDATE pur.sites SET seg_crop='PEAR' WHERE site_name ~ 'PEAR' AND site_name !~ 'CACTUS';
UPDATE pur.sites SET seg_crop='ASPARAGUS' WHERE site_name ~ 'ASPARAGUS' AND grp=16;
UPDATE pur.sites SET seg_crop='ARTICHOKE' WHERE site_name ~ 'ARTICHOKE';
UPDATE pur.sites SET seg_crop='AVOCADO' WHERE site_name ~ 'AVOCADO';
UPDATE pur.sites SET seg_crop='BANANA' WHERE site_name ~ 'BANANA';
UPDATE pur.sites SET seg_crop='BARLEY' WHERE site_name ~ 'BARLEY' AND site_name !~ 'MIXTURE';
UPDATE pur.sites SET seg_crop='BEAN' WHERE site_name ~ 'BEAN';
UPDATE pur.sites SET seg_crop='SOYBEAN' WHERE site_name ~ 'SOYBEAN';
UPDATE pur.sites SET seg_crop='COCOA' WHERE site_name ~ 'COCOA';
UPDATE pur.sites SET seg_crop='CASTOR BEAN' WHERE site_name ~ 'CASTORBEAN';
UPDATE pur.sites SET seg_crop='SOYBEAN' WHERE site_name ~ 'SOYBAEN';
UPDATE pur.sites SET seg_crop='BEET' WHERE site_name ~ 'BEET' AND site_name !~ 'SUGAR';
UPDATE pur.sites SET seg_crop='GRASS' WHERE site_name ~ 'BENTGRASS';
UPDATE pur.sites SET seg_crop='BROCCOLI' WHERE site_name ~ 'BROCCOLI';
UPDATE pur.sites SET seg_crop='VEG, LEAFY' WHERE site_name ~ 'BURDOCK';
UPDATE pur.sites SET seg_crop='PEA' WHERE site_name ~ 'PEA' AND site_name !~ 'PEAR|PEANUT|PEACH' ;
UPDATE pur.sites SET seg_crop='PEANUT' WHERE site_name ~ 'PEANUT';
UPDATE pur.sites SET seg_crop='CABBAGE' WHERE site_name ~ 'CABBAGE';
UPDATE pur.sites SET seg_crop='CACTUS' WHERE site_name ~ 'CACTUS';
UPDATE pur.sites SET seg_crop='RAPE' WHERE site_name ~ 'RAPE' AND site_name !~ 'GRAPE';
UPDATE pur.sites SET seg_crop='CARROT' WHERE site_name ~ 'CARROT';
UPDATE pur.sites SET seg_crop='CAULIFLOWER' WHERE site_name ~ 'CAULIFLOWER';
UPDATE pur.sites SET seg_crop='CELERY' WHERE site_name ~ 'CELERY';
UPDATE pur.sites SET seg_crop='CHERRY' WHERE site_name ~ 'CHERRY';
UPDATE pur.sites SET seg_crop='VEG, LEAFY' WHERE site_name ~ 'CHICORY';
UPDATE pur.sites SET seg_crop='CHIVE' WHERE site_name ~ 'CHIVE';
UPDATE pur.sites SET seg_crop='XMAS TREE' WHERE site_name ~ 'CHRISTMAS TREE';
UPDATE pur.sites SET seg_crop='CLOVER' WHERE site_name ~ 'CLOVER';
UPDATE pur.sites SET seg_crop='COCONUT' WHERE site_name ~ 'COCONUT';
UPDATE pur.sites SET seg_crop='COFFEE' WHERE site_name ~ 'COFFEE';
UPDATE pur.sites SET seg_crop='CORN' WHERE site_name ~ 'CORN';
UPDATE pur.sites SET seg_crop='COTTON' WHERE site_name ~ 'COTTON';
UPDATE pur.sites SET seg_crop='CUCUMBER' WHERE site_name ~ 'CUCUMBER';
UPDATE pur.sites SET seg_crop='EGGPLANT' WHERE site_name ~ 'EGGPLANT';
UPDATE pur.sites SET seg_crop='FENNEL' WHERE site_name ~ 'FENNEL';
UPDATE pur.sites SET seg_crop='FOREST' WHERE site_name ~ 'FOREST TREES';
UPDATE pur.sites SET seg_crop='SORGHUM' WHERE site_name ~ 'SORGHUM';
UPDATE pur.sites SET seg_crop='FLAX' WHERE site_name ~ 'FLAX';
UPDATE pur.sites SET seg_crop='VINYARD' WHERE site_name ~ 'GRAPE' AND site_name !~ 'GRAPEFRUIT';
UPDATE pur.sites SET seg_crop='GREENHOUSE' WHERE site_name ~ 'GREENHOUSE';
UPDATE pur.sites SET seg_crop='HOP' WHERE site_name ~ 'HOP';
UPDATE pur.sites SET seg_crop='LEMON' WHERE site_name ~ 'LEMON';
UPDATE pur.sites SET seg_crop='ORANGE' WHERE site_name ~ 'ORANGE';
UPDATE pur.sites SET seg_crop='LETTUCE' WHERE site_name ~ 'LETTUCE';
UPDATE pur.sites SET seg_crop='DATE' WHERE site_name ~ 'DATE';
UPDATE pur.sites SET seg_crop='FIG' WHERE site_name ~ 'FIG';
UPDATE pur.sites SET seg_crop='MELON' WHERE site_name ~ 'MELON';
UPDATE pur.sites SET seg_crop='PEPPER' WHERE site_name ~ 'PEPPER' AND site_name !~ 'MINT';
UPDATE pur.sites SET seg_crop='MINT' WHERE site_name ~ 'MINT';
UPDATE pur.sites SET seg_crop='OAT' WHERE site_name ~ 'OAT' AND site_name !~ 'GOAT|BOAT|COAT|FLOAT';
UPDATE pur.sites SET seg_crop='STRAWBERRY' WHERE site_name ~ 'STRAWBERRY' AND site_name !~'CLOVER';
UPDATE pur.sites SET seg_crop='PASTURE' WHERE site_name ~ 'PASTURE';
UPDATE pur.sites SET seg_crop='PEACH' WHERE site_name ~ 'PEACH|NECTARINE';
UPDATE pur.sites SET seg_crop='POTATO' WHERE site_name ~ 'POTATO';
UPDATE pur.sites SET seg_crop='SWEET POTATO' WHERE site_name ~ 'SWEET POTATO';
UPDATE pur.sites SET seg_crop='RYE' WHERE site_name ~ 'RYE';
UPDATE pur.sites SET seg_crop='WALNUT' WHERE site_name ~ 'WALNUT';
UPDATE pur.sites SET seg_crop='TURNIP' WHERE site_name ~ 'TURNIP';
UPDATE pur.sites SET seg_crop='TARO' WHERE site_name ~ 'TARO';
UPDATE pur.sites SET seg_crop='TOMATO' WHERE site_name ~ 'TOMATO';
UPDATE pur.sites SET seg_crop='VEGETABLE' WHERE site_name ~ 'VEGETABLE';
UPDATE pur.sites SET seg_crop='SUNFLOWER' WHERE site_name ~ 'UNFLOWER';
UPDATE pur.sites SET seg_crop='SUDAN' WHERE site_name ~ 'SUDAN';
UPDATE pur.sites SET seg_crop='SUGARBEET' WHERE site_name ~ 'SUGARBEET';
-- UPDATE pur.sites SET seg_crop='' WHERE site_name ~ '';
UPDATE pur.sites SET seg_crop='WHEAT' WHERE site_name ~ 'WHEAT' AND site_name !~ 'BUCKWHEAT';
UPDATE pur.sites SET seg_crop='WATERMELON'  WHERE site_name ~ 'WATERMELON';
UPDATE pur.sites SET seg_crop='SPINACH' WHERE site_name ~ 'SPINACH';
UPDATE pur.sites SET seg_crop='LEGUME' WHERE site_code=28039;
UPDATE pur.sites SET seg_crop='SESAME' WHERE site_name ~ 'SESAME';
UPDATE pur.sites SET seg_crop='SAFFLOWER' WHERE site_name ~ 'SAFFLOWER';
UPDATE pur.sites SET seg_crop='ROOT' WHERE site_name ~ 'SALSIFY';
UPDATE pur.sites SET seg_crop='RICE' WHERE site_name ~ 'RICE';
UPDATE pur.sites SET seg_crop='PUMPKIN' WHERE site_name ~ 'PUMPKIN';
UPDATE pur.sites SET seg_crop='PEA' WHERE site_code IN (15510);
UPDATE pur.sites SET seg_crop='OLIVE' WHERE site_name ~ 'OLIVE';
UPDATE pur.sites SET seg_crop='LOVEGRASS' WHERE site_name ~ 'LOVEGRASS';
UPDATE pur.sites SET seg_crop='MUSTARD' WHERE site_name ~ 'MUSTARD' AND site_name !~ 'CABBAGE';
UPDATE pur.sites SET seg_crop='ROOT' WHERE site_name ~ 'HORSERADISH';
UPDATE pur.sites SET seg_crop='GRASS' WHERE site_name ~  'GRASS, SEED';
UPDATE pur.sites SET seg_crop='GARLIC' WHERE site_name ~ 'GARLIC';
UPDATE pur.sites SET seg_crop='BEET' WHERE site_name =  'BEETS, TABLE, RED, OR GARDEN (LEAFY VEGETABLE)';
UPDATE pur.sites SET seg_crop='BRUSSELS SPROUT' WHERE site_name ~ 'BRUSSELS SPROUT';

-- SELECT * FROM pur.sites WHERE site_name ~ 'GROUND' --AND site_name !~ 'GRAPE';
drop table if exists ca_pest.site_code;
drop table if exists splm.site_code;
drop table if exists rs.site_code;
SELECT site_code, grp AS site_sub_grp, dwr_crop AS crop INTO ca_pest.site_code  FROM pur.sites ;
SELECT site_code, grp AS site_sub_grp, crop INTO splm.site_code  FROM pur.sites ;
SELECT site_code, grp AS site_sub_grp, seg_crop AS crop INTO rs.site_code  FROM pur.sites ;



COMMIT;
VACUUM ANALYZE;

