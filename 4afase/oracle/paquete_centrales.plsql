create or replace package PCentrales as

    /****** Funciones y procedimientos Ejercicio 1 ******/
    procedure ExisteAerogenerador (p_codigo_aero varchar2);

    function ConvertirFecha (p_fecha varchar2) return varchar2;

    function ProduccionEnergia (p_codigo_aero aerogeneradores.codigo%TYPE,
                                p_fecha varchar2)
        return number;
            /****** Fin Ejercicio 1 ******/

end PCentrales;
/

create or replace package body PCentrales as

    /****** Funciones y procedimientos Ejercicio 1 ******/
    procedure ExisteAerogenerador (p_codigo_aero varchar2)
    is
        v_cantidad number;
    begin
        select nvl(count(*),0) into v_cantidad
        from aerogeneradores
        where codigo = p_codigo_aero;

        if v_cantidad = 0 then
            raise_application_error(-20001, 'No existe aerogenerador con ese código');
        end if;

    end ExisteAerogenerador;

    function ConvertirFecha (p_fecha varchar2)
    return varchar2
    is
        v_fecha varchar2(8);
        v_formato varchar2(10);
    begin
        case
            when regexp_like (p_fecha, '\d{1,2}/\d{1,2}/\d{2}') then
                v_formato := 'DD/MM/YY';
            when regexp_like (p_fecha, '\d{1,2}/\d{1,2}/\d{4}') then
                v_formato := 'DD/MM/YYYY';
            when regexp_like (p_fecha, '\d{1,2}-\d{1,2}-\d{4}') then
                v_formato := 'DD-MM-YYYY';
            when regexp_like (p_fecha, '\d{1,2}-\d{1,2}-\d{2}') then
                v_formato := 'DD-MM-YY';
            else
                RAISE_APPLICATION_ERROR (-20002, 'Formato de fecha incorrecto');
        end case;

        v_fecha := to_char(to_date(p_fecha, v_formato), 'DDMMYYYY');

        return v_fecha;
    end;

    function ProduccionEnergia (p_codigo_aero aerogeneradores.codigo%TYPE,
                                p_fecha varchar2)
        return number
    is
        v_produccion_dia    number;
        v_num_prods         number;
        v_fecha             varchar2(8);
    begin
        ExisteAerogenerador(p_codigo_aero);

        v_fecha := ConvertirFecha(p_fecha);

        select sum(produccion) into v_produccion_dia
        from producciones_aerogeneradores
        where cod_aerogenerador = p_codigo_aero
        and to_char(fechahora, 'DDMMYYYY') = v_fecha;

        /* Si v_num_prods == 0 => aerogenerador desconectado ese dia */
        /* v_num_prods == 23 => todo el día conectado*/
        if v_num_prods = 0 then
            raise_application_error(-20003, 'Aerogenerador desconectado ese día');
        end if;

        return v_produccion_dia;

    end ProduccionEnergia;
        /****** Fin Ejercicio 1 ******/

end PCentrales;
/
