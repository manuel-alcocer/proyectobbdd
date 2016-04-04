#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from random import randint, uniform, normalvariate, weibullvariate
from datetime import datetime,timedelta, time

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
    telefono = str((randint(8,9)))
    for numero in xrange(0,8):
        telefono += str(randint(0,9))
    return telefono

def Generarempresas(limite):
    with open ('empresas.txt') as f:
        contenido = f.readlines()
    empresas = {}
    cifs = []
#    for empresa in contenido:
    indice = 0
    numempresas = 0
    while indice < len(contenido) and numempresas < limite:
        empresa = contenido[indice]
        indice += 1
        # solo tomaré empresas de las que estén todos sus datos
        if any(len(contenido) == 0 for contenido in empresa.split(':')):
            continue
        numempresas += 1
        cif = GenerarCIF()
        # Evita cifs repetidos
        while cif in cifs:
            cif = GenerarCIF()
        cifs += [ cif ]
        if empresa.split(':')[2].upper() not in empresas.keys():
            empresas[empresa.split(':')[2].upper()] = {'cif' : cif} 
    return empresas

def DatosCentrales(diccionario, limite):
    with open ('empresas.txt') as f:
        contenido = f.readlines()
#    for empresa in contenido:
    indice = 0
    numempresas = 0
    while indice < len(contenido) and numempresas < limite:
        empresa = contenido[indice]
        indice += 1
        # si a algua empresa le falta algún dato, la salta
        if any(len(contenido) == 0 for contenido in empresa.split(':')):
            continue
        datos = empresa[:-1].split(':')
        nombrecentral = unicode(datos[1]).upper()
        diccionario[datos[2].upper()]['centrales'] = {}
        diccionario[datos[2].upper()]['centrales'][nombrecentral] = {}
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['nombre'] = nombrecentral
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['localizacion'] = int(datos[0])
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['municipio'] = unicode(datos[3],'utf8').upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['provincia'] = { 'nombre' : unicode(datos[4],'utf8').upper(), 'codigo' : Provincias(unicode(datos[4].upper(),'utf8'))}
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['potencia'] = datos[5].upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['cantidad'] = SumarAeros(datos[6])
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['potencia_ud'] = float(datos[7].upper())
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['marca'] = datos[8].upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['modelo'] = datos[9].upper()
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['listadoaeros'] = []
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['telefono'] = GenerarTelefono()
        # Velocidad media en m/s
        diccionario[datos[2].upper()]['centrales'][nombrecentral]['velmedia'] = round(uniform(6,9),2)
        numempresas += 1
    return

def SumarAeros(cadena):
    lista1 = []
    lista2 = []
    if 'y' in cadena.lower():
        lista1 = [ dato.strip() for dato in cadena.lower().split('y') ]
        for numero in lista1:
            if ',' in numero:
                lista2 += [ int(num1.strip()) for num1 in numero.split(',') ]
            elif ';' in numero:
                lista2 += [ int(num1.strip()) for num1 in numero.split(';') ]
            else:
                lista2 += [ int(numero) ]
    elif ',' in cadena:
        lista2 += [ int(num1.strip()) for num1 in cadena.split(',') ]
    elif ';' in cadena:
        lista2 += [ int(num1.strip()) for num1 in cadena.split(';') ]
    else:
        lista2 = [ int(cadena) ]
    return sum(lista2)

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

def ConstruirDiccionarioAeros():
    with open('./aeros.txt') as f:
        contenido = f.readlines()
    contenido = [ linea[:-1] for linea in contenido ]
    diccionario_aeros = {}
    for linea in contenido:
        datos = [ llinea.strip() for llinea in linea.split(':') ]
        marca = datos[0]
        modelo = datos[1]
        longitud = round(float(datos[2])/2-1,2)
        produccion = int(datos[3])
        velmaxima = int(datos[4])
        if marca not in diccionario_aeros.keys():
            diccionario_aeros[marca] = {}
        diccionario_aeros[marca][modelo] = {'longitud' : longitud, 'produccion' : produccion, 'velmax' : velmaxima }
    return diccionario_aeros

def GenerarViento(viento):
    maximo_fi = 360
    minimo_fi = 0.01
    delta_angulo = round(normalvariate(2,0.7)*10,2)
    if viento['estado']:
        if viento['direccion'] + delta_angulo >= maximo_fi:
            viento['estado'] = False
            viento['direccion'] -= delta_angulo
        else:
            viento['direccion'] += delta_angulo
    else:
        if viento['direccion'] - delta_angulo <= minimo_fi:
            viento['estado'] = True
            viento['direccion'] += delta_angulo
        else:
            viento['direccion'] -= delta_angulo
    # Para trampear la velocidad del viento y que meta algunos valores excesivos
    # para llenar la tabla de desconexiones hago que:
    # Haya un 30 % de probabilidades de añadir 15 a la velocidad media de la zona
    loteria = randint(1,10)
    if loteria < 3:
        extra = 15
    else:
        extra = 0
    viento['velocidad'] = round(weibullvariate(viento['velmedia']+extra, 2),2)
    return

