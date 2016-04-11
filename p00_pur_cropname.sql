-- name crop type accoring to DWR data
DROP TABLE IF EXISTS ca_pest.site_code;
CREATE TABLE ca_pest.site_code(
site_code int, fda_code int,  prefsite_sw int, siteup_dt date,  site_grp_cat int, 
site_name text,  site_sub_grp int, used_sw int, crop text);

INSERT INTO ca_pest.site_code(
SELECT site_code, fda_code,  prefsite_sw, siteup_dt,  site_grp_cat, site_name,  site_sub_grp, used_sw, '' AS crop 
FROM pur.site_code);

--upper group
UPDATE ca_pest.site_code SET crop = 'GRAIN_HAY'  WHERE site_sub_grp IN (24,22,23)  AND 
	site_sub_grp < 43;
UPDATE ca_pest.site_code SET crop = 'FIELD' WHERE site_sub_grp = 21;
UPDATE ca_pest.site_code SET crop = 'TRUCK'  WHERE site_sub_grp IN (8,13,14,15);
UPDATE ca_pest.site_code SET crop = 'MELON' WHERE site_sub_grp = 10;
UPDATE ca_pest.site_code SET crop = 'BUSHBERRY' WHERE site_sub_grp = 1;
UPDATE ca_pest.site_code SET crop = 'DECIDUOUS' WHERE site_sub_grp IN (3,4,5,35,30);
UPDATE ca_pest.site_code SET crop = 'SUBTROPICAL' WHERE site_sub_grp IN (6);
UPDATE ca_pest.site_code SET crop = 'NURSERY' WHERE site_sub_grp IN (31,32,33,34);

-- grain-hay
UPDATE ca_pest.site_code SET crop = 'BARLEY' WHERE site_name LIKE '%'||'BARLEY'||'%';
UPDATE ca_pest.site_code SET crop = 'WHEAT' WHERE site_name LIKE '%'||'WHEAT'||'%';
UPDATE ca_pest.site_code SET crop = 'OAT' WHERE site_name LIKE '%'||'OAT'||'%' AND 
	site_name NOT LIKE '%'||'GOAT'||'%' AND 
	site_name NOT LIKE '%'||'FLOATING'||'%' AND 
	site_name NOT LIKE '%'||'BOAT'||'%' AND 
	site_sub_grp < 43;
UPDATE ca_pest.site_code SET crop = 'RICE' WHERE site_name LIKE '%'||'RICE'||'%';
UPDATE ca_pest.site_code SET crop = 'WILD RICE' WHERE site_name LIKE '%'||'WILD RICE'||'%';

--field
UPDATE ca_pest.site_code SET crop = 'SORGHUM_SUDAN' WHERE site_name LIKE '%'||'SORGHUM'||'%' OR  site_name LIKE '%'||'SUDAN'||'%' ;
UPDATE ca_pest.site_code SET crop = 'COTTON' WHERE site_name LIKE '%'||'COTTON'||'%';
UPDATE ca_pest.site_code SET crop = 'SAFFLOWER' WHERE site_name LIKE '%'||'SAFFLOWER'||'%';
UPDATE ca_pest.site_code SET crop = 'FLAX' WHERE site_name LIKE '%'||'FLAX'||'%';
UPDATE ca_pest.site_code SET crop = 'SUGARBEET' WHERE site_name LIKE '%'||'SUGARBEET'||'%';
UPDATE ca_pest.site_code SET crop = 'CORN' WHERE site_name LIKE '%'||'CORN'||'%' AND site_name NOT LIKE '%'||'HEN'||'%';;
UPDATE ca_pest.site_code SET crop = 'SORGHUM' WHERE site_name LIKE '%'||'SORGHUM'||'%';
UPDATE ca_pest.site_code SET crop = 'SUDAN' WHERE site_name LIKE '%'||'SUDAN'||'%';
UPDATE ca_pest.site_code SET crop = 'CASTOR BEAN' WHERE site_name LIKE '%'||'CASTOR'||'%'; --oil crop
UPDATE ca_pest.site_code SET crop = 'SUNFLOWER' WHERE site_name LIKE '%'||'SUNFLOWER'||'%';
UPDATE ca_pest.site_code SET crop = 'MILLET' WHERE site_name LIKE '%'||'MILLET'||'%';
UPDATE ca_pest.site_code SET crop = 'SUGARCANE' WHERE site_name LIKE '%'||'SUGARCANE'||'%';

