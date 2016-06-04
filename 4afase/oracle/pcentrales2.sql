create or replace package PCentrales2 as

    TYPE TipoAerogenerador IS RECORD
    (
        codigo aerogeneradores.codigo%TYPE,
        marca modelos_aerogeneradores.marca%TYPE,
        modelo modelos_aerogeneradores.nombre%TYPE,
        produccion_max modelos_aerogeneradores.prod_max_horaria%TYPE
    );

    registroAerogenerador TipoAerogenerador;

    procedure CrearCabeceraAerogenerador(p_codigo aerogeneradores.codigo%TYPE);

    procedure MostrarCabeceraAerogenerador(
                                            p_codigo aerogeneradores.codigo%TYPE,
                                            p_fecha varchar2
                                          );
    procedure MostrarDesconexiones(
                                    p_codigo aerogeneradores.codigo%TYPE,
                                    p_fecha varchar2
                                  );

    procedure InformeProduccionAero(
                                        p_codigo aerogeneradores.codigo%TYPE,
                                        p_fecha varchar2
                                   );

    procedure InformeProduccionCentral(
                                        p_nombrecentral centrales.nombre%TYPE,
                                        p_fecha varchar2
                                      );

    procedure InformeProduccionEmpresa(
                                        p_nombre_empresa empresas.nombre%TYPE,
                                        p_fecha varchar2
                                      );

    /* Función principal */
    procedure GenerarInforme(
                                p_tipo_informe number,
                                p_fecha varchar2,
                                p_parametro varchar2
                            );
end PCentrales2;
/

create or replace package body PCentrales2 as

    procedure CrearCabeceraAerogenerador(p_codigo aerogeneradores.codigo%TYPE)
    is
    begin
        select a.codigo, m.marca, m.nombre, m.prod_max_horaria
        into registroAerogenerador
        from aerogeneradores a, modelos_aerogeneradores m
        where a.nombre_modelo = m.nombre
        and a.codigo = p_codigo;
    end CrearCabeceraAerogenerador;

    procedure MostrarCabeceraAerogenerador(
                                            p_codigo aerogeneradores.codigo%TYPE,
                                            p_fecha varchar2
                                          )
    is
    begin
        PCentrales1.ExisteAerogenerador(p_codigo);
        PCentrales1.AerogeneradorEnProduccion(p_codigo, p_fecha);
        CrearCabeceraAerogenerador(p_codigo);
        dbms_output.put_line(
                            'Aerogenerador ' || registroAerogenerador.codigo || ' '
                            || registroAerogenerador.marca || ' '
                            || registroAerogenerador.modelo
                           );

    end MostrarCabeceraAerogenerador;

    procedure MostrarDesconexiones(
                                    p_codigo aerogeneradores.codigo%TYPE,
                                    p_fecha varchar2
                                  )
    is
        v_desc number;
    begin
        v_desc := PCentrales1.AerogeneradorDesconectado(p_codigo, p_fecha);
        case
            when v_desc > 0 then
                dbms_output.put_line('Aerogenerador desconectado todo el día.');
            else
                NULL;
            end case;
    end MostrarDesconexiones;

    procedure InformeProduccionAero(
                                    p_codigo aerogeneradores.codigo%type,
                                    p_fecha varchar2
                                   )
    is
        v_desc number;
    begin
        MostrarCabeceraAerogenerador(p_codigo, p_fecha);
        MostrarDesconexiones(p_codigo, p_fecha);
    end InformeProduccionAero;

    procedure InformeProduccionCentral (
                                        p_nombrecentral centrales.nombre%type,
                                        p_fecha varchar2
                                       )
    is
    begin
        NULL;
    end InformeProduccionCentral;

    procedure InformeProduccionEmpresa (
                                        p_nombre_empresa empresas.nombre%type,
                                        p_fecha varchar2
                                       )
    is
    begin
        NULL;
    end InformeProduccionEmpresa;

    procedure GenerarInforme (
                                p_tipo_informe number,
                                p_fecha varchar2,
                                p_parametro varchar2
                             )
    is
        v_fecha varchar2(8);
    begin

        v_fecha := PCentrales1.ConvertirFecha(p_fecha);

        case
            when p_tipo_informe = 1 then
                InformeProduccionAero(p_parametro, v_fecha);
            when p_tipo_informe = 2 then
                InformeProduccionCentral(p_parametro, v_fecha);
            when p_tipo_informe = 3 then
                InformeProduccionEmpresa (p_parametro, v_fecha);
            else
                raise_application_error(-20005, 'Tipo de informe: ' || to_char(p_tipo_informe) || ' incorrecto');
        end case;

    end GenerarInforme;

end PCentrales2;
/
