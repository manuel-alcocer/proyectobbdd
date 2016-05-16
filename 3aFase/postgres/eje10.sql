/*
        10. Crea una vista con la central con mayor capacidad de producción de cada una de las
        empresas, incluyendo cual es esa capacidad y el número de aerogeneradores de que
        dispone.
*/

-- Para el ejercicio voy a modificar unas centrales para que pertenezcan a una misma empresa
update centrales
set cif_empresa = 'H13382588'
where nombre = 'LOS LABRADOS';

update centrales
set cif_empresa = 'H13382588'
where nombre = 'LOS VISOS';

update centrales
set cif_empresa = 'H13382588'
where nombre = 'MAGAZ';
update centrales
set cif_empresa = 'H13382588'
where nombre = 'LUNA';

update centrales
set cif_empresa = 'O6372135J'
where nombre = 'LEVANTERA';
update centrales
set cif_empresa = 'O6372135J'
where nombre = 'LOMILLAS';

update centrales
set cif_empresa = 'O6372135J'
where nombre = 'LA TELLA';
update centrales
set cif_empresa = 'O6372135J'
where nombre = 'LES COMES';

update centrales
set cif_empresa = 'O6372135J'
where nombre = 'LES CALOBRES';

/*
        10. Crea una vista con la central con mayor capacidad de producción de cada una de las
        empresas, incluyendo cual es esa capacidad y el número de aerogeneradores de que
        dispone.
*/

-- Vista con las empresas, centrales, aerogeneradores, modelo, prod_max_horaria
create or replace view DatosEmpresas (empresa,central,prod_total) as
select e.nombre, c.nombre,count(a.codigo)*m.prod_max_horaria
from empresas e, centrales c, aerogeneradores a,modelos_aerogeneradores m
where e.cif = c.cif_empresa
and c.nombre = a.nombre_central
and a.nombre_modelo = m.nombre
group by e.nombre,c.nombre,m.prod_max_horaria;

create or replace view MaxCapacidadEmpresas (empresa,central,produccion) as
select * from datosempresas d
where prod_total = (select max(prod_total) from datosempresas
                    where empresa = d.empresa);
