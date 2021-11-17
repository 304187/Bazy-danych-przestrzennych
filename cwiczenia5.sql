CREATE EXTENSION postgis;
CREATE TABLE obiekty(geometria geometry, nazwa char(15));
INSERT INTO obiekty values (ST_geomfromtext('MULTIPOINT(30 30 59,38 32 234)',0),'obiekt5');
INSERT INTO obiekty values (ST_geomfromtext('GEOMETRYCOLLECTION(POINT(4 2),LINESTRING(1 1,3 2))',0),'obiekt6');
INSERT INTO obiekty values (ST_geomfromtext('LINESTRING(20 20,25 25,27 24,25 22,26 21,22 19,20.5 19.5)',0),'obiekt4');
INSERT INTO obiekty values (ST_geomfromtext('POLYGON((7 15,10 17,12 13,7 15))',0),'obiekt3');
INSERT INTO obiekty values (ST_geomfromtext('CURVEPOLYGON(COMPOUNDCURVE((10 2,10 6,14 6),CIRCULARSTRING(14 6,16 4,14 2),CIRCULARSTRING(14 2,12 0,10 2)),CIRCULARSTRING(11 2,12 3,13 2,12 1,11 2)) ',0),'obiekt2');
INSERT INTO obiekty values ( ST_geomfromtext('MULTILINESTRING(( 0 1, 1 1),CIRCULARSTRING(1 1, 2 0,3 1),CIRCULARSTRING(3 1, 4 2,5 1),( 5 1, 6 1))', 0),'obiekt1');
--zad1--
SELECT ST_area(ST_buffer(ST_shortestline(a.geometria,b.geometria),5)) FROM obiekty a, obiekty b WHERE a.nazwa='obiekt3' AND b.nazwa='obiekt4'
--zad2--
UPDATE obiekty SET geometria = (SELECT ST_MakePolygon(ST_LineMerge(ST_Union((geometria),'LINESTRING(20.5 19.5,20 20)'))) FROM obiekty WHERE nazwa='obiekt4') WHERE nazwa = 'obiekt4';
--zad3--
INSERT INTO obiekty (nazwa, geometria) VALUES ('obiekt7', (SELECT ST_Union(a.geometria,b.geometria) FROM obiekty a, obiekty b WHERE a.nazwa='obiekt3' AND b.nazwa='obiekt4'));
--zad4--
SELECT sum(ST_Area(ST_buffer((geometria),5))) FROM obiekty WHERE ST_HasArc(geometria) = 'false';
