SELECT 	d.*,
	c.*,
	(select tipo_licencia from licencias where codigo_cargo=c.codigo_cargo) as licencia
FROM cargos c
LEFT JOIN docentes d ON c.legajo=d.legajo
WHERE apellido LIKE 'MARAZZ%';

