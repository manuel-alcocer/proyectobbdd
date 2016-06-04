exec PCentrales2.GenerarInforme(5,'wee','weee');

select cod_aerogenerador from desconexiones d
where cod_aerogenerador = 'T6380001'
and to_number(to_char(d.fechahora_inicio,'YYYYMMDDHH24MI'), '9') <= '201501010000'
and to_number(to_char(d.fechahora_salida,'YYYYMMDD'), '9') > '20150101'
