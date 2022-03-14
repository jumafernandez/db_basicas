CREATE OR REPLACE VIEW resumen_docente_por_cuatrimestre AS
SELECT	ea.legajo_docente,
		ea.anio_cursada,
		ea.cuatrimestre_cursada,
		COUNT(comision) as cantidad_comisiones,
		string_agg(((('('::text || ea.codigo_actividad::text) || ')'::text) || ' '::text) || aa.denominacion, ', '::text) as asignaturas
FROM equipos_por_actividad ea
INNER JOIN actividades_academicas aa ON ea.codigo_actividad=aa.codigo
GROUP BY 1, 2, 3
ORDER BY 1, 4, 3;

CREATE OR REPLACE VIEW docentes_y_comisiones_por_sede AS
SELECT	ea.legajo_docente,
		ea.cuatrimestre_cursada,
		ea.anio_cursada,
		cs.sede,
		COUNT(*) as cantidad_comisiones
FROM equipos_por_actividad ea
LEFT JOIN comisiones_por_sede cs ON ea.comision=cs.comision
GROUP BY 1, 2, 3, 4
ORDER BY 1, 3, 2, 5 DESC;
SELECT sede FROM docentes_y_comisiones_por_sede WHERE legajo_docente=3096;

CREATE OR REPLACE VIEW reporte_dimension_docente_cuatrimestre AS
SELECT 	dmc.legajo,
		dmc.nombres,
		dmc.apellido,
		dmc.division,
		dmc.cargo_docencia,
		dmc.modulos_del_docente,
		dmc.modulos_del_docente*2 as modulos_anualizados,
		rd.cuatrimestre_cursada,
		rd.anio_cursada,
		rd.cantidad_comisiones,
		(rd.cantidad_comisiones/dmc.modulos_del_docente) as cobertura_docente,
		(SELECT sede 
		 FROM docentes_y_comisiones_por_sede 
		 WHERE dmc.legajo=legajo_docente 
		 AND cuatrimestre_cursada=rd.cuatrimestre_cursada 
		 AND anio_cursada=rd.anio_cursada LIMIT 1) AS sede_mayoritaria,
		 TRIM(rd.asignaturas) as asignaturas
FROM docentes_por_maximo_cargo dmc
LEFT JOIN resumen_docente_por_cuatrimestre rd ON dmc.legajo=rd.legajo_docente;

DROP VIEW reporte_dimension_docente_anual;
CREATE OR REPLACE VIEW reporte_dimension_docente_anual AS
SELECT 	dmc.legajo,
		dmc.nombres,
		dmc.apellido,
		dmc.division,
		dmc.cargo_docencia,
		dmc.modulos_del_docente,
		dmc.modulos_del_docente*2 as modulos_anualizados,
		rd.anio_cursada AS anio,
		rd.cantidad_comisiones,
		ROUND((rd.cantidad_comisiones::decimal/NULLIF(dmc.modulos_del_docente*2, 0)), 2) AS cobertura_docente,
		(SELECT sede 
		 FROM docentes_y_comisiones_por_sede 
		 WHERE dmc.legajo=legajo_docente 
		 AND anio_cursada=rd.anio_cursada LIMIT 1) AS sede_mayoritaria,
		 TRIM(rd.asignaturas) as asignaturas
FROM docentes_por_maximo_cargo dmc
LEFT JOIN resumen_docente_por_anio rd ON dmc.legajo=rd.legajo_docente;

SELECT * 
FROM reporte_dimension_docente_anual 
WHERE division='Computación' 
AND anio = 2021
ORDER BY legajo;