DROP TABLE IF EXISTS ca_pest.udc_fld_grp_area;

WITH --duplist AS (
--	SELECT co_mtrs, area FROM ca_pest.purlayer 
--	WHERE co_mtrs IN ( 
--		SELECT co_mtrs 
--		FROM ca_pest.purlayer 
----		GROUP BY co_mtrs 
--		HAVING count(*) > 1 
--		ORDER BY count(*) DESC )),
--	--get duplicated comtrs and get the sum value 
    com_area AS (
	SELECT co_mtrs AS comtrs, SUM(area) AS area 
	FROM ca_pest.purlayer
	GROUP BY co_mtrs) 
--	UNION --union with unique comtrs and value 
--	SELECT co_mtrs AS comtrs, area 
--	FROM ca_pest.purlayer 
--	WHERE co_mtrs NOT IN (
--		SELECT co_mtrs FROM duplist))
--    SELECT * FROM com_area;

SELECT a.*, b.area*0.000247105 AS com_area
	INTO ca_pest.udc_fld_grp_area 
	FROM ca_pest.udc_fld_grp a
	INNER JOIN com_area b ON a.comtrs = b.comtrs
	ORDER BY a.year, a.comtrs;
