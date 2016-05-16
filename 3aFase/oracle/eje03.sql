/*
        3. Muestra para cada central eólica el total de energía producida por sus
        aerogeneradores durante el día 16 de enero de 2015, incluyendo aquéllas centrales
        que no tienen aerogeneradores.
*/

select e.nombre_central, nvl(sum(p.produccion / 100 * m.prod_max_horaria),0) as energia
from eolicas e, aerogeneradores a, producciones_aerogeneradores p, modelos_aerogeneradores m
where e.nombre_central = a.nombre_central(+)
and a.codigo = p.cod_aerogenerador(+)
and a.nombre_modelo = m.nombre(+)
and to_number(nvl(to_char(p.fechahora, 'DDD'),16)) = 16
group by e.nombre_central
order by energia asc;
