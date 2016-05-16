 /*
        9. Muestra las empresas que no tienen aerogeneradores de la marca Bornay en ninguna
        de sus centrales.
*/

-- SUSTITUIR 'DESA' POR LA MARCA DE AERO DEL EJERCICIO (bornay)
select distinct e.nombre
from empresas e
where e.cif not in ( 
                select c.cif_empresa
                from centrales c
                where c.nombre in (
                        select a.nombre_central
                        from aerogeneradores a, modelos_aerogeneradores m
                        where a.nombre_modelo = m.nombre
                        and m.marca = 'BORNAY'
                        group by a.nombre_central));
