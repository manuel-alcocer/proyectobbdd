create or replace package PControlAeroCentrales as

    TYPE TipoRegCantidadesAeros is RECORD
    (
        cantidad    number
    );
    TYPE TipoTablaCantidadesAeros is table of TipoRegCantidadesAeros
        index by centrales.nombre%TYPE;
    TablaCantidadesAeros TipoTablaCantidadesAeros;

    procedure ContarAeros;

    procedure UmbralInferior (p_nombre centrales.nombre%TYPE);

    procedure UmbralSuperior (p_nombre centrales.nombre%TYPE);

end PControlAeroCentrales;
/

create or replace package body PControlAeroCentrales as

    procedure ContarAeros
    is
        cursor c_aerocentrales is
            select nombre_central, count(*) as cantidad
                from aerogeneradores
                group by nombre_central;
    begin
        for v_central in c_aerocentrales loop
            TablaCantidadesAeros(v_central.nombre_central).cantidad := v_central.cantidad;
        end loop;
    end ContarAeros;

    procedure UmbralInferior (p_nombre centrales.nombre%TYPE)
    is
        v_umbral_minimo number := 5;
    begin
        TablaCantidadesAeros(p_nombre).cantidad := TablaCantidadesAeros(p_nombre).cantidad - 1;
        if TablaCantidadesAeros(p_nombre).cantidad < v_umbral_minimo then
            raise_application_error(-20011, 'Umbral mínimo ( ' || v_umbral_minimo ||
                                            ' ) de aerogeneradores alcanzado en esta central'
                                            || p_nombre);
        end if;
    end UmbralInferior;

    procedure UmbralSuperior (p_nombre centrales.nombre%TYPE)
    is
        v_umbral_maximo number := 20;
    begin
        TablaCantidadesAeros(p_nombre).cantidad := TablaCantidadesAeros(p_nombre).cantidad + 1;
        if TablaCantidadesAeros(p_nombre).cantidad > v_umbral_maximo then
            raise_application_error(-20012, 'Umbral máximo ( ' || v_umbral_maximo ||
                                            ' ) de aerogeneradores alcanzado en esta central: '
                                            || p_nombre);
        end if;
    end UmbralSuperior;

end PControlAeroCentrales;
/

create or replace trigger CuentaAeros
before insert or update or delete on aerogeneradores
begin
    PControlAeroCentrales.ContarAeros;
end CuentaAeros;
/

create or replace trigger MinMaxAeros
before insert or delete or update of nombre_central on aerogeneradores
for each row
begin
    if inserting then
        PControlAeroCentrales.UmbralSuperior(:new.nombre_central);
    elsif updating then
        if :new.nombre_central != :old.nombre_central then
            PControlAeroCentrales.UmbralInferior(:old.nombre_central);
            PControlAeroCentrales.UmbralSuperior(:new.nombre_central);
        end if;
    elsif deleting then
        PControlAeroCentrales.UmbralInferior(:old.nombre_central);
    end if;
end MinMaxAeros;
/

/*
 * PRUEBAS eje 7
 */

