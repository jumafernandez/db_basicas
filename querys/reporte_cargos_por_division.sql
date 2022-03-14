DROP VIEW resumen_cargos_por_division;
CREATE OR REPLACE VIEW resumen_cargos_por_division AS
SELECT	c.legajo,
		TRIM(c.nombres) AS nombres,
        TRIM(c.apellido) AS apellido,
        c.division,
        c.fecha_alta,
        c.caracter,
        c.cargo_docencia,
		c.dedicacion_docencia,
		TRIM(d.telefono) as telefono,
		TRIM(d.correo_electronico) as correo_electronico,
		TRIM(d.maximo_titulo) as maximo_titulo,
		CASE WHEN (SELECT tipo_licencia FROM licencias WHERE codigo_cargo=c.codigo_cargo) IS NULL THEN 'Activo'
                   ELSE (SELECT tipo_licencia FROM licencias WHERE codigo_cargo=c.codigo_cargo)
        END as licencia
FROM cargos c
INNER JOIN docentes d ON c.legajo=d.legajo
WHERE docencia
ORDER BY 1;