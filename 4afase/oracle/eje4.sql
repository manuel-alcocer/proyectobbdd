create or replace package PC4 as

    procedure ComprobarPrediccionesCentral (p_central centrales.nombre%TYPE default null);

    procedure CrearMonitor (p_central centrales.nombre%TYPE default null);

end PC4;
/

create or replace package body PC4 as

    procedure EnviarMail
    is
    begin
        null;
    end EnviarMail;

    procedure CrearMonitor (p_central centrales.nombre%TYPE default null)
    is
    begin
        if p_central is null then
            raise_application_error(-20012, 'ERROR: Hay que poner como parámetro el nombre de una central');
        end if;

    end CrearMonitor;

    procedure ComprobarPrediccionesCentral (p_central centrales.nombre%TYPE default null)
    is
        v_fecha_comprobar date := sysdate + 1;
        v_velocidad_viento predicciones_viento.velocidad%TYPE;

        cursor c_aeros is
            select a.codigo, m.vel_max_viento
                from aerogeneradores a, modelos_aerogeneradores m
                where a.nombre_modelo = m.nombre
                and a.nombre_central = p_central;

        cursor c_velocidades is
            select velocidad
                from predicciones_viento
                where nombre_central = p_central
                and to_char(fechahora, 'DDMMYYYY') = to_char(v_fecha_comprobar, 'DDMMYYYY')
                order by fechahora asc;

        v_velocidad c_velocidades%rowtype;
        v_desconectado number := 0;
    begin
        if p_central is null then
            raise_application_error(-20012, 'ERROR: Hay que poner como parámetro el nombre de una central');
        end if;

        for v_aero in c_aeros loop
            v_desconectado := 0;
            open c_velocidades;
            fetch c_velocidades into v_velocidad;
            while c_velocidades%found and v_desconectado = 0 loop
                if v_velocidad.velocidad > v_aero.vel_max_viento then
                    PC3.InsertarDesconexion (v_aero.codigo, v_fecha_comprobar);
                    EnviarMail;
                    v_desconectado := 1;
                end if;
                fetch c_velocidades into v_velocidad;
            end loop;
            close c_velocidades;
        end loop;
    end ComprobarPrediccionesCentral;

end PC4;
/


exec pc4.comprobarprediccionescentral('JEREZ');
