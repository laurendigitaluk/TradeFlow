create or replace function public.platform_extract_manual_ai_json_response(p_response_text text)
returns text
language plpgsql
immutable
set search_path = ''
as $function$
declare
  v_marker integer;
  v_start integer;
  v_i integer;
  v_depth integer := 0;
  v_in_string boolean := false;
  v_escape boolean := false;
  v_char text;
begin
  if p_response_text is null then return null; end if;
  v_marker := strpos(lower(p_response_text), '"schema_version"');
  if v_marker = 0 then return null; end if;

  for v_i in reverse v_marker..1 loop
    if substr(p_response_text, v_i, 1) = '{' then
      v_start := v_i;
      exit;
    end if;
  end loop;
  if v_start is null then return null; end if;

  for v_i in v_start..length(p_response_text) loop
    v_char := substr(p_response_text, v_i, 1);
    if v_in_string then
      if v_escape then
        v_escape := false;
      elsif v_char = chr(92) then
        v_escape := true;
      elsif v_char = '"' then
        v_in_string := false;
      end if;
    else
      if v_char = '"' then
        v_in_string := true;
      elsif v_char = '{' then
        v_depth := v_depth + 1;
      elsif v_char = '}' then
        v_depth := v_depth - 1;
        if v_depth = 0 then
          return substr(p_response_text, v_start, v_i - v_start + 1);
        elsif v_depth < 0 then
          return null;
        end if;
      end if;
    end if;
  end loop;
  return null;
end;
$function$;

revoke all on function public.platform_extract_manual_ai_json_response(text) from public, anon, authenticated;

do $migration$
declare
  v_definition text;
  v_old text := $old$
 v_json_response:=p_response_text;
 if position(chr(96)||chr(96)||chr(96)||'json' in lower(p_response_text))>0 then
  v_json_response:=substring(p_response_text from ('(?is)'||chr(96)||chr(96)||chr(96)||'json[[:space:]]*(.*?)'||chr(96)||chr(96)||chr(96)));
  if nullif(trim(v_json_response),'') is null then
   raise exception 'The response contains a JSON code block but it could not be extracted. Copy the final TradeFlow JSON block again.';
  end if;
 end if;
 begin v_payload:=v_json_response::jsonb;
 exception when others then raise exception 'The AI reply must include the final valid TradeFlow JSON code block. Keep the readable report above it; TradeFlow will extract the JSON block automatically.'; end;
$old$;
  v_new text := $new$
 v_json_response:=public.platform_extract_manual_ai_json_response(p_response_text);
 if nullif(trim(v_json_response),'') is null then
  raise exception 'TradeFlow could not locate the structured JSON object in the response. Paste the complete report with its TradeFlow JSON object included.';
 end if;
 begin v_payload:=v_json_response::jsonb;
 exception when others then
  raise exception 'TradeFlow found the JSON object but it is not valid JSON: %', sqlerrm;
 end;
$new$;
begin
  select pg_get_functiondef('public.platform_owner_submit_manual_ai_research_response(uuid,text)'::regprocedure)
    into v_definition;
  if position(v_old in v_definition) = 0 then
    raise exception 'Expected JSON extraction block not found; refusing to alter the submit function.';
  end if;
  v_definition := replace(v_definition, v_old, v_new);
  execute v_definition;
end;
$migration$;