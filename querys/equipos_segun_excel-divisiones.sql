-- select anio_cursada, cuatrimestre_cursada, count(*) from equipos_por_actividad group by 1,2;

-- 2/2019 y 1/2020
SELECT	ea.legajo_docente,
		d.apellido || ' ' || d.nombres,
		c.cargo_docencia,
		ea.codigo_actividad,
		aa.denominacion,
		ea.comision,
		axa.codigo_carrera,
		anio_cursada,
		cuatrimestre_cursada
FROM equipos_por_actividad ea
INNER JOIN actividades_academicas aa ON ea.codigo_actividad=aa.codigo
INNER JOIN asignaturas_por_carrera axa ON ea.codigo_actividad=axa.codigo_actividad
INNER JOIN docentes d ON ea.legajo_docente=d.legajo
INNER JOIN cargos c ON d.legajo=c.legajo;
