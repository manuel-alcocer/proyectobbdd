create or replace package PC4 as

    procedure ComprobarPrediccionesCentral (p_central centrales.nombre%TYPE default null);

    procedure CrearMonitor (p_central centrales.nombre%TYPE);
end PC4;
/

create or replace package body PC4 as

    procedure CrearMonitor (p_central centrales.nombre%TYPE)
    is
        v_nombre_job varchar2(16);
    begin
        v_nombre_job := replace(p_central, ' ', '');
        v_nombre_job := substr(v_nombre_job, 1, 16);

        dbms_scheduler.create_job (
            job_name            =>   v_nombre_job,
            job_type            =>  'STORED_PROCEDURE',
            job_action          =>  'PC4.ComprobarPrediccionesCentral',
            start_date          =>  TO_DATE(TO_CHAR(sysdate, 'DD-MM-YYYY HH24:MI'), 'DD-MM-YYYY HH24:MI'),
            /* PARA LA PRUEBA LO PONGO EN UN MINUTO
                repeat_interval     =>  'FREQ=MINUTELY;INTERVAL=1',
            */
            /* LO LANZO TODOS LOS DIAS A LAS 10 DE LA NOCHE */
            repeat_interval     =>  'FREQ=DAILY;BYHOUR=22',
            number_of_arguments => 1,
            enabled             =>  FALSE);

        dbms_scheduler.set_job_argument_value(
            job_name            => v_nombre_job,
            argument_position   => 1,
            argument_value      => p_central);

        dbms_scheduler.enable(v_nombre_job);
    end;

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
                    v_desconectado := 1;
                end if;
                fetch c_velocidades into v_velocidad;
            end loop;
            close c_velocidades;
        end loop;
    end ComprobarPrediccionesCentral;

end PC4;
/
