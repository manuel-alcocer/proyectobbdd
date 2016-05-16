/*
        1. Inserta una nueva central ubicada en el pueblo donde mas centrales hay de la provincia
        donde hay más centrales. Es de la empresa propietaria de la central cuyos aerogeneradores
        suman menor número de desconexiones. Su nombre es 'Facinas 2', su dirección
        'Campo de los Vientos (Facinas)' y su teléfono 956234422.'
*/


-- cantidad de centrales por provincia
create or replace view NumeroCentrales (cantidad,cod_provincia) as
select count(*), cod_provincia from MUNICIPIOS
        where codigo in (select cod_municipio from CENTRALES)
        group by cod_provincia;


-- provincia/s con mayor numero de centrales
create or replace view ProvinciaMaxima as
select cod_provincia from NumeroCentrales
where cantidad = (select max(cantidad) from NumeroCentrales);


-- cantidad de centrales por municipio de las provincias con mayor numero de centrales
create or replace view CentralesMunicipios (cantidad, municipio) as
select count(*), cod_municipio from CENTRALES
where cod_municipio in (select cod_municipio from MUNICIPIOS
                        where cod_provincia in (select * from ProvinciaMaxima))
group by cod_municipio;


-- Municipio con mayor numero de centrales
create or replace view MaxMunicipio (codigo) as
select max(municipio) from CentralesMunicipios;


-- desconexiones por central
create or replace view DesconexionesPorCentral (cantidad, nombre) as 
select count(*), nombre_central from AEROGENERADORES
where codigo in (select cod_aerogenerador from DESCONEXIONES)
group by nombre_central;


-- Nombre de central con menor número de desconexiones
create or replace view MenorDescCentral as
select nombre from DesconexionesPorCentral
where cantidad = (select min(cantidad) from DesconexionesPorCentral);


create or replace view MinEmpresa as
select cif from EMPRESAS
where cif = (select cif_empresa from CENTRALES
                where nombre = (select * from MenorDescCentral));


INSERT INTO CENTRALES values (
    'FACINAS 2',
    (select codigo from MaxMunicipio),
    (select cif from MinEmpresa),
    'Campo de los Vientos (Facinas)',
    '956234422'
);

select * from CENTRALES
where nombre = 'FACINAS 2'; 
