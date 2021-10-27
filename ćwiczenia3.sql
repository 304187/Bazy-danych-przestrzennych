--zad4--
CREATE TABLE tabela_B (gid INT, cat FLOAT, type CHAR(80),f_codedesc CHAR(80), geom GEOMETRY);
INSERT INTO tabela_B
SELECT p.gid, p.cat, p.type, p.f_codedesc, p.geom FROM majrivers m, popp p 
WHERE  (ST_DWithin(m.geom,p.geom,100000))='true' AND p.f_codedesc='Building';
--zad5--
CREATE TABLE airportsNew (name CHAR(80),elev numeric,geom GEOMETRY);
INSERT INTO airportsNew (name,elev,geom) SELECT name,elev,geom FROM airports;
SELECT ST_X(geom), ST_Y(geom), ST_AsText(geom) 
       FROM airportsNew;
SELECT max(ST_X(geom)),min(ST_X(geom))
FROM airportsNew;
INSERT INTO airportsnew(name,elev, geom) VALUES ('airportB', 100,(SELECT ST_CENTROID(st_makeline) FROM ( SELECT ST_MAKELINE(a.geom,b.geom) FROM airportsnew a, airportsnew b WHERE a.name = 'ANNETTE ISLAND' AND b.name = 'ATKA') as newpoint) );
SELECT * from airportsnew WHERE name='airportB'
--zad6--
SELECT ST_AREA(ST_BUFFER((ST_SHORTESTLINE((SELECT a.geom FROM airports a WHERE a.name='AMBLER'),(SELECT l.geom FROM lakes l WHERE l.names='Iliamna Lake'))),1000)) pole FROM  airports a, lakes l LIMIT 1;
--zad7--
SELECT  (SUM(tu.area_km2)+SUM(sw.areakm2)) suma,tr.vegdesc gatunek FROM  trees tr, tundra tu , swamp sw WHERE tu.area_km2  IN (SELECT tu.area_km2 FROM tundra tu, trees tr WHERE ST_CONTAINS(tr.geom,tu.geom) = 'true') AND sw.areakm2  IN (SELECT sw.areakm2 FROM swamp sw, trees tr WHERE ST_CONTAINS(tr.geom,sw.geom) = 'true') GROUP BY tr.vegdesc