-- grass
UPDATE ca_pest.site_code SET crop = 'ALFALFA' WHERE site_name LIKE '%'||'ALFALFA'||'%';   --AND site_sub_grp NOT IN ();
UPDATE ca_pest.site_code SET crop = 'CLOVER' WHERE site_name LIKE '%'||'CLOVER'||'%';
UPDATE ca_pest.site_code SET crop = 'PASTURE' WHERE site_name LIKE '%'||'PASTURE'||'%';
UPDATE ca_pest.site_code SET crop = 'GRASS' WHERE site_name LIKE '%'||'GRASS'||'%';
UPDATE ca_pest.site_code SET crop = 'TURF' WHERE site_name LIKE '%'||'TURF'||'%';
UPDATE ca_pest.site_code SET crop = 'BERMUDA' WHERE site_name LIKE '%'||'BERMUDA'||'%';
UPDATE ca_pest.site_code SET crop = 'RYE' WHERE site_name LIKE '%'||'RYE'||'%';
UPDATE ca_pest.site_code SET crop = 'KLEIN' WHERE site_name LIKE '%'||'KLEIN'||'%';

-- truck
UPDATE ca_pest.site_code SET crop = 'ARTICHOKE' WHERE site_name LIKE '%'||'ARTICHOKE'||'%';
UPDATE ca_pest.site_code SET crop = 'ASPARAGUS' WHERE site_name LIKE '%'||'ASPARAGUS'||'%';
-- UPDATE ca_pest.site_code SET crop = 'BEAN,GREEN' WHERE site_name LIKE '%'||'BEAN,GREEN'||'%';
UPDATE ca_pest.site_code SET crop = 'COLE' WHERE site_name LIKE '%'||'COLE'||'%';
UPDATE ca_pest.site_code SET crop = 'CARROT' WHERE site_name LIKE '%'||'CARROT'||'%';
UPDATE ca_pest.site_code SET crop = 'CELERY' WHERE site_name LIKE '%'||'CELERY'||'%';
UPDATE ca_pest.site_code SET crop = 'LETTUCE' WHERE site_name LIKE '%'||'LETTUCE'||'%';
UPDATE ca_pest.site_code SET crop = 'HOP' WHERE site_name LIKE '%'||'HOP'||'%' AND site_sub_grp < 43;

UPDATE ca_pest.site_code SET crop = 'MELON' WHERE site_name LIKE '%'||'MELON'||'%' OR site_name LIKE '%'||'SQUASH'||'%'  OR site_name LIKE '%'||'CUCUMBER'||'%';
UPDATE ca_pest.site_code SET crop = 'ONION' WHERE site_name LIKE '%'||'ONION'||'%' OR site_name LIKE '%'||'GARLIC'||'%';
UPDATE ca_pest.site_code SET crop = 'PEA' WHERE site_name LIKE '%'||'PEA'||'%'  AND 
	site_sub_grp < 43;;

UPDATE ca_pest.site_code SET crop = 'POTATO' WHERE site_name LIKE '%'||'POTATO'||'%' AND site_name LIKE '%'||'EQUIPMENT'||'%';
UPDATE ca_pest.site_code SET crop = 'SWEET POTATO' WHERE site_name LIKE '%'||'SWEET POTATO'||'%';
UPDATE ca_pest.site_code SET crop = 'SPINACH' WHERE site_name LIKE '%'||'SPINACH'||'%';
UPDATE ca_pest.site_code SET crop = 'TOMATO' WHERE site_name LIKE '%'||'TOMATO'||'%';
UPDATE ca_pest.site_code SET crop = 'NURSERY' WHERE site_name LIKE '%'||'NURSERY'||'%' OR site_name LIKE '%'||'ORNAMENTAL'||'%';


