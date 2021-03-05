-- Padron profesores
SELECT	d.legajo,
	(d.nombres || ' ' || d.apellido) AS nombre_apellido,
	c.cargo_docencia,
	c.dedicacion_docencia,
	c.caracter,
	c.division,
	to_char(now()::timestamp with time zone, 'YYYY'::text)::numeric - to_char(d.fecha_nacimiento::timestamp with time zone, 'YYYY'::text)::numeric as edad
FROM docentes d
LEFT JOIN cargos c ON d.legajo=c.legajo
WHERE caracter='ORDI' AND docencia
AND c.codigo_categoria IN (SELECT min(c2.codigo_categoria) AS min FROM cargos c2 WHERE c.legajo = c2.legajo AND c2.docencia AND caracter='ORDI')
AND cargo_docencia LIKE 'PROFE%'
ORDER BY legajo;

-- Padron auxiliares
SELECT	d.legajo,
	(d.nombres || ' ' || d.apellido) AS nombre_apellido,
	c.cargo_docencia,
	c.dedicacion_docencia,
	c.caracter,
	c.division,
	to_char(now()::timestamp with time zone, 'YYYY'::text)::numeric - to_char(d.fecha_nacimiento::timestamp with time zone, 'YYYY'::text)::numeric as edad
FROM docentes d
LEFT JOIN cargos c ON d.legajo=c.legajo
WHERE caracter='ORDI' AND docencia
AND c.codigo_categoria IN (SELECT min(c2.codigo_categoria) AS min FROM cargos c2 WHERE c.legajo = c2.legajo AND c2.docencia AND caracter='ORDI')
AND NOT(cargo_docencia LIKE 'PROFE%') AND cargo_docencia<>'AYUDANTE DE SEGUNDA'
ORDER BY legajo;

-- Docentes interinos
SELECT	d.legajo,
	(d.nombres || ' ' || d.apellido) AS nombre_apellido,
	c.cargo_docencia,
	c.dedicacion_docencia,
	c.caracter,
	c.division,
	to_char(now()::timestamp with time zone, 'YYYY'::text)::numeric - to_char(d.fecha_nacimiento::timestamp with time zone, 'YYYY'::text)::numeric as edad
FROM docentes d
LEFT JOIN cargos c ON d.legajo=c.legajo
WHERE caracter='INTE' AND docencia
AND c.codigo_categoria IN (SELECT min(c2.codigo_categoria) AS min FROM cargos c2 WHERE c.legajo = c2.legajo AND c2.docencia)
AND c.legajo NOT IN (SELECT legajo FROM cargos WHERE caracter='ORDI')
ORDER BY legajo;
