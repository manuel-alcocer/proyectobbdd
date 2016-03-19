#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from random import randint
import sys
reload(sys)
sys.setdefaultencoding('utf8')

def ComienzosCIF():
    # Comienzos del CIF
    comienzoscif = [[75, 81, 83], [65, 66, 69, 72], []]
    for codascii in xrange(65, 91):
        if codascii not in comienzoscif[0] and codascii not in comienzoscif[1]:
            comienzoscif[2] += [ codascii ]
    return comienzoscif

def CuerpoCIF():
    cuerpo = str(randint(0,9))
    for posicion in xrange(0,6):
        cuerpo += str(randint(0,9))
    return cuerpo

def GenerarCIF():
    inicioscif = ComienzosCIF()
    numaleatorio = randint(0, 2)
    inicio = chr(inicioscif[numaleatorio][randint(0, len(inicioscif[numaleatorio])-1)])
    # si el inicio es el tercer caso => final es número o letra
    if numaleatorio == 2: numaleatorio = randint(0,1)
    if numaleatorio == 0:
        # inicio CIF KQS => final es una letra
        ultimocaracter = chr(randint(65, 90))
    elif numaleatorio == 1:
        # inicio CIF ABEH => final es un número
        ultimocaracter = str(randint(0, 9))
    CIF = '%s%s%s' %(inicio, CuerpoCIF(), ultimocaracter)
    return CIF

def Generarempresas():
    with open ('empresas.txt') as f:
        contenido = f.readlines()
    empresas = {}
    cifs = []
    for empresa in contenido:
        # solo tomaré empresas de las que están todos sus datos
        if any(len(contenido) == 0 for contenido in empresa.split(':')):
            continue
        cif = GenerarCIF()
        while cif in cifs:
            cif = GenerarCIF()
        cifs += [ cif ]
        if empresa.split(':')[2].upper() not in empresas.keys():
            empresas[empresa.split(':')[2].upper()] = {'cif' : cif} 
    return empresas

def DatosCentrales(diccionario):
    with open ('empresas.txt') as f:
        contenido = f.readlines()
    for empresa in contenido:
        # si a algua empresa le falta algún dato, la salta
        if any(len(contenido) == 0 for contenido in empresa.split(':')):
            continue
        datos = empresa[:-1].encode('utf-8').split(':')
        diccionario[datos[2].upper()][datos[1].upper()] = {}
        diccionario[datos[2].upper()][datos[1].upper()]['localizacion'] = datos[0].upper()
        diccionario[datos[2].upper()][datos[1].upper()]['municipio'] = datos[3].upper()
        diccionario[datos[2].upper()][datos[1].upper()]['provincia'] = {'nombre': datos[4].upper(), 'codigo' : Provincias(datos[4].upper())}
        diccionario[datos[2].upper()][datos[1].upper()]['potencia'] = datos[5].upper()
        diccionario[datos[2].upper()][datos[1].upper()]['cantidad'] = datos[6].upper()
        diccionario[datos[2].upper()][datos[1].upper()]['potencia_ud'] = datos[7].upper()
        diccionario[datos[2].upper()][datos[1].upper()]['marca'] = datos[8].upper()
        diccionario[datos[2].upper()][datos[1].upper()]['modelo'] = datos[9].upper()
    return

def Provincias(nombre):
    with open('./provincias.txt') as f:
        contenido = f.readlines()
    provincias = {}
    for provincia in contenido:
        provincias[provincia[:-1].split(':')[1].upper()] = provincia[:-1].split(':')[0]
    return provincias[nombre]

def main():
    diccionario_de_empresas = Generarempresas()
    DatosCentrales(diccionario_de_empresas)
    print diccionario_de_empresas

if __name__ == '__main__':
    main()
