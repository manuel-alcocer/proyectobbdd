/*
        7. Muestra la producción total de cada central durante los diez primeros días de Enero.
*/

select e.nombre_central, coalesce(round(sum(p.produccion / 100 * m.prod_max_horaria),2),0) as produccion_enero
from eolicas e left outer join aerogeneradores a on e.nombre_central = a.nombre_central
left outer join producciones_aerogeneradores p on a.codigo = p.cod_aerogenerador
left outer join modelos_aerogeneradores m on a.nombre_modelo = m.nombre
where to_number(coalesce(to_char(p.fechahora, 'DDD'),'0'), '999') between 0 and 10 
group by e.nombre_central
order by produccion_enero desc;
