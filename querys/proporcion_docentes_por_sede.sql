--422
SELECT COUNT(*)
FROM docentes
WHERE legajo IN (SELECT DISTINCT(legajo) FROM cargos where docencia)
AND legajo IN (SELECT legajo_docente
FROM equipos_por_actividad ea
INNER JOIN comisiones_por_sede cs ON ea.comision=cs.comision
WHERE sede='LU');

--558
SELECT COUNT(*)
FROM docentes
WHERE legajo IN (SELECT DISTINCT(legajo) FROM cargos where docencia);