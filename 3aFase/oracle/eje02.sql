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

-- La central donde hay mas predicciones de dirección este
select nombre_central from predicciones_viento
where substr(direccion,-1) = 'E'
group by nombre_central
having count(*) = (
                select max(count(*)) from predicciones_viento
                where substr(direccion,-1) = 'E'
                group by nombre_central);

-- El modelo de aerogeneradores que soporta más velocidad
select nombre from modelos_aerogeneradores
where vel_max_viento = (
             select max(vel_max_viento)
             from modelos_aerogeneradores
                        );

-- SOLUCIÓN:
update aerogeneradores
set nombre_modelo = (select nombre from modelos_aerogeneradores
where vel_max_viento = (select max(vel_max_viento)
                        from modelos_aerogeneradores))
where nombre_central = (select nombre_central from predicciones_viento
                        where substr(direccion,-1) = 'E'
                        group by nombre_central
                        having count(*) = ( select max(count(*)) from predicciones_viento
                                            where substr(direccion,-1) = 'E'
                                            group by nombre_central));
