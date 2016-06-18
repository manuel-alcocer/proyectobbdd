/* modificación en la tabla desconexiones necesaria
            alter table desconexiones
            drop constraint pk_desconexiones;

            alter table desconexiones
            add CONSTRAINT pk_desconexiones  PRIMARY KEY (cod_aerogenerador, fechahora_inicio);
*/

create or replace package PC3 as
    procedure InsertarDesconexion (p_codigo aerogeneradores.codigo%TYPE,
                                   p_fecha desconexiones.fechahora_inicio%TYPE);
end PC3;
/

create or replace package body PC3 as
    procedure InsertarDesconexion (p_codigo aerogeneradores.codigo%TYPE,
                                   p_fecha desconexiones.fechahora_inicio%TYPE)
    is
        v_estado number;
        v_fecha_salida date;
    begin
        v_fecha_salida := p_fecha + 1;
        v_fecha_salida := to_date(to_char(v_fecha_salida, 'DDMMYYYY') || ' 09:00', 'DDMMYYYY HH24:MI');
        v_estado := PCentrales1.AerogeneradorDesconectado(p_codigo, to_char(p_fecha,'YYYYMMDD'));
        /* Si el aerogenerador no está desconectado para esa fechahora lo desconecta 1 día*/
        if v_estado < 1 then
            insert into desconexiones values (p_codigo, p_fecha, v_fecha_salida);
        end if;
    end InsertarDesconexion;

end PC3;
/

create or replace trigger VientosMaximos
after insert on predicciones_viento
for each row
declare
    v_nombre centrales.nombre%type;
    cursor c_aeros is
        select a.codigo,
            mo.vel_max_viento as velocidad
            from aerogeneradores a, modelos_aerogeneradores mo
            where a.nombre_central = v_nombre
            and a.nombre_modelo = mo.nombre
            order by a.codigo asc;
begin
    v_nombre := :new.nombre_central;
    for v_aeros in c_aeros loop
        if (:new.velocidad / v_aeros.velocidad) > 1.3 then
            PC3.InsertarDesconexion(v_aeros.codigo, :new.fechahora);
        end if;
    end loop;
end VientosMaximos;
/

