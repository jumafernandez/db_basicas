-- De aquí tomo los dos indicadores para la dimensión docencia de la disposición 506/2019
-- Puede consultarla aquí: http://www.prensa.unlu.edu.ar/sites/www.prensa.unlu.edu.ar/files/site/Disp_506_19.pdf

-- Esta vista genera las actividades académicas en las que trabaja cada docente agrupada por distintas características
DROP VIEW docentes_por_actividad_academica;
CREATE OR REPLACE VIEW docentes_por_actividad_academica AS
SELECT	ea.legajo_docente,
	(SELECT nombres || ' ' || apellido FROM docentes WHERE legajo=ea.legajo_docente) as nombre_apellido,
	(SELECT cargo_docencia FROM docentes_por_maximo_cargo WHERE legajo=ea.legajo_docente LIMIT 1) as maximo_cargo,
	ea.anio_cursada,
	ea.cuatrimestre_cursada,
	ea.codigo_actividad,
	aa.denominacion,
	ea.comision,
	(SELECT sede FROM oferta_academica WHERE codigo=ea.codigo_actividad AND comision=ea.comision AND sede IS NOT NULL LIMIT 1) as sede_dictado,
	aa.subarea,
	aa.area,
	aa.division
	FROM equipos_por_actividad ea
INNER JOIN actividades_academicas aa ON ea.codigo_actividad=aa.codigo
WHERE (SELECT nombres || ' ' || apellido FROM docentes WHERE legajo=ea.legajo_docente) IS NOT NULL
ORDER BY 4, 5, 1, 3, 6, 8;

-- La salida del siguiente query es el insumo para el siguiente indicador:
-- dimensión docencia: cantidad de módulos asignados a docencia por área, división y sede para actividades de grado
-- Se calcula en Excel a partir de una agregación por sede, división, área, subarea (filas) y maximo cargo (columnas) haciendo un COUNT(legajo)
SELECT * FROM docentes_por_actividad_academica
WHERE ((anio_cursada=2020 AND cuatrimestre_cursada=1) OR (anio_cursada=2019 AND cuatrimestre_cursada=2));

-- Genero una vista para contar la cantidad de modulos aplicados a docencia por cada docente
-- El criterio de simplificación es 1 comisión = 1 módulo
DROP VIEW cantidad_comisiones_por_docente_y_cuatrimestre;
CREATE OR REPLACE VIEW cantidad_comisiones_por_docente_y_cuatrimestre AS
SELECT 	legajo_docente,
	anio_cursada,
	cuatrimestre_cursada,
	COUNT(legajo_docente) AS cantidad_comisiones
FROM docentes_por_actividad_academica
GROUP BY 1, 2, 3;

-- Ahora tomo los módulos por docente para complementar el indicador
-- dimension docencia: cantidad de horas/módulos de docencia por docente
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

-- Aquí genero una vista con los módulos licenciados para descontar de los activos
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

-- Aquí agrupo la información de las dos vistas anteriores (modulos totales y licenciados por docente)
DROP VIEW modulos_por_docente;
CREATE OR REPLACE VIEW modulos_por_docente AS
SELECT  d.legajo,
	(SELECT cantidad_modulos 
	FROM modulos_totales_por_docente
	WHERE legajo=d.legajo) as modulos_totales,
	COALESCE((SELECT cantidad_modulos 
	FROM modulos_licenciados_por_docente
	WHERE legajo=d.legajo), 0) as modulos_licenciados
FROM docentes d
ORDER BY 1;

SELECT * FROM modulos_por_docente;

DROP VIEW modulos_por_responsabilidad_docente;
CREATE OR REPLACE VIEW modulos_por_responsabilidad_docente AS
SELECT	aa.legajo_docente_responsable,
	d.nombres,
	d.apellido,
	string_agg(((('('::text || aa.codigo::text) || ')'::text) || ' '::text) || aa.denominacion, ', '::text) AS asignaturas,
	COUNT(*) as cantidad_asignaturas
FROM actividades_academicas aa
LEFT JOIN docentes d ON aa.legajo_docente_responsable=d.legajo
GROUP BY 1,2,3;

SELECT * FROM modulos_por_responsabilidad_docente;

-- genero una vista para tomar los datos de cada docente
DROP VIEW docentes_por_maximo_cargo;
CREATE OR REPLACE VIEW docentes_por_maximo_cargo AS 
SELECT 	c.legajo,
	c.codigo_categoria,
	c.division,
	c.cargo_docencia,
	(SELECT mpd.modulos_totales - COALESCE(mpd.modulos_licenciados, 0::bigint)
	FROM modulos_por_docente mpd
	WHERE mpd.legajo = c.legajo) AS modulos_del_docente,
	d.nombres,
	d.apellido
FROM docentes d
LEFT JOIN cargos c ON c.legajo = d.legajo
WHERE c.docencia AND c.codigo_categoria = ((	SELECT min(c2.codigo_categoria) AS min
						FROM cargos c2
						WHERE c.legajo = c2.legajo AND c2.docencia))
GROUP BY 1, 2, 3, 4, 5, 6, 7;

-- Ahora, en función de todas las vistas anteriores genero el siguiente indicador
-- INDICADOR 2
-- dimensión docencia: cantidad de horas módulos de docencia por docente
DROP VIEW modulos_docencia_por_docente;
CREATE OR REPLACE VIEW modulos_docencia_por_docente AS
SELECT	dpmc.legajo,
	(dpmc.nombres || ' ' || dpmc.apellido) AS nombre_apellido,
	dpmc.cargo_docencia AS maximo_cargo,
	dpmc.division,
	mpd.modulos_totales,
	mpd.modulos_licenciados,
	(mpd.modulos_totales - mpd.modulos_licenciados) AS modulos_activos,
	ccpdyc.anio_cursada,
	ccpdyc.cuatrimestre_cursada,
	cantidad_comisiones,
	COALESCE((SELECT cantidad_asignaturas FROM modulos_por_responsabilidad_docente WHERE legajo_docente_responsable = dpmc.legajo), 0) AS modulos_responsables,
	(COALESCE(cantidad_comisiones,0)+ COALESCE((SELECT cantidad_asignaturas FROM modulos_por_responsabilidad_docente WHERE legajo_docente_responsable = dpmc.legajo), 0)) as total_modulos_docencia
FROM docentes_por_maximo_cargo dpmc
INNER JOIN modulos_por_docente mpd ON DPMC.legajo=mpd.legajo
LEFT JOIN cantidad_comisiones_por_docente_y_cuatrimestre ccpdyc ON ccpdyc.legajo_docente=dpmc.legajo
ORDER BY 3, 1, 2;

-- Para la salida ANUALIZO los indicadores que vengo calculando por cuatrimestre
SELECT	legajo,
	nombre_apellido,
	maximo_cargo,
	division,
	modulos_totales,
	modulos_licenciados,
	modulos_activos*2 AS modulos_activos_anualizados,
	modulos_responsables,
	SUM(cantidad_comisiones) AS cantidad_comisiones_anualizado,
	(SUM(cantidad_comisiones) + modulos_responsables)AS modulos_docencia_anualizados
FROM modulos_docencia_por_docente
WHERE ((anio_cursada=2020 AND cuatrimestre_cursada=1) OR (anio_cursada=2019 AND cuatrimestre_cursada=2))
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8;
