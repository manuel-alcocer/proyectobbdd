/*
        7. Muestra la producción total de cada central durante los diez primeros días de Enero.
*/

select e.nombre_central, coalesce(round(sum(p.produccion / 100 * m.prod_max_horaria),2),0) as produccion_enero
from EOLICAS e left outer join AEROGENERADORES a on e.nombre_central = a.nombre_central
left outer join PRODUCCIONES_AEROGENERADORES p on a.codigo = p.cod_aerogenerador
left outer join MODELOS_AEROGENERADORES m on a.nombre_modelo = m.nombre
where cast(coalesce(dayofyear(p.fechahora),'0') as unsigned integer) between 0 and 10 
group by e.nombre_central
order by produccion_enero asc;
