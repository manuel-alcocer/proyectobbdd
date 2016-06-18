/* ------------------- PRUEBA 1 ------------------------------*/

exec PCentrales2.GenerarInforme(5,'wee','weee');

        /*---------------- SALIDA ------------------*/

        SQL> exec PCentrales2.GenerarInforme(5,'wee','weee');
BEGIN PCentrales2.GenerarInforme(5,'wee','weee'); END;

*
ERROR at line 1:
ORA-20002: Formato de fecha incorrecto
ORA-06512: at "FASEDOS.PCENTRALES1", line 34
ORA-06512: at "FASEDOS.PCENTRALES2", line 362
ORA-06512: at line 1


/* ------------------- PRUEBA 2 ------------------------------*/

exec PCentrales2.GenerarInforme(1,'1-1-2015','T6380001');

        /*---------------- SALIDA ------------------*/

SQL> exec PCentrales2.GenerarInforme(1,'1-1-2015','T6380001');
Aerogenerador T6380001 BORNAY P-10
===================================================================
Día: 01/01/2015

Lista de Desconexiones
======================
0: 01-01-2015 01:00 - 01-01-2015 09:00

Lista de producciones
=====================
00:00: 151.5
09:00: 250
10:00: 250
11:00: 0
12:00: 139
13:00: 29.75
14:00: 178.25
15:00: 85.25
16:00: 50
17:00: 54
18:00: 66.75
19:00: 250
20:00: 171.75
21:00: 32.75
22:00: 126
23:00: 132.75

Energía total: 1967.75

PL/SQL procedure successfully completed.

SQL>

/* ------------------- PRUEBA 3 ------------------------------*/

exec PCentrales2.GenerarInforme(2, '8-1-2015', 'LA RABIA');

        /*---------------- SALIDA ------------------*/
SQL> exec PCentrales2.GenerarInforme(2, '8-1-2015', 'LA RABIA');

Central: LA RABIA
JERÉZ DE LA FRONTERA (CÁDIZ)
Día: 08/01/2015
Energía total día: 204418.71

Detalle de producciones
========================
00:00: 14.76km/h - 207.57
01:00: 14.51km/h - 56.61
02:00: 38.48km/h - 14020.41
03:00: 76.03km/h - 18870
04:00: 37.26km/h - 13322.22
05:00: 54.18km/h - 18870
06:00: 7.27km/h - 0
07:00: 68.83km/h - 18870
08:00: 11.12km/h - 0
09:00: 10.84km/h - 0
10:00: 16.27km/h - 1094.46
11:00: 59.15km/h - 18870
12:00: 51.48km/h - 18870
13:00: 33.34km/h - 11020.08
14:00: 31.28km/h - 9831.27
15:00: 24.37km/h - 5811.96
16:00: 18.83km/h - 2585.19
17:00: 21.78km/h - 4302.36
18:00: 22.64km/h - 4792.98
19:00: 8.5km/h - 0
20:00: 11.99km/h - 0
21:00: 23.47km/h - 5283.6
22:00: 78.19km/h - 18870
23:00: 52.34km/h - 18870

PL/SQL procedure successfully completed.

SQL>

/* ------------------- PRUEBA 4 ------------------------------*/

exec PCentrales2.GenerarInforme(3, '8-1-2015', 'GECAL, S.A');

        /*---------------- SALIDA ------------------*/

SQL> exec PCentrales2.GenerarInforme(3, '8-1-2015', 'GECAL, S.A');

Empresa: GECAL, S.A
Día: 08/01/2015

>>> Central: LA RABIA
=======================================
T4140000 - 2708.25
T4140001 - 2708.25
T4140002 - 18091.11
T4140003 - 18091.11
T4140004 - 18091.11
T4140005 - 18091.11
T4140006 - 18091.11
T4140007 - 18091.11
T4140008 - 18091.11
T4140009 - 18091.11
T4140010 - 18091.11
T4140011 - 18091.11
T4140012 - 18091.11

**** Total generado LA RABIA: 204418.71

>>> Central: TACICA DE PLATA
=======================================
T2300000 - 994.75
T2300001 - 994.75
T2300002 - 7958
T2300003 - 7958
T2300004 - 7958
T2300005 - 7958
T2300006 - 7958
T2300007 - 7958
T2300008 - 7958
T2300009 - 7958
T2300010 - 7958
T2300011 - 7958
T2300012 - 7958

**** Total generado TACICA DE PLATA: 89527.5

PL/SQL procedure successfully completed.

/* ------------------------------------------ */

/* MODIFICACIONES QUE HICE EN LA BBDD PARA TENER VARIAS CENTRALES EN UNA EMPRESA */
update centrales
set cif_empresa = (select c.cif_empresa from centrales
                    where c.nombre = 'LA RABIA')
where nombre = 'TACICA DE PLATA';
/


select e.nombre from empresas e, centrales c
where e.cif = c.cif_empresa
and c.nombre = 'LA RABIA';

select cod_aerogenerador from desconexiones d
where cod_aerogenerador = 'T6380001'
and to_number(to_char(d.fechahora_inicio,'YYYYMMDDHH24MI'), '9') <= '201501010000'
and to_number(to_char(d.fechahora_salida,'YYYYMMDD'), '9') > '20150101'
