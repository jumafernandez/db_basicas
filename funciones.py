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
        data = pd.read_csv(PATH_ARCHIVO, skiprows=filas_ignoradas)

    return data