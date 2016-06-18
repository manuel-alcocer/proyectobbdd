select codigo, nombre_modelo from aerogeneradores
where nombre_central = 'JEREZ';

/* salida */
select codigo, nombre_modelo from aerogeneradores
  2  where nombre_central = 'JEREZ';
T4130000                 S88
T4130001                 S88
T4130002                 S88
T4130003                 S88
T4130004                 S88
T4130005                 S88
T4130006                 S88
T4130007                 S88
T4130008                 S88
T4130009                 S88
T4130010                 S88
T4130011                 S88
T4130012                 S88
T4130013                 S88
T4130014                 S88
T4130015                 S88
T4130016                 S88
T4130017                 S88
T4130018                 S88
T4130019                 S88
T4130020                 S88
T4130021                 S88
T4130022                 S88
T4130023                 S88
T4130025                 S88

25 rows selected.

SQL>

/* Cambio para que tenga 2 modelos */
update aerogeneradores
    set nombre_modelo = 'P-10'
    where codigo like 'T413000%';

/* salida */

  update aerogeneradores
    set nombre_modelo = 'P-10'
    where codigo like 'T413000%';

10 rows updated.

SQL>
    select codigo, nombre_modelo from aerogeneradores
  2  where nombre_central = 'JEREZ';
T4130000                 P-10
T4130001                 P-10
T4130002                 P-10
T4130003                 P-10
T4130004                 P-10
T4130005                 P-10
T4130006                 P-10
T4130007                 P-10
T4130008                 P-10
T4130009                 P-10
T4130010                 S88
T4130011                 S88
T4130012                 S88
T4130013                 S88
T4130014                 S88
T4130015                 S88
T4130016                 S88
T4130017                 S88
T4130018                 S88
T4130019                 S88
T4130020                 S88
T4130021                 S88
T4130022                 S88
T4130023                 S88
T4130025                 S88

25 rows selected.

SQL>


/* N100 */

update aerogeneradores
set nombre_modelo = 'N100'
where codigo like 'T413001%';

/* salida */
update aerogeneradores
set nombre_modelo = 'N100'
  3  where codigo like 'T413001%';

10 rows updated.


select codigo, nombre_modelo from aerogeneradores
  2  where nombre_central = 'JEREZ';
T4130000                 P-10
T4130001                 P-10
T4130002                 P-10
T4130003                 P-10
T4130004                 P-10
T4130005                 P-10
T4130006                 P-10
T4130007                 P-10
T4130008                 P-10
T4130009                 P-10
T4130010                 N100
T4130011                 N100
T4130012                 N100
T4130013                 N100
T4130014                 N100
T4130015                 N100
T4130016                 N100
T4130017                 N100
T4130018                 N100
T4130019                 N100
T4130020                 S88
T4130021                 S88
T4130022                 S88
T4130023                 S88
T4130025                 S88

25 rows selected.

/* N90 */

update aerogeneradores
    set nombre_modelo = 'N90'
    where codigo = 'T4130018';

select codigo, nombre_modelo from aerogeneradores
where nombre_central = 'JEREZ';
