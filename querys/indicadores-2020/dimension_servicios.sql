-- genero una vista para tomar los datos de cada docente
DROP VIEW docentes_por_maximo_cargo;
CREATE OR REPLACE VIEW docentes_por_maximo_cargo AS 
SELECT 	c.legajo,
	c.codigo_categoria,
	c.division,
	c.cargo_docencia,
	(SELECT mpd.modulos_totales - COALESCE(mpd.modulos_licenciados, 0::bigint)
	FROM modulos_por_docente mpd
	WHERE mpd.legajo = c.legajo) AS modulos_del_docente,
	d.nombres,
	d.apellido
FROM docentes d
LEFT JOIN cargos c ON c.legajo = d.legajo
WHERE c.docencia AND c.codigo_categoria = ((	SELECT min(c2.codigo_categoria) AS min
						FROM cargos c2
						WHERE c.legajo = c2.legajo AND c2.docencia))
GROUP BY 1, 2, 3, 4, 5, 6, 7;


DROP VIEW resumen_equipos_por_actividad;
CREATE VIEW resumen_equipos_por_actividad AS
SELECT	ea.anio_cursada,
	ea.cuatrimestre_cursada,
	ea.codigo_actividad,
	ea.comision,
	string_agg('(' || ea.legajo_docente::text || ')' || ' ' || d.nombres || ' ' || d.apellido, ', ') AS docentes,
	sum(CASE WHEN cargo_docencia LIKE 'PROFESOR%' THEN 1 else 0 END) AS cargos_profesor,
	sum(CASE WHEN (cargo_docencia = 'JEFE DE TRABAJOS PRÁCTICOS' OR cargo_docencia = 'AYUDANTE DE PRIMERA') THEN 1 else 0 END) AS cargos_auxiliares,
	sum(CASE WHEN (cargo_docencia = 'AYUDANTE DE SEGUNDA') THEN 1 else 0 END) AS cargos_ayudantes_alumnos,
	sum(modulos_del_docente) as cantidad_modulos
FROM equipos_por_actividad ea
INNER JOIN docentes_por_maximo_cargo d ON ea.legajo_docente=d.legajo
GROUP BY 1,2,3,4
ORDER BY 1,2,3,4;

DROP VIEW dimension_servicios_academicos;
CREATE OR REPLACE VIEW dimension_servicios_academicos AS
SELECT 	oa.anio_cursada,
	oa.cuatrimestre_cursada,
	oa.codigo,
	aa.denominacion,
	oa.comision,
	aa.subarea,
	aa.area,
	aa.division,
	oa.sede,
	oa.cantidad_inscriptos,
	repa.docentes,
	repa.cargos_profesor,
	repa.cargos_auxiliares,
	repa.cargos_ayudantes_alumnos,
	repa.cantidad_modulos
FROM oferta_academica oa
INNER JOIN actividades_academicas aa ON oa.codigo=aa.codigo
LEFT JOIN resumen_equipos_por_actividad repa ON (oa.anio_cursada=repa.anio_cursada AND oa.cuatrimestre_cursada=repa.cuatrimestre_cursada AND oa.codigo=repa.codigo_actividad AND oa.comision=repa.comision)
ORDER BY 1,2,3,5;

SELECT *
FROM dimension_servicios_academicos;
