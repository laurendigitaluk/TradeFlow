-- Fix platform-owner email validation.
-- The previous validation pattern was over-escaped in the PL/pgSQL string,
-- causing valid addresses such as info@scenesource.co.uk to be rejected.
create or replace function public.platform_owner_save_email(p_email text)
returns jsonb
language plpgsql
security definer
set search_path=''
as $function$
declare
  v_email text;
begin
  if not private.is_platform_owner(auth.uid()) then
    raise exception 'Not authorised';
  end if;

  v_email := nullif(lower(trim(p_email)), '');

  if v_email is not null
     and v_email !~ $re$^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$re$
  then
    raise exception 'Please enter a valid TradeFlow email address.';
  end if;

  update public.platform_email_settings
  set sender_email=v_email,
      email_enabled=(v_email is not null),
      sender_verification_status=case when v_email is null then 'not_configured' else 'pending' end,
      sender_verified_at=null,
      updated_at=now(),
      updated_by=auth.uid()
  where id=true;

  return (select to_jsonb(p) from public.platform_email_settings p where id=true);
end
$function$;
