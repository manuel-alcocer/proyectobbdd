
select * from desconexiones
where cod_aerogenerador in (
select codigo from aerogeneradores
where nombre_central = 'JEREZ');

INSERT INTO PREDICCIONES_VIENTO VALUES (TO_DATE('1 1 2020 0:0', 'DD MM YYYY HH24:MI'), 'JEREZ', 300, '201°1''S');
