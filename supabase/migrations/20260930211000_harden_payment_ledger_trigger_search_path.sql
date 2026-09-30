CREATE OR REPLACE FUNCTION public.guard_payment_record_status_entry()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'pg_catalog'
AS $function$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status AND current_user <> 'postgres' THEN
    RAISE EXCEPTION 'Payment status changes must use transition_workflow_entity';
  END IF;
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.guard_ledger_entry_status_entry()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'pg_catalog'
AS $function$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status AND current_user <> 'postgres' THEN
    RAISE EXCEPTION 'Ledger status changes must use transition_workflow_entity';
  END IF;
  RETURN NEW;
END;
$function$;
