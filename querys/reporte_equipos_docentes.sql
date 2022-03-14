DROP VIEW resumen_equipos_por_oferta_academica;
CREATE OR REPLACE VIEW resumen_equipos_por_oferta_academica AS
SELECT	oa.anio_cursada,
		oa.cuatrimestre_cursada,
		-- datos de la asignatura
		oa.codigo,
		aa.denominacion,
		oa.comision,
		aa.division,
		-- datos del docente
		ea.legajo_docente as legajo,
		dmc.nombres,
		dmc.apellido,
		dmc.cargo_docencia
FROM oferta_academica oa
LEFT JOIN equipos_por_actividad ea 
ON (oa.codigo=ea.codigo_actividad AND oa.comision=ea.comision AND oa.cuatrimestre_cursada=ea.cuatrimestre_cursada AND oa.anio_cursada=ea.anio_cursada)
LEFT JOIN actividades_academicas aa ON ea.codigo_actividad=aa.codigo
LEFT JOIN docentes_por_maximo_cargo dmc ON ea.legajo_docente=dmc.legajo;