###########################################
## Generar lista de modelos en centrales ##
###########################################
def ListaAerogen(diccionario):
    marcas = {}
    for empresa in diccionario.keys():
        for central in diccionario[empresa]['centrales'].keys():
            marca = unicode(diccionario[empresa]['centrales'][central]['marca'],'utf8')
            if marca not in marcas.keys():
                marcas[marca] = {}
            modelo = unicode(diccionario[empresa]['centrales'][central]['modelo'],'utf8')
            if modelo not in marcas[marca].keys():
                marcas[marca][modelo] = {}
    return marcas


def CogerDireccion():
    with open('./calles.txt') as f:
        contenido = f.readlines()
    listacalles = [ calle[:-1] for calle in contenido ]
    numero = str(randint(1,100))
    tipos = ['Calle', 'Carretera', 'Bulevar', 'Avenida', 'Paseo']
    tipo = tipos[randint(0,4)]
    direccion = listacalles[randint(0,len(listacalles)-1)]
    direccion_completa = '%s %s, %s' %(tipo, direccion, numero)
    return direccion_completa

##############################
### GENERACIÓN DE FICHEROS ###
##############################
def InsercionEmpresas(diccionario):
    with open('./ficherosinsercion/insercion-empresas.sql', 'w') as f:
        for empresa in diccionario.keys():
            f.write("INSERT INTO EMPRESAS VALUES('%s','%s');\n" % (diccionario[empresa]['cif'],empresa.replace('\'','\'\'')))
    return

def InsercionProvincias():
    listado = Provincias('insercion')
    with open('./ficherosinsercion/insercion-provincias.sql', 'w') as f:
        for provincia in listado.keys():
            f.write("INSERT INTO PROVINCIAS VALUES('%s','%s');\n" %(listado[provincia],provincia))
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
    with open ('./ficherosinsercion/insercion-municipios.sql', 'w') as f:
        for clave in pueblos.keys():
            f.write("INSERT INTO MUNICIPIOS VALUES('%s', '%s', '%s');\n" % (pueblos[clave]['codigo'], pueblos[clave]['codprov'], clave.upper()))
    return pueblos

def InsercionCentrales(diccionario, pueblos):
    with open ('./ficherosinsercion/insercion-centrales.sql', 'w') as f:
        for empresa in diccionario.keys():
            cif = diccionario[empresa]['cif']
            for central in diccionario[empresa]['centrales'].keys():
                nombre = central
                codigomunicipio = pueblos[diccionario[empresa]['centrales'][central]['municipio']]['codigo']
                # Falta la dirección.. a ver que me invento
                direccion = CogerDireccion()
                telefono = diccionario[empresa]['centrales'][central]['telefono']
                f.write("INSERT INTO CENTRALES VALUES ('%s', '%s', '%s', '%s', '%s');\n" % (nombre.replace('\'','\'\''),codigomunicipio,cif,direccion,telefono))
    return

def InsercionEolicas(diccionario):
    with open ('./ficherosinsercion/insercion-eolicas.sql', 'w') as f:
        for empresa in diccionario.keys():
            for central in diccionario[empresa]['centrales']:
                # La velocidad media en las zonas de aerogeneradores
                # suele estar entre 6 y 9 m/s ( [21 - 33] Km/h )
                velocidadmedia = diccionario[empresa]['centrales'][central]['velmedia'] 
                f.write("INSERT INTO EOLICAS VALUES ('%s', '%s');\n" %(central.replace('\'','\'\''), velocidadmedia))
    return

