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
        diccionario[datos[2].upper()][datos[1].upper()]['provincia'] = { 'nombre' : datos[4].upper(), 'codigo' : Provincias(unicode(datos[4].upper(),'utf8'))}
        diccionario[datos[2].upper()][datos[1].upper()]['potencia'] = datos[5].upper()
        diccionario[datos[2].upper()][datos[1].upper()]['cantidad'] = datos[6].upper()
        diccionario[datos[2].upper()][datos[1].upper()]['potencia_ud'] = datos[7].upper()
        diccionario[datos[2].upper()][datos[1].upper()]['marca'] = datos[8].upper()
        diccionario[datos[2].upper()][datos[1].upper()]['modelo'] = datos[9].upper()
    return

def Provincias(nombre):
    with open ('./provincias.txt') as f:
        contenido = f.readlines()
    lista = {}
    for provincia in contenido:
        lista[unicode(provincia[:-1].split(':')[1],'utf8')] = provincia.split(':')[0]
    if nombre != 'insercion':
        if nombre in [u'LAS PALMAS (GRAN CANARIA)', u'LAS PALMAS (FUERTEVENTURA)', u'GRAN CANARIA']:
            nombre = 'LAS PALMAS'
        if nombre in ['SC TENERIFE (TENERIFE)', u'SC TENERIFE (LA PALMA)', u'SC TENERIFE (LANZAROTE)', u'SC TENERIFE (LA GOMERA)', u'EL HIERRO']:
            nombre = 'SANTA CRUZ DE TENERIFE'
        return lista[nombre.upper()]
    else:
        return lista

### GENERACIÓN DE FICHEROS
##########################

def InsercionEmpresas(diccionario):
    with open('insercion-empresas.sql', 'w') as f:
        for empresa in diccionario.keys():
            f.write("INSERT INTO EMPRESAS VALUES('%s','%s')\n" % (empresa,diccionario[empresa]['cif']))

def InsercionProvincias():
    listado = Provincias('insercion')
    with open('insercion-provincias.sql', 'w') as f:
        for provincia in listado.keys():
            f.write("INSERT INTO PROVINCIAS VALUES('%s','%s')\n" %(listado[provincia],provincia))

def InsercionPueblos(diccionario):
    pueblos = []
    for empresa in diccionario.keys():
        for central in diccionario[empresa].keys():
            pass
    
def main():
    diccionario_de_empresas = Generarempresas()
    DatosCentrales(diccionario_de_empresas)
    # Generar fichero tabla: Empresas
    InsercionEmpresas(diccionario_de_empresas)
    InsercionProvincias()

if __name__ == '__main__':
    main()
    localizaciones_marinas = ([745,272,144,811,883,890,881,1058,1062,887,888,882,461,740,
        264,987,999,985,266,986,120,628,544,719,949,951,530,661,259,230,924,114,527,191,
        202,201,200])
