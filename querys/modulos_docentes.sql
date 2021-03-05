DROP VIEW modulos_totales_por_docente;
CREATE OR REPLACE VIEW modulos_totales_por_docente AS
SELECT  c.legajo,
	SUM(CASE WHEN c.dedicacion_docencia='EXCLUSIVA' THEN 4
		 WHEN c.dedicacion_docencia='SEMIEXCLUSIVA' THEN 2
		 WHEN c.dedicacion_docencia='SIMPLE' THEN 1
        ELSE 0 END) AS cantidad_modulos
FROM cargos c
WHERE docencia=True
GROUP BY 1;

DROP VIEW modulos_licenciados_por_docente;
CREATE OR REPLACE VIEW modulos_licenciados_por_docente AS
SELECT  c.legajo,
	SUM(CASE WHEN c.dedicacion_docencia='EXCLUSIVA' THEN 4
		 WHEN c.dedicacion_docencia='SEMIEXCLUSIVA' THEN 2
		 WHEN c.dedicacion_docencia='SIMPLE' THEN 1
        ELSE 0 END) AS cantidad_modulos
FROM cargos c
WHERE docencia=True
AND c.codigo_cargo IN (SELECT codigo_cargo FROM licencias)
GROUP BY 1;

DROP VIEW modulos_por_docente;
CREATE OR REPLACE VIEW modulos_por_docente AS
SELECT  d.legajo,
	(SELECT cantidad_modulos 
	FROM modulos_totales_por_docente
	WHERE legajo=d.legajo) as modulos_totales,
	(SELECT cantidad_modulos 
	FROM modulos_licenciados_por_docente
	WHERE legajo=d.legajo) as modulos_licenciados, 
	((SELECT cantidad_modulos 
	 FROM modulos_totales_por_docente
	 WHERE legajo=d.legajo) - (SELECT cantidad_modulos 
				    FROM modulos_licenciados_por_docente
				    WHERE legajo=d.legajo)) as modulos_del_docente
FROM docentes d;



DROP VIEW cantidad_comisiones_por_docente;
CREATE OR REPLACE VIEW cantidad_comisiones_por_docente AS
SELECT	ea.legajo_docente,
	ea.cuatrimestre_cursada,
	ea.anio_cursada,
	count(comision) as cantidad_comisiones
FROM equipos_por_actividad ea
GROUP BY 1,2,3;

DROP VIEW modulos_y_comisiones_por_docente;
CREATE OR REPLACE VIEW modulos_y_comisiones_por_docente AS
SELECT	d.legajo,
	d.apellido,
	d.nombres,
	MAX(md.modulos_del_docente) as modulos_del_docente,
	SUM(ccd.cantidad_comisiones) as cantidad_comisiones
FROM docentes d
LEFT JOIN modulos_por_docente md ON d.legajo=md.legajo
LEFT JOIN cantidad_comisiones_por_docente ccd ON d.legajo=ccd.legajo_docente
where d.legajo IN (SELECT c.legajo FROM cargos c WHERE c.docencia=True)
GROUP BY 1,2,3;

SELECT sum(modulos_del_docente) FROM modulos_y_comisiones_por_docente;
SELECT sum(cantidad_inscriptos) FROM oferta_academica;



DROP VIEW cantidad_estudiantes_por_modulo_docente;
CREATE OR REPLACE VIEW cantidad_estudiantes_por_modulo_docente AS
SELECT	aa.division,
	aa.area,
	aa.legajo_docente_responsable as codigo_carrera,
	aa.codigo as codigo_actividad,
	aa.denominacion as denominacion_actividad,
	oa.anio_cursada,
	oa.cuatrimestre_cursada,
	oa.comision,
	c.cargo_docencia,
	c.dedicacion_docencia,
	CASE 	WHEN c.dedicacion_docencia='EXCLUSIVA' THEN 4
		WHEN c.dedicacion_docencia='SEMIEXCLUSIVA' THEN 2
        ELSE 1 END AS modulos_docentes,
	oa.cantidad_inscriptos
FROM equipos_por_actividad ea
INNER JOIN actividades_academicas aa ON ea.codigo_actividad=aa.codigo
INNER JOIN oferta_academica oa ON 	(ea.codigo_actividad = oa.codigo AND ea.comision = ea.comision 
					AND ea.cuatrimestre_cursada = oa.cuatrimestre_cursada AND ea.anio_cursada = oa.anio_cursada)
INNER JOIN cargos c ON ea.legajo_docente=c.legajo;

select * from cantidad_estudiantes_por_modulo_docente;

select * from equipos_por_actividad;
select * from oferta_academica;
select * from cargos;

CREATE OR REPLACE VIEW estudiantes_por_asignatura_area_división AS
SELECT	aa.division,
	aa.area,
	oa.anio_cursada,
	oa.cuatrimestre_cursada,
	oa.codigo,
	oa.comision,
	oa.cantidad_inscriptos
FROM oferta_academica oa
INNER JOIN actividades_academicas aa ON oa.codigo=aa.codigo;
