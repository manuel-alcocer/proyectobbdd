/* Comprobación del ejercicio 1 */



                /************
                 * PRUEBA 1 *
                 ************
                 */

/* Esa select levanta excepcion -20002 si no se introduce fecha */
select PC1.ProduccionEnergia('T2300009') from dual;

                /* SALIDA SELECT */
SQL> select PC1.ProduccionEnergia('T2300009') from dual;
select PC1.ProduccionEnergia('T2300009') from dual
       *
ERROR at line 1:
ORA-20002: Debes introducir el parámetro fecha
ORA-06512: at "FASEDOS.PCENTRALES1", line 92
ORA-06512: at line 1




                /************
                 * PRUEBA 2 *
                 ************
                 */

                /* select correcta */
select PC1.ProduccionEnergia('T6380001','1-1-2015') from dual;

                /* SALIDA SELECT */
SQL> select PC1.ProduccionEnergia('T6380001','1-1-2015') from dual;
                                            72916.25


                /************
                 * PRUEBA 3 *
                 ************
                 */

/* AEROGENERADOR INEXISTENTE EXCEPCIÓN: -20001 */
select PC1.ProduccionEnergia('T6380401','1-1-2015') from dual;

                /* SALIDA SELECT */
SQL> select PC1.ProduccionEnergia('T6380401','1-1-2015') from dual;
select PC1.ProduccionEnergia('T6380401','1-1-2015') from dual
       *
ERROR at line 1:
ORA-20001: No existe aerogenerador con ese código
ORA-06512: at "FASEDOS.PCENTRALES1", line 12
ORA-06512: at "FASEDOS.PCENTRALES1", line 120
ORA-06512: at line 1


                /************
                 * PRUEBA 4 *
                 ************
                 */
insert into desconexiones values ('M9990068', to_date('20-01-2010 0900','DD-MM-YYYY HH24MI'),to_date('25-01-2010 1000','DD-MM-YYYY HH24MI'));

select PC1.ProduccionEnergia('M9990068','22-1-2010') from dual;

                    /* SALIDA SELECT */
SQL> select PC1.ProduccionEnergia('M9990068','22-1-2010') from dual;
select PC1.ProduccionEnergia('M9990068','22-1-2010') from dual
       *
ERROR at line 1:
ORA-20003: Aerogenerador desconectado ese día
ORA-06512: at "FASEDOS.PCENTRALES1", line 104
ORA-06512: at line 1

                    /* SALIDA DE PRODUCCIÓN 0 */
SQL> select PC1.ProduccionEnergia('M9990068','20-1-2010') from dual;
                                                    0