-- CHECK BUSH BERRY
UPDATE ca_pest.site_code SET crop = 'STRAWBERRY' WHERE site_name LIKE '%'||'STRAWBERRY'||'%';
UPDATE ca_pest.site_code SET crop = 'PEPPER' WHERE site_name LIKE '%'||'PEPPER'||'%' AND 
	site_sub_grp < 43;;
UPDATE ca_pest.site_code SET crop = 'BROCCOLI' WHERE site_name LIKE '%'||'BROCCOLI'||'%';
UPDATE ca_pest.site_code SET crop = 'CABBAGE' WHERE site_name LIKE '%'||'CABBAGE'||'%';
UPDATE ca_pest.site_code SET crop = 'CAULIFLOWER' WHERE site_name LIKE '%'||'CAULIFLOWER'||'%';
UPDATE ca_pest.site_code SET crop = 'BRUSSELS_SPROUT' WHERE site_name LIKE '%'||'BRUSSELS_SPROUT'||'%';
UPDATE ca_pest.site_code SET crop = 'GREENHOUSE' WHERE site_name LIKE '%'||'GREENHOUSE'||'%';

-- DECIDUOUS
UPDATE ca_pest.site_code SET crop = 'APPLE' WHERE site_name LIKE '%'||'APPLE'||'%' AND site_name NOT LIKE '%'||'GUAVA'||'%';
UPDATE ca_pest.site_code SET crop = 'APRICOT' WHERE site_name LIKE '%'||'APRICOT'||'%';
UPDATE ca_pest.site_code SET crop = 'CHERRY' WHERE site_name LIKE '%'||'CHERRY'||'%';
UPDATE ca_pest.site_code SET crop = 'PEACH' WHERE site_name LIKE '%'||'PEACH'||'%' OR site_name LIKE '%'||'NECTARINE'||'%';
UPDATE ca_pest.site_code SET crop = 'PEAR' WHERE site_name LIKE '%'||'PEAR'||'%' AND site_name NOT LIKE '%'||'PEARL MILLET'||'%';
UPDATE ca_pest.site_code SET crop = 'PRUNE' WHERE site_name LIKE '%'||'PRUNE'||'%';
UPDATE ca_pest.site_code SET crop = 'PLUM' WHERE site_name LIKE '%'||'PLUM'||'%';
UPDATE ca_pest.site_code SET crop = 'FIG' WHERE site_name LIKE '%'||'FIG'||'%';
UPDATE ca_pest.site_code SET crop = 'DECIDUOUS' WHERE site_name LIKE '%'||'DECIDUOUS'||'%';
UPDATE ca_pest.site_code SET crop = 'ALMOND' WHERE site_name LIKE '%'||'ALMOND'||'%';
UPDATE ca_pest.site_code SET crop = 'WALNUT' WHERE site_name LIKE '%'||'WALNUT'||'%';
UPDATE ca_pest.site_code SET crop = 'PISTACHIO' WHERE site_name LIKE '%'||'PISTACHIO'||'%';

--citrus
UPDATE ca_pest.site_code SET crop = 'CITRUS' WHERE site_sub_grp = 2 OR site_code IN (6033, 28026);
UPDATE ca_pest.site_code SET crop = 'GRAPEFRUIT' WHERE site_name LIKE '%'||'GRAPEFRUIT'||'%';
UPDATE ca_pest.site_code SET crop = 'LEMON' WHERE site_name LIKE '%'||'LEMON'||'%';
UPDATE ca_pest.site_code SET crop = 'ORANGE' WHERE site_name LIKE '%'||'ORANGE'||'%';
UPDATE ca_pest.site_code SET crop = 'DATE' WHERE site_name LIKE '%'||'DATE'||'%';
UPDATE ca_pest.site_code SET crop = 'AVOCADO' WHERE site_name LIKE '%'||'AVOCADO'||'%';
UPDATE ca_pest.site_code SET crop = 'OLIVE' WHERE site_name LIKE '%'||'OLIVE'||'%';

