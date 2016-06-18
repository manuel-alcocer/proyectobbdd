
insert into predicciones_viento values (to_date('12-02-2017 16:00', 'DD-MM-YYYY HH24:MI'), 'JEREZ', '99', '355°13''N');

1 row created.

select * from desconexiones
where to_char(fechahora_inicio, 'DDMMYYYY') = '12022017';

/* SALIDA */
SQL> select * from desconexiones
  2  where to_char(fechahora_inicio, 'DDMMYYYY') = '12022017';
T4130000                 12-FEB-17          13-FEB-17
T4130001                 12-FEB-17          13-FEB-17
T4130002                 12-FEB-17          13-FEB-17
T4130003                 12-FEB-17          13-FEB-17
T4130004                 12-FEB-17          13-FEB-17
T4130005                 12-FEB-17          13-FEB-17
T4130006                 12-FEB-17          13-FEB-17
T4130007                 12-FEB-17          13-FEB-17
T4130008                 12-FEB-17          13-FEB-17
T4130009                 12-FEB-17          13-FEB-17
T4130010                 12-FEB-17          13-FEB-17
T4130011                 12-FEB-17          13-FEB-17
T4130012                 12-FEB-17          13-FEB-17
T4130013                 12-FEB-17          13-FEB-17
T4130014                 12-FEB-17          13-FEB-17
T4130015                 12-FEB-17          13-FEB-17
T4130016                 12-FEB-17          13-FEB-17
T4130017                 12-FEB-17          13-FEB-17
T4130018                 12-FEB-17          13-FEB-17
T4130019                 12-FEB-17          13-FEB-17
T4130020                 12-FEB-17          13-FEB-17
T4130021                 12-FEB-17          13-FEB-17
T4130022                 12-FEB-17          13-FEB-17
T4130023                 12-FEB-17          13-FEB-17

24 rows selected.

insert into predicciones_viento values (to_date('12-02-2017 17:00', 'DD-MM-YYYY HH24:MI'), 'JEREZ', '99', '355°13''N');

1 row created.

SQL>
select * from desconexiones
  2  where to_char(fechahora_inicio, 'DDMMYYYY') = '12022017';
T4130000                 12-FEB-17          13-FEB-17
T4130001                 12-FEB-17          13-FEB-17
T4130002                 12-FEB-17          13-FEB-17
T4130003                 12-FEB-17          13-FEB-17
T4130004                 12-FEB-17          13-FEB-17
T4130005                 12-FEB-17          13-FEB-17
T4130006                 12-FEB-17          13-FEB-17
T4130007                 12-FEB-17          13-FEB-17
T4130008                 12-FEB-17          13-FEB-17
T4130009                 12-FEB-17          13-FEB-17
T4130010                 12-FEB-17          13-FEB-17
T4130011                 12-FEB-17          13-FEB-17
T4130012                 12-FEB-17          13-FEB-17
T4130013                 12-FEB-17          13-FEB-17
T4130014                 12-FEB-17          13-FEB-17
T4130015                 12-FEB-17          13-FEB-17
T4130016                 12-FEB-17          13-FEB-17
T4130017                 12-FEB-17          13-FEB-17
T4130018                 12-FEB-17          13-FEB-17
T4130019                 12-FEB-17          13-FEB-17
T4130020                 12-FEB-17          13-FEB-17
T4130021                 12-FEB-17          13-FEB-17
T4130022                 12-FEB-17          13-FEB-17
T4130023                 12-FEB-17          13-FEB-17

24 rows selected.

SQL>
