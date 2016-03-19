create database fasedos;
use fasedos;

-- Tabla 1:2
CREATE TABLE empresas (
    cif     VARCHAR(9),
    nombre  VARCHAR(50),
    CONSTRAINT pk_empresas PRIMARY KEY (cif),
    CONSTRAINT uni_nombre_emp_unico UNIQUE (nombre),
    CONSTRAINT nombre_empresa_nonulo  CHECK (nombre IS NOT NULL)
);

-- Tabla 2:2
CREATE TABLE provincias (
    codigo  INTEGER(2),
    nombre  VARCHAR(20),
    CONSTRAINT pk_provincias PRIMARY KEY (codigo),
    CONSTRAINT uni_nombre_prov UNIQUE (nombre),
    CONSTRAINT cod_prov_valido CHECK (codigo LIKE '__' AND codigo BETWEEN 01 AND 52),
    CONSTRAINT nombre_provincia CHECK (nombre IS NOT NULL)
);

-- Tabla 3:5
CREATE TABLE centrales (
    nombre          VARCHAR(50),
    cod_provincia   INTEGER(6),
    cif_empresa     VARCHAR(9),
    direccion       VARCHAR(50),
    telefono        INTEGER(9),
    CONSTRAINT pk_centrales PRIMARY KEY (nombre),
    CONSTRAINT fk_cod_provincia FOREIGN KEY (cod_provincia) REFERENCES provincias (codigo),
    CONSTRAINT fk_cif_empresa FOREIGN KEY (cif_empresa) REFERENCES empresas (cif),
    CONSTRAINT telefono_valido CHECK (telefono LIKE '8%' OR telefono LIKE '9%'),
    CONSTRAINT fk_cod_provincia_nonulo CHECK (cod_provincia IS NOT NULL),
    CONSTRAINT fk_cif_empresa_nonulo CHECK (cif_empresa IS NOT NULL)
);

-- Tabla4:2
CREATE TABLE eolicas (
    nombre_central      VARCHAR(50),
    vel_media_viento    FLOAT(5,2),
    CONSTRAINT pk_eolicas PRIMARY KEY (nombre_central),
    CONSTRAINT fk_nombre_central_eolica FOREIGN KEY (nombre_central) REFERENCES centrales (nombre),
    CONSTRAINT vel_media_valida CHECK (vel_media_viento between 0 AND 999.9)
);

-- Tabla 5:5
CREATE TABLE predicciones_viento (
    fechahora           DATETIME,
    nombre_central      VARCHAR(50),
    velocidad           FLOAT(5),
    direccion           VARCHAR(3),
    CONSTRAINT pk_predicciones_viento PRIMARY KEY (fechahora),
    CONSTRAINT fk_nombre_central_pred FOREIGN KEY (nombre_central) REFERENCES eolicas (nombre_central)
);

-- Tabla 6:5
CREATE TABLE modelos_aerogeneradores (
    nombre              VARCHAR(30),
    marca               VARCHAR(30),
    longitud_aspas      FLOAT(4,2),
    prod_max_horaria    FLOAT(5),
    vel_max_viento      FLOAT(5),
    CONSTRAINT pk_modelos_aerogeneradores PRIMARY KEY (nombre)
);

-- Tabla 7:3
CREATE TABLE aerogeneradores (
    codigo          VARCHAR(8),
    nombre_central  VARCHAR(50),
    nombre_modelo   VARCHAR(30),
    CONSTRAINT pk_aerogeneradores PRIMARY KEY (codigo),
    CONSTRAINT fk_nombre_central_aeorgen FOREIGN KEY (nombre_central) REFERENCES eolicas (nombre_central),
    CONSTRAINT fk_nombre_modelo FOREIGN KEY (nombre_modelo) REFERENCES modelos_aerogeneradores (nombre),
    CONSTRAINT cod_aerogen_valido CHECK (codigo LIKE 'T_______' OR codigo LIKE 'M_______'),
    CONSTRAINT fk_nombre_central_aeorgen_nonulo CHECK (nombre_central IS NOT NULL),
    CONSTRAINT fk_nombre_modelo_nonulo  CHECK (nombre_modelo IS NOT NULL)
);

-- Tabla 8:4
CREATE TABLE producciones_aerogeneradores (
    fechahora           DATETIME,
    cod_aerogenerador   VARCHAR(8),
    produccion          FLOAT(5),
    CONSTRAINT pk_producciones_aerogenradores PRIMARY KEY (fechahora, cod_aerogenerador),
    CONSTRAINT fk_cod_aerogenerador_prod FOREIGN KEY (cod_aerogenerador) REFERENCES aerogeneradores (codigo)
);

-- Tabla 9:5
CREATE TABLE desconexiones (
    cod_aerogenerador   VARCHAR(8),
    fechahora_inicio    DATETIME,
    fechahora_fin       DATETIME,
    CONSTRAINT pk_desconexiones PRIMARY KEY (cod_aerogenerador,fechahora_inicio,fechahora_fin),
    CONSTRAINT fk_cod_aerogenerador_desconec FOREIGN KEY (cod_aerogenerador) REFERENCES aerogeneradores (codigo)
);
