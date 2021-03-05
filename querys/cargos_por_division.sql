DROP VIEW cargos_por_division;
CREATE VIEW cargos_por_division AS
SELECT	c.legajo,
	d.nombres,
	d.apellido,
	c.codigo_cargo,
	c.fecha_alta,
	c.fecha_baja,
	c.division,
	c.cargo_docencia,
	c.dedicacion_docencia,
	c.caracter,
	d.telefono_celular,
	d.correo_electronico,
	COALESCE((SELECT tipo_licencia FROM licencias where codigo_cargo=c.codigo_cargo), 'No') as licencia
FROM cargos c
LEFT JOIN docentes d ON c.legajo=d.legajo
WHERE docencia;

SELECT 	division,
	count(*)
FROM cargos_por_division
WHERE cargo_docencia LIKE 'PROFESOR%' AND caracter='ORDI'
GROUP BY 1;

select * from cargos_por_division;