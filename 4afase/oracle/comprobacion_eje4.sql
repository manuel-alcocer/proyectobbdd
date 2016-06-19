
grant scheduler_admin to fasedos;

Grant succeeded.

SQL> grant create job to fasedos;

Grant succeeded.

SQL> grant manage scheduler to fasedos;

Grant succeeded.



/* LA PLANA III */

/* PRIMERO INSERTO UN VIENTO QUE SUPERA LA VELOCIDAD MAXIMA PARA EL DIA DE MAÑANA */
INSERT INTO PREDICCIONES_VIENTO VALUES (TO_DATE('20 6 2016 0:0', 'DD MM YYYY HH24:MI'), 'LA PLANA III', 300, '201°1''S');

/* CREO EL MONITOR PARA ESA CENTRAL (EN MI CÓDIGO LO PUSE CON UN INTERVALO DE UN MINUTO PARA LA PRUEBA)*/
exec PC4.CrearMonitor('LA PLANA III');


PL/SQL procedure successfully completed.

/* ESPERO UN PAR DE MINUTOS Y ESTA ES LA SALIDA */
select * from desconexiones
where cod_aerogenerador in (
    select codigo from aerogeneradores
    where nombre_central = 'LA PLANA III');

select * from desconexiones
where cod_aerogenerador in (
    select codigo from aerogeneradores
  4      where nombre_central = 'LA PLANA III');
T4510000                 20-JUN-16          21-JUN-16
T4510001                 20-JUN-16          21-JUN-16
T4510002                 20-JUN-16          21-JUN-16
T4510003                 20-JUN-16          21-JUN-16
T4510004                 20-JUN-16          21-JUN-16
T4510005                 20-JUN-16          21-JUN-16
T4510006                 20-JUN-16          21-JUN-16
T4510007                 20-JUN-16          21-JUN-16
T4510008                 20-JUN-16          21-JUN-16
T4510009                 20-JUN-16          21-JUN-16
T4510010                 20-JUN-16          21-JUN-16
T4510011                 20-JUN-16          21-JUN-16
T4510012                 20-JUN-16          21-JUN-16
T4510013                 20-JUN-16          21-JUN-16
T4510014                 20-JUN-16          21-JUN-16
T4510015                 20-JUN-16          21-JUN-16
T4510016                 20-JUN-16          21-JUN-16
T4510017                 20-JUN-16          21-JUN-16
T4510018                 20-JUN-16          21-JUN-16
T4510019                 20-JUN-16          21-JUN-16
T4510020                 20-JUN-16          21-JUN-16
T4510021                 20-JUN-16          21-JUN-16
T4510022                 20-JUN-16          21-JUN-16
T4510023                 20-JUN-16          21-JUN-16
T4510024                 20-JUN-16          21-JUN-16
T4510025                 20-JUN-16          21-JUN-16
T4510026                 20-JUN-16          21-JUN-16
T4510027                 20-JUN-16          21-JUN-16
T4510028                 20-JUN-16          21-JUN-16
T4510029                 20-JUN-16          21-JUN-16
T4510030                 20-JUN-16          21-JUN-16
T4510031                 20-JUN-16          21-JUN-16
T4510032                 20-JUN-16          21-JUN-16
T4510033                 20-JUN-16          21-JUN-16
T4510034                 20-JUN-16          21-JUN-16

35 rows selected.

SQL>
