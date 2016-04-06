drop database fasedos;
create database fasedos;
use fasedos;
-- Tabla 1:2
CREATE TABLE EMPRESAS (
    cif    VARCHAR(9),
    nombre VARCHAR(60),
    -- Claves
    CONSTRAINT pk_empresas      PRIMARY KEY (cif),
    CONSTRAINT uni_nom_emp_uniq UNIQUE (nombre),
    -- Restricciones CHECK
    CONSTRAINT nom_emp_nonulo CHECK (nombre IS NOT NULL),
    CONSTRAINT cif_valido     CHECK (REGEXP_LIKE(cif, '[KQS]\d{7}[A-Z]|[ABEH]\d{8}|[CDFGIJL-PRT-Z]\d{7}[A-Z0-9]'))
);

-- Tabla 2:2
CREATE TABLE PROVINCIAS (
    codigo VARCHAR(2),
    nombre VARCHAR(40),
    -- Claves
    CONSTRAINT pk_provincias   PRIMARY KEY (codigo),
    CONSTRAINT uni_nombre_prov UNIQUE (nombre),
    -- Restricciones CHECK
    CONSTRAINT cod_prov_dos_cifras CHECK (REGEXP_LIKE(codigo, '0[1-9]|[1-4]\d|5[0-2]')),
    CONSTRAINT nombre_provincia    CHECK (nombre IS NOT NULL)
);

-- Tabla Intermedia
CREATE TABLE MUNICIPIOS (  
    codigo        VARCHAR(3),
    cod_provincia VARCHAR(2),
    nombre        VARCHAR(60),
    CONSTRAINT pk_municipios PRIMARY KEY (codigo),
    CONSTRAINT fk_cod_prov_munic FOREIGN KEY (cod_provincia) REFERENCES PROVINCIAS (codigo)
);

-- Tabla 3:5
CREATE TABLE CENTRALES (
    nombre        VARCHAR(50),
    cod_municipio VARCHAR(3),
    cif_empresa   VARCHAR(9),
    direccion     VARCHAR(50),
    telefono      VARCHAR(9),
    -- Claves
    CONSTRAINT pk_centrales     PRIMARY KEY (nombre),
    CONSTRAINT fk_cod_municipio FOREIGN KEY (cod_municipio) REFERENCES MUNICIPIOS (codigo),
    CONSTRAINT fk_cif_empresa   FOREIGN KEY (cif_empresa) REFERENCES EMPRESAS (cif),
    -- Restricciones CHECK
    CONSTRAINT telefono_valido    CHECK (REGEXP_LIKE(telefono, '[89]\d{8}')),
    CONSTRAINT fk_cod_muni_nonulo CHECK (cod_municipio IS NOT NULL),
    CONSTRAINT fk_cif_emp_nonulo  CHECK (cif_empresa IS NOT NULL)
);

-- Tabla4:2
CREATE TABLE EOLICAS (
    nombre_central   VARCHAR(50),
    vel_media_viento DECIMAL(5,2),
    -- Claves
    CONSTRAINT pk_eolicas         PRIMARY KEY (nombre_central),
    CONSTRAINT fk_nom_cent_eolica FOREIGN KEY (nombre_central) REFERENCES CENTRALES (nombre),
    -- Restricciones CHECK
    CONSTRAINT vel_media_valida CHECK (vel_media_viento between 0 AND 999.99)
);

