
alter table centrales
add ( CapacidadProdMaxima number );


create or replace package PControlCentrales as

    TYPE TipoRegCantidadesAeros is RECORD
    (
        cantidad    number
    );
    TYPE TipoTablaCantidadesAeros is table of TipoRegCantidadesAeros
        index by varchar2;
    TablaCantidadesAeros TipoTablaCantidadesAeros;

    procedure RellenarCapMax;

    procedure InsercionEnAeros (p_nombre centrales.nombre%TYPE,
                                p_modelo modelos_aerogeneradores.nombre%TYPE);

    procedure BorradoEnAeros (p_nombre centrales.nombre%TYPE,
                              p_viejo_modelo modelos_aerogeneradores.nombre%TYPE);

    procedure CambioEnModelos (p_nombre_modelo modelos_aerogeneradores.nombre%TYPE,
                               p_nueva_prod modelos_aerogeneradores.prod_max_horaria%TYPE,
                               p_vieja_prod modelos_aerogeneradores.prod_max_horaria%TYPE);

    procedure ContarAeros;

end PControlCentrales;
/

create or replace package body PControlCentrales as
    procedure RellenarCapMax
    is
        cursor c_centrales is
            select nombre_central from eolicas;
    begin
        for v_central in c_centrales loop
            update centrales
                set CapacidadProdMaxima = (
                                            select sum(m.prod_max_horaria)
                                                from aerogeneradores a, modelos_aerogeneradores m
                                                where a.nombre_central = v_central.nombre_central
                                                and a.nombre_modelo = m.nombre
                                           )
                where nombre = v_central.nombre_central;
        end loop;
    end RellenarCapMax;

    procedure InsercionEnAeros (p_nombre centrales.nombre%TYPE,
                                p_modelo modelos_aerogeneradores.nombre%TYPE)
    is
        v_prod_max modelos_aerogeneradores.prod_max_horaria%TYPE;
    begin
        select prod_max_horaria into v_prod_max
            from modelos_aerogeneradores
            where nombre = p_modelo;

        update centrales
            set CapacidadProdMaxima = CapacidadProdMaxima + v_prod_max
            where nombre = p_nombre;
    end InsercionEnAeros;

    procedure BorradoEnAeros (p_nombre centrales.nombre%TYPE,
                              p_viejo_modelo modelos_aerogeneradores.nombre%TYPE)
    is
        v_prod_max modelos_aerogeneradores.prod_max_horaria%TYPE;
    begin
        select prod_max_horaria into v_prod_max
            from modelos_aerogeneradores
            where nombre = p_viejo_modelo;

        update centrales
            set CapacidadProdMaxima = CapacidadProdMaxima - v_prod_max
            where nombre = p_nombre;
    end BorradoEnAeros;

    procedure CambioEnModelos (p_nombre_modelo modelos_aerogeneradores.nombre%TYPE,
                               p_nueva_prod modelos_aerogeneradores.prod_max_horaria%TYPE,
                               p_vieja_prod modelos_aerogeneradores.prod_max_horaria%TYPE)
    is
        cursor c_centrales is
            select distinct nombre_central
                from aerogeneradores
                where nombre_modelo = p_nombre_modelo;
        v_cantidad_aeros    number;
    begin
        for v_central in c_centrales loop
            select nvl(count(*),0) into v_cantidad_aeros
                from aerogeneradores
                where nombre_central = v_central.nombre_central
                and nombre_modelo = p_nombre_modelo;

            update centrales
                set CapacidadProdMaxima = CapacidadProdMaxima + v_cantidad_aeros * (p_nueva_prod - p_vieja_prod)
                where nombre = v_central.nombre_central;
        end loop;
    end CambioEnModelos;

    procedure ContarAeros
    is
    begin
        null;
    end ContarAeros;

end PControlCentrales;
/

/*
 * TIGRES EJERCICIO 5
 */

create or replace trigger ControlAerogeneradores
after insert or update or delete on aerogeneradores
for each row
    begin
        case
            when inserting then
                PControlCentrales.InsercionEnAeros(:new.nombre_central, :new.nombre_modelo);
            when updating then
                PControlCentrales.BorradoEnAeros(:old.nombre_central, :old.nombre_modelo);
                PControlCentrales.InsercionEnAeros(:new.nombre_central, :new.nombre_modelo);
            when deleting then
                PControlCentrales.BorradoEnAeros(:old.nombre_central, :old.nombre_modelo);
        end case;
end ControlCapMaxCentral;
/

create or replace trigger ControlModelos
after update of prod_max_horaria on modelos_aerogeneradores
for each row
begin
    PControlCentrales.CambioEnModelos(:new.nombre, :new.prod_max_horaria, :old.prod_max_horaria);
end ControlModelos;
/
