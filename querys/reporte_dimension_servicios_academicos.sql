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

DROP VIEW oferta_academica_por_sede;
CREATE OR REPLACE VIEW public.oferta_academica_por_sede AS
SELECT	oa.anio_cursada,
    	oa.cuatrimestre_cursada,
    	oa.codigo,
		aa.denominacion,
    	cs.sede,
		aa.division,
		sum(oa.cantidad_inscriptos) as cantidad_inscriptos
FROM oferta_academica oa
INNER JOIN comisiones_por_sede cs ON oa.comision=cs.comision
LEFT JOIN actividades_academicas aa ON oa.codigo=aa.codigo
GROUP BY oa.anio_cursada, oa.cuatrimestre_cursada, oa.codigo, aa.denominacion, cs.sede, aa.division
ORDER BY oa.anio_cursada, oa.cuatrimestre_cursada, oa.codigo, aa.denominacion, cs.sede, aa.division;

SELECT * FROM oferta_academica_por_sede WHERE codigo=11071;

DROP VIEW indicadores_equipos_por_actividad_y_sede;
CREATE OR REPLACE VIEW public.indicadores_equipos_por_actividad_y_sede AS
SELECT	ea.anio_cursada,
    	ea.cuatrimestre_cursada,
    	ea.codigo_actividad,	
		aa.denominacion,
    	cs.sede,
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
		-- acumuladores de docentes (texto)
    	string_agg(DISTINCT ((((('('::text || ea.legajo_docente::text) || ')'::text) || ' '::text) || d.nombres) || ' '::text) || d.apellido, ', '::text) AS docentes
FROM oferta_academica oa
INNER JOIN comisiones_por_sede cs ON oa.comision=cs.comision
LEFT JOIN actividades_academicas aa ON oa.codigo=aa.codigo
LEFT JOIN equipos_por_actividad ea ON (oa.codigo=ea.codigo_actividad AND oa.comision=ea.comision AND oa.anio_cursada=ea.anio_cursada AND oa.cuatrimestre_cursada=ea.cuatrimestre_cursada)
LEFT JOIN docentes_por_maximo_cargo d ON ea.legajo_docente = d.legajo
GROUP BY ea.anio_cursada, aa.denominacion, ea.cuatrimestre_cursada, ea.codigo_actividad, cs.sede, aa.division
ORDER BY ea.anio_cursada, aa.denominacion, ea.cuatrimestre_cursada, ea.codigo_actividad, cs.sede, aa.division;

SELECT * FROM indicadores_equipos_por_actividad_y_sede WHERE codigo_actividad=11071;

DROP VIEW resumen_equipos_por_actividad_y_sede;
CREATE OR REPLACE VIEW public.resumen_equipos_por_actividad_y_sede AS
SELECT	oa.anio_cursada,
    	oa.cuatrimestre_cursada,
    	oa.codigo,
		oa.denominacion,
    	oa.sede,
		oa.division,
		oa.cantidad_inscriptos,
		cargos_profesor,
		cargos_auxiliares,
		cargos_ayudantes_alumnos,
		cantidad_modulos,
		modulos_profesor,
		modulos_auxiliar,
		modulos_ayudante_alumno,
		docentes
FROM oferta_academica_por_sede oa
LEFT JOIN indicadores_equipos_por_actividad_y_sede ie 
ON (oa.codigo=ie.codigo_actividad AND oa.sede=ie.sede AND oa.anio_cursada=ie.anio_cursada AND oa.cuatrimestre_cursada=ie.cuatrimestre_cursada);

SELECT * 
FROM resumen_equipos_por_actividad_y_sede
WHERE codigo=11071 AND anio_cursada=2021;