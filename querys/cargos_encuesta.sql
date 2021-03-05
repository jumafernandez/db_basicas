SELECT 	c.legajo,
	d.apellido || ', ' || d.nombres as apellido_nombre,
	CASE	WHEN c.cargo_docencia='PROFESOR TITULAR' THEN 'Prof. Titular'
		WHEN c.cargo_docencia='PROFESOR ASOCIADO' THEN 'Prof. Asociado'
		WHEN c.cargo_docencia='PROFESOR ADJUNTO' THEN 'Prof. Adjunto'
		WHEN c.cargo_docencia='JEFE DE TRABAJOS PRÁCTICOS' THEN 'JTP'
		WHEN c.cargo_docencia='AYUDANTE DE PRIMERA' THEN 'Ayudante 1°'
		WHEN c.cargo_docencia='AYUDANTE DE SEGUNDA' THEN 'Ayudante 2°'
	END as cargo_encuesta
FROM docentes_por_maximo_cargo c
INNER JOIN docentes d ON c.legajo=d.legajo
ORDER BY 1;
