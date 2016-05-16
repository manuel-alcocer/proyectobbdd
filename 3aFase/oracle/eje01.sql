/*
        1. Inserta una nueva central ubicada en el pueblo donde más centrales hay de la provincia
        donde hay más centrales. Es de la empresa propietaria de la central cuyos aerogeneradores
        suman menor número de desconexiones. Su nombre es 'Facinas 2', su dirección
        'Campo de los Vientos (Facinas)' y su teléfono 956234422.'
*/

-- Provincia con mayor numero de centrales
create or replace view prov_max
as
select cod_provincia from municipios
where codigo in (
        select cod_municipio from centrales
                )
group by cod_provincia
having count(*) = (
        select max(count(*)) from municipios
        where codigo in (select cod_municipio from centrales)
        group by cod_provincia
                    );

INSERT INTO CENTRALES VALUES ( 'FACINAS 2',
            (select c.cod_municipio from centrales c
            where c.cod_municipio in (
                            select codigo from municipios
                            where cod_provincia = (select * from prov_max))
            group by c.cod_municipio
            having count(c.cod_municipio) = (
                            select max(count(*)) from centrales cc
                            where cc.cod_municipio in (
                                            select m.codigo from municipios m
                                            where m.cod_provincia = (select * from prov_max))
                            group by cc.cod_municipio)),
            (select e.cif from empresas e
            where e.cif = ( 
                    select c.cif_empresa from centrales c
                    where c.nombre = (
                            select a.nombre_central from aerogeneradores a, desconexiones d
                            where a.codigo = d.cod_aerogenerador
                            group by nombre_central
                            having count(*) = ( 
                                    select min(count(*)) from aerogeneradores a, desconexiones d
                                    where a.codigo = d.cod_aerogenerador
                                    group by nombre_central)))),
                                'Campo de los Vientos (FACINAS)', '956234422');
