/*
        3. Muestra para cada central eólica el total de energía producida por sus
        aerogeneradores durante el día 16 de enero de 2015, incluyendo aquéllas centrales
        que no tienen aerogeneradores.
*/

select e.nombre_central, coalesce(round(sum(p.produccion / 100 * m.prod_max_horaria),2),0) as energia
from EOLICAS e left outer join AEROGENERADORES a on e.nombre_central = a.nombre_central
left outer join PRODUCCIONES_AEROGENERADORES p on a.codigo = p.cod_aerogenerador
left outer join MODELOS_AEROGENERADORES m on a.nombre_modelo = m.nombre
and cast(coalesce(dayofyear(p.fechahora),'0') as unsigned integer) = 16 
group by e.nombre_central
order by energia asc;
