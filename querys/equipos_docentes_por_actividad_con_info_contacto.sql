SELECT  oa.anio_cursada,
	oa.cuatrimestre_cursada,
	oa.codigo,
	(select denominacion from actividades_academicas where codigo=oa.codigo limit 1) as denominacion,
	oa.sede,
        ea.legajo_docente,
        concat(d.apellido, ', ', d.nombres) as apellido_nombre,
        (select concat(dmc.cargo_docencia, ' ', dmc.dedicacion_docencia) from docentes_por_maximo_cargo dmc where dmc.legajo=ea.legajo_docente limit 1) as cargo_docente,
        d.telefono_celular,
        d.correo_electronico
FROM oferta_academica oa
INNER JOIN equipos_por_actividad ea ON (oa.codigo=ea.codigo_actividad and oa.comision=ea.comision and oa.anio_cursada=ea.anio_cursada and oa.cuatrimestre_cursada=ea.cuatrimestre_cursada)
INNER JOIN docentes d ON ea.legajo_docente=d.legajo
--WHERE oa.codigo=10015
--group by 1,2,3,4,5,6,7,8,9,10,11
ORDER BY 1,2,3,5;
