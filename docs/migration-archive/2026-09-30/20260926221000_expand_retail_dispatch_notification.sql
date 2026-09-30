-- Expand the retail dispatch email with shipping details.
update public.notification_templates
set body_template='Your order {{order_reference}} has been dispatched.

Item(s): {{item_summary}}
Shipping service: {{shipping_service}}
Carrier: {{carrier}}
Tracking number: {{tracking_number}}
Tracking link: {{tracking_url}}

Shipping instructions:
{{shipping_instructions}}

You can view the order and tracking details in your TradeFlow customer portal: {{portal_url}}',
    updated_at=now()
where template_code='system_order_dispatched';
