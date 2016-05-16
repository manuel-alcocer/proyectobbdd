 
/*
        2. Los aerogeneradores de la central eólica donde se predicen con más frecuencia
        vientos de dirección Este van a cambiar de modelo. Pasarán a ser del modelo que
        resiste una mayor velocidad máxima del viento.
*/

-- Para este ejercicio hacen falta 2 cosas:
    -- La central donde hay más predicciones de dirección este
    -- El modelo de aerogeneradores que soporta más velocidad

-- Voy a insertar un modelo de aerogenerador que sea el que mayor velocidad soporte    
INSERT INTO MODELOS_AEROGENERADORES VALUES ('GE 2,7 XXL', 'GE', '49.00', '2500', '32');

-- cantidad de predicciones con componente este
create or replace view CentralesEste (cantidad,nombre) as
select count(*), nombre_central from PREDICCIONES_VIENTO
where substr(direccion,length(direccion)) = 'E'
group by nombre_central;

-- Central con mayor número de predicciones
create or replace view MaxCentralEste (nombre) as
select nombre from CentralesEste
where cantidad = (select max(cantidad) from CentralesEste);

-- Aerogenerador con mayor velocidad
create or replace view MaxAerogenerador (nombre) as
select nombre from MODELOS_AEROGENERADORES
where vel_max_viento = (select max(vel_max_viento)
                        from MODELOS_AEROGENERADORES);

-- Actualización
update AEROGENERADORES
set nombre_modelo = (select nombre from MaxAerogenerador)
where nombre_central = (select nombre from MaxCentralEste);
