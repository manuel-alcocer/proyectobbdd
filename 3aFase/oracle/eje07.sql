/*
        7. Muestra la producción total de cada central durante los diez primeros días de Enero.
*/

select e.nombre_central, nvl(sum(p.produccion / 100 * m.prod_max_horaria),0) as produccion_enero
from eolicas e, aerogeneradores a,
producciones_aerogeneradores p, modelos_aerogeneradores m
where e.nombre_central = a.nombre_central(+)
and a.codigo = p.cod_aerogenerador(+)
and a.nombre_modelo = m.nombre(+)
and to_number(nvl(to_char(p.fechahora, 'DDD'),0)) between 0 and 10 
group by e.nombre_central
order by produccion_enero asc;
