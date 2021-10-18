--Zad 2--
CREATE DATABASE baza

--Zad 3--
CREATE EXTENSION postgis;

--Zad 4--
CREATE TABLE budynki(id INT NOT NULL, geometria GEOMETRY,nazwa VARCHAR(20), PRIMARY KEY(id));
CREATE TABLE drogi(id INT NOT NULL, geometria GEOMETRY,nazwa VARCHAR(20), PRIMARY KEY(id));
CREATE TABLE punkty_informacyjne(id INT NOT NULL, geometria GEOMETRY,nazwa VARCHAR(20), PRIMARY KEY(id));

--Zad 5--
INSERT INTO budynki(id,geometria,nazwa) VALUES(1,ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))',0),'BuildingA');
INSERT INTO budynki(id,geometria,nazwa) VALUES(2,ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))',0),'BuildingB');
INSERT INTO budynki(id,geometria,nazwa) VALUES(3,ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))',0),'BuildingC');
INSERT INTO budynki(id,geometria,nazwa) VALUES(4,ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))',0),'BuildingD');
INSERT INTO budynki(id,geometria,nazwa) VALUES(5,ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))',0),'BuildingF');
INSERT INTO drogi(id,geometria,nazwa) VALUES (1,ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)', 0), 'Road Y');
INSERT INTO drogi(id,geometria,nazwa) VALUES (2,ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)', 0), 'Road X');
INSERT INTO punkty_informacyjne(id,geometria,nazwa) VALUES(1,ST_GeomFromText('POINT(1 3.5)', 0),'G');
INSERT INTO punkty_informacyjne(id,geometria,nazwa) VALUES(2,ST_GeomFromText('POINT(5.5 1.5)', 0),'H');
INSERT INTO punkty_informacyjne(id,geometria,nazwa) VALUES(3,ST_GeomFromText('POINT(9.5 6)', 0),'I');
INSERT INTO punkty_informacyjne(id,geometria,nazwa) VALUES(4,ST_GeomFromText('POINT(6.5 6)', 0),'J');
INSERT INTO punkty_informacyjne(id,geometria,nazwa) VALUES(5,ST_GeomFromText('POINT(6 9.5)', 0),'K');

--Zad 6--
--a
SELECT SUM(ST_Length(geometria)) AS "Długość dróg" FROM drogi
--b
SELECT ST_AsText(geometria) AS WKT, ST_Perimeter(geometria) AS obwód, ST_AREA(geometria) as powierzchnia FROM budynki WHERE "nazwa"= 'BuildingA';
--c
SELECT nazwa, ST_Area(geometria) AS "pole powierzchni" FROM budynki ORDER BY nazwa;
--d
SELECT nazwa,ST_Perimeter(geometria) FROM budynki ORDER BY ST_Perimeter(geometria) DESC LIMIT 2;
--e
SELECT ST_DISTANCE(budynki.geometria, punkty_informacyjne.geometria) 
AS odległość
FROM budynki, punkty_informacyjne
WHERE budynki.nazwa='BuildingC' AND punkty_informacyjne.nazwa='G';
--f 
SELECT ST_Area(ST_Difference(a.geometria, ST_Buffer(b.geometria,0.5)))
FROM budynki a, budynki B
WHERE a.nazwa='BuildingC'
AND b.nazwa='BuildingB'

 --g 
SELECT a.nazwa
FROM budynki a, drogi b
WHERE ST_Y(ST_Centroid(a.geometria))>ST_Y(ST_StartPoint(b.geometria))
AND b.nazwa='Road X'

SELECT ST_Area(budynki.geometria) + ST_Area('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))') 
- 2*ST_Area(ST_Intersection(budynki.geometria,'POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))
AS "pole powierzchni"
FROM budynki
WHERE budynki.nazwa='BuildingC'
