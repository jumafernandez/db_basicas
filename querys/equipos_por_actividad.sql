SELECT	ea.codigo_actividad,
	aa.denominacion,
	ea.comision,
	ea.legajo_docente,
	(select nombres || ' ' || apellido from docentes where legajo=ea.legajo_docente) as apellido_nombres,
	(select cargo_docencia from docentes_por_maximo_cargo where legajo=ea.legajo_docente limit 1) as maximo_cargo,
	(select modulos_del_docente from modulos_por_docente where legajo=ea.legajo_docente) as cantidad_modulos,
	ea.anio_cursada,
	ea.cuatrimestre_cursada
from equipos_por_actividad ea
inner join actividades_academicas aa ON ea.codigo_actividad=aa.codigo
where aa.division='Biología'
order by anio_cursada, cuatrimestre_cursada, codigo_actividad;