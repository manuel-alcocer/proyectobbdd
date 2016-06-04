   /* selects de pruebas  Ejercicio 1 */

select PCentrales1.ProduccionEnergia('T6380001','1-1-2015') from dual;

select count(p.cod_aerogenerador)
from aerogeneradores a, producciones_aerogeneradores p, desconexiones d
where a.codigo = p.cod_aerogenerador(+)
and a.codigo = d.cod_aerogenerador(+)
and (
    to_char(p.fechahora,'YYYYMMDD') > '20160101'
    or
    to_char(d.fechahora_inicio, 'YYYYMMDD') > '20160101'
)
and p.cod_aerogenerador = 'T6380001';

    /* Fin selects de pruebas */
