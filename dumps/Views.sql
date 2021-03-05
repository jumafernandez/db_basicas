--
-- PostgreSQL VIEWS dump
--

-- Dumped from database version 9.6.11
-- Dumped by pg_dump version 9.6.11

--
-- Name: modulos_por_docente; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.modulos_por_docente AS
 SELECT c.legajo,
    c.apellido,
    c.nombres,
    sum(
        CASE
            WHEN (c.dedicacion_docencia = 'EXCLUSIVA'::text) THEN 4
            WHEN (c.dedicacion_docencia = 'SEMIEXCLUSIVA'::text) THEN 2
            WHEN (c.dedicacion_docencia = 'SIMPLE'::text) THEN 1
            ELSE 0
        END) AS modulos_del_docente
   FROM public.cargos c
  WHERE (c.docencia = true)
  GROUP BY c.legajo, c.apellido, c.nombres;


ALTER TABLE public.modulos_por_docente OWNER TO postgres;

--
-- Name: docente_por_maximo_cargo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.docente_por_maximo_cargo AS
 SELECT c.legajo,
    c.apellido,
    c.nombres,
    c.cuil,
    c.codigo_cargo,
    c.fecha_alta,
    c.fecha_baja,
    c.caracter,
    c.codigo_categoria,
    c.categoria,
    c.tipo_categoria4,
    c.tipo_norma,
    c.numero_norma,
    c.emisor,
    c.division,
    c.cargo_docencia,
    c.dedicacion_docencia,
    c.docencia,
    md.modulos_del_docente
   FROM (public.cargos c
     JOIN public.modulos_por_docente md ON ((c.legajo = md.legajo)))
  WHERE (c.codigo_categoria = ( SELECT min(c2.codigo_categoria) AS min
           FROM public.cargos c2
          WHERE ((c.legajo = c2.legajo) AND c2.docencia)));


ALTER TABLE public.docente_por_maximo_cargo OWNER TO postgres;

--
-- Name: asignacion_docente; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.asignacion_docente AS
 SELECT ea.codigo_actividad,
    aa.denominacion,
    ea.cuatrimestre_cursada,
    ea.anio_cursada,
    ea.comision,
    ea.legajo_docente,
    concat(btrim(c.apellido), ', ', btrim(c.nombres)) AS concat,
    c.cargo_docencia,
    c.dedicacion_docencia,
    c.modulos_del_docente,
    aa.division
   FROM ((public.equipos_por_actividad ea
     JOIN public.actividades_academicas aa ON ((ea.codigo_actividad = aa.codigo)))
     JOIN public.docente_por_maximo_cargo c ON ((ea.legajo_docente = c.legajo)))
  WHERE (c.docencia = true);


ALTER TABLE public.asignacion_docente OWNER TO postgres;

--
-- Name: asignacion_docente_2019_2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.asignacion_docente_2019_2 AS
 SELECT ea.codigo_actividad,
    aa.denominacion,
    ea.comision,
    ea.legajo_docente,
    concat(btrim(c.apellido), ', ', btrim(c.nombres)) AS concat,
    c.cargo_docencia,
    c.dedicacion_docencia,
    c.modulos_del_docente,
    c.division
   FROM ((public.equipos_por_actividad ea
     JOIN public.actividades_academicas aa ON ((ea.codigo_actividad = aa.codigo)))
     JOIN public.docente_por_maximo_cargo c ON ((ea.legajo_docente = c.legajo)))
  WHERE ((ea.cuatrimestre_cursada = 2) AND (ea.anio_cursada = 2019) AND (c.docencia = true));


ALTER TABLE public.asignacion_docente_2019_2 OWNER TO postgres;

--
-- Name: asignacion_docente_2020_1; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.asignacion_docente_2020_1 AS
 SELECT ea.codigo_actividad,
    aa.denominacion,
    ea.comision,
    ea.legajo_docente,
    concat(btrim(c.apellido), ', ', btrim(c.nombres)) AS concat,
    c.cargo_docencia,
    c.dedicacion_docencia,
    c.modulos_del_docente,
    c.division
   FROM ((public.equipos_por_actividad ea
     JOIN public.actividades_academicas aa ON ((ea.codigo_actividad = aa.codigo)))
     JOIN public.docente_por_maximo_cargo c ON ((ea.legajo_docente = c.legajo)))
  WHERE ((ea.cuatrimestre_cursada = 1) AND (ea.anio_cursada = 2020) AND (c.docencia = true));


ALTER TABLE public.asignacion_docente_2020_1 OWNER TO postgres;

--
-- Name: asignacion_docente_2020_2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.asignacion_docente_2020_2 AS
 SELECT ea.codigo_actividad,
    aa.denominacion,
    ea.comision,
    ea.legajo_docente,
    concat(btrim(c.apellido), ', ', btrim(c.nombres)) AS concat,
    c.cargo_docencia,
    c.dedicacion_docencia,
    c.modulos_del_docente,
    c.division
   FROM ((public.equipos_por_actividad ea
     JOIN public.actividades_academicas aa ON ((ea.codigo_actividad = aa.codigo)))
     JOIN public.docente_por_maximo_cargo c ON ((ea.legajo_docente = c.legajo)))
  WHERE ((ea.cuatrimestre_cursada = 2) AND (ea.anio_cursada = 2020) AND (c.docencia = true));


