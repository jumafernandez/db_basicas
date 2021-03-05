-- Descripción: Análisis de módulos docentes por división

select sum(modulos_del_docente)
from modulos_por_docente md
inner join cargos c ON md.legajo=c.legajo
where division='Física' and cargo_docencia LIKE 'PROFESOR%'
order by 1;


-- Descripción: Cantidad de comisiones por división
 
select * 
from oferta_academica oa
inner join actividades_academicas aa ON oa.codigo=aa.codigo
where division='Física';