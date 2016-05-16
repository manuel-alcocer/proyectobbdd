/*
        6. Muestra el número de desconexiones que se han producido en cada central,
        incluyendo aquéllas en las que no se ha producido ninguna.
*/

select e.nombre_central, count(d.cod_aerogenerador) as total_desconexiones
from eolicas e, aerogeneradores a, desconexiones d
where e.nombre_central = a.nombre_central(+)
and a.codigo = d.cod_aerogenerador(+)
group by e.nombre_central
order by total_desconexiones asc;