def InsercionPredicciones(empresas, dias, predsdia, aerogeneradores, modelos):
    # dias <-- Número de días a predecir
    # predsdia <-- Predicciones por dia, siempre < 24
    contador = 1
    with open ('./ficherosinsercion/insercion-predicciones.sql', 'w') as f:
        with open ('./ficherosinsercion/insercion-producciones.sql', 'w') as fproducciones:
            with open ('./ficherosinsercion/insercion-desconexiones.sql', 'w') as fdesconexiones:
                for empresa in empresas.keys():
                    # estado previo: True = dia anterior conectado, False = desconectado
                    for central in empresas[empresa]['centrales'].keys():
                        estado_previo = True
                        hora10 = False
                        cambiodia = False
                        viento = {}
                        viento['velmedia'] = empresas[empresa]['centrales'][central]['velmedia']
                        viento['direccion'] = round(uniform(0.01,360),2)
                        viento['estado'] = True
                        viento['velocidad'] = viento['velmedia']
                        fecha = datetime(2015,1,1,0,0,0)
                        fechafinal = fecha + timedelta(days=dias)
                        while fecha < fechafinal:
                            GenerarViento(viento)
                            formatfecha = "TO_DATE('%s %s %s %s:%s', 'DD MM YYYY HH24:MI')" % (fecha.day,fecha.month,fecha.year,fecha.hour,fecha.minute)
                            f.write("INSERT INTO PREDICCIONES_VIENTO VALUES (%s, '%s', %.2f, '%s');\n" % (formatfecha,central.replace('\'','\'\''),Velocidad(viento),Direccion(viento)))
                            estado_previo = Insercion_Producciones(empresas[empresa]['centrales'][central],modelos,fecha, viento['velocidad'], estado_previo, fproducciones, fdesconexiones)
                            fecha = fecha + timedelta(hours=1)
    return

def FuncionProduccion(potencia,velocidad):
    #print velocidad
    #print potencia
    #raw_input('jjjjj')
    if 4 <= velocidad <= 13:
        potmax = potencia
        velocidad -= 4
        potencia = velocidad * potmax / (13-4)
        potencia = potencia * 100 / potmax
        return potencia
    elif velocidad > 13:
        return potencia
    else:
        return 0

def Insercion_Producciones(central,modelos,fecha,viento,estado, fprods, fdesc):
    # Teniendo en cuenta la gráfica de los aerogeneradores gamesa,
    # aproximo a una recta el tramo entre [ 4 m/s - 13 m/s ]
    # de pendiente: m = potencia_máx / (13-4);
    # para tramos entre ( 13 - 25 ] = potencia_máx
    # para tramos [ 0 - 4 ) = 0 W
    horamin = time(9,0)
    horamax = time(11,30)
    marca = central['marca']
    modelo = central['modelo']
    potencia = central['potencia_ud']
    velmaxima = modelos[marca][modelo]['velmax']
#    print central['listadoaeros']
#    raw_input('ggggggg')
    if velmaxima > viento and estado:
        for aerogenrador in central['listadoaeros']:
#            print aerogenrador
#            print velmaxima
#            print viento
#            print fecha
            # Insertar valor produccion
            potgen = FuncionProduccion(potencia,viento)
            formatfecha = "TO_DATE('%s %s %s %s:%s', 'DD MM YYYY HH24:MI')" % (fecha.day,fecha.month,fecha.year,fecha.hour,fecha.minute)
            fprods.write("INSERT INTO PREDICCIONES_VIENTO VALUES (%s, '%s', %.1f);\n" % (formatfecha,aerogenrador,potgen))
        return True
    elif not estado and (horamin <= fecha.time() < horamax) and velmaxima > viento:
        for aerogenrador in central['listadoaeros']:
            if estado == False:
                formatfecha = "TO_DATE(%s %s %s %s:%s', 'DD MM YYYY HH24:MI');\n" % (fecha.day,fecha.month,fecha.year,fecha.hour,fecha.minute)
                fprods.write("-- CONEXION\n")
                fdesc.write("%s');\n" % (formatfecha))
                # insertar en desconexiones fechahorafin
#            print aerogenrador
#            print velmaxima
#            print viento
#            print fecha
            # insertar valor producción
            potgen = FuncionProduccion(potencia,viento)
            formatfecha = "TO_DATE('%s %s %s %s:%s', 'DD MM YYYY HH24:MI')" % (fecha.day,fecha.month,fecha.year,fecha.hour,fecha.minute)
            fprods.write("INSERT INTO PREDICCIONES_VIENTO VALUES (%s, '%s', %.1f);\n" % (formatfecha,aerogenrador,potgen))
        return True
    else:
        for aerogenrador in central['listadoaeros']:
            if estado == True:
                # insertar en desconexiones fechahorainicio
                formatfecha = "TO_DATE('%s %s %s %s:%s', 'DD MM YYYY HH24:MI')" % (fecha.day,fecha.month,fecha.year,fecha.hour,fecha.minute)
                fprods.write("-- DESCONEXION\n")
                fdesc.write("INSERT INTO PREDICCIONES_VIENTO VALUES ('%s', %s, " % (aerogenrador,formatfecha))
 #           print 'desconex'
 #           print velmaxima
 #           print viento
 #           print estado
 #           print fecha
        return False

def Insercion_Desconexiones(central,fecha,viento, aerogeneradores, modelos, fichero):
    # Teniendo en cuenta la gráfica de los aerogeneradores gamesa,
    # aproximo a una recta el tramo entre [ 4 m/s - 13 m/s ]
    # de pendiente: m = potencia_máx / (13-4);
    # para tramos entre ( 13 - 25 ] = potencia_máx
    # para tramos [ 0 - 4 ) = 0 W
    return

