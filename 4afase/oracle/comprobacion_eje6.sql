insert into aerogeneradores values ('T4130025', 'JEREZ', 'S88');

/* salida */
SQL> insert into aerogeneradores values ('T4130025', 'JEREZ', 'S88');

1 row created.

/* Periodo de desconexión inválido */

insert into desconexiones values ('T4130025',to_date('11-10-17 9:40','DD-MM-YY HH24:MI'),to_date('11-10-17 09:49','DD-MM-YY HH24:MI'));

SQL> SQL> insert into desconexiones values ('T4130025',to_date('11-10-17 9:40','DD-MM-YY HH24:MI'),to_date('11-10-17 09:49','DD-MM-YY HH24:MI'));
insert into desconexiones values ('T4130025',to_date('11-10-17 9:40','DD-MM-YY HH24:MI'),to_date('11-10-17 09:49','DD-MM-YY HH24:MI'))
            *
ERROR at line 1:
ORA-20010: El periodo de desconexion no puede ser inferior a 10 minutos
ORA-06512: at "FASEDOS.DESCONEXION10MAX", line 5
ORA-04088: error during execution of trigger 'FASEDOS.DESCONEXION10MAX'


SQL>

/* Periodo de desconexión válido */

insert into desconexiones values ('T4130025',to_date('12-10-18 9:40','DD-MM-YY HH24:MI'),to_date('12-10-18 09:50','DD-MM-YY HH24:MI'));

insert into desconexiones values ('T4130025',to_date('12-10-18 9:40','DD-MM-YY HH24:MI'),to_date('12-10-18 09:50','DD-MM-YY HH24:MI'));

1 row created.

SQL>
SQL>
SQL> insert into desconexiones values ('T4130025',to_date('13-10-18 9:40','DD-MM-YY HH24:MI'),to_date('13-10-18 09:49','DD-MM-YY HH24:MI'));
insert into desconexiones values ('T4130025',to_date('13-10-18 9:40','DD-MM-YY HH24:MI'),to_date('13-10-18 09:49','DD-MM-YY HH24:MI'))
            *
ERROR at line 1:
ORA-20010: El periodo de desconexion no puede ser inferior a 10 minutos
ORA-06512: at "FASEDOS.DESCONEXION10MAX", line 5
ORA-04088: error during execution of trigger 'FASEDOS.DESCONEXION10MAX'


