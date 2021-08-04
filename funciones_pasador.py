# -*- coding: utf-8 -*-
"""
Created on Sun Apr 12 10:17:05 2020

@author: unlu
"""

def cargar_tabla_docentes(data, engine_con):
    ''' Carga la tabla docentes en la DB PostgreSQL
    en función del archivo descargado de Interfaz UNLu-Mapuche
    '''

    # Cambio el nombre de las columnas para guardar en la tabla con los nombres del df
    data.columns = ['legajo', 'apellido', 'nombres', 'fecha_nacimiento', 'edad', 'sexo', 'dependencias', 'tipo_documento', 'numero_documento', 'calle', 'numero', 'piso', 'barrio', 'depto', 'codigo_postal', 'telefono', 'fax', 'telefono_celular', 'correo_electronico', 'localidad', 'provincia']

    # Elimino la columna edad
    data = data.drop(['edad'], axis=1)
    
    # Quito los espacios entre el texto en las columnas textuales (object)
    data_coltexto = data.select_dtypes(['object'])
    data[data_coltexto.columns] = data_coltexto.apply(lambda x: x.str.strip())

    # Guardar el dataframe en la DB
    try: # Pruebo en caso que no exista
        data.to_sql('docentes', engine_con, index=False, if_exists='fail')
        with engine_con.connect() as con:
            con.execute('ALTER TABLE docentes ADD PRIMARY KEY(legajo);')
            con.execute('ALTER TABLE docentes ALTER COLUMN numero_documento TYPE text;')
            # Preparo la tabla para cargar el máximo título del docente
            con.execute('ALTER TABLE docentes ADD COLUMN maximo_titulo text;')
            con.execute('ALTER TABLE docentes ADD COLUMN entidad_otorgante_titulo text;')
            con.execute('ALTER TABLE docentes ADD COLUMN fecha_emision_titulo date;')
    except: # Si existe borro los registros y vuelvo a cargar los nuevos
        engine_con.execute("DELETE FROM docentes;")      
        data.to_sql('docentes', engine_con, index=False, if_exists='append')


def separar_cargo(row):
    '''
    De acuerdo a un código de categoría (que determina cargo y dedicación),
    la función se queda únicamente con el cargo y lo retorna
    '''
    if(row['Cód. Categoría'] == 213 or row['Cód. Categoría'] == 214 or row['Cód. Categoría'] == 215 or row['Cód. Categoría'] == 1215):
        return 'PROFESOR TITULAR'
    elif(row['Cód. Categoría'] == 216 or row['Cód. Categoría'] == 217 or row['Cód. Categoría'] == 218 or row['Cód. Categoría'] == 1218):
        return 'PROFESOR ASOCIADO'
    elif(row['Cód. Categoría'] == 219 or row['Cód. Categoría'] == 220 or row['Cód. Categoría'] == 221 or row['Cód. Categoría'] == 1221):
        return 'PROFESOR ADJUNTO'
    elif(row['Cód. Categoría'] == 222 or row['Cód. Categoría'] == 223 or row['Cód. Categoría'] == 224 or row['Cód. Categoría'] == 1224):
        return 'JEFE DE TRABAJOS PRÁCTICOS'
    elif(row['Cód. Categoría'] == 225 or row['Cód. Categoría'] == 226 or row['Cód. Categoría'] == 227 or row['Cód. Categoría'] == 1227):
        return 'AYUDANTE DE PRIMERA'
    elif(row['Cód. Categoría'] == 228 or row['Cód. Categoría'] == 1228):
        return 'AYUDANTE DE SEGUNDA'
    else:
        return None

