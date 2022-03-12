DROP VIEW docentes_por_sede_y_cuatrimestre;
CREATE OR REPLACE VIEW docentes_por_sede_y_cuatrimestre AS
SELECT 	ea.legajo_docente as legajo,
		oa.sede,
		oa.anio_cursada,
		oa.cuatrimestre_cursada
FROM equipos_por_actividad ea
INNER JOIN oferta_academica oa ON ea.codigo_actividad=oa.codigo and ea.comision=oa.comision;

SELECT DISTINCT(sede)
FROM docentes_por_sede_y_cuatrimestre;

SELECT 	c.legajo,
		(SELECT apellido || ', ' || nombres FROM docentes where legajo=c.legajo) AS apellido_nombre,
		c.cargo_docencia,
		c.caracter
FROM cargos c
WHERE c.legajo IN (SELECT DISTINCT(dpsyc.legajo)
				   FROM docentes_por_sede_y_cuatrimestre dpsyc
				   WHERE anio_cursada=2020 AND sede = 'CA')
AND caracter='ORDI'
AND ((cargo_docencia NOT LIKE 'PROFESOR%') AND (cargo_docencia<>'AYUDANTE DE SEGUNDA'))
ORDER BY apellido_nombre;
