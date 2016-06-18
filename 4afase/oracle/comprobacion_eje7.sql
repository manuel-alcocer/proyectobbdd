/*
 * Busco centrales que estén en los márgenes
 * y que no tengan aerogeneradores en desconexiones
 * para evitar problemas de claves
 */

select a.nombre_central, count(a.codigo) from aerogeneradores a
where a.codigo not in (
                        select cod_aerogenerador from desconexiones
                        group by cod_aerogenerador
                      )
group by nombre_central
having count(codigo) > 5
and count(codigo) < 20;


select codigo from aerogeneradores
where nombre_central = 'PEÑA II';

/* salida */
select codigo from aerogeneradores
  2  where nombre_central = 'PEÑA II';
T8940000
T8940001
T8940002
T8940003
T8940004
T8940005
T8940006
T8940007
T8940008

9 rows selected.

/* límite inferior múltiples */

delete from aerogeneradores
where codigo like 'T89400%';

delete from aerogeneradores
            *
ERROR at line 1:
ORA-20011: Umbral mínimo ( 5 ) de aerogeneradores alcanzado en esta centralPEÑA II
ORA-06512: at "FASEDOS.PCONTROLAEROCENTRALES", line 21
ORA-06512: at "FASEDOS.MINMAXAEROS", line 11
ORA-04088: error during execution of trigger 'FASEDOS.MINMAXAEROS'


select codigo from aerogeneradores
  2  where nombre_central = 'PEÑA II';
T8940000
T8940001
T8940002
T8940003
T8940004
T8940005
T8940006
T8940007
T8940008

9 rows selected.

/* límite inferior uno a uno */

delete from aerogeneradores
where codigo like 'T8940001';

delete from aerogeneradores
  2  where codigo like 'T8940001';

1 row deleted.

/* updating */
/*
BAOS Y PUMAR FASE II
             11
*/

/* múltiple */
update aerogeneradores
set nombre_central = 'BAOS Y PUMAR FASE II'
where codigo like 'T8940002';

update aerogeneradores
set nombre_central = 'BAOS Y PUMAR FASE II'
  3  where codigo like 'T89400%';
update aerogeneradores
       *
ERROR at line 1:
ORA-20011: Umbral mínimo ( 5 ) de aerogeneradores alcanzado en esta centralPEÑA II
ORA-06512: at "FASEDOS.PCONTROLAEROCENTRALES", line 21
ORA-06512: at "FASEDOS.MINMAXAEROS", line 7
ORA-04088: error during execution of trigger 'FASEDOS.MINMAXAEROS'


/* uno a uno */
update aerogeneradores
set nombre_central = 'BAOS Y PUMAR FASE II'
  3  where codigo like 'T8940002';

1 row updated.



/* superior */
/*
 * LA DEHESICA
             19
*/
select codigo from aerogeneradores
where nombre_central = 'LA DEHESICA';
select codigo from aerogeneradores
  2  where nombre_central = 'LA DEHESICA';
T4590000
T4590001
T4590002
T4590003
T4590004
T4590005
T4590006
T4590007
T4590008
T4590009
T4590010
T4590011
T4590012
T4590013
T4590014
T4590015
T4590016
T4590017
T4590018

19 rows selected.


/* inserción múltiple */

insert into aerogeneradores
    select * from aerogeneradores
    where nombre_central = 'JEREZ';

insert into aerogeneradores
            *
ERROR at line 1:
ORA-20012: Umbral máximo ( 20 ) de aerogeneradores alcanzado en esta central: JEREZ
ORA-06512: at "FASEDOS.PCONTROLAEROCENTRALES", line 33
ORA-06512: at "FASEDOS.MINMAXAEROS", line 4
ORA-04088: error during execution of trigger 'FASEDOS.MINMAXAEROS'


/* uno a uno */
      insert into aerogeneradores values ('T4590019', 'LA DEHESICA', 'S88');


1 row created.

SQL> SQL>     insert into aerogeneradores values ('T4590020', 'LA DEHESICA', 'S88');
    insert into aerogeneradores values ('T4590020', 'LA DEHESICA', 'S88')
                *
ERROR at line 1:
ORA-20012: Umbral máximo ( 20 ) de aerogeneradores alcanzado en esta central: LA DEHESICA
ORA-06512: at "FASEDOS.PCONTROLAEROCENTRALES", line 33
ORA-06512: at "FASEDOS.MINMAXAEROS", line 4
ORA-04088: error during execution of trigger 'FASEDOS.MINMAXAEROS'


SQL> select count(*) from aerogeneradores
  2  where nombre_central = 'LA DEHESICA';
        20

