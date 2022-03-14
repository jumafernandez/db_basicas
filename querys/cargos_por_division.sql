SELECT 	c.legajo,
		TRIM(c.nombres) AS nombres,
		TRIM(c.apellido) AS apellido,
		c.fecha_alta,
		c.caracter,
		c.division,
		c.cargo_docencia,
		c.dedicacion_docencia,
		c.division,
		TRIM(d.telefono),
		TRIM(d.correo_electronico),
		TRIM(d.maximo_titulo),
		CASE WHEN (SELECT tipo_licencia FROM licencias WHERE codigo_cargo=c.codigo_cargo) IS NULL THEN 'Activo'
			ELSE (SELECT tipo_licencia FROM licencias WHERE codigo_cargo=c.codigo_cargo)
		END as licencia
FROM cargos c
INNER JOIN docentes d ON c.legajo=d.legajo
WHERE docencia;

-- select * from docentes;