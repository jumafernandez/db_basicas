# -*- coding: utf-8 -*-
"""
Created on Sat Apr 11 22:46:07 2020

@author: unlu
"""

def main(dir, file_docentes, file_cargos, file_licencias, file_equipos, file_materias, file_comisiones, file_carreras, file_estudios):
    
    from funciones_pasador import cargar_tabla_cargos, cargar_tabla_equipos_docentes, cargar_tabla_actividades_academicas, cargar_tabla_oferta_academica, cargar_tabla_docentes, cargar_tabla_licencias, cargar_tabla_actividades_academicas_por_carrera, cargar_tabla_carreras, cargar_maximo_titulo_en_docentes
    from funciones import file2df, insert_fecha_update
    
    # Creación de la cadena de conexion
    from sqlalchemy import create_engine
    engine = create_engine('postgresql://postgres:888888@localhost:5432/exportaciones_basicas')
    
    # Actualizo la tabla con las actualizaciones
    insert_fecha_update(engine)
    
    #Se llama a las funciones para llenar las tablas
    
    # docentes
    df = file2df(dir + file_docentes, True)
    cargar_tabla_docentes(df, engine)

    # maxímo titulo
    df = file2df(dir + file_estudios, True)
    cargar_maximo_titulo_en_docentes(df, engine)
    
    # cargos
    df = file2df(dir + file_cargos, True)
    cargar_tabla_cargos(df, engine)
    
    # licencias
    df = file2df(dir + file_licencias, True)
    cargar_tabla_licencias(df, engine)
    
    # equipos_docentes
    df = file2df(dir + file_equipos, False)
    cargar_tabla_equipos_docentes(df, engine)
    
    # actividades académicas
    df = file2df(dir + file_materias, False)
    cargar_tabla_actividades_academicas(df, engine)
    
    # actividades_academicas_por_carrera
    df = file2df(dir + file_materias, False)  
    cargar_tabla_actividades_academicas_por_carrera(df, engine)
    
    # oferta academica
    df = file2df(dir + file_comisiones, False)
    cargar_tabla_oferta_academica(df, engine)
    
    # carreras
    df = file2df(dir + file_carreras, False)
    cargar_tabla_carreras(df, engine)
    
    # Se cierra el engine de conexión
    engine.dispose()
    

if __name__ == '__main__':
    # Path del archivo a cargar
    DIRECTORIO = 'C:/Users/unlu/Google Drive/PC-Juan/Secretaría Académica/exportaciones_basicas/data/'
    ARCHIVO_DOCENTES    = 'basijuan_domicilio_todos.xlsx'
    ARCHIVO_CARGOS      = 'basijuan_cargos_vigentes.xlsx'
    ARCHIVO_EQUIPOS     = 'Equipos_Docentes_2-2019-1-2020.xlsx'
    ARCHIVO_MATERIAS    = 'Asignaturas, responsables y áreas por División.xlsx'
    ARCHIVO_OFERTA      = 'Inscriptos-2-2019_1-2020-Basicas.xlsx'
    ARCHIVO_LICENCIAS   = 'basijuan_cat_escal_Por_Cargo_cuadro.xlsx'
    ARCHIVO_CARRERAS    = 'carreras.csv'
    ARCHIVO_ESTUDIOS    = 'basijuan_nivel_educacion_max_nivel_cuadro.xlsx'

    main(DIRECTORIO, ARCHIVO_DOCENTES, ARCHIVO_CARGOS, ARCHIVO_LICENCIAS, ARCHIVO_EQUIPOS, ARCHIVO_MATERIAS, ARCHIVO_OFERTA, ARCHIVO_CARRERAS, ARCHIVO_ESTUDIOS)
