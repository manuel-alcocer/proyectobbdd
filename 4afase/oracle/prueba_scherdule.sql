BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'update_charges',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN MyJob; END;',
    start_date      => TRUNC(SYSDATE),
    repeat_interval => 'freq=minutely;',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'Update the discharged date in charges.');
END;
/

create or replace procedure MyJob
is
begin
    dbms_output.put_line('hola hola: ');
end MyJob;
/