ALTER TABLE public.asignacion_docente_2020_2 OWNER TO postgres;

--
-- Name: asignacion_docente_por_cuatrimestre; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.asignacion_docente_por_cuatrimestre AS
 SELECT ea.codigo_actividad,
    aa.denominacion,
    ea.comision,
    ea.legajo_docente,
    concat(btrim(c.apellido), ', ', btrim(c.nombres)) AS concat,
    c.cargo_docencia,
    c.dedicacion_docencia,
    c.modulos_del_docente,
    c.division
   FROM ((public.equipos_por_actividad ea
     JOIN public.actividades_academicas aa ON ((ea.codigo_actividad = aa.codigo)))
     JOIN public.docente_por_maximo_cargo c ON ((ea.legajo_docente = c.legajo)))
  WHERE ((ea.cuatrimestre_cursada = 1) AND (ea.anio_cursada = 2020) AND (c.docencia = true));


ALTER TABLE public.asignacion_docente_por_cuatrimestre OWNER TO postgres;

--
-- Name: cantidad_comisiones_por_docente; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.cantidad_comisiones_por_docente AS
 SELECT ea.legajo_docente,
    ea.cuatrimestre_cursada,
    ea.anio_cursada,
    count(ea.comision) AS cantidad_comisiones
   FROM public.equipos_por_actividad ea
  GROUP BY ea.legajo_docente, ea.cuatrimestre_cursada, ea.anio_cursada;


ALTER TABLE public.cantidad_comisiones_por_docente OWNER TO postgres;

--
-- Name: cantidad_estudiantes_por_modulo_docente; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.cantidad_estudiantes_por_modulo_docente AS
 SELECT aa.division,
    aa.area,
    aa.legajo_docente_responsable AS codigo_carrera,
    aa.codigo AS codigo_actividad,
    aa.denominacion AS denominacion_actividad,
    oa.anio_cursada,
    oa.cuatrimestre_cursada,
    oa.comision,
    c.cargo_docencia,
    c.dedicacion_docencia,
        CASE
            WHEN (c.dedicacion_docencia = 'EXCLUSIVA'::text) THEN 4
            WHEN (c.dedicacion_docencia = 'SEMIEXCLUSIVA'::text) THEN 2
            ELSE 1
        END AS modulos_docentes,
    oa.cantidad_inscriptos
   FROM (((public.equipos_por_actividad ea
     JOIN public.actividades_academicas aa ON ((ea.codigo_actividad = aa.codigo)))
     JOIN public.oferta_academica oa ON (((ea.codigo_actividad = oa.codigo) AND (ea.comision = ea.comision) AND (ea.cuatrimestre_cursada = oa.cuatrimestre_cursada) AND (ea.anio_cursada = oa.anio_cursada))))
     JOIN public.cargos c ON ((ea.legajo_docente = c.legajo)));


ALTER TABLE public.cantidad_estudiantes_por_modulo_docente OWNER TO postgres;

--
-- Name: estudiantes_por_asignatura_area_división; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."estudiantes_por_asignatura_area_división" AS
 SELECT aa.division,
    aa.area,
    oa.anio_cursada,
    oa.cuatrimestre_cursada,
    oa.codigo,
    oa.comision,
    oa.cantidad_inscriptos
   FROM (public.oferta_academica oa
     JOIN public.actividades_academicas aa ON ((oa.codigo = aa.codigo)));


ALTER TABLE public."estudiantes_por_asignatura_area_división" OWNER TO postgres;

--
-- Name: modulos_y_comisiones_por_docente; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.modulos_y_comisiones_por_docente AS
 SELECT d.legajo,
    d.apellido,
    d.nombres,
    max(md.modulos_del_docente) AS modulos_del_docente,
    sum(ccd.cantidad_comisiones) AS cantidad_comisiones
   FROM ((public.docentes d
     LEFT JOIN public.modulos_por_docente md ON ((d.legajo = md.legajo)))
     LEFT JOIN public.cantidad_comisiones_por_docente ccd ON ((d.legajo = ccd.legajo_docente)))
  WHERE (d.legajo IN ( SELECT c.legajo
           FROM public.cargos c
          WHERE (c.docencia = true)))
  GROUP BY d.legajo, d.apellido, d.nombres;


ALTER TABLE public.modulos_y_comisiones_por_docente OWNER TO postgres;


--
-- PostgreSQL database dump complete
--

CREATE OR REPLACE VIEW public.docente_por_maximo_cargo AS 
 SELECT c.legajo,
    c.apellido,
    c.nombres,
    c.cuil,
    c.codigo_cargo,
    c.fecha_alta,
    c.fecha_baja,
    c.caracter,
    c.codigo_categoria,
    c.categoria,
    c.tipo_categoria4,
    c.tipo_norma,
    c.numero_norma,
    c.emisor,
    c.division,
    c.cargo_docencia,
    c.dedicacion_docencia,
    c.docencia,
    md.modulos_del_docente
   FROM cargos c
     JOIN modulos_por_docente md ON c.legajo = md.legajo
  WHERE c.codigo_categoria = (( SELECT min(c2.codigo_categoria) AS min
           FROM cargos c2
          WHERE c.legajo = c2.legajo AND c2.docencia));

ALTER TABLE public.docente_por_maximo_cargo
  OWNER TO postgres;

