/*
        10. Crea una vista con la central con mayor capacidad de producción de cada una de las
        empresas, incluyendo cual es esa capacidad y el número de aerogeneradores de que
        dispone.
*/

-- Para el ejercicio voy a modificar unas centrales para que pertenezcan a una misma empresa
update CENTRALES
set cif_empresa = 'K8166903T'
where nombre = 'LOS LABRADOS';

update CENTRALES
set cif_empresa = 'K8166903T'
where nombre = 'LOS VISOS';

update CENTRALES
set cif_empresa = 'K8166903T'
where nombre = 'MAGAZ';
update CENTRALES
set cif_empresa = 'K8166903T'
where nombre = 'LUNA';

update CENTRALES
set cif_empresa = 'E80861943'
where nombre = 'LEVANTERA';
update CENTRALES
set cif_empresa = 'E80861943'
where nombre = 'LOMILLAS';

update CENTRALES
set cif_empresa = 'E80861943'
where nombre = 'LA TELLA';
update CENTRALES
set cif_empresa = 'E80861943'
where nombre = 'LES COMES';

update CENTRALES
set cif_empresa = 'E80861943'
where nombre = 'LES CALOBRES';

/*
        10. Crea una vista con la central con mayor capacidad de producción de cada una de las
        empresas, incluyendo cual es esa capacidad y el número de aerogeneradores de que
        dispone.
*/

-- Vista con las empresas, centrales, aerogeneradores, modelo, prod_max_horaria
create or replace view DatosEmpresas (empresa,central,prod_total) as
select e.nombre, c.nombre,count(a.codigo)*m.prod_max_horaria
from EMPRESAS e, CENTRALES c, AEROGENERADORES a,MODELOS_AEROGENERADORES m
where e.cif = c.cif_empresa
and c.nombre = a.nombre_central
and a.nombre_modelo = m.nombre
group by e.nombre,c.nombre,m.prod_max_horaria;

create or replace view MaxCapacidadEmpresas (empresa,central,produccion) as
select * from DatosEmpresas d
where prod_total = (select max(prod_total) from DatosEmpresas
                    where empresa = d.empresa);
