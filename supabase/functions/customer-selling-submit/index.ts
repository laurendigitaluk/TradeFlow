import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type","Access-Control-Allow-Methods":"POST, OPTIONS"};
const json=(body:unknown,status=200)=>new Response(JSON.stringify(body),{status,headers:{...cors,"Content-Type":"application/json"}});
Deno.serve(async(req:Request)=>{
 if(req.method==='OPTIONS')return new Response('ok',{headers:cors});
 if(req.method!=='POST')return json({error:'POST required'},405);
 const auth=req.headers.get('Authorization'); if(!auth)return json({error:'Authentication required'},401);
 const token=auth.replace(/^Bearer\s+/i,'');
 const form=await req.formData(); const tenantId=String(form.get('tenant_id')||''); const payloadText=String(form.get('payload')||'');
 if(!tenantId||!payloadText)return json({error:'tenant_id and payload are required'},400);
 let payload:any; try{payload=JSON.parse(payloadText)}catch{return json({error:'Invalid payload'},400)}
 const publishable= Deno.env.get('SUPABASE_ANON_KEY') || Deno.env.get('SUPABASE_PUBLISHABLE_KEY') || '';
 if(!publishable)return json({error:'Supabase publishable key is not configured'},500);
 const userClient=createClient(Deno.env.get('SUPABASE_URL')!,publishable,{global:{headers:{Authorization:`Bearer ${token}`}}});
 const {data:{user},error:userError}=await userClient.auth.getUser(token); if(userError||!user)return json({error:'Authentication required'},401);
 const suppliedDetails=[['Product type',payload.product_type],['Manufacturer',payload.manufacturer],['Model',payload.model],['Package',payload.package_name],['Condition',payload.condition],['Missing items',payload.missing_items],['Legal right to sell',payload.legal_right],['Serial number',payload.serial_number],['Customer notes',payload.notes]].filter(([,v])=>v!==null&&v!==undefined&&String(v).trim()!=='').map(([label,v])=>label+': '+String(v).trim()).join('\\n'); const {data:requestId,error:submitError}=await userClient.rpc('customer_submit_buying_request',{p_tenant_id:tenantId,p_notes:payload.notes||null,p_items:[{category_id:payload.category_id,title:[payload.manufacturer,payload.model,payload.package_name].filter(Boolean).join(' ')||'Selling request',description:suppliedDetails||null,quantity:1,condition:payload.condition||null,fields:[]}]});
 if(submitError||!requestId)return json({error:submitError?.message||'Unable to submit valuation request'},400);
 const admin=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
 const {data:customer}=await admin.from('customers').select('id').eq('tenant_id',tenantId).eq('auth_user_id',user.id).maybeSingle();
 if(!customer)return json({error:'Customer account not found'},403);
 const {data:item}=await admin.from('buying_items').select('id').eq('tenant_id',tenantId).eq('buying_request_id',requestId).order('sort_order',{ascending:true}).limit(1).maybeSingle();
 if(!item)return json({error:'Submitted item could not be found'},500);
 const files=form.getAll('files').filter((x):x is File=>x instanceof File);
 const uploaded=[];
 for(const file of files){
   if(!file.type.startsWith('image/'))return json({error:`${file.name} is not an image`},400);
   if(file.size>10*1024*1024)return json({error:`${file.name} is larger than 10MB`},400);
   const ext=(file.name.split('.').pop()||'jpg').toLowerCase().replace(/[^a-z0-9]/g,'')||'jpg';
   const path=`${tenantId}/customer-buying/${item.id}/${crypto.randomUUID()}.${ext}`;
   const {error:uploadError}=await admin.storage.from('tradeflow-media').upload(path,new Uint8Array(await file.arrayBuffer()),{contentType:file.type,upsert:false});
   if(uploadError)return json({error:uploadError.message,request_id:requestId},500);
   const {data:asset,error:assetError}=await admin.from('media_assets').insert({tenant_id:tenantId,storage_bucket:'tradeflow-media',storage_path:path,original_filename:file.name,mime_type:file.type,byte_size:file.size,asset_kind:'customer_valuation_photo',retention_policy:'customer_valuation'}).select('id').single();
   if(assetError){await admin.storage.from('tradeflow-media').remove([path]);return json({error:assetError.message,request_id:requestId},500)}
   const {error:linkError}=await admin.from('buying_item_media').insert({tenant_id:tenantId,buying_item_id:item.id,media_asset_id:asset.id,sort_order:uploaded.length});
   if(linkError){await admin.from('media_assets').delete().eq('tenant_id',tenantId).eq('id',asset.id);await admin.storage.from('tradeflow-media').remove([path]);return json({error:linkError.message,request_id:requestId},500)}
   uploaded.push(asset.id);
 }
 return json({request_id:requestId,buying_item_id:item.id,uploaded_media_count:uploaded.length});
});