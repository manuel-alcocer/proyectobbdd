-- 8. Muestra los aerogeneradores que han producido menos de la mitad de energia que la
-- media de los aerogeneradores de su central.

-- Voy  a crear un aerogenerador de la marca Bornay cuya producción máxima
-- horaria es la menor de todos los aerogeneradores.
-- la velocidad máxima de este generador es de 10 m/s
INSERT INTO MODELOS_AEROGENERADORES VALUES ('P-10', 'BORNAY', '10', '100', '25');

-- Voy a cambiar, para cada central, los dos primeros aerogeneradores XXXX[0-1]
-- por ese modelo (tabla aerogeneradores)
UPDATE aerogeneradores
set nombre_modelo = 'P-10'
where substr(codigo,-2) in ('00', '01');

-- media_aerogenerador = sumatorio(produccion / 100 * prod_max_horaria) / n°_de_producciones
create or replace view medias_aeros (codigo,media) as
select pa.cod_aerogenerador, sum(pa.produccion/100*mo.prod_max_horaria) / count(pa.fechahora)
from producciones_aerogeneradores pa, aerogeneradores a, modelos_aerogeneradores mo
where pa.cod_aerogenerador = a.codigo
and a.nombre_modelo = mo.nombre
group by pa.cod_aerogenerador
order by pa.cod_aerogenerador;

-- Media de la central = sumatorio(media_aerogenerador) / n°_de_aerogeneradores
create or replace view medias_eolicas (nombre, media) as
select a.nombre_central, sum(ma.media)/count(*)
from medias_aeros ma, aerogeneradores a
where ma.codigo = a.codigo
group by a.nombre_central;

-- SOLUCIÓN:
select a.codigo, round(ma.media,2) as media_aero,
round(me.media,2) as media_eolica
from aerogeneradores a, medias_aeros ma, medias_eolicas me
where a.codigo = ma.codigo
and ma.media < me.media
and a.nombre_central = me.nombre;