-- SUBTROPICAL
UPDATE ca_pest.site_code SET crop = 'KIWIS' WHERE site_name LIKE '%'||'KIWIS'||'%';
UPDATE ca_pest.site_code SET crop = 'JOJOBA' WHERE site_name LIKE '%'||'JOJOBA'||'%';
UPDATE ca_pest.site_code SET crop = 'EUCALYPTUS' WHERE site_name LIKE '%'||'EUCALYPTUS'||'%';
UPDATE ca_pest.site_code SET crop = 'VINEYARD' WHERE site_name LIKE '%'||'GRAPE'||'%' AND site_name NOT LIKE '%'||'GRAPEFRUIT'||'%';
UPDATE ca_pest.site_code SET crop = 'IDLE' WHERE site_name LIKE '%'||'IDLE'||'%';
UPDATE ca_pest.site_code SET crop = 'TOMATO' WHERE site_name LIKE '%'||'TOMATO'||'%';

UPDATE ca_pest.site_code SET crop = 'TRUCK' WHERE site_code=6028;
UPDATE ca_pest.site_code SET crop = 'SUBTROPICAL' WHERE site_code IN (7000,6036,6013,28004); --7000=beverage crop
UPDATE ca_pest.site_code SET crop = 'GRAIN_HAY' WHERE site_code IN (23038,26001,28501,23010, 23011,23012,23006,28032,28070,28068,28078);
UPDATE ca_pest.site_code SET crop = 'PEANUT' WHERE site_code IN (28015);
UPDATE ca_pest.site_code SET crop = 'GRASS' WHERE site_code IN (28028,28045,28051,13063);
UPDATE ca_pest.site_code SET crop = 'TRUCK' WHERE site_code IN (29011,28081,8025,13048,8052,8025,8503,8517,16003,15043,14033,11008,11001,11000,8516,8502,28002, 28011,28024,28018,28012,28080,28061,28060,28056,28034,29123,28024,28047,28504,28013,28071,28022);
UPDATE ca_pest.site_code SET crop = 'FIELD' WHERE site_code IN (27010,23036,29109,15010,28001,28023,28049); --27010:oil soybean
--23022-soybean;
UPDATE ca_pest.site_code SET crop = 'NURSERY' WHERE site_code IN (28084,28083);
UPDATE ca_pest.site_code SET crop = 'DECIDUOUS' WHERE site_code IN (28509,15028);

UPDATE ca_pest.site_code SET crop = 'LEMON' WHERE site_code IN (10017);
UPDATE ca_pest.site_code SET crop = 'BUSHBERRY' WHERE site_code IN (11006,11010);
UPDATE ca_pest.site_code SET crop = 'LUTTUCE' WHERE site_code IN (13031,13045);
UPDATE ca_pest.site_code SET crop = 'CITRUS' WHERE site_code IN (2013);
UPDATE ca_pest.site_code SET crop = 'MELON' WHERE site_code IN (11007);
UPDATE ca_pest.site_code SET crop = 'RICE' WHERE site_code IN (24004);
UPDATE ca_pest.site_code SET crop = 'WILD RICE' WHERE site_code IN (24013);
UPDATE ca_pest.site_code SET crop = 'ASPARAGUS' WHERE site_name LIKE '%'||'ASPARAGUS'||'%';

--Green beans
-- UPDATE ca_pest.site_code SET crop = 'BEAN,GREEN' WHERE site_name LIKE '%'||'BEAN,GREEN'||'%';

UPDATE ca_pest.site_code SET crop = 'BEAN,GREEN' WHERE site_code IN (14024,14029,15002,
15003,15010,15012,15013,15014,15016,15017,15019,15022,15024,15025,15027,15029,15030,15033,
15035,15036,15042,15043,15047,15502,15503,15504,15506,15507,15508,15509,23032,29026);
UPDATE ca_pest.site_code SET crop = 'BEAN, DRY' WHERE site_name LIKE '%'||'BEANS, DRIED-TYPE'||'%';
UPDATE ca_pest.site_code SET crop = 'GRAIN_HAY' WHERE site_code IN (23002, 23022,23035,23020); --23002-bean;23022-soybean
UPDATE ca_pest.site_code SET crop = 'CLOVER' WHERE site_code IN (23031);
UPDATE ca_pest.site_code SET crop = 'TRUCK' WHERE site_name LIKE '%'||'PEANUT'||'%';