def separar_dedicacion(row):
    '''
    De acuerdo a un código de categoría (que determina cargo y dedicación),
    la función se queda únicamente con la dedicación y la retorna
    '''
    if(row['Cód. Categoría'] == 213 or row['Cód. Categoría'] == 216 or row['Cód. Categoría'] == 219 or row['Cód. Categoría'] == 222 or row['Cód. Categoría'] == 225):
        return 'EXCLUSIVA'
    if(row['Cód. Categoría'] == 214 or row['Cód. Categoría'] == 217 or row['Cód. Categoría'] == 220 or row['Cód. Categoría'] == 223 or row['Cód. Categoría'] == 226):
        return 'SEMIEXCLUSIVA'
    if(row['Cód. Categoría'] == 215 or row['Cód. Categoría'] == 218 or row['Cód. Categoría'] == 221 or row['Cód. Categoría'] == 224 or row['Cód. Categoría'] == 227 or row['Cód. Categoría'] == 228):
        return 'SIMPLE'
    if(row['Cód. Categoría'] == 1218 or row['Cód. Categoría'] == 1221 or row['Cód. Categoría'] == 1224 or row['Cód. Categoría'] == 1227 or row['Cód. Categoría'] == 1228):
        return 'AD HONOREM'   
    else:
        return None

def cargar_tabla_cargos(data, engine_con):
    
    # Unifica la forma en que se mencionan las diferentes divisiones
    data["División"].replace({"División Estadística": "Estadística", 
                              "Division Química": "Química",
                              "Division Computación":"Computación"}, inplace=True)

    # En los datos faltantes los determino como Gestión (Prof. Eméritos, autoridades y personal de gabinete)
    data["División"] = data["División"].fillna("Gestión")

    # Separo los códigos de cargo en cargo y dedicación
    data['cargo_docencia'] = data.apply(lambda row: separar_cargo(row), axis=1)
    data['dedicacion_docencia'] = data.apply(lambda row: separar_dedicacion(row), axis=1)

    # Cambio el nombre de las columnas para guardar en la tabla con los nombres del df
    data.columns = ['legajo', 'apellido', 'nombres', 'cuil', 'codigo_cargo', 'fecha_alta', 'fecha_baja', 'caracter', 'codigo_categoria', 'categoria', 'tipo_categoria4', 'tipo_norma', 'numero_norma', 'emisor', 'division', 'cargo_docencia', 'dedicacion_docencia']

    # Elimino las columnas repetidas en otra tabla
    data = data.drop(['categoria', 'tipo_categoria4'], axis=1)

    # Guardar el dataframe en la DB
    try: # Pruebo en caso que no exista
        # Guardar el dataframe en la DB
        data.to_sql('cargos', engine_con, index=False, if_exists='replace')
    
        with engine_con.connect() as con:
            con.execute('ALTER TABLE cargos ADD PRIMARY KEY(codigo_cargo);')
            con.execute('ALTER TABLE cargos ADD COLUMN docencia BOOLEAN NOT NULL DEFAULT TRUE;')
            con.execute("UPDATE cargos SET docencia = FALSE WHERE division = 'Gestión';");
            con.execute('ALTER TABLE cargos ALTER COLUMN fecha_alta TYPE date USING (fecha_alta::date);')
            con.execute('ALTER TABLE cargos ALTER COLUMN fecha_baja TYPE date USING (fecha_baja::date);;')
            # Agrego el cuil que tengo en el cargo en la tabla docentes que es donde corresponde
            con.execute('ALTER TABLE docentes ADD COLUMN cuil text;')
            con.execute('UPDATE docentes d SET cuil = (SELECT cuil FROM cargos c WHERE d.legajo=c.legajo LIMIT 1);')

    except: # Si existe borro los registros y vuelvo a cargar los nuevos
        engine_con.execute("DELETE FROM cargos;")
        data.to_sql('cargos', engine_con, index=False, if_exists='append')
        with engine_con.connect() as con:
            con.execute('UPDATE docentes d SET cuil = (SELECT cuil FROM cargos c WHERE d.legajo=c.legajo LIMIT 1);')
            con.execute("UPDATE cargos SET docencia = FALSE WHERE division = 'Gestión';");


def cargar_tabla_equipos_docentes(data, engine_con):
    '''
    Esta función recibe los equipos docentes por comisión que remiten las jefaturas de 
    división y las cargan en la tabla equipos_por_actividad de PostgreSQL
    '''

    # Se borran las columnas repetidas
    data = data.drop(['NOMBRE Y APELLIDO'], axis=1)

    # Cambio el nombre de las columnas para guardar en la tabla con los nombres del df
    data.columns = ['legajo_docente', 'codigo_actividad', 'comision', 'anio_cursada', 'cuatrimestre_cursada']

    # Guardar el dataframe en la DB
    try: # Pruebo en caso que no exista
        # Guardar el dataframe en la DB
        data.to_sql('equipos_por_actividad', engine_con, index=False, if_exists='replace')
        with engine_con.connect() as con:
            con.execute('ALTER TABLE equipos_por_actividad ADD PRIMARY KEY(legajo_docente, codigo_actividad, comision, anio_cursada, cuatrimestre_cursada);')

    except: # Si existe borro los registros y vuelvo a cargar los nuevos
        engine_con.execute("DELETE FROM equipos_por_actividad;")
        data.to_sql('equipos_por_actividad', engine_con, index=False, if_exists='append')

        
