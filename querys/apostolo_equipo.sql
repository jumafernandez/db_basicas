select 	ea.legajo_docente,
	
	ea.codigo_actividad
from equipos_por_actividad ea
--inner join cargos c on ea.legajo_docente=c.legajo
where legajo_docente in
(select legajo_docente from equipos_por_actividad where codigo_actividad=11038);

select 	c.legajo,
	d.nombres || ' ' || d.apellido,
	c.cargo_docencia,
	c.dedicacion_docencia
from cargos c
inner join docentes d on c.legajo=d.legajo
where c.legajo=3566;

select * from equipos_por_actividad where legajo_docente=3566;