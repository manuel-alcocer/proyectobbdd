create or replace view datosempresas (central,prod_total) as
select c.nombre,sum(m.prod_max_horaria)
from empresas e, centrales c, aerogeneradores a,modelos_aerogeneradores m
where e.cif = c.cif_empresa
and c.nombre = a.nombre_central
and a.nombre_modelo = m.nombre
group by c.nombre;


create or replace view MaxCapacidadEmpresas (central,produccion) as
select central, sum(prod_total) from datosempresas d
group by central
having sum(prod_total) = (  select max(sum(prod_total)) from datosempresas
                            where central = d.central
                            group by central);