def cargar_tabla_actividades_academicas(data, engine_con):
    """
    Esta funcion recibe las actividades académicas por área, división y subarea (si corresponde)
    y las carga en la tabla actividades_academicas de la DB exportaciones_basicas
    """
    
    # Se eliminan las columnas repetidas en otras tablas
    data = data.drop(["Docente Responsable - Apellido y Nombres", "Carrera/s - Código"], axis=1)

    # Cambio el nombre de las columnas para guardar en la tabla con los nombres del df
    data.columns = ['codigo', 'denominacion', 'legajo_docente_responsable', 'area', 'subarea', 'division', 'carreras_descripcion']

    # Guardar el dataframe en la DB
    try: # Pruebo en caso que no exista
        # Guardar el dataframe en la DB
        data.to_sql('actividades_academicas', engine_con, index=False, if_exists='replace')   
        with engine_con.connect() as con:
            con.execute('ALTER TABLE actividades_academicas ADD PRIMARY KEY(codigo);')

    except: # Si existe borro los registros y vuelvo a cargar los nuevos
        engine_con.execute("DELETE FROM actividades_academicas;")
        data.to_sql('actividades_academicas', engine_con, index=False, if_exists='append')


def cargar_tabla_actividades_academicas_por_carrera(data, engine_con):
    """
    Esta funcion recibe las actividades académicas por área, división y subarea (si corresponde)
    y las carga en la tabla asignaturas_por_carrera de la DB exportaciones_basicas
    """
    
    # Se eliminan las columnas repetidas en otras tablas
    data = data.drop(["Denominación", "Carrera/s", "Docente Responsable - Apellido y Nombres", "Docente Responsable - Legajo", "Área", "Subárea", "División"], axis=1)

    # Cambio el nombre de las columnas para guardar en la tabla con los nombres del df
    data.columns = ['codigo_asignatura', 'codigo_carrera']

    # Crea la tabla si es que no existe
    engine_con.execute("CREATE TABLE IF NOT EXISTS asignaturas_por_carrera(codigo_actividad numeric, codigo_carrera numeric, CONSTRAINT asignaturas_carrera_pkey PRIMARY KEY (codigo_actividad, codigo_carrera));");
    engine_con.execute("DELETE FROM asignaturas_por_carrera;");
    # Inserto las asignaturas por carrera
          
    for index, row in data.iterrows():
        carreras = str(row['codigo_carrera']).split(",")
        for cod_carrera in carreras:
            engine_con.execute('INSERT INTO asignaturas_por_carrera(codigo_actividad, codigo_carrera) VALUES('+ str(row['codigo_asignatura'])+', '+str(cod_carrera)+');')
    

def cargar_tabla_oferta_academica(data, engine_con):
    """
    Esta funcion recibe las comisiones que se dictan en un año determinado y las carga
    en la tabla. También posee la información de cupo e inscriptos
    """
    
    # Borro las columnas repetidas en otras tablas
    data = data.drop(["Descripción"], axis=1)

    # Cambio el nombre de las columnas para guardar en la tabla con los nombres del df
    data.columns = ['codigo', 'comision', 'horario', 'sede', 'cupo', 'cantidad_inscriptos', 'cuatrimestre_cursada', 'anio_cursada']

    try: # Pruebo en caso que no exista
        # Guardar el dataframe en la DB
        data.to_sql('oferta_academica', engine_con, index=False, if_exists='replace')   
        with engine_con.connect() as con:
            con.execute('ALTER TABLE oferta_academica ADD PRIMARY KEY(codigo, comision, cuatrimestre_cursada, anio_cursada);')
    
    except: # Si existe borro los registros y vuelvo a cargar los nuevos
        engine_con.execute("DELETE FROM oferta_academica;")
        data.to_sql('oferta_academica', engine_con, index=False, if_exists='append')



