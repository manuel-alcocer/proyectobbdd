/* PRUEBAS */

SQL> exec pc5.rellenarcapmax;

PL/SQL procedure successfully completed.

select nombre, CapacidadProdMaxima from centrales where nombre = 'JEREZ';

SQL> select nombre, CapacidadProdMaxima from centrales where nombre = 'JEREZ';
JEREZ
              44850

/* Comprobacion de la suma */
select a.nombre_central,sum(m.prod_max_horaria) from modelos_aerogeneradores m, aerogeneradores a
where a.nombre_modelo = m.nombre
and a.nombre_central = 'JEREZ'
group by a.nombre_central;

SQL> select a.nombre_central,sum(m.prod_max_horaria) from modelos_aerogeneradores m, aerogeneradores a
where a.nombre_modelo = m.nombre
and a.nombre_central = 'JEREZ'
group by a.nombre_central;

JEREZ
                  44850

                  /* inserto un aerogenerador */

insert into aerogeneradores values ('T4130024', 'JEREZ', 'S88');

SQL> insert into aerogeneradores values ('T4130024', 'JEREZ', 'S88');

1 row created.

/* compruebo la tabla */

SQL> select nombre, CapacidadProdMaxima from centrales where nombre = 'JEREZ';
JEREZ
              46950


/* compruebo la suma */

SQL> select sum(m.prod_max_horaria) from aerogeneradores a, modelos_aerogeneradores m
where a.nombre_central = 'JEREZ'
  3  and a.nombre_modelo = m.nombre;
                  46950


/* actualizando valores */

update aerogeneradores
set nombre_modelo = 'P-10'
where codigo like 'T413%'
and nombre_modelo = 'S88';

/* salida */

update aerogeneradores
set nombre_modelo = 'P-10'
where codigo like 'T413%'
  4  and nombre_modelo = 'S88';

22 rows updated.

/* compruebo la tabla */

SQL> select nombre, CapacidadProdMaxima from centrales where nombre = 'JEREZ';
JEREZ
               6250


/* compruebo la suma */


SQL> select a.nombre_central,sum(m.prod_max_horaria) from modelos_aerogeneradores m, aerogeneradores a
where a.nombre_modelo = m.nombre
and a.nombre_central = 'JEREZ'
  4  group by a.nombre_central;
JEREZ
                   6250

/* Actualizo de nuevo */

update aerogeneradores
set nombre_modelo = 'S88'
where codigo like 'T413%'
and nombre_modelo = 'P-10';

/* salida */

update aerogeneradores
set nombre_modelo = 'S88'
where codigo like 'T413%'
  4  and nombre_modelo = 'P-10';

25 rows updated.


/* borro */

delete from aerogeneradores where codigo = 'T4130024';

/* salida */
SQL> delete from aerogeneradores where codigo = 'T4130024';

1 row deleted.


SQL> select nombre, CapacidadProdMaxima from centrales where nombre = 'JEREZ';
JEREZ
              50400


select a.nombre_central,sum(m.prod_max_horaria) from modelos_aerogeneradores m, aerogeneradores a
where a.nombre_modelo = m.nombre
and a.nombre_central = 'JEREZ'
  4  group by a.nombre_central;
JEREZ
                  50400


SQL>


/* Ahora sobre la tabla modelos_aerogeneradores */

update modelos_aerogeneradores
set prod_max_horaria = 1333
where nombre = 'S88';

/* salida */
update modelos_aerogeneradores
set prod_max_horaria = 1333
where nombre = 'S88';


1 row updated.

SQL> SQL>


/* compruebo la tabla y la suma */
SQL> select nombre, CapacidadProdMaxima from centrales where nombre = 'JEREZ';
JEREZ
              31992

select a.nombre_central,sum(m.prod_max_horaria) from modelos_aerogeneradores m, aerogeneradores a
where a.nombre_modelo = m.nombre
and a.nombre_central = 'JEREZ'
  4  group by a.nombre_central;
JEREZ
                  31992



