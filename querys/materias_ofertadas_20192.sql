select distinct(oa.codigo), aa.denominacion, aa.carreras_descripcion, aa.division
from oferta_academica oa
inner join actividades_academicas aa ON oa.codigo=aa.codigo
where cuatrimestre_cursada=2 and anio_cursada=2019
order by 1;