def cargar_tabla_licencias(data, engine_con):
    '''
    Se cargan las licencias (tanto remuneradas como no remuneradas) en función de un archivo
    unificado sacado de Interfaz Mapuche-UNLu
    '''
    import numpy as np
    
    data = data.drop(['Legajo', 'Apellido', 'Nombre', 'Tipo Documento', 'Número', 'Categoría', 'División'], axis=1)
    
    # Cambio el nombre de las columnas para guardar en la tabla con los nombres del df
    data.columns = ['codigo_cargo', 'fecha_alta', 'fecha_baja', 'tipo_licencia', 'sede'] 

    # Debo filtrar los registros con licencias (saco los que están vacíos en tipo_licencia)
    data['tipo_licencia'].replace('', np.nan, inplace=True)
    data.dropna(subset=['tipo_licencia'], inplace=True)

    # Guardar el dataframe en la DB
    try: # Pruebo en caso que no exista
        data.to_sql('licencias', engine_con, index=False, if_exists='fail')
        with engine_con.connect() as con:
            con.execute('ALTER TABLE licencias ALTER COLUMN fecha_alta TYPE date USING (fecha_alta::date);')
            con.execute('ALTER TABLE licencias ALTER COLUMN fecha_baja TYPE date USING (fecha_baja::date);')
            con.execute('ALTER TABLE licencias ADD PRIMARY KEY(codigo_cargo, fecha_alta);')

    except: # Si existe borro los registros y vuelvo a cargar los nuevos
        engine_con.execute("DELETE FROM licencias;")
        data.to_sql('licencias', engine_con, index=False, if_exists='append')
    


def cargar_tabla_carreras(data, engine_con):
    """
    Esta funcion recibe las carreras en csv
    y las carga en la tabla carreras de la DB exportaciones_basicas
    """
    
    # Guardar el dataframe en la DB
    try: # Pruebo en caso que no exista
        data.to_sql('carreras', engine_con, index=False, if_exists='fail')
        with engine_con.connect() as con:
            con.execute('ALTER TABLE carreras ADD PRIMARY KEY(codigo);')

    except: # Si existe borro los registros y vuelvo a cargar los nuevos
        engine_con.execute("DELETE FROM carreras;")
        data.to_sql('carreras', engine_con, index=False, if_exists='append')
        

def cargar_maximo_titulo_en_docentes(data, engine_con):
    ''' Carga el máximo titulo de cada docente en la tabla docentes en la DB PostgreSQL
    en función del archivo descargado de Interfaz UNLu-Mapuche
    '''
    import math
    # Cambio el nombre de las columnas para guardar en la tabla con los nombres del df
    data.columns = ['legajo', 'apellido', 'nombres', 'maximo_titulo', 'entidad_otorgante_titulo', 'fecha_emision', 'codigo_acreditacion']

    # Elimino la columna edad
    data = data.drop(['apellido', 'nombres', 'codigo_acreditacion'], axis=1)
    
    # Quito los espacios entre el texto en las columnas textuales (object)
    data_coltexto = data.select_dtypes(['object'])
    data[data_coltexto.columns] = data_coltexto.apply(lambda x: x.str.strip())

    # Guardar el dataframe en la DB  
    for index, row in data.iterrows():
        legajo = row['legajo']
        maximo_titulo = row['maximo_titulo']
        entidad_otorgante_titulo = row['entidad_otorgante_titulo']
        fecha_emision = str(row['fecha_emision'])
        if  fecha_emision != 'nan':
            engine_con.execute(f'UPDATE docentes SET maximo_titulo = \'{maximo_titulo}\', entidad_otorgante_titulo = \'{entidad_otorgante_titulo}\', fecha_emision_titulo = \'{fecha_emision}\' WHERE legajo={legajo};')
        else:
            engine_con.execute(f'UPDATE docentes SET maximo_titulo = \'{maximo_titulo}\', entidad_otorgante_titulo = \'{entidad_otorgante_titulo}\' WHERE legajo={legajo};')
        