def PotenciaGeneradaAero(potenciamax,velocidad):
    if 0 <= velocidad < 4:
        PotenciaG = 0
    elif velocidad > 13:
        PotenciaG = potenciamax
    else:
        PotenciaG = (velocidad - 4) * 600 / (13 - 4)
    return PotenciaG


def Velocidad(viento):
    # Cuando se inserta en predicciones la velocidad hay que convertirla a Km/h
    return viento['velocidad']*3600/1000

def Direccion(viento):
    direccion = str(viento['direccion'])
    minutos = str(int(round(float(direccion.split('.')[1]) * 60/100,0)))
    grados = int(direccion.split('.')[0])
    if 45 <= grados <= 134:
        ptocardinal = 'E'
    elif 135 <= grados <= 224:
        ptocardinal = 'S'
    elif 225 <= grados <= 314:
        ptocardinal = 'W'
    else:
        ptocardinal = 'N'
    return "%d°%s''%s" %(grados,minutos,ptocardinal)

def InsercionModelos(diccionario):
    aerodict = ConstruirDiccionarioAeros()
    # print aerodict
    tablamodelos = {}
    with open ('./ficherosinsercion/insercion-modelos-aerogens.sql', 'w') as f:
        for marca in aerodict.keys():
            for modelo in aerodict[marca].keys():
                f.write("INSERT INTO MODELOS_AEROGENS VALUES ('%s', '%s', '%.2f', '%d', '%d');\n" %(modelo,marca,aerodict[marca][modelo]['longitud'],aerodict[marca][modelo]['produccion'],aerodict[marca][modelo]['velmax']))
    return aerodict

def InsercionAerogeneradores(empresas,modelos):
    zonasmarinas = ([745,272,144,811,883,890,881,1058,1062,887,888,882,461,740,
        264,987,999,985,266,986,120,628,544,719,949,951,530,661,259,230,924,114,527,191,
        202,201,200])
    aerocentrales = {}
    with open ('./ficherosinsercion/insercion-aerogeneradores.sql', 'w') as f:
        for empresa in empresas.keys():
            for central in empresas[empresa]['centrales'].keys():
                if empresas[empresa]['centrales'][central]['localizacion'] in zonasmarinas:
                    inicio = 'M'
                else:
                    inicio = 'T'
                loclong = len(str(empresas[empresa]['centrales'][central]['localizacion']))
                nombrecentral = central
                nombrecentral = nombrecentral.replace('\'','\'\'')
                marca = modelos[empresas[empresa]['centrales'][central]['marca']]
                modelo = empresas[empresa]['centrales'][central]['modelo']
                aerocentrales[nombrecentral] = {'listado' : [], 'modelo' : modelo}
                for numaero in xrange(0,empresas[empresa]['centrales'][central]['cantidad']):
                    codigo = '%s%s%s' %(inicio,empresas[empresa]['centrales'][central]['localizacion'],str(numaero).zfill(7-loclong))
                    f.write("INSERT INTO AEROGENERADORES VALUES ('%s', '%s', '%s');\n" %(codigo,nombrecentral,modelo))
                    #aerocentrales[codigo] = {'central' : nombrecentral, 'modelo' : modelo}
                    aerocentrales[nombrecentral]['listado'].append(codigo)
                    empresas[empresa]['centrales'][central]['listadoaeros'] += [codigo]
    return aerocentrales

def main():
    # limite: 20
    limite = 10
    diccionario_de_empresas = Generarempresas(limite)
    DatosCentrales(diccionario_de_empresas, limite)
    # Genera fichero: tabla - Empresas
    InsercionEmpresas(diccionario_de_empresas)
    # Genera fichero: tabla - Provincias
    InsercionProvincias()
    # Genera fichero: tabla - Municipios
    lista_de_pueblos = InsercionPueblos(diccionario_de_empresas)
    # Genera fichero: tabla - Centrales
    InsercionCentrales(diccionario_de_empresas,lista_de_pueblos)
    # Genera fichero: tabla - Eólicas
    InsercionEolicas(diccionario_de_empresas)
    # Genera fichero: tabla - Modelos_aerogens
    diccionario_modelos = InsercionModelos(diccionario_de_empresas)
    # Genera fichero: tabla - aerogeneradores
    diccionario_aerogeneradores = InsercionAerogeneradores(diccionario_de_empresas, diccionario_modelos)
    # Genera ficheros: tablas - Predicciones - producciones - desconexiones
    InsercionPredicciones(diccionario_de_empresas,365,24, diccionario_aerogeneradores, diccionario_modelos)

if __name__ == '__main__':
    main()