-- Tabla 5:5
CREATE TABLE PREDICCIONES_VIENTO (
    fechahora      DATETIME,
    nombre_central VARCHAR(50),
    velocidad      DECIMAL(5,2),
    direccion      VARCHAR(9),
    -- Claves
    CONSTRAINT pk_predicciones_viento PRIMARY KEY (fechahora, nombre_central),
    CONSTRAINT fk_nombre_central_pred FOREIGN KEY (nombre_central) REFERENCES EOLICAS (nombre_central),
    -- Restricciones CHECK
    CONSTRAINT dir_viento_valido CHECK (
                (
                    TO_DECIMAL(
                        SUBSTR(direccion,1,INSTR(velocidad, 'º')-1), '99')
                        BETWEEN 0.01 AND 360
                )
                AND
                (
                    TO_DECIMAL(
                        SUBSTR(direccion,INSTR(velocidad, 'º')+1, INSTR(velocidad, '''')-1), '99')
                        BETWEEN 0 AND 59
                )
                AND
                (
                    REGEXP_LIKE(
                        direccion, '\d{1,3}º\d{1,2}''[NSWE]')
                )
            ),
    CONSTRAINT prediccion_navidad CHECK ( 
                                         (TO_DECIMAL(TO_CHAR(fechahora,'MMDD'),'9999') NOT BETWEEN 1225 AND 1231)
                                          AND
                                         (TO_DECIMAL(TO_CHAR(fechahora,'MMDD'),'9999') NOT BETWEEN 0101 AND 0106)
                                        )
);

-- Tabla 6:5
CREATE TABLE MODELOS_AEROGENERADORES (
    nombre           VARCHAR(30),
    marca            VARCHAR(30),
    longitud_aspas   DECIMAL(4,2),
    prod_max_horaria INT(5),
    vel_max_viento   INT(5),
    -- Claves
    CONSTRAINT pk_modelos_aerogen PRIMARY KEY (nombre)
);

-- Tabla 7:3
CREATE TABLE AEROGENERADORES (
    codigo         VARCHAR(8),
    nombre_central VARCHAR(50),
    nombre_modelo  VARCHAR(30),
    -- Claves
    CONSTRAINT pk_aerogens       PRIMARY KEY (codigo),
    CONSTRAINT fk_nom_cent_aerog FOREIGN KEY (nombre_central) REFERENCES EOLICAS (nombre_central),
    CONSTRAINT fk_nom_model      FOREIGN KEY (nombre_modelo) REFERENCES MODELOS_AEROGENERADORES (nombre),
    -- Restricciones CHECK
    CONSTRAINT cod_aerogen_valido CHECK (
                                        (codigo LIKE 'T%' OR codigo LIKE 'M%')
                                        AND 
                                        (LENGTH(codigo) = 8)
                                    ),
    CONSTRAINT fk_nom_cen_aeor_nonulo CHECK (nombre_central IS NOT NULL),
    CONSTRAINT fk_nom_model_nonulo    CHECK (nombre_modelo IS NOT NULL)
);

-- Tabla 8:4
CREATE TABLE PRODUCCIONES_AEROGENERADORES (
    fechahora         DATETIME,
    cod_aerogenerador VARCHAR(8),
    produccion        DECIMAL(4,1),
    -- Claves
    CONSTRAINT pk_prod_aerog     PRIMARY KEY (fechahora, cod_aerogenerador),
    CONSTRAINT fk_cod_aerog_prod FOREIGN KEY (cod_aerogenerador) REFERENCES AEROGENERADORES (codigo),
    -- Restricciones CHECK
    CONSTRAINT produccion_valida CHECK (
        (TO_CHAR(fechahora, 'MI') = '00')
        AND
        (produccion BETWEEN 0 AND 100)
    )
);

-- Tabla 9:5
CREATE TABLE DESCONEXIONES (
    cod_aerogenerador VARCHAR(8),
    fechahora_inicio  DATETIME,
    fechahora_fin     DATETIME,
    -- Claves
    CONSTRAINT pk_desconexiones  PRIMARY KEY (cod_aerogenerador, fechahora_inicio, fechahora_fin),
    CONSTRAINT fk_cod_aerog_desc FOREIGN KEY (cod_aerogenerador) REFERENCES AEROGENERADORES (codigo),
    -- Restricciones CHECK
    CONSTRAINT salida_conex_ok CHECK (TO_DECIMAL(TO_CHAR(fechahora_fin, 'HH24MI'),'9999') BETWEEN 0900 AND 1130)
);
