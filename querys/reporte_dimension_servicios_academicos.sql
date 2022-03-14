-- View: public.resumen_equipos_por_actividad

-- DROP VIEW public.resumen_equipos_por_actividad;

DROP VIEW resumen_equipos_por_actividad;
CREATE OR REPLACE VIEW public.resumen_equipos_por_actividad AS
SELECT	oa.anio_cursada,
    	oa.cuatrimestre_cursada,
    	oa.codigo,
		aa.denominacion,
    	oa.comision,
		aa.division,
    	-- acumuladores con cantidad de cargos
		SUM(CASE WHEN d.cargo_docencia ~~ 'PROFESOR%'::text THEN 1 ELSE 0 END) AS cargos_profesor,
    	SUM(CASE WHEN d.cargo_docencia = 'JEFE DE TRABAJOS PRÁCTICOS'::text 
				   OR d.cargo_docencia = 'AYUDANTE DE PRIMERA'::text THEN 1 ELSE 0 END) AS cargos_auxiliares,
    	SUM(CASE WHEN d.cargo_docencia = 'AYUDANTE DE SEGUNDA'::text THEN 1 ELSE 0 END) AS cargos_ayudantes_alumnos,
    	-- acumuladores con cantidad de módulos
	    SUM(d.modulos_del_docente) AS cantidad_modulos,
	    SUM(CASE WHEN d.cargo_docencia ~~ 'PROFESOR%'::text THEN d.modulos_del_docente ELSE 0 END) AS modulos_profesor,
	    SUM(CASE WHEN d.cargo_docencia = 'JEFE DE TRABAJOS PRÁCTICOS'::text 
				   OR d.cargo_docencia = 'AYUDANTE DE PRIMERA'::text THEN d.modulos_del_docente ELSE 0 END) AS modulos_auxiliar,
	    SUM(CASE WHEN d.cargo_docencia = 'AYUDANTE DE SEGUNDA'::text THEN d.modulos_del_docente	ELSE 0 END) AS modulos_ayudante_alumno,
		oa.cantidad_inscriptos,
		-- acumuladores de docentes (texto)
    	string_agg(((((('('::text || ea.legajo_docente::text) || ')'::text) || ' '::text) || d.nombres) || ' '::text) || d.apellido, ', '::text) AS docentes
FROM oferta_academica oa
LEFT JOIN actividades_academicas aa ON oa.codigo=aa.codigo
LEFT JOIN equipos_por_actividad ea ON (oa.codigo=ea.codigo_actividad AND oa.comision=ea.comision AND oa.anio_cursada=ea.anio_cursada AND oa.cuatrimestre_cursada=ea.cuatrimestre_cursada)
LEFT JOIN docentes_por_maximo_cargo d ON ea.legajo_docente = d.legajo
GROUP BY oa.anio_cursada, aa.denominacion, oa.cuatrimestre_cursada, oa.codigo, oa.comision, aa.division
ORDER BY oa.anio_cursada, aa.denominacion, oa.cuatrimestre_cursada, oa.codigo, oa.comision, aa.division;

SELECT * 
FROM resumen_equipos_por_actividad
WHERE codigo=11071 AND anio_cursada=2021;