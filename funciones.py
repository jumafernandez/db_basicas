# -*- coding: utf-8 -*-
"""
Created on Sun May 10 11:33:06 2020

@author: unlu
"""

def file2df(PATH_ARCHIVO, elimina_primera_fila):
    
    import pandas as pd
    import os.path
    
    # Verifico si debo ignorar la primera fila
    if elimina_primera_fila:
        filas_ignoradas = [0]
    else:
        filas_ignoradas = []

    # Verifico la extensión del archivo para ver como lo cargo        
    nombre_archivo, extension = os.path.splitext(PATH_ARCHIVO)

    if extension == '.xlsx':
        data = pd.read_excel(PATH_ARCHIVO, skiprows=filas_ignoradas)
    else:
        data = pd.read_csv(PATH_ARCHIVO, skiprows=filas_ignoradas, sep=';')

    return data

def insert_fecha_update(engine_con):
    '''
    Esta función actualiza la tabla fecha_actualizaciones de la BD
    '''
    import pandas as pd
    from datetime import datetime

    fecha_hora_actual = []
    fecha_hora_actual.append(str(datetime.now()))
    data = pd.DataFrame({"fecha_hora": fecha_hora_actual})

    # Guardar el dataframe en la DB
    try: # Pruebo en caso que no exista
        data.to_sql('fecha_actualizaciones', engine_con, index=False, if_exists='fail')
        with engine_con.connect() as con:
            con.execute('ALTER TABLE fecha_actualizaciones ADD PRIMARY KEY(fecha_hora);')

    except: # Si existe borro los registros y vuelvo a cargar los nuevos
        data.to_sql('fecha_actualizaciones', engine_con, index=False, if_exists='append')
