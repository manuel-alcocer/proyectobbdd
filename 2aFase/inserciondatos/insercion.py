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

def GenerarTelefono():
    telefono = str((randint(1,2)%2)+8)
    for numero in xrange(0,8):
        telefono += str(randint(0,9))
    return telefono

def Generarempresas():
    with open ('empresas.txt') as f:
        contenido = f.readlines()
    empresas = {}
    cifs = []
    for empresa in contenido:
        # solo tomaré empresas de las que estén todos sus datos
        if any(len(contenido) == 0 for contenido in empresa.split(':')):
            continue
        cif = GenerarCIF()
        # Evita cifs repetidos
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
        datos = empresa[:-1].split(':')
        nombrecentral = unicode(datos[1]).upper().replace("'","''")
        diccionario[datos[2].upper()]['centrales'] = {}
        diccionario[datos[2].upper()]['centrales'][nombrecentral] = {}
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['localizacion'] = datos[0].upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['municipio'] = unicode(datos[3],'utf8').upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['provincia'] = { 'nombre' : unicode(datos[4],'utf8').upper(), 'codigo' : Provincias(unicode(datos[4].upper(),'utf8'))}
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['potencia'] = datos[5].upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['cantidad'] = datos[6].upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['potencia_ud'] = datos[7].upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['marca'] = datos[8].upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['modelo'] = datos[9].upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['telefono'] = GenerarTelefono()
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
    return

def InsercionProvincias():
    listado = Provincias('insercion')
    with open('insercion-provincias.sql', 'w') as f:
        for provincia in listado.keys():
            f.write("INSERT INTO PROVINCIAS VALUES('%s','%s')\n" %(listado[provincia],provincia))
    return

def InsercionPueblos(diccionario):
    pueblos = {}
    for empresa in diccionario.keys():
        for central in diccionario[empresa]['centrales'].keys():
            pueblo = diccionario[empresa]['centrales'][central]['municipio']
            if pueblo not in pueblos.keys():
                codprovincia = diccionario[empresa]['centrales'][central]['provincia']['codigo']
                posicion = str(len(pueblos)+1)
                pueblos[pueblo] = { 'codigo' : codprovincia + posicion, 'codprov' : codprovincia, 'nombre' : pueblo.upper() } 
    with open ('insercion-municipios.sql', 'w') as f:
        for clave in pueblos.keys():
            f.write("INSERT INTO MUNICIPIOS VALUES('%s', '%s', '%s')\n" % (pueblos[clave]['codigo'], pueblos[clave]['codprov'], clave.upper()))
    return pueblos

def InsercionCentrales(diccionario, pueblos):
    with open ('insercion-centrales.sql', 'w') as f:
        for empresa in diccionario.keys():
            cif = diccionario[empresa]['cif']
            for central in diccionario[empresa]['centrales'].keys():
                nombre = central
                codigomunicipio = pueblos[diccionario[empresa]['centrales'][central]['municipio']]['codigo']
                # Falta la dirección.. a ver que me invento
                telefono = diccionario[empresa]['centrales'][central]['telefono']
                f.write("INSERT INTO CENTRALES VALUES ('%s', '%s', '%s', '%s')\n" % (nombre,codigomunicipio,cif,telefono))
    return

def main():
    diccionario_de_empresas = Generarempresas()
    DatosCentrales(diccionario_de_empresas)
    # Genera fichero: tabla - Empresas
    InsercionEmpresas(diccionario_de_empresas)
    # Genera fichero: tabla - Provincias
    InsercionProvincias()
    # Genera fichero: tabla - Municipios
    lista_de_pueblos = InsercionPueblos(diccionario_de_empresas)
    # Genera fichero: tabla - Centrales
    InsercionCentrales(diccionario_de_empresas,lista_de_pueblos)

if __name__ == '__main__':
    main()
    localizaciones_marinas = ([745,272,144,811,883,890,881,1058,1062,887,888,882,461,740,
        264,987,999,985,266,986,120,628,544,719,949,951,530,661,259,230,924,114,527,191,
        202,201,200])
