SET local check_function_bodies = off;

CREATE SCHEMA "private";

CREATE EXTENSION "pg_cron";

CREATE EXTENSION "pg_net" SCHEMA "public";

CREATE TABLE "public"."acquisition_fulfilments" (
  "id"                   uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"            uuid                     NOT NULL,
  "acquisition_id"       uuid                     NOT NULL,
  "acquisition_item_id"  uuid,
  "fulfilment_reference" text                     NOT NULL,
  "status"               text                     NOT NULL DEFAULT 'awaiting'::text,
  "direction"            text                     NOT NULL DEFAULT 'inbound'::text,
  "carrier"              text,
  "service"              text,
  "tracking_number"      text,
  "tracking_url"         text,
  "recipient_name"       text,
  "recipient_email"      text,
  "shipping_address"     jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "label_url"            text,
  "dispatched_at"        timestamp with time zone,
  "delivered_at"         timestamp with time zone,
  "returned_at"          timestamp with time zone,
  "notes"                text,
  "metadata"             jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"           timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"           timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "acquisition_fulfilments_direction_check" CHECK ((direction = 'inbound'::text)),
  CONSTRAINT "acquisition_fulfilments_pkey" PRIMARY KEY (id),
  CONSTRAINT "acquisition_fulfilments_status_check"
    CHECK ((status = ANY (ARRAY['awaiting'::text, 'label'::text, 'dispatched'::text, 'delivered'::text, 'returned'::text, 'cancelled'::text]))),
  CONSTRAINT "acquisition_fulfilments_tenant_id_fulfilment_reference_key" UNIQUE (tenant_id, fulfilment_reference),
  CONSTRAINT "acquisition_fulfilments_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."acquisition_fulfilments"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."acquisition_fulfilments" FROM "anon";

CREATE TABLE "public"."acquisition_items" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"      uuid                     NOT NULL,
  "acquisition_id" uuid                     NOT NULL,
  "buying_item_id" uuid                     NOT NULL,
  "offer_id"       uuid,
  "status"         text                     NOT NULL DEFAULT 'accepted'::text,
  "agreed_amount"  numeric(12,2)            NOT NULL DEFAULT 0,
  "final_amount"   numeric(12,2),
  "currency"       text                     NOT NULL DEFAULT 'GBP'::text,
  "received_at"    timestamp with time zone,
  "finalised_at"   timestamp with time zone,
  "paid_at"        timestamp with time zone,
  "completed_at"   timestamp with time zone,
  "notes"          text,
  "metadata"       jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"     timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"     timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "acquisition_items_agreed_amount_check" CHECK ((agreed_amount >= (0)::numeric)),
  CONSTRAINT "acquisition_items_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "acquisition_items_final_amount_check" CHECK (((final_amount IS NULL) OR (final_amount >= (0)::numeric))),
  CONSTRAINT "acquisition_items_pkey" PRIMARY KEY (id),
  CONSTRAINT "acquisition_items_status_check"
    CHECK
    ((status = ANY (ARRAY['accepted'::text, 'awaiting_item'::text, 'received'::text, 'inspection'::text, 'finalised'::text, 'paid'::text, 'completed'::text, 'cancelled'::text]))),
  CONSTRAINT "acquisition_items_tenant_id_acquisition_id_buying_item_id_key" UNIQUE (tenant_id, acquisition_id, buying_item_id),
  CONSTRAINT "acquisition_items_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."acquisition_items"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."acquisition_items" FROM "anon";

CREATE TABLE "public"."acquisitions" (
  "id"                              uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"                       uuid                     NOT NULL,
  "acquisition_reference"           text                     NOT NULL,
  "status"                          text                     NOT NULL DEFAULT 'accepted'::text,
  "customer_id"                     uuid                     NOT NULL,
  "source_offer_id"                 uuid,
  "currency"                        text                     NOT NULL DEFAULT 'GBP'::text,
  "agreed_total"                    numeric(12,2)            NOT NULL DEFAULT 0,
  "payment_total"                   numeric(12,2)            NOT NULL DEFAULT 0,
  "accepted_at"                     timestamp with time zone NOT NULL DEFAULT now(),
  "received_at"                     timestamp with time zone,
  "finalised_at"                    timestamp with time zone,
  "paid_at"                         timestamp with time zone,
  "completed_at"                    timestamp with time zone,
  "cancelled_at"                    timestamp with time zone,
  "notes"                           text,
  "metadata"                        jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_by"                      uuid,
  "created_at"                      timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"                      timestamp with time zone NOT NULL DEFAULT now(),
  "shipping_label_url"              text,
  "shipping_carrier"                text,
  "shipping_service"                text,
  "shipping_tracking_number"        text,
  "shipping_instructions"           text,
  "posted_at"                       timestamp with time zone,
  "shipping_label_storage_path"     text,
  "shipping_method"                 text                     NOT NULL DEFAULT 'subscriber_override'::text,
  "shipping_qr_url"                 text,
  "shipping_qr_storage_path"        text,
  "shipping_provider"               text,
  "shipping_provider_connection_id" uuid,
  "shipping_provider_shipment_id"   text,
  "shipping_tracking_url"           text,
  "shipping_status"                 text,
  "shipping_status_updated_at"      timestamp with time zone,
  "shipping_quote_session_id"       uuid,
  "shipping_provider_order_id"      text,
  "shipping_payment_url"            text,
  "shipping_parcel_weight"          numeric,
  "shipping_parcel_length"          numeric,
  "shipping_parcel_width"           numeric,
  "shipping_parcel_height"          numeric,
  "customer_sent_at"                timestamp with time zone,
  "shipping_service_url"            text,
  CONSTRAINT "acquisitions_agreed_total_check" CHECK ((agreed_total >= (0)::numeric)),
  CONSTRAINT "acquisitions_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "acquisitions_payment_total_check" CHECK ((payment_total >= (0)::numeric)),
  CONSTRAINT "acquisitions_pkey" PRIMARY KEY (id),
  CONSTRAINT "acquisitions_shipping_method_check" CHECK ((shipping_method = ANY (ARRAY['automated'::text, 'subscriber_override'::text]))),
  CONSTRAINT "acquisitions_status_check"
    CHECK
    ((status = ANY (ARRAY['accepted'::text, 'awaiting_item'::text, 'received'::text, 'inspection'::text, 'finalised'::text, 'paid'::text, 'completed'::text, 'cancelled'::text]))),
  CONSTRAINT "acquisitions_tenant_id_acquisition_reference_key" UNIQUE (tenant_id, acquisition_reference),
  CONSTRAINT "acquisitions_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."acquisitions"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."acquisitions" FROM "anon";

CREATE TABLE "public"."buying_item_field_values" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"      uuid                     NOT NULL,
  "buying_item_id" uuid                     NOT NULL,
  "field_id"       uuid                     NOT NULL,
  "value_text"     text,
  "value_number"   numeric,
  "value_boolean"  boolean,
  "value_date"     date,
  "value_json"     jsonb,
  "created_at"     timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"     timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "buying_item_field_values_check" CHECK ((num_nonnulls(value_text, value_number, value_boolean, value_date, value_json) = 1)),
  CONSTRAINT "buying_item_field_values_pkey" PRIMARY KEY (id),
  CONSTRAINT "buying_item_field_values_tenant_id_buying_item_id_field_id_key" UNIQUE (tenant_id, buying_item_id, field_id),
  CONSTRAINT "buying_item_field_values_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."buying_item_field_values"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."buying_item_field_values" FROM "anon";

CREATE TABLE "public"."buying_item_inspections" (
  "id"              uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"       uuid                     NOT NULL,
  "buying_item_id"  uuid                     NOT NULL,
  "inspection_type" text                     NOT NULL DEFAULT 'condition'::text,
  "outcome"         text                     NOT NULL,
  "condition_grade" text,
  "notes"           text,
  "passed"          boolean                  NOT NULL DEFAULT false,
  "inspected_by"    uuid,
  "inspected_at"    timestamp with time zone NOT NULL DEFAULT now(),
  "metadata"        jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "buying_item_inspections_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."buying_item_inspections"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."buying_item_media" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"      uuid                     NOT NULL,
  "buying_item_id" uuid                     NOT NULL,
  "media_asset_id" uuid                     NOT NULL,
  "sort_order"     integer                  NOT NULL DEFAULT 0,
  "created_at"     timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "buying_item_media_buying_item_id_media_asset_id_key" UNIQUE (buying_item_id, media_asset_id),
  CONSTRAINT "buying_item_media_pkey" PRIMARY KEY (id),
  CONSTRAINT "buying_item_media_sort_order_check" CHECK ((sort_order >= 0))
);

ALTER TABLE "public"."buying_item_media"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."buying_item_media" FROM "anon";

CREATE TABLE "public"."buying_item_return_shipping" (
  "id"                          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"                   uuid                     NOT NULL,
  "buying_item_id"              uuid                     NOT NULL,
  "return_reason"               text,
  "shipping_method"             text                     NOT NULL DEFAULT 'subscriber_override'::text,
  "shipping_provider"           text,
  "shipping_service_url"        text,
  "shipping_carrier"            text,
  "shipping_service"            text,
  "shipping_tracking_number"    text,
  "shipping_tracking_url"       text,
  "shipping_label_url"          text,
  "shipping_label_storage_path" text,
  "shipping_qr_url"             text,
  "shipping_qr_storage_path"    text,
  "shipping_instructions"       text,
  "shipping_status"             text                     NOT NULL DEFAULT 'return_required'::text,
  "shipping_status_updated_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "shipped_at"                  timestamp with time zone,
  "created_at"                  timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"                  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "buying_item_return_shipping_buying_item_id_key" UNIQUE (buying_item_id),
  CONSTRAINT "buying_item_return_shipping_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."buying_item_return_shipping"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."buying_item_shipping" (
  "id"                              uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"                       uuid                     NOT NULL,
  "buying_item_id"                  uuid                     NOT NULL,
  "shipping_method"                 text                     NOT NULL DEFAULT 'subscriber_override'::text,
  "shipping_provider"               text,
  "shipping_provider_connection_id" uuid,
  "shipping_provider_order_id"      text,
  "shipping_status"                 text,
  "shipping_status_updated_at"      timestamp with time zone,
  "shipping_tracking_url"           text,
  "shipping_payment_url"            text,
  "shipping_label_url"              text,
  "shipping_label_storage_path"     text,
  "shipping_qr_url"                 text,
  "shipping_qr_storage_path"        text,
  "shipping_carrier"                text,
  "shipping_service"                text,
  "shipping_tracking_number"        text,
  "shipping_instructions"           text,
  "shipping_service_url"            text,
  "posted_at"                       timestamp with time zone,
  "customer_sent_at"                timestamp with time zone,
  "created_at"                      timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"                      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "buying_item_shipping_buying_item_id_key" UNIQUE (buying_item_id),
  CONSTRAINT "buying_item_shipping_pkey" PRIMARY KEY (id),
  CONSTRAINT "buying_item_shipping_shipping_method_check" CHECK ((shipping_method = ANY (ARRAY['subscriber_override'::text, 'automated'::text])))
);

ALTER TABLE "public"."buying_item_shipping"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."buying_items" (
  "id"                        uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"                 uuid                     NOT NULL,
  "buying_request_id"         uuid                     NOT NULL,
  "category_id"               uuid                     NOT NULL,
  "item_reference"            text                     NOT NULL,
  "status"                    text                     NOT NULL DEFAULT 'draft'::text,
  "title"                     text,
  "description"               text,
  "quantity"                  integer                  NOT NULL DEFAULT 1,
  "sort_order"                integer                  NOT NULL DEFAULT 0,
  "created_at"                timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"                timestamp with time zone NOT NULL DEFAULT now(),
  "branch_id"                 uuid,
  "buying_product_id"         uuid,
  "item_condition"            text,
  "purchase_stage"            text                     NOT NULL DEFAULT 'none'::text,
  "purchase_stage_updated_at" timestamp with time zone,
  "item_received_at"          timestamp with time zone,
  "inspection_completed_at"   timestamp with time zone,
  "final_offer_accepted_at"   timestamp with time zone,
  "purchased_at"              timestamp with time zone,
  CONSTRAINT "buying_items_item_condition_ck"
    CHECK (((item_condition IS NULL) OR (item_condition = ANY (ARRAY['sealed'::text, 'opened_never_used'::text, 'excellent'::text, 'good'::text, 'poor'::text])))),
  CONSTRAINT "buying_items_pkey" PRIMARY KEY (id),
  CONSTRAINT "buying_items_purchase_stage_check"
    CHECK
    ((purchase_stage = ANY (ARRAY['none'::text, 'offer_ready'::text, 'offer_refused'::text, 'awaiting_item'::text, 'shipping'::text, 'received'::text, 'inspection'::text,
    'testing'::text,
    'repair'::text,
    'return_pending'::text,
    'final_offer_required'::text, 'final_offer_sent'::text, 'final_offer_accepted'::text, 'final_offer_refused'::text, 'payment_pending'::text, 'purchased'::text]))),
  CONSTRAINT "buying_items_quantity_check" CHECK ((quantity > 0)),
  CONSTRAINT "buying_items_status_check"
    CHECK ((status = ANY (ARRAY['draft'::text, 'submitted'::text, 'under_review'::text, 'valued'::text, 'offer_ready'::text, 'closed'::text]))),
  CONSTRAINT "buying_items_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "buying_items_tenant_id_item_reference_key" UNIQUE (tenant_id, item_reference)
);

ALTER TABLE "public"."buying_items"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."buying_items" FROM "anon";

CREATE TABLE "public"."buying_requests" (
  "id"                uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"         uuid                     NOT NULL,
  "customer_id"       uuid                     NOT NULL,
  "request_reference" text                     NOT NULL,
  "status"            text                     NOT NULL DEFAULT 'draft'::text,
  "source"            text                     NOT NULL DEFAULT 'customer_portal'::text,
  "notes"             text,
  "submitted_at"      timestamp with time zone,
  "closed_at"         timestamp with time zone,
  "created_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"        timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "buying_requests_pkey" PRIMARY KEY (id),
  CONSTRAINT "buying_requests_source_check" CHECK ((source = ANY (ARRAY['customer_portal'::text, 'staff'::text, 'import'::text, 'api'::text]))),
  CONSTRAINT "buying_requests_status_check"
    CHECK ((status = ANY (ARRAY['draft'::text, 'submitted'::text, 'under_review'::text, 'valued'::text, 'offer_ready'::text, 'closed'::text]))),
  CONSTRAINT "buying_requests_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "buying_requests_tenant_id_request_reference_key" UNIQUE (tenant_id, request_reference)
);

ALTER TABLE "public"."buying_requests"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."buying_requests" FROM "anon";

CREATE TABLE "public"."catalogue_master_branches" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "category_id" uuid                     NOT NULL,
  "name"        text                     NOT NULL,
  "slug"        text                     NOT NULL,
  "active"      boolean                  NOT NULL DEFAULT true,
  "sort_order"  integer                  NOT NULL DEFAULT 0,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "catalogue_master_branches_category_id_name_key" UNIQUE (category_id, name),
  CONSTRAINT "catalogue_master_branches_category_id_slug_key" UNIQUE (category_id, slug),
  CONSTRAINT "catalogue_master_branches_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."catalogue_master_branches"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."catalogue_master_branches" FROM "anon", "authenticated";

CREATE TABLE "public"."catalogue_master_categories" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "name"       text                     NOT NULL,
  "slug"       text                     NOT NULL,
  "active"     boolean                  NOT NULL DEFAULT true,
  "sort_order" integer                  NOT NULL DEFAULT 0,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "catalogue_master_categories_pkey" PRIMARY KEY (id),
  CONSTRAINT "catalogue_master_categories_slug_key" UNIQUE (slug)
);

ALTER TABLE "public"."catalogue_master_categories"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."catalogue_master_categories" FROM "anon", "authenticated";

CREATE TABLE "public"."catalogue_master_manufacturers" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "name"       text                     NOT NULL,
  "active"     boolean                  NOT NULL DEFAULT true,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "catalogue_master_manufacturers_name_key" UNIQUE (name),
  CONSTRAINT "catalogue_master_manufacturers_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."catalogue_master_manufacturers"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."catalogue_master_manufacturers" FROM "anon", "authenticated";

CREATE TABLE "public"."catalogue_master_product_identifiers" (
  "id"                  uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "product_id"          uuid                     NOT NULL,
  "identifier_type"     text                     NOT NULL,
  "identifier_value"    text                     NOT NULL,
  "normalized_value"    text                     NOT NULL,
  "source_name"         text,
  "source_url"          text,
  "verification_status" text                     NOT NULL DEFAULT 'imported'::text,
  "verified_at"         timestamp with time zone,
  "notes"               text,
  "created_at"          timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"          timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "catalogue_master_product_iden_product_id_identifier_type_no_key" UNIQUE (product_id, identifier_type, normalized_value),
  CONSTRAINT "catalogue_master_product_identifiers_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."catalogue_master_product_identifiers"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."catalogue_master_product_identifiers" FROM "anon", "authenticated";

CREATE TABLE "public"."catalogue_master_products" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "category_id"        uuid                     NOT NULL,
  "branch_id"          uuid,
  "manufacturer_id"    uuid                     NOT NULL,
  "model"              text                     NOT NULL,
  "package_key"        text                     NOT NULL,
  "package_name"       text                     NOT NULL,
  "catalogue_category" text,
  "main_category"      text,
  "product_type"       text,
  "notes"              text,
  "active"             boolean                  NOT NULL DEFAULT true,
  "customer_visible"   boolean                  NOT NULL DEFAULT true,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "catalogue_master_products_category_id_branch_id_manufacture_key" UNIQUE (category_id, branch_id, manufacturer_id, model, package_key),
  CONSTRAINT "catalogue_master_products_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."catalogue_master_products"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."catalogue_master_products" FROM "anon", "authenticated";

CREATE TABLE "public"."categories" (
  "id"              uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"       uuid                     NOT NULL,
  "name"            text                     NOT NULL,
  "slug"            text                     NOT NULL,
  "description"     text,
  "active"          boolean                  NOT NULL DEFAULT true,
  "buying_enabled"  boolean                  NOT NULL DEFAULT true,
  "selling_enabled" boolean                  NOT NULL DEFAULT true,
  "sort_order"      integer                  NOT NULL DEFAULT 0,
  "created_at"      timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "categories_pkey" PRIMARY KEY (id),
  CONSTRAINT "categories_sort_order_check" CHECK ((sort_order >= 0)),
  CONSTRAINT "categories_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."categories"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."categories" FROM "anon";

CREATE TABLE "public"."category_branches" (
  "id"                        uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"                 uuid                     NOT NULL,
  "category_id"               uuid                     NOT NULL,
  "name"                      text                     NOT NULL,
  "slug"                      text                     NOT NULL,
  "description"               text,
  "active"                    boolean                  NOT NULL DEFAULT true,
  "buying_enabled"            boolean                  NOT NULL DEFAULT true,
  "selling_enabled"           boolean                  NOT NULL DEFAULT true,
  "sort_order"                integer                  NOT NULL DEFAULT 0,
  "created_at"                timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"                timestamp with time zone NOT NULL DEFAULT now(),
  "default_buying_percentage" numeric(6,2),
  CONSTRAINT "category_branches_default_buying_percentage_ck"
    CHECK (((default_buying_percentage IS NULL) OR ((default_buying_percentage >= (0)::numeric) AND (default_buying_percentage <= (100)::numeric)))),
  CONSTRAINT "category_branches_pkey" PRIMARY KEY (id),
  CONSTRAINT "category_branches_sort_order_check" CHECK ((sort_order >= 0)),
  CONSTRAINT "category_branches_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."category_branches"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."category_field_options" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"   uuid                     NOT NULL,
  "category_id" uuid                     NOT NULL,
  "field_id"    uuid                     NOT NULL,
  "value"       text                     NOT NULL,
  "label"       text                     NOT NULL,
  "sort_order"  integer                  NOT NULL DEFAULT 0,
  "active"      boolean                  NOT NULL DEFAULT true,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "category_field_options_pkey" PRIMARY KEY (id),
  CONSTRAINT "category_field_options_sort_order_check" CHECK ((sort_order >= 0)),
  CONSTRAINT "category_field_options_tenant_id_field_id_value_key" UNIQUE (tenant_id, field_id, VALUE),
  CONSTRAINT "category_field_options_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."category_field_options"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."category_field_options" FROM "anon";

CREATE TABLE "public"."category_fields" (
  "id"                   uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"            uuid                     NOT NULL,
  "category_id"          uuid                     NOT NULL,
  "field_key"            text                     NOT NULL,
  "label"                text                     NOT NULL,
  "field_type"           text                     NOT NULL,
  "required_for_buying"  boolean                  NOT NULL DEFAULT false,
  "required_for_selling" boolean                  NOT NULL DEFAULT false,
  "customer_visible"     boolean                  NOT NULL DEFAULT true,
  "staff_visible"        boolean                  NOT NULL DEFAULT true,
  "valuation_relevant"   boolean                  NOT NULL DEFAULT false,
  "sort_order"           integer                  NOT NULL DEFAULT 0,
  "validation_config"    jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"           timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"           timestamp with time zone NOT NULL DEFAULT now(),
  "branch_id"            uuid,
  "enabled_for_buying"   boolean                  NOT NULL DEFAULT true,
  "enabled_for_selling"  boolean                  NOT NULL DEFAULT true,
  CONSTRAINT "category_fields_field_type_check"
    CHECK
    ((field_type = ANY (ARRAY['text'::text, 'textarea'::text, 'number'::text, 'currency'::text, 'boolean'::text, 'date'::text, 'select'::text, 'multiselect'::text, 'email'::text,
    'phone'::text, 'url'::text]))),
  CONSTRAINT "category_fields_pkey" PRIMARY KEY (id),
  CONSTRAINT "category_fields_sort_order_check" CHECK ((sort_order >= 0)),
  CONSTRAINT "category_fields_tenant_id_category_id_field_key_key" UNIQUE (tenant_id, category_id, field_key),
  CONSTRAINT "category_fields_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."category_fields"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."category_fields" FROM "anon";

CREATE TABLE "public"."customer_addresses" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"      uuid                     NOT NULL,
  "customer_id"    uuid                     NOT NULL,
  "address_type"   text                     NOT NULL DEFAULT 'primary'::text,
  "recipient_name" text,
  "company_name"   text,
  "line1"          text                     NOT NULL,
  "line2"          text,
  "city"           text                     NOT NULL,
  "county"         text,
  "postcode"       text                     NOT NULL,
  "country_code"   text                     NOT NULL DEFAULT 'GB'::text,
  "is_default"     boolean                  NOT NULL DEFAULT false,
  "created_at"     timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"     timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "customer_addresses_address_type_check" CHECK ((address_type = ANY (ARRAY['primary'::text, 'billing'::text, 'shipping'::text, 'other'::text]))),
  CONSTRAINT "customer_addresses_pkey" PRIMARY KEY (id),
  CONSTRAINT "customer_addresses_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."customer_addresses"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."customer_addresses" FROM "anon";

CREATE TABLE "public"."customer_bank_details" (
  "id"                  uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"           uuid                     NOT NULL,
  "customer_id"         uuid                     NOT NULL,
  "account_holder_name" text                     NOT NULL,
  "sort_code"           text                     NOT NULL,
  "account_number"      text                     NOT NULL,
  "bank_name"           text,
  "created_at"          timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"          timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "customer_bank_details_pkey" PRIMARY KEY (id),
  CONSTRAINT "customer_bank_details_tenant_id_customer_id_key" UNIQUE (tenant_id, customer_id)
);

ALTER TABLE "public"."customer_bank_details"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."customer_bank_details" FROM "anon", "authenticated";

CREATE TABLE "public"."customer_credit_accounts" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"   uuid                     NOT NULL,
  "customer_id" uuid                     NOT NULL,
  "balance"     numeric                  NOT NULL DEFAULT 0,
  "currency"    text                     NOT NULL DEFAULT 'GBP'::text,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "customer_credit_accounts_balance_check" CHECK ((balance >= (0)::numeric)),
  CONSTRAINT "customer_credit_accounts_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "customer_credit_accounts_pkey" PRIMARY KEY (id),
  CONSTRAINT "customer_credit_accounts_tenant_id_customer_id_key" UNIQUE (tenant_id, customer_id)
);

ALTER TABLE "public"."customer_credit_accounts"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."customer_credit_holds" (
  "id"              uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"       uuid                     NOT NULL,
  "customer_id"     uuid                     NOT NULL,
  "retail_order_id" uuid                     NOT NULL,
  "amount"          numeric(12,2)            NOT NULL,
  "status"          text                     NOT NULL DEFAULT 'active'::text,
  "created_at"      timestamp with time zone NOT NULL DEFAULT now(),
  "applied_at"      timestamp with time zone,
  "released_at"     timestamp with time zone,
  CONSTRAINT "customer_credit_holds_amount_check" CHECK ((amount > (0)::numeric)),
  CONSTRAINT "customer_credit_holds_pkey" PRIMARY KEY (id),
  CONSTRAINT "customer_credit_holds_retail_order_id_key" UNIQUE (retail_order_id),
  CONSTRAINT "customer_credit_holds_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'applied'::text, 'released'::text])))
);

ALTER TABLE "public"."customer_credit_holds"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."customer_credit_holds" FROM "anon", "authenticated";

CREATE TABLE "public"."customers" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"          uuid                     NOT NULL,
  "auth_user_id"       uuid,
  "customer_reference" text                     NOT NULL,
  "first_name"         text                     NOT NULL,
  "last_name"          text,
  "email"              text,
  "phone"              text,
  "status"             text                     NOT NULL DEFAULT 'active'::text,
  "notes"              text,
  "metadata"           jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "customers_pkey" PRIMARY KEY (id),
  CONSTRAINT "customers_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'inactive'::text, 'archived'::text]))),
  CONSTRAINT "customers_tenant_id_customer_reference_key" UNIQUE (tenant_id, customer_reference),
  CONSTRAINT "customers_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."customers"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."customers" FROM "anon";

CREATE TABLE "public"."domain_tld_catalog" (
  "id"                         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tld"                        text                     NOT NULL,
  "active"                     boolean                  NOT NULL DEFAULT true,
  "registration_price"         numeric(12,2),
  "renewal_price"              numeric(12,2),
  "transfer_price"             numeric(12,2),
  "currency"                   text                     NOT NULL DEFAULT 'GBP'::text,
  "default_registration_years" integer                  NOT NULL DEFAULT 1,
  "max_registration_years"     integer                  NOT NULL DEFAULT 10,
  "provider_code"              text,
  "provider_product_code"      text,
  "metadata"                   jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"                 timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"                 timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "domain_tld_catalog_currency_chk" CHECK (((currency = upper(TRIM(BOTH FROM currency))) AND (length(currency) = 3))),
  CONSTRAINT "domain_tld_catalog_pkey" PRIMARY KEY (id),
  CONSTRAINT "domain_tld_catalog_prices_chk"
    CHECK
    (((COALESCE(registration_price, (0)::numeric) >= (0)::numeric) AND (COALESCE(renewal_price, (0)::numeric) >= (0)::numeric) AND (COALESCE(transfer_price, (0)::numeric) >=
    (0)::numeric))),
  CONSTRAINT "domain_tld_catalog_tld_chk" CHECK (((tld = lower(TRIM(BOTH FROM tld))) AND (tld ~~ '.%'::text) AND ((length(tld) >= 2) AND (length(tld) <= 63)))),
  CONSTRAINT "domain_tld_catalog_tld_unique" UNIQUE (tld),
  CONSTRAINT "domain_tld_catalog_years_chk"
    CHECK ((((default_registration_years >= 1) AND (default_registration_years <= max_registration_years)) AND ((max_registration_years >= 1) AND (max_registration_years <= 99))))
);

ALTER TABLE "public"."domain_tld_catalog"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."email_templates" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"        uuid,
  "event_code"       text                     NOT NULL,
  "template_code"    text                     NOT NULL,
  "subject_template" text                     NOT NULL,
  "body_template"    text                     NOT NULL,
  "active"           boolean                  NOT NULL DEFAULT true,
  "is_system"        boolean                  NOT NULL DEFAULT false,
  "created_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"       timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "email_templates_event_code_check"
    CHECK
    ((event_code = ANY (ARRAY['offer_sent'::text, 'offer_accepted'::text, 'offer_refused'::text, 'item_received'::text, 'item_dispatched'::text, 'payment_sent'::text,
    'order_confirmation'::text, 'order_dispatched'::text, 'return_received'::text, 'refund_issued'::text]))),
  CONSTRAINT "email_templates_pkey" PRIMARY KEY (id),
  CONSTRAINT "email_templates_tenant_id_event_code_key" UNIQUE (tenant_id, event_code),
  CONSTRAINT "email_templates_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."email_templates"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."email_templates" FROM "anon";

CREATE TABLE "public"."fulfilment_events" (
  "id"                uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"         uuid                     NOT NULL,
  "fulfilment_id"     uuid                     NOT NULL,
  "parcel_id"         uuid,
  "event_type"        text                     NOT NULL,
  "status"            text,
  "event_at"          timestamp with time zone NOT NULL DEFAULT now(),
  "location"          text,
  "description"       text,
  "provider_event_id" text,
  "metadata"          jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"        timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "fulfilment_events_pkey" PRIMARY KEY (id),
  CONSTRAINT "fulfilment_events_tenant_id_provider_event_id_key" UNIQUE (tenant_id, provider_event_id)
);

ALTER TABLE "public"."fulfilment_events"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."fulfilment_events" FROM "anon";

CREATE TABLE "public"."fulfilment_parcels" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"        uuid                     NOT NULL,
  "fulfilment_id"    uuid                     NOT NULL,
  "parcel_reference" text                     NOT NULL,
  "status"           text                     NOT NULL DEFAULT 'awaiting'::text,
  "carrier"          text,
  "service"          text,
  "tracking_number"  text,
  "tracking_url"     text,
  "weight"           numeric(12,3),
  "length"           numeric(12,3),
  "width"            numeric(12,3),
  "height"           numeric(12,3),
  "label_url"        text,
  "dispatched_at"    timestamp with time zone,
  "delivered_at"     timestamp with time zone,
  "returned_at"      timestamp with time zone,
  "notes"            text,
  "metadata"         jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"       timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "fulfilment_parcels_pkey" PRIMARY KEY (id),
  CONSTRAINT "fulfilment_parcels_status_check"
    CHECK ((status = ANY (ARRAY['awaiting'::text, 'label'::text, 'dispatched'::text, 'delivered'::text, 'returned'::text, 'cancelled'::text]))),
  CONSTRAINT "fulfilment_parcels_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "fulfilment_parcels_tenant_id_parcel_reference_key" UNIQUE (tenant_id, parcel_reference)
);

ALTER TABLE "public"."fulfilment_parcels"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."fulfilment_parcels" FROM "anon";

CREATE TABLE "public"."fulfilments" (
  "id"                    uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"             uuid                     NOT NULL,
  "retail_order_id"       uuid                     NOT NULL,
  "fulfilment_reference"  text                     NOT NULL,
  "status"                text                     NOT NULL DEFAULT 'awaiting'::text,
  "carrier"               text,
  "service"               text,
  "tracking_number"       text,
  "tracking_url"          text,
  "recipient_name"        text,
  "recipient_email"       text,
  "shipping_address"      jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "label_url"             text,
  "dispatched_at"         timestamp with time zone,
  "delivered_at"          timestamp with time zone,
  "returned_at"           timestamp with time zone,
  "notes"                 text,
  "metadata"              jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"            timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"            timestamp with time zone NOT NULL DEFAULT now(),
  "shipping_method"       text,
  "shipping_provider"     text,
  "shipping_service_url"  text,
  "shipping_instructions" text,
  "label_storage_path"    text,
  "qr_url"                text,
  "qr_storage_path"       text,
  "customer_sent_at"      timestamp with time zone,
  CONSTRAINT "fulfilments_pkey" PRIMARY KEY (id),
  CONSTRAINT "fulfilments_status_check" CHECK ((status = ANY (ARRAY['awaiting'::text, 'label'::text, 'dispatched'::text, 'delivered'::text, 'returned'::text, 'cancelled'::text]))),
  CONSTRAINT "fulfilments_tenant_id_fulfilment_reference_key" UNIQUE (tenant_id, fulfilment_reference),
  CONSTRAINT "fulfilments_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."fulfilments"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."fulfilments" FROM "anon";

CREATE TABLE "public"."inventory_asset_media" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"          uuid                     NOT NULL,
  "inventory_asset_id" uuid                     NOT NULL,
  "media_asset_id"     uuid                     NOT NULL,
  "sort_order"         integer                  NOT NULL DEFAULT 0,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "inventory_asset_media_pkey" PRIMARY KEY (id),
  CONSTRAINT "inventory_asset_media_tenant_id_inventory_asset_id_media_as_key" UNIQUE (tenant_id, inventory_asset_id, media_asset_id)
);

ALTER TABLE "public"."inventory_asset_media"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."inventory_assets" (
  "id"                   uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"            uuid                     NOT NULL,
  "acquisition_item_id"  uuid,
  "buying_item_id"       uuid,
  "category_id"          uuid                     NOT NULL,
  "asset_reference"      text                     NOT NULL,
  "status"               text                     NOT NULL DEFAULT 'received'::text,
  "title"                text,
  "description"          text,
  "condition_grade"      text,
  "customer_condition"   text,
  "quantity"             integer                  NOT NULL DEFAULT 1,
  "serial_number"        text,
  "purchase_price"       numeric(12,2),
  "current_value"        numeric(12,2),
  "currency"             text                     NOT NULL DEFAULT 'GBP'::text,
  "location"             text,
  "notes"                text,
  "dynamic_values"       jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "metadata"             jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "received_at"          timestamp with time zone,
  "ready_for_sale_at"    timestamp with time zone,
  "sold_at"              timestamp with time zone,
  "created_by"           uuid,
  "created_at"           timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"           timestamp with time zone NOT NULL DEFAULT now(),
  "branch_id"            uuid,
  "catalogue_product_id" uuid,
  CONSTRAINT "inventory_assets_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "inventory_assets_current_value_check" CHECK (((current_value IS NULL) OR (current_value >= (0)::numeric))),
  CONSTRAINT "inventory_assets_pkey" PRIMARY KEY (id),
  CONSTRAINT "inventory_assets_purchase_price_check" CHECK (((purchase_price IS NULL) OR (purchase_price >= (0)::numeric))),
  CONSTRAINT "inventory_assets_quantity_check" CHECK ((quantity > 0)),
  CONSTRAINT "inventory_assets_status_check"
    CHECK
    ((status = ANY (ARRAY['received'::text, 'inspection'::text, 'testing'::text, 'repair'::text, 'ready_for_sale'::text, 'listed'::text, 'reserved'::text, 'sold'::text,
    'returned'::text, 'written_off'::text, 'archived'::text]))),
  CONSTRAINT "inventory_assets_tenant_id_asset_reference_key" UNIQUE (tenant_id, asset_reference),
  CONSTRAINT "inventory_assets_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."inventory_assets"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."inventory_assets" FROM "anon";

CREATE TABLE "public"."inventory_costs" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"          uuid                     NOT NULL,
  "inventory_asset_id" uuid                     NOT NULL,
  "cost_type"          text                     NOT NULL,
  "amount"             numeric(12,2)            NOT NULL,
  "currency"           text                     NOT NULL DEFAULT 'GBP'::text,
  "description"        text,
  "incurred_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "created_by"         uuid,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "inventory_costs_amount_check" CHECK ((amount >= (0)::numeric)),
  CONSTRAINT "inventory_costs_cost_type_check"
    CHECK ((cost_type = ANY (ARRAY['purchase'::text, 'shipping_in'::text, 'repair'::text, 'testing'::text, 'refurbishment'::text, 'fees'::text, 'other'::text]))),
  CONSTRAINT "inventory_costs_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "inventory_costs_pkey" PRIMARY KEY (id),
  CONSTRAINT "inventory_costs_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."inventory_costs"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."inventory_costs" FROM "anon";

CREATE TABLE "public"."inventory_inspections" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"          uuid                     NOT NULL,
  "inventory_asset_id" uuid                     NOT NULL,
  "inspection_type"    text                     NOT NULL,
  "outcome"            text,
  "condition_grade"    text,
  "notes"              text,
  "passed"             boolean,
  "inspected_by"       uuid,
  "inspected_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "metadata"           jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "inventory_inspections_inspection_type_check"
    CHECK ((inspection_type = ANY (ARRAY['receipt'::text, 'condition'::text, 'testing'::text, 'repair'::text, 'final'::text]))),
  CONSTRAINT "inventory_inspections_pkey" PRIMARY KEY (id),
  CONSTRAINT "inventory_inspections_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."inventory_inspections"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."inventory_inspections" FROM "anon";

CREATE TABLE "public"."inventory_movements" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"          uuid                     NOT NULL,
  "inventory_asset_id" uuid                     NOT NULL,
  "movement_type"      text                     NOT NULL,
  "from_status"        text,
  "to_status"          text,
  "from_location"      text,
  "to_location"        text,
  "quantity"           integer                  NOT NULL DEFAULT 1,
  "notes"              text,
  "actor_user_id"      uuid,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "inventory_movements_movement_type_check"
    CHECK
    ((movement_type = ANY (ARRAY['received'::text, 'location_change'::text, 'status_change'::text, 'adjustment'::text, 'sold'::text, 'returned'::text, 'written_off'::text]))),
  CONSTRAINT "inventory_movements_pkey" PRIMARY KEY (id),
  CONSTRAINT "inventory_movements_quantity_check" CHECK ((quantity > 0)),
  CONSTRAINT "inventory_movements_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."inventory_movements"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."inventory_movements" FROM "anon";

CREATE TABLE "public"."ledger_entries" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"          uuid                     NOT NULL,
  "entry_reference"    text                     NOT NULL,
  "entry_type"         text                     NOT NULL,
  "direction"          text                     NOT NULL,
  "status"             text                     NOT NULL DEFAULT 'posted'::text,
  "amount"             numeric(12,2)            NOT NULL,
  "currency"           text                     NOT NULL DEFAULT 'GBP'::text,
  "customer_id"        uuid,
  "retail_order_id"    uuid,
  "acquisition_id"     uuid,
  "return_id"          uuid,
  "inventory_asset_id" uuid,
  "description"        text,
  "reference_type"     text,
  "reference_id"       uuid,
  "metadata"           jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "occurred_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "posted_at"          timestamp with time zone,
  "created_by"         uuid,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "ledger_entries_amount_check" CHECK ((amount >= (0)::numeric)),
  CONSTRAINT "ledger_entries_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "ledger_entries_direction_check" CHECK ((direction = ANY (ARRAY['debit'::text, 'credit'::text]))),
  CONSTRAINT "ledger_entries_entry_type_check"
    CHECK ((entry_type = ANY (ARRAY['sale'::text, 'purchase'::text, 'refund'::text, 'expense'::text, 'fee'::text, 'adjustment'::text, 'payment'::text, 'other'::text]))),
  CONSTRAINT "ledger_entries_pkey" PRIMARY KEY (id),
  CONSTRAINT "ledger_entries_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'posted'::text, 'voided'::text, 'reversed'::text]))),
  CONSTRAINT "ledger_entries_tenant_id_entry_reference_key" UNIQUE (tenant_id, entry_reference),
  CONSTRAINT "ledger_entries_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."ledger_entries"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."ledger_entries" FROM "anon";

CREATE TABLE "public"."listing_events" (
  "id"            uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"     uuid                     NOT NULL,
  "listing_id"    uuid                     NOT NULL,
  "event_type"    text                     NOT NULL,
  "from_status"   text,
  "to_status"     text,
  "old_price"     numeric(12,2),
  "new_price"     numeric(12,2),
  "notes"         text,
  "actor_user_id" uuid,
  "created_at"    timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "listing_events_event_type_check"
    CHECK
    ((event_type = ANY (ARRAY['created'::text, 'ready'::text, 'published'::text, 'reserved'::text, 'sold'::text, 'delisted'::text, 'cancelled'::text, 'price_changed'::text,
    'edited'::text]))),
  CONSTRAINT "listing_events_pkey" PRIMARY KEY (id),
  CONSTRAINT "listing_events_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."listing_events"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."listing_events" FROM "anon";

CREATE TABLE "public"."listing_media" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"      uuid                     NOT NULL,
  "listing_id"     uuid                     NOT NULL,
  "media_asset_id" uuid                     NOT NULL,
  "sort_order"     integer                  NOT NULL DEFAULT 0,
  "created_at"     timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "listing_media_pkey" PRIMARY KEY (id),
  CONSTRAINT "listing_media_tenant_id_listing_id_media_asset_id_key" UNIQUE (tenant_id, listing_id, media_asset_id)
);

ALTER TABLE "public"."listing_media"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."listings" (
  "id"                uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"         uuid                     NOT NULL,
  "asset_id"          uuid                     NOT NULL,
  "channel_id"        uuid                     NOT NULL,
  "category_id"       uuid                     NOT NULL,
  "listing_reference" text                     NOT NULL,
  "status"            text                     NOT NULL DEFAULT 'draft'::text,
  "title"             text                     NOT NULL,
  "description"       text,
  "asking_price"      numeric(12,2)            NOT NULL,
  "currency"          text                     NOT NULL DEFAULT 'GBP'::text,
  "quantity"          integer                  NOT NULL DEFAULT 1,
  "listing_data"      jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "published_at"      timestamp with time zone,
  "reserved_at"       timestamp with time zone,
  "sold_at"           timestamp with time zone,
  "delisted_at"       timestamp with time zone,
  "created_by"        uuid,
  "created_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "branch_id"         uuid,
  CONSTRAINT "listings_asking_price_check" CHECK ((asking_price >= (0)::numeric)),
  CONSTRAINT "listings_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "listings_pkey" PRIMARY KEY (id),
  CONSTRAINT "listings_quantity_check" CHECK ((quantity > 0)),
  CONSTRAINT "listings_status_check"
    CHECK ((status = ANY (ARRAY['draft'::text, 'ready'::text, 'published'::text, 'reserved'::text, 'sold'::text, 'delisted'::text, 'cancelled'::text]))),
  CONSTRAINT "listings_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "listings_tenant_id_listing_reference_key" UNIQUE (tenant_id, listing_reference)
);

ALTER TABLE "public"."listings"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."listings" FROM "anon";

CREATE TABLE "public"."media_assets" (
  "id"                   uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"            uuid                     NOT NULL,
  "storage_bucket"       text                     NOT NULL,
  "storage_path"         text                     NOT NULL,
  "original_filename"    text,
  "mime_type"            text,
  "byte_size"            bigint,
  "width"                integer,
  "height"               integer,
  "checksum"             text,
  "status"               text                     NOT NULL DEFAULT 'active'::text,
  "created_by"           uuid,
  "created_at"           timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"           timestamp with time zone NOT NULL DEFAULT now(),
  "asset_kind"           text                     NOT NULL DEFAULT 'customer_upload'::text,
  "retention_policy"     text                     NOT NULL DEFAULT 'manual'::text,
  "retention_expires_at" timestamp with time zone,
  "deleted_at"           timestamp with time zone,
  CONSTRAINT "media_assets_byte_size_check" CHECK (((byte_size IS NULL) OR (byte_size >= 0))),
  CONSTRAINT "media_assets_height_check" CHECK (((height IS NULL) OR (height > 0))),
  CONSTRAINT "media_assets_pkey" PRIMARY KEY (id),
  CONSTRAINT "media_assets_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'active'::text, 'deleted'::text, 'quarantined'::text]))),
  CONSTRAINT "media_assets_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "media_assets_tenant_id_storage_bucket_storage_path_key" UNIQUE (tenant_id, storage_bucket, storage_path),
  CONSTRAINT "media_assets_width_check" CHECK (((width IS NULL) OR (width > 0)))
);

ALTER TABLE "public"."media_assets"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."media_assets" FROM "anon";

CREATE TABLE "public"."notification_event_log" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"   uuid                     NOT NULL,
  "event_code"  text                     NOT NULL,
  "entity_type" text                     NOT NULL,
  "entity_id"   uuid                     NOT NULL,
  "occurred_at" timestamp with time zone NOT NULL DEFAULT now(),
  "payload"     jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "notification_event_log_pkey" PRIMARY KEY (id),
  CONSTRAINT "notification_event_log_tenant_id_event_code_entity_type_ent_key" UNIQUE (tenant_id, event_code, entity_type, entity_id)
);

ALTER TABLE "public"."notification_event_log"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."notification_event_log" FROM "anon";

CREATE TABLE "public"."notification_events" (
  "id"                  uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"           uuid                     NOT NULL,
  "notification_id"     uuid,
  "event_code"          text                     NOT NULL,
  "recipient_email"     text,
  "provider"            text,
  "provider_message_id" text,
  "status"              text                     NOT NULL,
  "occurred_at"         timestamp with time zone NOT NULL DEFAULT now(),
  "metadata"            jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"          timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "notification_events_pkey" PRIMARY KEY (id),
  CONSTRAINT "notification_events_status_check"
    CHECK ((status = ANY (ARRAY['queued'::text, 'sent'::text, 'delivered'::text, 'bounced'::text, 'failed'::text, 'opened'::text, 'clicked'::text]))),
  CONSTRAINT "notification_events_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."notification_events"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."notification_events" FROM "anon";

CREATE TABLE "public"."notification_queue" (
  "id"                  uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"           uuid                     NOT NULL,
  "event_code"          text                     NOT NULL,
  "recipient_email"     text                     NOT NULL,
  "recipient_name"      text,
  "subject"             text                     NOT NULL,
  "template_code"       text                     NOT NULL,
  "payload"             jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "status"              text                     NOT NULL DEFAULT 'queued'::text,
  "attempts"            integer                  NOT NULL DEFAULT 0,
  "provider"            text,
  "provider_message_id" text,
  "idempotency_key"     text,
  "scheduled_for"       timestamp with time zone NOT NULL DEFAULT now(),
  "sent_at"             timestamp with time zone,
  "last_error"          text,
  "created_at"          timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"          timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "notification_queue_attempts_check" CHECK ((attempts >= 0)),
  CONSTRAINT "notification_queue_pkey" PRIMARY KEY (id),
  CONSTRAINT "notification_queue_status_check" CHECK ((status = ANY (ARRAY['queued'::text, 'processing'::text, 'sent'::text, 'failed'::text, 'cancelled'::text]))),
  CONSTRAINT "notification_queue_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "notification_queue_tenant_id_idempotency_key_key" UNIQUE (tenant_id, idempotency_key)
);

ALTER TABLE "public"."notification_queue"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."notification_queue" FROM "anon";

CREATE TABLE "public"."notification_templates" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"        uuid,
  "event_code"       text                     NOT NULL,
  "template_code"    text                     NOT NULL,
  "subject_template" text                     NOT NULL,
  "body_template"    text                     NOT NULL,
  "enabled"          boolean                  NOT NULL DEFAULT true,
  "is_system"        boolean                  NOT NULL DEFAULT false,
  "created_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"       timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "notification_templates_event_code_check"
    CHECK
    ((event_code = ANY (ARRAY['offer_sent'::text, 'offer_accepted'::text, 'offer_refused'::text, 'item_received'::text, 'item_dispatched'::text, 'payment_sent'::text,
    'order_confirmation'::text,
    'order_dispatched'::text,
    'order_shipping_ready'::text,
    'return_received'::text,
    'refund_issued'::text,
    'valuation_received'::text, 'valuation_manual_required'::text, 'customer_buying_request_received'::text, 'payment_bank_details_required'::text, 'valuation_refused'::text]))),
  CONSTRAINT "notification_templates_pkey" PRIMARY KEY (id),
  CONSTRAINT "notification_templates_tenant_id_event_code_key" UNIQUE (tenant_id, event_code),
  CONSTRAINT "notification_templates_tenant_id_template_code_key" UNIQUE (tenant_id, template_code)
);

ALTER TABLE "public"."notification_templates"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."notification_templates" FROM "anon";

CREATE TABLE "public"."offer_events" (
  "id"            uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"     uuid                     NOT NULL,
  "offer_id"      uuid                     NOT NULL,
  "event_type"    text                     NOT NULL,
  "from_status"   text,
  "to_status"     text,
  "amount"        numeric,
  "notes"         text,
  "actor_user_id" uuid,
  "created_at"    timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "offer_events_amount_check" CHECK (((amount IS NULL) OR (amount >= (0)::numeric))),
  CONSTRAINT "offer_events_event_type_check"
    CHECK
    ((event_type = ANY (ARRAY['created'::text, 'published'::text, 'accepted'::text, 'refused'::text, 'withdrawn'::text, 'superseded'::text, 'expired'::text, 'revised'::text]))),
  CONSTRAINT "offer_events_pkey" PRIMARY KEY (id),
  CONSTRAINT "offer_events_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."offer_events"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."offer_events" FROM "anon";

CREATE TABLE "public"."offers" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"        uuid                     NOT NULL,
  "buying_item_id"   uuid                     NOT NULL,
  "trading_value_id" uuid                     NOT NULL,
  "offer_reference"  text                     NOT NULL,
  "offer_type"       text                     NOT NULL DEFAULT 'initial'::text,
  "status"           text                     NOT NULL DEFAULT 'draft'::text,
  "amount"           numeric                  NOT NULL,
  "currency"         text                     NOT NULL DEFAULT 'GBP'::text,
  "expires_at"       timestamp with time zone,
  "published_at"     timestamp with time zone,
  "responded_at"     timestamp with time zone,
  "response_notes"   text,
  "created_by"       uuid,
  "created_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "offer_mode"       text                     NOT NULL DEFAULT 'cash'::text,
  CONSTRAINT "offers_amount_check" CHECK ((amount >= (0)::numeric)),
  CONSTRAINT "offers_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "offers_offer_mode_check" CHECK ((offer_mode = ANY (ARRAY['cash'::text, 'trade_in'::text]))),
  CONSTRAINT "offers_offer_type_check" CHECK ((offer_type = ANY (ARRAY['initial'::text, 'revised'::text, 'final'::text]))),
  CONSTRAINT "offers_pkey" PRIMARY KEY (id),
  CONSTRAINT "offers_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'published'::text, 'accepted'::text, 'refused'::text, 'withdrawn'::text, 'superseded'::text]))),
  CONSTRAINT "offers_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "offers_tenant_id_offer_reference_key" UNIQUE (tenant_id, offer_reference)
);

ALTER TABLE "public"."offers"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."offers" FROM "anon";

CREATE TABLE "public"."payment_provider_connections" (
  "id"                   uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"            uuid                     NOT NULL,
  "provider"             text                     NOT NULL,
  "connection_type"      text                     NOT NULL,
  "status"               text                     NOT NULL DEFAULT 'pending'::text,
  "provider_account_id"  text,
  "provider_customer_id" text,
  "display_name"         text,
  "country_code"         text,
  "default_currency"     text,
  "livemode"             boolean                  NOT NULL DEFAULT false,
  "charges_enabled"      boolean,
  "payouts_enabled"      boolean,
  "details_submitted"    boolean,
  "metadata"             jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "connected_at"         timestamp with time zone,
  "disconnected_at"      timestamp with time zone,
  "created_at"           timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"           timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "payment_provider_connections_connection_type_check" CHECK ((connection_type = ANY (ARRAY['customer_payments'::text, 'payouts'::text, 'both'::text]))),
  CONSTRAINT "payment_provider_connections_pkey" PRIMARY KEY (id),
  CONSTRAINT "payment_provider_connections_status_check"
    CHECK ((status = ANY (ARRAY['pending'::text, 'onboarding'::text, 'active'::text, 'restricted'::text, 'disconnected'::text, 'disabled'::text]))),
  CONSTRAINT "payment_provider_connections_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "payment_provider_connections_tenant_id_provider_connection__key" UNIQUE (tenant_id, PROVIDER, connection_type)
);

ALTER TABLE "public"."payment_provider_connections"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."payment_provider_connections" FROM "anon";

CREATE TABLE "public"."payment_provider_customers" (
  "id"                   uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"            uuid                     NOT NULL,
  "connection_id"        uuid                     NOT NULL,
  "customer_id"          uuid,
  "provider"             text                     NOT NULL,
  "provider_customer_id" text                     NOT NULL,
  "livemode"             boolean                  NOT NULL DEFAULT false,
  "metadata"             jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"           timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"           timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "payment_provider_customers_pkey" PRIMARY KEY (id),
  CONSTRAINT "payment_provider_customers_tenant_id_connection_id_provider_key" UNIQUE (tenant_id, connection_id, provider_customer_id),
  CONSTRAINT "payment_provider_customers_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."payment_provider_customers"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."payment_provider_customers" FROM "anon";

CREATE TABLE "public"."payment_provider_events" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "provider"     text                     NOT NULL,
  "event_id"     text                     NOT NULL,
  "event_type"   text                     NOT NULL,
  "processed_at" timestamp with time zone NOT NULL DEFAULT now(),
  "metadata"     jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  CONSTRAINT "payment_provider_events_pkey" PRIMARY KEY (id),
  CONSTRAINT "payment_provider_events_provider_event_id_key" UNIQUE (PROVIDER, event_id)
);

ALTER TABLE "public"."payment_provider_events"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."payment_provider_events" FROM "anon", "authenticated";

CREATE TABLE "public"."payment_records" (
  "id"                  uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"           uuid                     NOT NULL,
  "payment_reference"   text                     NOT NULL,
  "payment_type"        text                     NOT NULL,
  "status"              text                     NOT NULL DEFAULT 'pending'::text,
  "direction"           text                     NOT NULL,
  "amount"              numeric(12,2)            NOT NULL,
  "currency"            text                     NOT NULL DEFAULT 'GBP'::text,
  "provider"            text,
  "provider_payment_id" text,
  "payment_method"      text,
  "customer_id"         uuid,
  "retail_order_id"     uuid,
  "acquisition_id"      uuid,
  "return_id"           uuid,
  "idempotency_key"     text,
  "failure_code"        text,
  "failure_message"     text,
  "notes"               text,
  "metadata"            jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "requested_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "processed_at"        timestamp with time zone,
  "created_by"          uuid,
  "created_at"          timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"          timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "payment_records_amount_check" CHECK ((amount >= (0)::numeric)),
  CONSTRAINT "payment_records_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "payment_records_direction_check" CHECK ((direction = ANY (ARRAY['inbound'::text, 'outbound'::text]))),
  CONSTRAINT "payment_records_payment_type_check"
    CHECK ((payment_type = ANY (ARRAY['customer_payment'::text, 'seller_payment'::text, 'refund'::text, 'payout'::text, 'expense'::text, 'other'::text]))),
  CONSTRAINT "payment_records_pkey" PRIMARY KEY (id),
  CONSTRAINT "payment_records_status_check"
    CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'paid'::text, 'failed'::text, 'cancelled'::text, 'refunded'::text, 'partially_refunded'::text]))),
  CONSTRAINT "payment_records_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "payment_records_tenant_id_payment_reference_key" UNIQUE (tenant_id, payment_reference)
);

ALTER TABLE "public"."payment_records"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."payment_records" FROM "anon";

CREATE TABLE "public"."payment_webhook_events" (
  "id"                uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"         uuid,
  "provider"          text                     NOT NULL,
  "provider_event_id" text                     NOT NULL,
  "event_type"        text                     NOT NULL,
  "status"            text                     NOT NULL DEFAULT 'received'::text,
  "livemode"          boolean                  NOT NULL DEFAULT false,
  "payload_hash"      text,
  "payload"           jsonb,
  "received_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "processed_at"      timestamp with time zone,
  "attempt_count"     integer                  NOT NULL DEFAULT 0,
  "last_error"        text,
  "created_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"        timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "payment_webhook_events_attempt_count_check" CHECK ((attempt_count >= 0)),
  CONSTRAINT "payment_webhook_events_pkey" PRIMARY KEY (id),
  CONSTRAINT "payment_webhook_events_provider_provider_event_id_key" UNIQUE (PROVIDER, provider_event_id),
  CONSTRAINT "payment_webhook_events_status_check" CHECK ((status = ANY (ARRAY['received'::text, 'processing'::text, 'processed'::text, 'ignored'::text, 'failed'::text])))
);

ALTER TABLE "public"."payment_webhook_events"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."payment_webhook_events" FROM "anon";

CREATE TABLE "public"."permissions" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "code"        text                     NOT NULL,
  "name"        text                     NOT NULL,
  "description" text,
  "domain"      text                     NOT NULL,
  "active"      boolean                  NOT NULL DEFAULT true,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "permissions_code_format" CHECK ((code ~ '^[a-z][a-z0-9_.]*$'::text)),
  CONSTRAINT "permissions_code_key" UNIQUE (code),
  CONSTRAINT "permissions_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."permissions"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."permissions" FROM "anon";

CREATE TABLE "public"."plan_features" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "plan_id"      uuid                     NOT NULL,
  "feature_code" text                     NOT NULL,
  "enabled"      boolean                  NOT NULL DEFAULT true,
  "config"       jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "plan_features_pkey" PRIMARY KEY (id),
  CONSTRAINT "plan_features_plan_id_feature_code_key" UNIQUE (plan_id, feature_code)
);

ALTER TABLE "public"."plan_features"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."plan_features" FROM "anon";

CREATE TABLE "public"."plans" (
  "id"                      uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "code"                    text                     NOT NULL,
  "name"                    text                     NOT NULL,
  "description"             text,
  "active"                  boolean                  NOT NULL DEFAULT true,
  "sort_order"              integer                  NOT NULL DEFAULT 0,
  "created_at"              timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"              timestamp with time zone NOT NULL DEFAULT now(),
  "website_visible"         boolean                  NOT NULL DEFAULT false,
  "monthly_price"           numeric(12,2),
  "annual_price"            numeric(12,2),
  "currency"                text                     NOT NULL DEFAULT 'GBP'::text,
  "stripe_product_id"       text,
  "stripe_monthly_price_id" text,
  "stripe_annual_price_id"  text,
  CONSTRAINT "plans_code_key" UNIQUE (code),
  CONSTRAINT "plans_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."plans"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."plans" FROM "anon";

CREATE TABLE "public"."platform_email_settings" (
  "id"                         boolean                  NOT NULL DEFAULT true,
  "sender_email"               text,
  "sender_name"                text                     NOT NULL DEFAULT 'TradeFlow'::text,
  "email_enabled"              boolean                  NOT NULL DEFAULT false,
  "sender_verification_status" text                     NOT NULL DEFAULT 'not_configured'::text,
  "sender_verified_at"         timestamp with time zone,
  "provider"                   text                     NOT NULL DEFAULT 'resend'::text,
  "updated_at"                 timestamp with time zone NOT NULL DEFAULT now(),
  "updated_by"                 uuid,
  CONSTRAINT "platform_email_settings_id_check" CHECK ((id = true)),
  CONSTRAINT "platform_email_settings_pkey" PRIMARY KEY (id),
  CONSTRAINT "platform_email_settings_sender_verification_status_check"
    CHECK ((sender_verification_status = ANY (ARRAY['not_configured'::text, 'pending'::text, 'verified'::text, 'failed'::text])))
);

ALTER TABLE "public"."platform_email_settings"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."platform_memberships" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "user_id"    uuid                     NOT NULL,
  "status"     text                     NOT NULL DEFAULT 'active'::text,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "platform_memberships_pkey" PRIMARY KEY (id),
  CONSTRAINT "platform_memberships_status_check" CHECK ((status = ANY (ARRAY['invited'::text, 'active'::text, 'suspended'::text, 'removed'::text]))),
  CONSTRAINT "platform_memberships_user_id_key" UNIQUE (user_id)
);

ALTER TABLE "public"."platform_memberships"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."published_site_index" (
  "hostname"        text                     NOT NULL,
  "tenant_id"       uuid                     NOT NULL,
  "domain_id"       uuid                     NOT NULL,
  "revision_id"     uuid                     NOT NULL,
  "revision_number" integer                  NOT NULL,
  "content"         jsonb                    NOT NULL,
  "published_at"    timestamp with time zone NOT NULL,
  "updated_at"      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "published_site_index_content_object" CHECK ((jsonb_typeof(content) = 'object'::text)),
  CONSTRAINT "published_site_index_pkey" PRIMARY KEY (hostname)
);

ALTER TABLE "public"."published_site_index"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."retail_order_items" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"          uuid                     NOT NULL,
  "order_id"           uuid                     NOT NULL,
  "listing_id"         uuid                     NOT NULL,
  "inventory_asset_id" uuid                     NOT NULL,
  "quantity"           integer                  NOT NULL DEFAULT 1,
  "title"              text                     NOT NULL,
  "unit_price"         numeric(12,2)            NOT NULL,
  "discount_amount"    numeric(12,2)            NOT NULL DEFAULT 0,
  "tax_amount"         numeric(12,2)            NOT NULL DEFAULT 0,
  "line_total"         numeric(12,2)            NOT NULL,
  "currency"           text                     NOT NULL DEFAULT 'GBP'::text,
  "metadata"           jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "retail_order_items_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "retail_order_items_discount_amount_check" CHECK ((discount_amount >= (0)::numeric)),
  CONSTRAINT "retail_order_items_line_total_check" CHECK ((line_total >= (0)::numeric)),
  CONSTRAINT "retail_order_items_pkey" PRIMARY KEY (id),
  CONSTRAINT "retail_order_items_quantity_check" CHECK ((quantity > 0)),
  CONSTRAINT "retail_order_items_tax_amount_check" CHECK ((tax_amount >= (0)::numeric)),
  CONSTRAINT "retail_order_items_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "retail_order_items_tenant_id_order_id_listing_id_key" UNIQUE (tenant_id, order_id, listing_id),
  CONSTRAINT "retail_order_items_unit_price_check" CHECK ((unit_price >= (0)::numeric))
);

ALTER TABLE "public"."retail_order_items"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."retail_order_items" FROM "anon";

CREATE TABLE "public"."retail_order_trade_ins" (
  "id"                      uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"               uuid                     NOT NULL,
  "retail_order_id"         uuid                     NOT NULL,
  "trade_in_transaction_id" uuid                     NOT NULL,
  "credit_amount"           numeric(12,2)            NOT NULL,
  "currency"                text                     NOT NULL DEFAULT 'GBP'::text,
  "status"                  text                     NOT NULL DEFAULT 'pending'::text,
  "applied_at"              timestamp with time zone,
  "reversed_at"             timestamp with time zone,
  "notes"                   text,
  "created_at"              timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"              timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "retail_order_trade_ins_credit_amount_check" CHECK ((credit_amount >= (0)::numeric)),
  CONSTRAINT "retail_order_trade_ins_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "retail_order_trade_ins_pkey" PRIMARY KEY (id),
  CONSTRAINT "retail_order_trade_ins_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'reserved'::text, 'applied'::text, 'reversed'::text, 'cancelled'::text]))),
  CONSTRAINT "retail_order_trade_ins_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "retail_order_trade_ins_tenant_id_retail_order_id_trade_in_t_key" UNIQUE (tenant_id, retail_order_id, trade_in_transaction_id)
);

ALTER TABLE "public"."retail_order_trade_ins"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."retail_order_trade_ins" FROM "anon";

CREATE TABLE "public"."retail_orders" (
  "id"                    uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"             uuid                     NOT NULL,
  "order_reference"       text                     NOT NULL,
  "customer_id"           uuid,
  "channel_id"            uuid                     NOT NULL,
  "status"                text                     NOT NULL DEFAULT 'initiated'::text,
  "currency"              text                     NOT NULL DEFAULT 'GBP'::text,
  "subtotal"              numeric(12,2)            NOT NULL DEFAULT 0,
  "shipping_total"        numeric(12,2)            NOT NULL DEFAULT 0,
  "tax_total"             numeric(12,2)            NOT NULL DEFAULT 0,
  "discount_total"        numeric(12,2)            NOT NULL DEFAULT 0,
  "total"                 numeric(12,2)            NOT NULL DEFAULT 0,
  "payment_status"        text                     NOT NULL DEFAULT 'unpaid'::text,
  "customer_email"        text,
  "customer_name"         text,
  "shipping_address"      jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "billing_address"       jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "notes"                 text,
  "metadata"              jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "placed_at"             timestamp with time zone,
  "paid_at"               timestamp with time zone,
  "completed_at"          timestamp with time zone,
  "cancelled_at"          timestamp with time zone,
  "created_at"            timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"            timestamp with time zone NOT NULL DEFAULT now(),
  "trade_in_credit_total" numeric(12,2)            NOT NULL DEFAULT 0,
  "amount_due"            numeric(12,2)            NOT NULL DEFAULT 0,
  "pricing_version"       text,
  CONSTRAINT "retail_orders_amount_due_check" CHECK ((amount_due >= (0)::numeric)),
  CONSTRAINT "retail_orders_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "retail_orders_discount_total_check" CHECK ((discount_total >= (0)::numeric)),
  CONSTRAINT "retail_orders_payment_status_check"
    CHECK ((payment_status = ANY (ARRAY['unpaid'::text, 'pending'::text, 'paid'::text, 'failed'::text, 'partially_refunded'::text, 'refunded'::text]))),
  CONSTRAINT "retail_orders_pkey" PRIMARY KEY (id),
  CONSTRAINT "retail_orders_shipping_total_check" CHECK ((shipping_total >= (0)::numeric)),
  CONSTRAINT "retail_orders_status_check"
    CHECK
    ((status = ANY (ARRAY['initiated'::text, 'pending_payment'::text, 'paid'::text, 'fulfilment'::text, 'completed'::text, 'cancelled'::text, 'refunded'::text,
    'partially_refunded'::text]))),
  CONSTRAINT "retail_orders_subtotal_check" CHECK ((subtotal >= (0)::numeric)),
  CONSTRAINT "retail_orders_tax_total_check" CHECK ((tax_total >= (0)::numeric)),
  CONSTRAINT "retail_orders_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "retail_orders_tenant_id_order_reference_key" UNIQUE (tenant_id, order_reference),
  CONSTRAINT "retail_orders_total_check" CHECK ((total >= (0)::numeric)),
  CONSTRAINT "retail_orders_trade_in_credit_total_check" CHECK ((trade_in_credit_total >= (0)::numeric))
);

ALTER TABLE "public"."retail_orders"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."retail_orders" FROM "anon";

CREATE TABLE "public"."return_events" (
  "id"            uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"     uuid                     NOT NULL,
  "return_id"     uuid                     NOT NULL,
  "event_type"    text                     NOT NULL,
  "from_status"   text,
  "to_status"     text,
  "notes"         text,
  "actor_user_id" uuid,
  "created_at"    timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "return_events_event_type_check"
    CHECK
    ((event_type = ANY (ARRAY['requested'::text, 'authorised'::text, 'awaiting_return'::text, 'received'::text, 'inspected'::text, 'approved'::text, 'refunded'::text,
    'replaced'::text, 'rejected'::text, 'closed'::text, 'note'::text]))),
  CONSTRAINT "return_events_pkey" PRIMARY KEY (id),
  CONSTRAINT "return_events_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."return_events"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."return_events" FROM "anon";

CREATE TABLE "public"."return_resolutions" (
  "id"              uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"       uuid                     NOT NULL,
  "return_id"       uuid                     NOT NULL,
  "resolution_type" text                     NOT NULL,
  "outcome"         text,
  "refund_amount"   numeric(12,2),
  "currency"        text                     NOT NULL DEFAULT 'GBP'::text,
  "disposition"     text,
  "notes"           text,
  "resolved_by"     uuid,
  "resolved_at"     timestamp with time zone NOT NULL DEFAULT now(),
  "metadata"        jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  CONSTRAINT "return_resolutions_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "return_resolutions_pkey" PRIMARY KEY (id),
  CONSTRAINT "return_resolutions_refund_amount_check" CHECK (((refund_amount IS NULL) OR (refund_amount >= (0)::numeric))),
  CONSTRAINT "return_resolutions_resolution_type_check"
    CHECK ((resolution_type = ANY (ARRAY['refund'::text, 'replacement'::text, 'repair'::text, 'resale'::text, 'write_off'::text, 'reject'::text, 'other'::text]))),
  CONSTRAINT "return_resolutions_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."return_resolutions"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."return_resolutions" FROM "anon";

CREATE TABLE "public"."returns" (
  "id"                  uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"           uuid                     NOT NULL,
  "return_reference"    text                     NOT NULL,
  "return_type"         text                     NOT NULL,
  "status"              text                     NOT NULL DEFAULT 'requested'::text,
  "customer_id"         uuid,
  "order_id"            uuid,
  "order_item_id"       uuid,
  "inventory_asset_id"  uuid,
  "acquisition_id"      uuid,
  "acquisition_item_id" uuid,
  "reason_code"         text,
  "reason"              text,
  "customer_notes"      text,
  "staff_notes"         text,
  "requested_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "authorised_at"       timestamp with time zone,
  "received_at"         timestamp with time zone,
  "inspected_at"        timestamp with time zone,
  "resolved_at"         timestamp with time zone,
  "closed_at"           timestamp with time zone,
  "refund_amount"       numeric(12,2),
  "currency"            text                     NOT NULL DEFAULT 'GBP'::text,
  "metadata"            jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_by"          uuid,
  "created_at"          timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"          timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "returns_check1"
    CHECK ((((return_type = 'customer_retail'::text) AND (acquisition_item_id IS NULL)) OR ((return_type = 'acquisition'::text) AND (order_item_id IS NULL)))),
  CONSTRAINT "returns_check" CHECK ((((return_type = 'customer_retail'::text) AND (order_item_id IS NOT NULL)) OR ((return_type = 'acquisition'::text) AND (acquisition_item_id IS
    NOT NULL)))),
  CONSTRAINT "returns_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "returns_pkey" PRIMARY KEY (id),
  CONSTRAINT "returns_refund_amount_check" CHECK (((refund_amount IS NULL) OR (refund_amount >= (0)::numeric))),
  CONSTRAINT "returns_return_type_check" CHECK ((return_type = ANY (ARRAY['customer_retail'::text, 'acquisition'::text]))),
  CONSTRAINT "returns_status_check"
    CHECK
    ((status = ANY (ARRAY['requested'::text, 'authorised'::text, 'awaiting_return'::text, 'received'::text, 'inspected'::text, 'approved'::text, 'refunded'::text, 'replaced'::text,
    'rejected'::text, 'closed'::text]))),
  CONSTRAINT "returns_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "returns_tenant_id_return_reference_key" UNIQUE (tenant_id, return_reference)
);

ALTER TABLE "public"."returns"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."returns" FROM "anon";

CREATE TABLE "public"."role_permissions" (
  "role_id"       uuid                     NOT NULL,
  "permission_id" uuid                     NOT NULL,
  "created_at"    timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "role_permissions_pkey" PRIMARY KEY (role_id, permission_id)
);

ALTER TABLE "public"."role_permissions"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."role_permissions" FROM "anon";

CREATE TABLE "public"."roles" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "code"        text                     NOT NULL,
  "name"        text                     NOT NULL,
  "description" text,
  "is_system"   boolean                  NOT NULL DEFAULT true,
  "active"      boolean                  NOT NULL DEFAULT true,
  "sort_order"  integer                  NOT NULL DEFAULT 0,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "roles_code_format" CHECK ((code ~ '^[a-z][a-z0-9_]*$'::text)),
  CONSTRAINT "roles_code_key" UNIQUE (code),
  CONSTRAINT "roles_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."roles"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."roles" FROM "anon";

CREATE TABLE "public"."sales_channels" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"    uuid                     NOT NULL,
  "name"         text                     NOT NULL,
  "channel_type" text                     NOT NULL DEFAULT 'storefront'::text,
  "slug"         text                     NOT NULL,
  "description"  text,
  "active"       boolean                  NOT NULL DEFAULT true,
  "settings"     jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "sales_channels_channel_type_check" CHECK ((channel_type = ANY (ARRAY['storefront'::text, 'marketplace'::text, 'manual'::text, 'other'::text]))),
  CONSTRAINT "sales_channels_pkey" PRIMARY KEY (id),
  CONSTRAINT "sales_channels_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "sales_channels_tenant_id_slug_key" UNIQUE (tenant_id, slug)
);

ALTER TABLE "public"."sales_channels"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."sales_channels" FROM "anon";

CREATE TABLE "public"."shipping_provider_catalog" (
  "provider_code"      text                     NOT NULL,
  "provider_name"      text                     NOT NULL,
  "provider_type"      text                     NOT NULL,
  "connection_method"  text                     NOT NULL,
  "website_url"        text,
  "documentation_url"  text,
  "setup_url"          text,
  "description"        text,
  "setup_instructions" text,
  "required_fields"    jsonb                    NOT NULL DEFAULT '[]'::jsonb,
  "capabilities"       jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "availability"       text                     NOT NULL DEFAULT 'available'::text,
  "adapter_status"     text                     NOT NULL DEFAULT 'planned'::text,
  "sort_order"         integer                  NOT NULL DEFAULT 100,
  "enabled"            boolean                  NOT NULL DEFAULT true,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "shipping_provider_catalog_adapter_status_check" CHECK ((adapter_status = ANY (ARRAY['active'::text, 'framework_ready'::text, 'planned'::text]))),
  CONSTRAINT "shipping_provider_catalog_availability_check" CHECK ((availability = ANY (ARRAY['available'::text, 'setup_required'::text, 'planned'::text]))),
  CONSTRAINT "shipping_provider_catalog_connection_method_check"
    CHECK ((connection_method = ANY (ARRAY['api_credentials'::text, 'oauth'::text, 'account_credentials'::text, 'manual'::text]))),
  CONSTRAINT "shipping_provider_catalog_pkey" PRIMARY KEY (provider_code),
  CONSTRAINT "shipping_provider_catalog_provider_type_check" CHECK ((provider_type = ANY (ARRAY['multi_carrier'::text, 'direct_carrier'::text])))
);

ALTER TABLE "public"."shipping_provider_catalog"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."shipping_provider_connections" (
  "id"                         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"                  uuid                     NOT NULL,
  "provider"                   text                     NOT NULL,
  "status"                     text                     NOT NULL DEFAULT 'not_connected'::text,
  "connection_type"            text                     NOT NULL DEFAULT 'subscriber_account'::text,
  "provider_account_id"        text,
  "display_name"               text,
  "auth_mode"                  text,
  "capabilities"               jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "metadata"                   jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "connected_at"               timestamp with time zone,
  "disconnected_at"            timestamp with time zone,
  "created_at"                 timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"                 timestamp with time zone NOT NULL DEFAULT now(),
  "environment"                text                     NOT NULL DEFAULT 'sandbox'::text,
  "api_client_id"              text,
  "api_client_secret_vault_id" uuid,
  "last_tested_at"             timestamp with time zone,
  "credentials_vault_id"       uuid,
  CONSTRAINT "shipping_provider_connections_environment_check" CHECK ((environment = ANY (ARRAY['sandbox'::text, 'live'::text]))),
  CONSTRAINT "shipping_provider_connections_pkey" PRIMARY KEY (id),
  CONSTRAINT "shipping_provider_connections_provider_check"
    CHECK
    ((provider = ANY (ARRAY['parcel2go'::text, 'sendcloud'::text, 'shippo'::text, 'shiptheory'::text, 'scurri'::text, 'metapack'::text, 'linnworks'::text, 'royalmail'::text,
    'evri'::text,
    'yodel'::text, 'dpd'::text, 'dhl'::text, 'parcelforce'::text, 'ups'::text, 'fedex'::text, 'dx'::text, 'apc'::text, 'inpost'::text, 'whistl'::text, 'amazon_shipping'::text]))),
  CONSTRAINT "shipping_provider_connections_status_check"
    CHECK ((status = ANY (ARRAY['not_connected'::text, 'pending'::text, 'connected'::text, 'error'::text, 'disconnected'::text]))),
  CONSTRAINT "shipping_provider_connections_tenant_id_provider_key" UNIQUE (tenant_id, PROVIDER),
  CONSTRAINT "shipping_provider_connections_type_check" CHECK ((connection_type = 'subscriber_account'::text))
);

ALTER TABLE "public"."shipping_provider_connections"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."shipping_quote_sessions" (
  "id"                     uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"              uuid                     NOT NULL,
  "acquisition_id"         uuid                     NOT NULL,
  "customer_id"            uuid                     NOT NULL,
  "provider"               text                     NOT NULL,
  "provider_connection_id" uuid                     NOT NULL,
  "status"                 text                     NOT NULL DEFAULT 'quoted'::text,
  "request_payload"        jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "response_payload"       jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "selected_service"       jsonb,
  "provider_order_id"      text,
  "payment_url"            text,
  "tracking_url"           text,
  "label_url"              text,
  "created_at"             timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"             timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "shipping_quote_sessions_pkey" PRIMARY KEY (id),
  CONSTRAINT "shipping_quote_sessions_provider_check" CHECK ((provider = ANY (ARRAY['parcel2go'::text, 'sendcloud'::text, 'shippo'::text]))),
  CONSTRAINT "shipping_quote_sessions_status_check"
    CHECK ((status = ANY (ARRAY['quoted'::text, 'order_created'::text, 'paid'::text, 'cancelled'::text, 'expired'::text, 'error'::text])))
);

ALTER TABLE "public"."shipping_quote_sessions"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."shipping_service_catalog" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "service_code" text                     NOT NULL,
  "service_name" text                     NOT NULL,
  "service_url"  text                     NOT NULL,
  "service_type" text                     NOT NULL DEFAULT 'courier'::text,
  "description"  text,
  "active"       boolean                  NOT NULL DEFAULT true,
  "sort_order"   integer                  NOT NULL DEFAULT 0,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "shipping_service_catalog_pkey" PRIMARY KEY (id),
  CONSTRAINT "shipping_service_catalog_service_code_key" UNIQUE (service_code),
  CONSTRAINT "shipping_service_catalog_service_type_check" CHECK ((service_type = ANY (ARRAY['courier'::text, 'multi_carrier'::text, 'specialist'::text])))
);

ALTER TABLE "public"."shipping_service_catalog"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."site_revisions" (
  "id"              uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"       uuid                     NOT NULL,
  "revision_number" integer                  NOT NULL,
  "status"          text                     NOT NULL DEFAULT 'draft'::text,
  "content"         jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_by"      uuid,
  "published_by"    uuid,
  "published_at"    timestamp with time zone,
  "created_at"      timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "site_revisions_content_check" CHECK ((jsonb_typeof(content) = 'object'::text)),
  CONSTRAINT "site_revisions_pkey" PRIMARY KEY (id),
  CONSTRAINT "site_revisions_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text]))),
  CONSTRAINT "site_revisions_tenant_id_id_unique" UNIQUE (tenant_id, id),
  CONSTRAINT "site_revisions_tenant_revision_unique" UNIQUE (tenant_id, revision_number)
);

ALTER TABLE "public"."site_revisions"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."site_revisions" FROM "anon";

CREATE TABLE "public"."tenant_buying_condition_rules" (
  "id"                                      uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"                               uuid                     NOT NULL,
  "buying_product_id"                       uuid                     NOT NULL,
  "sealed_percentage"                       numeric(6,2),
  "excellent_percentage"                    numeric(6,2),
  "good_percentage"                         numeric(6,2),
  "poor_percentage"                         numeric(6,2),
  "created_at"                              timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"                              timestamp with time zone NOT NULL DEFAULT now(),
  "opened_never_used_percentage"            numeric(6,2),
  "sealed_reference_type"                   text                     NOT NULL DEFAULT 'uk_new'::text,
  "opened_never_used_reference_type"        text                     NOT NULL DEFAULT 'uk_new'::text,
  "excellent_reference_type"                text                     NOT NULL DEFAULT 'uk_used'::text,
  "good_reference_type"                     text                     NOT NULL DEFAULT 'uk_used'::text,
  "poor_reference_type"                     text                     NOT NULL DEFAULT 'uk_used'::text,
  "sealed_manual_price"                     numeric(10,2),
  "opened_never_used_manual_price"          numeric(10,2),
  "excellent_manual_price"                  numeric(10,2),
  "good_manual_price"                       numeric(10,2),
  "poor_manual_price"                       numeric(10,2),
  "sealed_trade_in_percentage"              numeric(6,2),
  "opened_never_used_trade_in_percentage"   numeric(6,2),
  "excellent_trade_in_percentage"           numeric(6,2),
  "good_trade_in_percentage"                numeric(6,2),
  "poor_trade_in_percentage"                numeric(6,2),
  "sealed_trade_in_manual_price"            numeric(10,2),
  "opened_never_used_trade_in_manual_price" numeric(10,2),
  "excellent_trade_in_manual_price"         numeric(10,2),
  "good_trade_in_manual_price"              numeric(10,2),
  "poor_trade_in_manual_price"              numeric(10,2),
  CONSTRAINT "tenant_buying_condition_rules_manual_prices_ck"
    CHECK
    ((((sealed_manual_price IS NULL) OR (sealed_manual_price >= (0)::numeric)) AND ((opened_never_used_manual_price IS NULL) OR (opened_never_used_manual_price >= (0)::numeric))
    AND ((excellent_manual_price IS NULL) OR (excellent_manual_price >= (0)::numeric)) AND ((good_manual_price IS NULL) OR (good_manual_price >= (0)::numeric)) AND
    ((poor_manual_price IS NULL) OR (poor_manual_price >= (0)::numeric)))),
  CONSTRAINT "tenant_buying_condition_rules_percentages_ck"
    CHECK
    ((((COALESCE(sealed_percentage, (0)::numeric) >= (0)::numeric) AND (COALESCE(sealed_percentage, (0)::numeric) <= (100)::numeric)) AND ((COALESCE(opened_never_used_percentage,
    (0)::numeric) >= (0)::numeric) AND (COALESCE(opened_never_used_percentage, (0)::numeric) <= (100)::numeric)) AND
    ((COALESCE(excellent_percentage, (0)::numeric) >= (0)::numeric) AND (COALESCE(excellent_percentage, (0)::numeric) <= (100)::numeric)) AND
    ((COALESCE(good_percentage, (0)::numeric) >= (0)::numeric) AND (COALESCE(good_percentage, (0)::numeric) <= (100)::numeric)) AND
    ((COALESCE(poor_percentage, (0)::numeric) >= (0)::numeric) AND (COALESCE(poor_percentage, (0)::numeric) <= (100)::numeric)))),
  CONSTRAINT "tenant_buying_condition_rules_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_buying_condition_rules_reference_types_ck"
    CHECK
    (((sealed_reference_type = ANY (ARRAY['uk_new'::text, 'uk_used'::text])) AND (opened_never_used_reference_type = ANY (ARRAY['uk_new'::text, 'uk_used'::text])) AND
    (excellent_reference_type = ANY (ARRAY['uk_new'::text, 'uk_used'::text])) AND (good_reference_type = ANY (ARRAY['uk_new'::text, 'uk_used'::text])) AND
    (poor_reference_type = ANY (ARRAY['uk_new'::text, 'uk_used'::text])))),
  CONSTRAINT "tenant_buying_condition_rules_tenant_id_buying_product_id_key" UNIQUE (tenant_id, buying_product_id),
  CONSTRAINT "tenant_buying_condition_rules_trade_in_pricing_ck"
    CHECK
    ((((sealed_trade_in_percentage IS NULL) OR ((sealed_trade_in_percentage >= (0)::numeric) AND (sealed_trade_in_percentage <= (100)::numeric))) AND
    ((opened_never_used_trade_in_percentage IS NULL) OR ((opened_never_used_trade_in_percentage >= (0)::numeric) AND (opened_never_used_trade_in_percentage <= (100)::numeric))) AND
    ((excellent_trade_in_percentage IS NULL) OR ((excellent_trade_in_percentage >= (0)::numeric) AND (excellent_trade_in_percentage <= (100)::numeric))) AND
    ((good_trade_in_percentage IS NULL) OR ((good_trade_in_percentage >= (0)::numeric) AND (good_trade_in_percentage <= (100)::numeric))) AND
    ((poor_trade_in_percentage IS NULL) OR ((poor_trade_in_percentage >= (0)::numeric) AND (poor_trade_in_percentage <= (100)::numeric))) AND
    ((sealed_trade_in_manual_price IS NULL) OR (sealed_trade_in_manual_price >= (0)::numeric)) AND
    ((opened_never_used_trade_in_manual_price IS NULL) OR (opened_never_used_trade_in_manual_price >= (0)::numeric)) AND
    ((excellent_trade_in_manual_price IS NULL) OR (excellent_trade_in_manual_price >= (0)::numeric)) AND
    ((good_trade_in_manual_price IS NULL) OR (good_trade_in_manual_price >= (0)::numeric)) AND
    ((poor_trade_in_manual_price IS NULL) OR (poor_trade_in_manual_price >= (0)::numeric))))
);

ALTER TABLE "public"."tenant_buying_condition_rules"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."tenant_buying_manufacturers" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"  uuid                     NOT NULL,
  "name"       text                     NOT NULL,
  "active"     boolean                  NOT NULL DEFAULT true,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "tenant_buying_manufacturers_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_buying_manufacturers_tenant_id_name_key" UNIQUE (tenant_id, name)
);

ALTER TABLE "public"."tenant_buying_manufacturers"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."tenant_buying_products" (
  "id"                   uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"            uuid                     NOT NULL,
  "category_id"          uuid                     NOT NULL,
  "branch_id"            uuid                     NOT NULL,
  "manufacturer"         text                     NOT NULL,
  "model"                text                     NOT NULL,
  "package_name"         text,
  "active"               boolean                  NOT NULL DEFAULT true,
  "automatic_percentage" numeric(6,2),
  "manual_offer_price"   numeric(12,2),
  "pricing_notes"        text,
  "created_at"           timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"           timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "tenant_buying_products_manual_price_ck" CHECK (((manual_offer_price IS NULL) OR (manual_offer_price >= (0)::numeric))),
  CONSTRAINT "tenant_buying_products_percentage_ck"
    CHECK (((automatic_percentage IS NULL) OR ((automatic_percentage >= (0)::numeric) AND (automatic_percentage <= (100)::numeric)))),
  CONSTRAINT "tenant_buying_products_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_buying_products_pricing_ck" CHECK (((automatic_percentage IS NULL) OR (manual_offer_price IS NULL)))
);

ALTER TABLE "public"."tenant_buying_products"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenant_buying_products" FROM "anon";

CREATE TABLE "public"."tenant_buying_research" (
  "id"                uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"         uuid                     NOT NULL,
  "buying_product_id" uuid                     NOT NULL,
  "evidence_type"     text                     NOT NULL,
  "source_name"       text                     NOT NULL,
  "source_url"        text,
  "observed_price"    numeric(12,2),
  "price_currency"    text                     NOT NULL DEFAULT 'GBP'::text,
  "item_condition"    text,
  "availability"      text,
  "notes"             text,
  "checked_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "created_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "created_by"        uuid,
  CONSTRAINT "tenant_buying_research_evidence_type_check" CHECK ((evidence_type = ANY (ARRAY['uk_new'::text, 'uk_used'::text, 'overseas'::text]))),
  CONSTRAINT "tenant_buying_research_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."tenant_buying_research"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenant_buying_research" FROM "anon";

CREATE TABLE "public"."tenant_catalogue_selections" (
  "id"                uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"         uuid                     NOT NULL,
  "master_product_id" uuid                     NOT NULL,
  "category_id"       uuid                     NOT NULL,
  "branch_id"         uuid,
  "manufacturer"      text                     NOT NULL,
  "model"             text                     NOT NULL,
  "package_name"      text                     NOT NULL,
  "buying_enabled"    boolean                  NOT NULL DEFAULT false,
  "selling_enabled"   boolean                  NOT NULL DEFAULT false,
  "active"            boolean                  NOT NULL DEFAULT true,
  "created_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "website_visible"   boolean                  NOT NULL DEFAULT true,
  CONSTRAINT "tenant_catalogue_selections_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_catalogue_selections_tenant_id_master_product_id_key" UNIQUE (tenant_id, master_product_id)
);

ALTER TABLE "public"."tenant_catalogue_selections"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."tenant_catalogue_state" (
  "tenant_id"          uuid                     NOT NULL,
  "master_version"     integer                  NOT NULL DEFAULT 1,
  "seeded_at"          timestamp with time zone,
  "category_count"     integer                  NOT NULL DEFAULT 0,
  "branch_count"       integer                  NOT NULL DEFAULT 0,
  "manufacturer_count" integer                  NOT NULL DEFAULT 0,
  "product_count"      integer                  NOT NULL DEFAULT 0,
  "updated_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "tenant_catalogue_state_pkey" PRIMARY KEY (tenant_id)
);

ALTER TABLE "public"."tenant_catalogue_state"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenant_catalogue_state" FROM "anon", "authenticated";

CREATE TABLE "public"."tenant_domain_orders" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"          uuid                     NOT NULL,
  "domain_id"          uuid,
  "operation"          text                     NOT NULL DEFAULT 'register'::text,
  "hostname"           text                     NOT NULL,
  "tld"                text                     NOT NULL,
  "term_years"         integer                  NOT NULL DEFAULT 1,
  "status"             text                     NOT NULL DEFAULT 'pending_payment'::text,
  "currency"           text                     NOT NULL DEFAULT 'GBP'::text,
  "retail_amount"      numeric(12,2)            NOT NULL DEFAULT 0,
  "registrar_cost"     numeric(12,2),
  "payment_provider"   text,
  "payment_reference"  text,
  "provider_order_id"  text,
  "provider_domain_id" text,
  "purchased_at"       timestamp with time zone,
  "expires_at"         timestamp with time zone,
  "auto_renew"         boolean                  NOT NULL DEFAULT true,
  "failure_reason"     text,
  "metadata"           jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "tenant_domain_orders_amount_chk" CHECK (((retail_amount >= (0)::numeric) AND ((registrar_cost IS NULL) OR (registrar_cost >= (0)::numeric)))),
  CONSTRAINT "tenant_domain_orders_currency_chk" CHECK (((currency = upper(TRIM(BOTH FROM currency))) AND (length(currency) = 3))),
  CONSTRAINT "tenant_domain_orders_hostname_chk" CHECK (((hostname = lower(TRIM(BOTH FROM hostname))) AND ((length(hostname) >= 3) AND (length(hostname) <= 253)))),
  CONSTRAINT "tenant_domain_orders_operation_chk" CHECK ((operation = ANY (ARRAY['register'::text, 'renew'::text, 'transfer'::text]))),
  CONSTRAINT "tenant_domain_orders_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_domain_orders_status_chk"
    CHECK
    ((status = ANY (ARRAY['pending_payment'::text, 'payment_failed'::text, 'submitted'::text, 'registering'::text, 'registered'::text, 'failed'::text, 'cancelled'::text,
    'refunded'::text]))),
  CONSTRAINT "tenant_domain_orders_tld_chk" CHECK (((tld = lower(TRIM(BOTH FROM tld))) AND (tld ~~ '.%'::text) AND ((length(tld) >= 2) AND (length(tld) <= 63)))),
  CONSTRAINT "tenant_domain_orders_years_chk" CHECK (((term_years >= 1) AND (term_years <= 99)))
);

ALTER TABLE "public"."tenant_domain_orders"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenant_domain_orders" FROM "anon";

CREATE TABLE "public"."tenant_domains" (
  "id"                  uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"           uuid                     NOT NULL,
  "hostname"            text                     NOT NULL,
  "domain_type"         text                     NOT NULL DEFAULT 'subdomain'::text,
  "status"              text                     NOT NULL DEFAULT 'pending'::text,
  "is_primary"          boolean                  NOT NULL DEFAULT false,
  "verification_token"  text,
  "verified_at"         timestamp with time zone,
  "activated_at"        timestamp with time zone,
  "metadata"            jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"          timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"          timestamp with time zone NOT NULL DEFAULT now(),
  "acquisition_source"  text                     NOT NULL DEFAULT 'connected'::text,
  "registrar_provider"  text,
  "registrar_domain_id" text,
  "registered_at"       timestamp with time zone,
  "expires_at"          timestamp with time zone,
  "auto_renew"          boolean                  NOT NULL DEFAULT false,
  "provider_metadata"   jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  CONSTRAINT "tenant_domains_acquisition_source_chk" CHECK ((acquisition_source = ANY (ARRAY['connected'::text, 'purchased'::text, 'transferred'::text]))),
  CONSTRAINT "tenant_domains_domain_type_check" CHECK ((domain_type = ANY (ARRAY['subdomain'::text, 'custom'::text]))),
  CONSTRAINT "tenant_domains_hostname_format"
    CHECK (((hostname = lower(TRIM(BOTH FROM hostname))) AND ((length(TRIM(BOTH FROM hostname)) >= 3) AND (length(TRIM(BOTH FROM hostname)) <= 253)))),
  CONSTRAINT "tenant_domains_hostname_unique" UNIQUE (hostname),
  CONSTRAINT "tenant_domains_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_domains_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'verified'::text, 'active'::text, 'disabled'::text]))),
  CONSTRAINT "tenant_domains_tenant_id_id_unique" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."tenant_domains"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenant_domains" FROM "anon";

CREATE TABLE "public"."tenant_email_notification_settings" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"  uuid                     NOT NULL,
  "event_code" text                     NOT NULL,
  "enabled"    boolean                  NOT NULL DEFAULT true,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "tenant_email_notification_settings_event_code_check"
    CHECK
    ((event_code = ANY (ARRAY['offer_sent'::text, 'offer_accepted'::text, 'offer_refused'::text, 'item_received'::text, 'item_dispatched'::text, 'payment_sent'::text,
    'order_confirmation'::text, 'order_dispatched'::text, 'return_received'::text, 'refund_issued'::text]))),
  CONSTRAINT "tenant_email_notification_settings_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_email_notification_settings_tenant_id_event_code_key" UNIQUE (tenant_id, event_code),
  CONSTRAINT "tenant_email_notification_settings_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."tenant_email_notification_settings"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenant_email_notification_settings" FROM "anon";

CREATE TABLE "public"."tenant_email_settings" (
  "id"                         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"                  uuid                     NOT NULL,
  "sender_email"               text                     NOT NULL,
  "reply_to_email"             text,
  "sender_name"                text,
  "email_enabled"              boolean                  NOT NULL DEFAULT true,
  "created_at"                 timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"                 timestamp with time zone NOT NULL DEFAULT now(),
  "sender_verification_status" text                     NOT NULL DEFAULT 'unverified'::text,
  "sender_verified_at"         timestamp with time zone,
  "sender_provider"            text,
  "sender_provider_id"         text,
  "email_footer"               text,
  "business_name_override"     text,
  CONSTRAINT "tenant_email_settings_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_email_settings_reply_to_email_check"
    CHECK (((reply_to_email IS NULL) OR ((length(TRIM(BOTH FROM reply_to_email)) >= 3) AND (length(TRIM(BOTH FROM reply_to_email)) <= 320)))),
  CONSTRAINT "tenant_email_settings_sender_email_check" CHECK (((length(TRIM(BOTH FROM sender_email)) >= 3) AND (length(TRIM(BOTH FROM sender_email)) <= 320))),
  CONSTRAINT "tenant_email_settings_sender_verification_status_check"
    CHECK ((sender_verification_status = ANY (ARRAY['unverified'::text, 'pending'::text, 'verified'::text, 'failed'::text]))),
  CONSTRAINT "tenant_email_settings_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "tenant_email_settings_tenant_id_key" UNIQUE (tenant_id)
);

ALTER TABLE "public"."tenant_email_settings"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenant_email_settings" FROM "anon";

CREATE TABLE "public"."tenant_memberships" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"  uuid                     NOT NULL,
  "user_id"    uuid                     NOT NULL,
  "role_code"  text                     NOT NULL DEFAULT 'staff'::text,
  "status"     text                     NOT NULL DEFAULT 'active'::text,
  "invited_at" timestamp with time zone,
  "joined_at"  timestamp with time zone,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "tenant_memberships_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_memberships_role_code_check" CHECK ((role_code = ANY (ARRAY['owner'::text, 'admin'::text, 'staff'::text]))),
  CONSTRAINT "tenant_memberships_status_check" CHECK ((status = ANY (ARRAY['invited'::text, 'active'::text, 'suspended'::text, 'removed'::text]))),
  CONSTRAINT "tenant_memberships_tenant_id_user_id_key" UNIQUE (tenant_id, user_id)
);

ALTER TABLE "public"."tenant_memberships"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenant_memberships" FROM "anon";

CREATE TABLE "public"."tenant_payment_methods" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"    uuid                     NOT NULL,
  "method_code"  text                     NOT NULL,
  "display_name" text                     NOT NULL,
  "enabled"      boolean                  NOT NULL DEFAULT true,
  "instructions" text,
  "sort_order"   integer                  NOT NULL DEFAULT 0,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "tenant_payment_methods_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_payment_methods_tenant_id_method_code_key" UNIQUE (tenant_id, method_code)
);

ALTER TABLE "public"."tenant_payment_methods"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."tenant_public_profiles" (
  "tenant_id"     uuid                     NOT NULL,
  "public_email"  text,
  "public_phone"  text,
  "address_line1" text,
  "address_line2" text,
  "city"          text,
  "county"        text,
  "postcode"      text,
  "country_code"  text                     NOT NULL DEFAULT 'GB'::text,
  "description"   text,
  "logo_url"      text,
  "show_email"    boolean                  NOT NULL DEFAULT true,
  "show_phone"    boolean                  NOT NULL DEFAULT true,
  "show_address"  boolean                  NOT NULL DEFAULT true,
  "updated_at"    timestamp with time zone NOT NULL DEFAULT now(),
  "business_name" text,
  "banner_url"    text,
  CONSTRAINT "tenant_public_profiles_pkey" PRIMARY KEY (tenant_id)
);

ALTER TABLE "public"."tenant_public_profiles"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."tenant_shipping_services" (
  "id"           uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"    uuid                     NOT NULL,
  "service_code" text                     NOT NULL,
  "service_name" text                     NOT NULL,
  "service_url"  text                     NOT NULL,
  "enabled"      boolean                  NOT NULL DEFAULT true,
  "sort_order"   integer                  NOT NULL DEFAULT 0,
  "created_at"   timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"   timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "tenant_shipping_services_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_shipping_services_tenant_id_service_code_key" UNIQUE (tenant_id, service_code)
);

ALTER TABLE "public"."tenant_shipping_services"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."tenant_site_state" (
  "tenant_id"             uuid                     NOT NULL,
  "draft_revision_id"     uuid                     NOT NULL,
  "published_revision_id" uuid,
  "updated_at"            timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "tenant_site_state_pkey" PRIMARY KEY (tenant_id)
);

ALTER TABLE "public"."tenant_site_state"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenant_site_state" FROM "anon";

CREATE TABLE "public"."tenant_subscriptions" (
  "id"                       uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"                uuid                     NOT NULL,
  "plan_id"                  uuid                     NOT NULL,
  "status"                   text                     NOT NULL DEFAULT 'trialing'::text,
  "billing_provider"         text,
  "provider_customer_id"     text,
  "provider_subscription_id" text,
  "current_period_start"     timestamp with time zone,
  "current_period_end"       timestamp with time zone,
  "cancel_at_period_end"     boolean                  NOT NULL DEFAULT false,
  "trial_end"                timestamp with time zone,
  "started_at"               timestamp with time zone NOT NULL DEFAULT now(),
  "ended_at"                 timestamp with time zone,
  "metadata"                 jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"               timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"               timestamp with time zone NOT NULL DEFAULT now(),
  "provider_price_id"        text,
  "billing_interval"         text,
  "provider_status"          text,
  "provider_metadata"        jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  CONSTRAINT "tenant_subscriptions_billing_interval_check" CHECK (((billing_interval IS NULL) OR (billing_interval = ANY (ARRAY['month'::text, 'year'::text, 'one_time'::text])))),
  CONSTRAINT "tenant_subscriptions_billing_provider_check" CHECK (((billing_provider IS NULL) OR (billing_provider = ANY (ARRAY['stripe'::text, 'manual'::text, 'other'::text])))),
  CONSTRAINT "tenant_subscriptions_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenant_subscriptions_status_check"
    CHECK ((status = ANY (ARRAY['trialing'::text, 'active'::text, 'past_due'::text, 'paused'::text, 'cancelled'::text, 'expired'::text])))
);

ALTER TABLE "public"."tenant_subscriptions"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenant_subscriptions" FROM "anon";

CREATE TABLE "public"."tenants" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "name"        text                     NOT NULL,
  "slug"        text                     NOT NULL,
  "status"      text                     NOT NULL DEFAULT 'active'::text,
  "settings"    jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "archived_at" timestamp with time zone,
  CONSTRAINT "tenants_pkey" PRIMARY KEY (id),
  CONSTRAINT "tenants_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'suspended'::text, 'archived'::text])))
);

ALTER TABLE "public"."tenants"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tenants" FROM "anon";

CREATE TABLE "public"."trade_in_transactions" (
  "id"                  uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"           uuid                     NOT NULL,
  "trade_in_reference"  text                     NOT NULL,
  "customer_id"         uuid                     NOT NULL,
  "buying_request_id"   uuid,
  "buying_item_id"      uuid,
  "offer_id"            uuid,
  "acquisition_id"      uuid,
  "acquisition_item_id" uuid,
  "status"              text                     NOT NULL DEFAULT 'valuation_requested'::text,
  "valuation_method"    text,
  "trading_value"       numeric(12,2),
  "cash_price"          numeric(12,2),
  "trade_in_price"      numeric(12,2),
  "credit_amount"       numeric(12,2),
  "currency"            text                     NOT NULL DEFAULT 'GBP'::text,
  "customer_notes"      text,
  "staff_notes"         text,
  "metadata"            jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "requested_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "valued_at"           timestamp with time zone,
  "accepted_at"         timestamp with time zone,
  "received_at"         timestamp with time zone,
  "credited_at"         timestamp with time zone,
  "completed_at"        timestamp with time zone,
  "cancelled_at"        timestamp with time zone,
  "created_by"          uuid,
  "created_at"          timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"          timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "trade_in_transactions_cash_price_check" CHECK (((cash_price IS NULL) OR (cash_price >= (0)::numeric))),
  CONSTRAINT "trade_in_transactions_check" CHECK (((buying_item_id IS NULL) OR (buying_request_id IS NOT NULL))),
  CONSTRAINT "trade_in_transactions_credit_amount_check" CHECK (((credit_amount IS NULL) OR (credit_amount >= (0)::numeric))),
  CONSTRAINT "trade_in_transactions_currency_check" CHECK ((char_length(currency) = 3)),
  CONSTRAINT "trade_in_transactions_pkey" PRIMARY KEY (id),
  CONSTRAINT "trade_in_transactions_status_check"
    CHECK
    ((status = ANY (ARRAY['valuation_requested'::text, 'valued'::text, 'offer_pending'::text, 'accepted'::text, 'item_awaiting'::text, 'received'::text, 'inspection'::text,
    'approved'::text, 'credited'::text, 'rejected'::text, 'cancelled'::text, 'completed'::text]))),
  CONSTRAINT "trade_in_transactions_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "trade_in_transactions_tenant_id_trade_in_reference_key" UNIQUE (tenant_id, trade_in_reference),
  CONSTRAINT "trade_in_transactions_trade_in_price_check" CHECK (((trade_in_price IS NULL) OR (trade_in_price >= (0)::numeric))),
  CONSTRAINT "trade_in_transactions_trading_value_check" CHECK (((trading_value IS NULL) OR (trading_value >= (0)::numeric))),
  CONSTRAINT "trade_in_transactions_valuation_method_check"
    CHECK (((valuation_method IS NULL) OR (valuation_method = ANY (ARRAY['manual'::text, 'rule'::text, 'market'::text, 'ai'::text]))))
);

ALTER TABLE "public"."trade_in_transactions"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."trade_in_transactions" FROM "anon";

CREATE TABLE "public"."trading_value_components" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"        uuid                     NOT NULL,
  "trading_value_id" uuid                     NOT NULL,
  "component_type"   text                     NOT NULL,
  "label"            text                     NOT NULL,
  "amount"           numeric(14,2)            NOT NULL,
  "source_reference" jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "notes"            text,
  "sort_order"       integer                  NOT NULL DEFAULT 0,
  "created_at"       timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "trading_value_components_pkey" PRIMARY KEY (id),
  CONSTRAINT "trading_value_components_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."trading_value_components"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."trading_value_components" FROM "anon";

CREATE TABLE "public"."trading_values" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"        uuid                     NOT NULL,
  "buying_item_id"   uuid                     NOT NULL,
  "method"           text                     NOT NULL DEFAULT 'manual'::text,
  "status"           text                     NOT NULL DEFAULT 'draft'::text,
  "amount"           numeric(14,2)            NOT NULL,
  "currency"         text                     NOT NULL DEFAULT 'GBP'::text,
  "confidence"       numeric(5,4),
  "calculated_at"    timestamp with time zone NOT NULL DEFAULT now(),
  "approved_at"      timestamp with time zone,
  "approved_by"      uuid,
  "superseded_at"    timestamp with time zone,
  "notes"            text,
  "metadata"         jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "cash_price"       numeric,
  "trade_in_price"   numeric,
  "effective_from"   timestamp with time zone,
  "effective_to"     timestamp with time zone,
  "approved_by_name" text,
  CONSTRAINT "trading_values_amount_check" CHECK ((amount >= (0)::numeric)),
  CONSTRAINT "trading_values_cash_price_check" CHECK (((cash_price IS NULL) OR (cash_price >= (0)::numeric))),
  CONSTRAINT "trading_values_check1" CHECK ((((status = 'superseded'::text) AND (superseded_at IS NOT NULL)) OR (status <> 'superseded'::text))),
  CONSTRAINT "trading_values_check" CHECK ((((status = 'approved'::text) AND (approved_at IS NOT NULL)) OR (status <> 'approved'::text))),
  CONSTRAINT "trading_values_confidence_check" CHECK (((confidence IS NULL) OR ((confidence >= (0)::numeric) AND (confidence <= (1)::numeric)))),
  CONSTRAINT "trading_values_currency_check" CHECK ((currency ~ '^[A-Z]{3}$'::text)),
  CONSTRAINT "trading_values_effective_period_check" CHECK (((effective_to IS NULL) OR (effective_from IS NULL) OR (effective_to > effective_from))),
  CONSTRAINT "trading_values_method_check" CHECK ((method = ANY (ARRAY['manual'::text, 'rule'::text, 'market'::text, 'ai'::text]))),
  CONSTRAINT "trading_values_pkey" PRIMARY KEY (id),
  CONSTRAINT "trading_values_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'approved'::text, 'superseded'::text]))),
  CONSTRAINT "trading_values_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "trading_values_tenant_item_id_key" UNIQUE (tenant_id, buying_item_id, id),
  CONSTRAINT "trading_values_trade_in_price_check" CHECK (((trade_in_price IS NULL) OR (trade_in_price >= (0)::numeric)))
);

ALTER TABLE "public"."trading_values"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."trading_values" FROM "anon";

CREATE TABLE "public"."valuation_rules" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"        uuid                     NOT NULL,
  "category_id"      uuid                     NOT NULL,
  "name"             text                     NOT NULL,
  "version"          integer                  NOT NULL DEFAULT 1,
  "priority"         integer                  NOT NULL DEFAULT 100,
  "criteria"         jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "adjustment_logic" jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "active"           boolean                  NOT NULL DEFAULT true,
  "starts_at"        timestamp with time zone,
  "ends_at"          timestamp with time zone,
  "notes"            text,
  "created_at"       timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"       timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "valuation_rules_check" CHECK (((ends_at IS NULL) OR (starts_at IS NULL) OR (ends_at > starts_at))),
  CONSTRAINT "valuation_rules_pkey" PRIMARY KEY (id),
  CONSTRAINT "valuation_rules_tenant_id_id_key" UNIQUE (tenant_id, id),
  CONSTRAINT "valuation_rules_version_check" CHECK ((version > 0))
);

ALTER TABLE "public"."valuation_rules"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."valuation_rules" FROM "anon";

CREATE TABLE "public"."workflow_transitions" (
  "id"            uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id"     uuid                     NOT NULL,
  "entity_type"   text                     NOT NULL,
  "entity_id"     uuid                     NOT NULL,
  "from_status"   text                     NOT NULL,
  "to_status"     text                     NOT NULL,
  "actor_user_id" uuid,
  "notes"         text,
  "metadata"      jsonb                    NOT NULL DEFAULT '{}'::jsonb,
  "created_at"    timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "workflow_transitions_pkey" PRIMARY KEY (id),
  CONSTRAINT "workflow_transitions_status_change_chk" CHECK ((from_status <> to_status)),
  CONSTRAINT "workflow_transitions_tenant_id_id_key" UNIQUE (tenant_id, id)
);

ALTER TABLE "public"."workflow_transitions"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."workflow_transitions" FROM "anon";

CREATE OR REPLACE FUNCTION private.bootstrap_tenant_site()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_revision_id uuid;
  v_content jsonb;
begin
  v_content := jsonb_build_object(
    'schema_version', 1,
    'site', jsonb_build_object(
      'name', new.name,
      'homepage', jsonb_build_object(),
      'navigation', jsonb_build_array(),
      'theme', jsonb_build_object(),
      'pages', jsonb_build_array(),
      'category_manifest', jsonb_build_array()
    )
  );

  insert into public.site_revisions (
    tenant_id, revision_number, status, content, created_by
  ) values (
    new.id, 1, 'draft', v_content, null
  ) returning id into v_revision_id;

  insert into public.tenant_site_state (
    tenant_id, draft_revision_id, published_revision_id
  ) values (
    new.id, v_revision_id, null
  );

  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION private.can_tenant (
  p_tenant_id       uuid,
  p_permission_code text,
  p_feature_code    text DEFAULT NULL::text
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  SELECT private.has_tenant_permission(p_tenant_id, auth.uid(), p_permission_code)
     AND (p_feature_code IS NULL OR private.has_tenant_feature(p_tenant_id, p_feature_code));
$function$;

CREATE OR REPLACE FUNCTION private.create_tenant_with_owner (
  p_name text,
  p_slug text
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_user_id uuid := auth.uid();
  v_tenant_id uuid;
  v_slug text := lower(trim(p_slug));
  v_name text := trim(p_name);
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  if v_name = '' then
    raise exception 'Tenant name is required';
  end if;

  if v_slug = '' or v_slug !~ '^[a-z0-9]+([a-z0-9-]*[a-z0-9])?$' then
    raise exception 'Tenant slug must contain lowercase letters, numbers and hyphens only';
  end if;

  if exists (select 1 from public.tenants where lower(slug) = v_slug) then
    raise exception 'Tenant slug is already in use';
  end if;

  insert into public.tenants (name, slug)
  values (v_name, v_slug)
  returning id into v_tenant_id;

  insert into public.tenant_memberships (tenant_id, user_id, role_code, status, joined_at)
  values (v_tenant_id, v_user_id, 'owner', 'active', now());

  return v_tenant_id;
end;
$function$;

CREATE OR REPLACE FUNCTION private.current_tenant_plan (
  p_tenant_id uuid
)
  RETURNS text
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  SELECT pl.code
  FROM public.tenant_subscriptions ts
  JOIN public.plans pl ON pl.id = ts.plan_id AND pl.active = true
  WHERE ts.tenant_id = p_tenant_id
    AND ts.status IN ('trialing','active','past_due')
    AND (ts.ended_at IS NULL OR ts.ended_at > now())
  ORDER BY CASE ts.status WHEN 'active' THEN 1 WHEN 'trialing' THEN 2 WHEN 'past_due' THEN 3 ELSE 9 END,
           ts.started_at DESC
  LIMIT 1;
$function$;

CREATE OR REPLACE FUNCTION private.customer_can_access_buying_item_shipping (
  p_tenant_id      uuid,
  p_buying_item_id uuid,
  p_auth_user_id   uuid
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
  select exists (
    select 1
    from public.customers c
    join public.buying_requests br
      on br.tenant_id = c.tenant_id
     and br.customer_id = c.id
    join public.buying_items bi
      on bi.buying_request_id = br.id
     and bi.tenant_id = c.tenant_id
    where c.tenant_id = p_tenant_id
      and c.auth_user_id = p_auth_user_id
      and bi.id = p_buying_item_id
  );
$function$;

CREATE OR REPLACE FUNCTION private.customer_id_for_current_user (
  p_tenant_id uuid
)
  RETURNS uuid
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select c.id
  from public.customers c
  where c.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  limit 1
$function$;

CREATE OR REPLACE FUNCTION private.customer_id_for_user (
  p_tenant_id uuid,
  p_user_id   uuid DEFAULT auth.uid()
)
  RETURNS uuid
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select c.id
  from public.customers c
  where c.tenant_id = p_tenant_id
    and c.auth_user_id = coalesce(p_user_id, auth.uid())
  limit 1;
$function$;

CREATE OR REPLACE FUNCTION private.guard_site_revision_lifecycle()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if tg_op = 'DELETE' then
    if old.status in ('published','archived') then
      raise exception 'Published or archived site revisions cannot be deleted';
    end if;
    return old;
  end if;

  if old.status in ('published','archived') then
    if current_user <> 'postgres' then
      raise exception 'Published or archived site revisions are immutable';
    end if;
  end if;

  if old.status = 'draft' and new.status = 'archived' then
    raise exception 'Draft revisions cannot be archived directly';
  end if;

  if new.status = 'published' and old.status <> 'published' and current_user <> 'postgres' then
    raise exception 'Use the authoritative publish function';
  end if;

  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION private.has_platform_owner_access (
  p_user_id uuid DEFAULT auth.uid()
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select p_user_id = auth.uid() and private.is_platform_owner(p_user_id);
$function$;

CREATE OR REPLACE FUNCTION private.has_tenant_feature (
  p_tenant_id    uuid,
  p_feature_code text
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select coalesce(p_tenant_id is not null and nullif(trim(p_feature_code), '') is not null, false)
     and exists (
       select 1
       from public.tenant_subscriptions ts
       join public.plans pl
         on pl.id = ts.plan_id
        and pl.active = true
       join public.plan_features pf
         on pf.plan_id = pl.id
        and pf.enabled = true
        and pf.feature_code = p_feature_code
       where ts.tenant_id = p_tenant_id
         and (
           (ts.status = 'trialing' and ts.trial_end is not null and ts.trial_end > now())
           or
           (ts.status in ('active','past_due') and ts.current_period_end is not null and ts.current_period_end > now())
         )
         and (ts.ended_at is null or ts.ended_at > now())
     );
$function$;

CREATE OR REPLACE FUNCTION private.has_tenant_permission (
  p_tenant_id       uuid,
  p_user_id         uuid,
  p_permission_code text
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$ select exists(select 1 from public.tenant_memberships tm join public.roles r on r.code=tm.role_code and r.active join public.role_permissions rp on rp.role_id=r.id join public.permissions p on p.id=rp.permission_id and p.code=p_permission_code and p.active where tm.tenant_id=p_tenant_id and tm.user_id=p_user_id and tm.status='active'); $function$;

CREATE OR REPLACE FUNCTION private.has_tenant_role (
  p_tenant_id uuid,
  p_user_id   uuid,
  p_role_code text
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$ select exists(select 1 from public.tenant_memberships tm where tm.tenant_id=p_tenant_id and tm.user_id=p_user_id and tm.role_code=p_role_code and tm.status='active'); $function$;

CREATE OR REPLACE FUNCTION private.is_active_tenant (
  p_tenant_id uuid
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select exists (
    select 1
    from public.tenants t
    where t.id = p_tenant_id
      and t.status = 'active'
  );
$function$;

CREATE OR REPLACE FUNCTION private.is_platform_owner (
  p_user_id uuid DEFAULT auth.uid()
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select exists (
    select 1
    from public.platform_memberships pm
    where pm.user_id = p_user_id
      and pm.status = 'active'
  );
$function$;

CREATE OR REPLACE FUNCTION private.is_tenant_admin (
  p_tenant_id uuid,
  p_user_id   uuid DEFAULT auth.uid()
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select exists (
    select 1
    from public.tenant_memberships tm
    where tm.tenant_id = p_tenant_id
      and tm.user_id = p_user_id
      and tm.status = 'active'
      and tm.role_code in ('owner','admin')
  );
$function$;

CREATE OR REPLACE FUNCTION private.is_tenant_member (
  p_tenant_id uuid,
  p_user_id   uuid DEFAULT auth.uid()
)
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select exists (
    select 1
    from public.tenant_memberships tm
    where tm.tenant_id = p_tenant_id
      and tm.user_id = p_user_id
      and tm.status = 'active'
  );
$function$;

CREATE OR REPLACE FUNCTION private.platform_admin_create_tenant (
  p_name          text,
  p_slug          text,
  p_owner_user_id uuid,
  p_plan_code     text
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_tenant_id uuid;
  v_plan_id uuid;
begin
  if not private.has_platform_owner_access() then
    raise exception 'platform owner access required';
  end if;

  if nullif(btrim(p_name),'') is null then
    raise exception 'business name is required';
  end if;
  if nullif(btrim(p_slug),'') is null then
    raise exception 'business slug is required';
  end if;
  if p_owner_user_id is null then
    raise exception 'owner user ID is required';
  end if;
  if not exists (select 1 from auth.users where id=p_owner_user_id) then
    raise exception 'owner auth user does not exist';
  end if;

  select id into v_plan_id from public.plans where code=lower(btrim(p_plan_code)) and active=true;
  if v_plan_id is null then
    raise exception 'active subscription plan not found';
  end if;

  if exists (select 1 from public.tenants where lower(slug)=lower(btrim(p_slug))) then
    raise exception 'tenant slug already exists';
  end if;

  insert into public.tenants(name,slug,status)
  values (btrim(p_name), lower(btrim(p_slug)), 'active')
  returning id into v_tenant_id;

  insert into public.tenant_memberships(tenant_id,user_id,role_code,status,joined_at)
  values (v_tenant_id,p_owner_user_id,'owner','active',now());

  insert into public.tenant_subscriptions(tenant_id,plan_id,status,billing_provider)
  values (v_tenant_id,v_plan_id,'trialing','manual');

  return v_tenant_id;
exception
  when unique_violation then
    raise exception 'tenant could not be created because a unique value already exists';
end;
$function$;

CREATE OR REPLACE FUNCTION private.platform_admin_find_user (
  p_email text
)
  RETURNS TABLE (
    user_id         uuid,
    email           text,
    email_confirmed boolean
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_platform_owner();
  return query
  select u.id, u.email::text, (u.email_confirmed_at is not null)
  from auth.users u
  where lower(u.email)=lower(btrim(p_email))
  limit 1;
end;
$function$;

CREATE OR REPLACE FUNCTION private.platform_admin_list_subscriber_accounts()
  RETURNS TABLE (
    tenant_id               uuid,
    business_name           text,
    business_slug           text,
    business_status         text,
    owner_name              text,
    owner_email             text,
    owner_membership_status text,
    joined_at               timestamp with time zone
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
  perform private.require_platform_owner();

  return query
  select
    t.id,
    t.name,
    t.slug,
    t.status,
    coalesce(
      nullif(u.raw_user_meta_data->>'full_name',''),
      nullif(u.raw_user_meta_data->>'name',''),
      ''
    )::text as owner_name,
    u.email::text,
    tm.status,
    coalesce(tm.joined_at, tm.created_at, t.created_at)
  from public.tenants t
  left join lateral (
    select tm1.*
    from public.tenant_memberships tm1
    where tm1.tenant_id=t.id
      and tm1.role_code='owner'
    order by tm1.created_at asc
    limit 1
  ) tm on true
  left join auth.users u on u.id=tm.user_id
  where coalesce((t.settings->>'test_lab')::boolean,false)=false
  order by t.created_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION private.platform_admin_list_tenants()
  RETURNS TABLE (
    tenant_id           uuid,
    tenant_name         text,
    tenant_slug         text,
    tenant_status       text,
    plan_code           text,
    plan_name           text,
    subscription_status text,
    owner_count         bigint,
    member_count        bigint,
    created_at          timestamp with time zone
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_platform_owner();
  return query
  select
    t.id,
    t.name,
    t.slug,
    t.status,
    p.code,
    p.name,
    ts.status,
    coalesce((select count(*) from public.tenant_memberships tm where tm.tenant_id=t.id and tm.role_code='owner' and tm.status='active'),0),
    coalesce((select count(*) from public.tenant_memberships tm where tm.tenant_id=t.id and tm.status='active'),0),
    t.created_at
  from public.tenants t
  left join lateral (
    select ts1.* from public.tenant_subscriptions ts1
    where ts1.tenant_id=t.id
    order by ts1.created_at desc
    limit 1
  ) ts on true
  left join public.plans p on p.id=ts.plan_id
  order by t.created_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION private.platform_admin_manage_subscription (
  p_tenant_id uuid,
  p_action    text,
  p_plan_code text DEFAULT NULL::text
)
  RETURNS TABLE (
    tenant_id           uuid,
    tenant_status       text,
    plan_code           text,
    subscription_status text
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_subscription public.tenant_subscriptions%rowtype;
  v_plan public.plans%rowtype;
  v_current_plan public.plans%rowtype;
  v_action text := lower(btrim(coalesce(p_action,'')));
begin
  perform private.require_platform_owner();

  if p_tenant_id is null then
    raise exception 'tenant ID is required';
  end if;

  if not exists (select 1 from public.tenants where id=p_tenant_id) then
    raise exception 'subscriber business not found';
  end if;

  select ts.*
  into v_subscription
  from public.tenant_subscriptions ts
  where ts.tenant_id=p_tenant_id
  order by ts.created_at desc
  limit 1;

  if v_subscription.id is null then
    raise exception 'subscription record not found';
  end if;

  if v_action='upgrade' then
    select p.* into v_plan
    from public.plans p
    where p.code=lower(btrim(p_plan_code))
      and p.active=true
    limit 1;

    if v_plan.id is null then
      raise exception 'active target plan not found';
    end if;

    select p.* into v_current_plan
    from public.plans p
    where p.id=v_subscription.plan_id
    limit 1;

    if v_current_plan.id is null then
      raise exception 'current plan not found';
    end if;

    if v_plan.sort_order <= v_current_plan.sort_order then
      raise exception 'target plan is not an upgrade';
    end if;

    update public.tenant_subscriptions
    set plan_id=v_plan.id,
        metadata=coalesce(metadata,'{}'::jsonb)
          || jsonb_build_object(
               'last_platform_change','upgrade',
               'last_platform_change_at',now(),
               'previous_plan_code',v_current_plan.code
             ),
        updated_at=now()
    where id=v_subscription.id;

  elsif v_action='close' then
    update public.tenant_subscriptions
    set status='cancelled',
        ended_at=coalesce(ended_at,now()),
        cancel_at_period_end=false,
        metadata=coalesce(metadata,'{}'::jsonb)
          || jsonb_build_object(
               'closed_by_platform_owner',true,
               'closed_at',now(),
               'close_reason','platform_owner_close'
             ),
        updated_at=now()
    where id=v_subscription.id;

    update public.tenants
    set status='archived',
        archived_at=coalesce(archived_at,now()),
        updated_at=now()
    where id=p_tenant_id;

  else
    raise exception 'unsupported platform subscription action';
  end if;

  return query
  select
    t.id,
    t.status,
    p.code,
    ts.status
  from public.tenants t
  join public.tenant_subscriptions ts on ts.tenant_id=t.id
  join public.plans p on p.id=ts.plan_id
  where t.id=p_tenant_id
  order by ts.created_at desc
  limit 1;
end;
$function$;

CREATE OR REPLACE FUNCTION private.provision_platform_owner (
  p_user_id uuid
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
BEGIN
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'Platform Owner user ID is required';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = p_user_id) THEN
    RAISE EXCEPTION 'Auth user does not exist';
  END IF;

  INSERT INTO public.platform_memberships (user_id, status)
  VALUES (p_user_id, 'active')
  ON CONFLICT (user_id) DO UPDATE
    SET status = 'active';
END;
$function$;

CREATE OR REPLACE FUNCTION private.queue_buying_request_received_notification()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare v_customer record; v_item record; v_sender record; v_name text;
begin
 select c.email,c.first_name,c.last_name into v_customer from public.customers c where c.tenant_id=new.tenant_id and c.id=new.customer_id;
 select bi.item_reference,bi.title into v_item from public.buying_items bi where bi.tenant_id=new.tenant_id and bi.buying_request_id=new.id order by bi.sort_order limit 1;
 v_name:=trim(coalesce(v_customer.first_name,'')||' '||coalesce(v_customer.last_name,''));
 if v_customer.email is not null then
   perform private.queue_customer_notification(new.tenant_id,'valuation_received','buying_request',new.id,v_customer.email,v_name,jsonb_build_object('customer_name',v_name,'item_title',coalesce(v_item.title,'your item'),'item_reference',coalesce(v_item.item_reference,''),'request_reference',new.request_reference));
 end if;
 select sender_email,sender_name,email_enabled,sender_verification_status into v_sender from public.tenant_email_settings where tenant_id=new.tenant_id;
 if v_sender.sender_email is not null then
   perform private.queue_customer_notification(new.tenant_id,'customer_buying_request_received','buying_request',new.id,v_sender.sender_email,coalesce(v_sender.sender_name,''),jsonb_build_object('customer_name',v_name,'item_title',coalesce(v_item.title,'customer item'),'item_reference',coalesce(v_item.item_reference,''),'request_reference',new.request_reference));
 end if;
 return new;
end $function$;

CREATE OR REPLACE FUNCTION private.queue_customer_notification (
  p_tenant_id       uuid,
  p_event_code      text,
  p_entity_type     text,
  p_entity_id       uuid,
  p_recipient_email text,
  p_recipient_name  text  DEFAULT NULL::text,
  p_payload         jsonb DEFAULT '{}'::jsonb
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare v_template public.notification_templates%rowtype; v_enabled boolean; v_notification_id uuid; v_idempotency text;
begin
 if p_tenant_id is null or p_event_code is null or p_entity_type is null or p_entity_id is null or p_recipient_email is null then raise exception 'notification arguments are incomplete'; end if;
 select coalesce(email_enabled,false) into v_enabled from public.tenant_email_settings where tenant_id=p_tenant_id;
 if not found or not v_enabled then return null; end if;
 select enabled into v_enabled from public.tenant_email_notification_settings where tenant_id=p_tenant_id and event_code=p_event_code;
 if not found then v_enabled:=true; end if;
 if not v_enabled then return null; end if;
 select * into v_template from public.notification_templates where tenant_id=p_tenant_id and event_code=p_event_code and enabled=true limit 1;
 if not found then select * into v_template from public.notification_templates where tenant_id is null and event_code=p_event_code and enabled=true and is_system=true limit 1; end if;
 if not found then raise exception 'no notification template configured for event %',p_event_code; end if;
 v_idempotency:=p_tenant_id::text||':'||p_event_code||':'||p_entity_type||':'||p_entity_id::text;
 insert into public.notification_event_log(tenant_id,event_code,entity_type,entity_id,payload) values(p_tenant_id,p_event_code,p_entity_type,p_entity_id,p_payload) on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;
 insert into public.notification_queue(tenant_id,event_code,recipient_email,recipient_name,subject,template_code,payload,status,idempotency_key)
 values(p_tenant_id,p_event_code,p_recipient_email,p_recipient_name,v_template.subject_template,v_template.template_code,p_payload,'queued',v_idempotency)
 on conflict (tenant_id,idempotency_key) do nothing
 returning id into v_notification_id;
 return v_notification_id;
end; $function$;

CREATE OR REPLACE FUNCTION private.require_platform_owner (
  p_user_id uuid DEFAULT auth.uid()
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if p_user_id is distinct from auth.uid() then raise exception 'platform owner identity mismatch'; end if;
  if not private.is_platform_owner(auth.uid()) then raise exception 'platform owner access required'; end if;
end;
$function$;

CREATE OR REPLACE FUNCTION private.require_tenant_feature (
  p_tenant_id    uuid,
  p_feature_code text
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if p_tenant_id is null or p_feature_code is null or btrim(p_feature_code) = '' then raise exception 'tenant and feature are required'; end if;
  if not private.has_tenant_feature(p_tenant_id, p_feature_code) then raise exception 'Subscription capability required: %', p_feature_code; end if;
end; $function$;

CREATE OR REPLACE FUNCTION private.touch_fulfilment_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$ begin new.updated_at = now(); return new; end; $function$;

CREATE OR REPLACE FUNCTION private.touch_site_publication_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  new.updated_at := now();
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.activate_master_catalogue_products (
  p_tenant_id          uuid,
  p_master_product_ids uuid[],
  p_buying_enabled     boolean DEFAULT false,
  p_selling_enabled    boolean DEFAULT false
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_ids uuid[];
  v_product_count integer := 0;
  v_category_count integer := 0;
  v_branch_count integer := 0;
  v_buying_count integer := 0;
  v_selling_count integer := 0;
begin
  if not (select private.has_tenant_permission(p_tenant_id, auth.uid(), 'categories.manage')) then
    raise exception 'Tenant user is not authorised to manage catalogue selections';
  end if;

  if not (
    select private.has_tenant_feature(p_tenant_id, 'module.buying')
    or private.has_tenant_feature(p_tenant_id, 'module.selling')
  ) then
    raise exception 'Catalogue selection is not enabled for this subscription';
  end if;

  if not (select private.has_tenant_feature(p_tenant_id, 'catalogue.pre_filled')) then
    raise exception 'Pre-filled catalogue is not enabled for this subscription';
  end if;

  if coalesce(array_length(p_master_product_ids, 1), 0) = 0 then
    raise exception 'Select at least one catalogue product';
  end if;

  select array_agg(distinct p.id)
  into v_ids
  from public.catalogue_master_products p
  where p.id = any(p_master_product_ids)
    and p.active
    and p.customer_visible;

  if coalesce(array_length(v_ids, 1), 0) = 0 then
    raise exception 'No active catalogue products were found';
  end if;

  -- The subscriber-facing category is the copied catalogue_category label.
  insert into public.categories
    (tenant_id,name,slug,description,active,buying_enabled,selling_enabled,sort_order)
  select distinct
    p_tenant_id,
    coalesce(nullif(trim(mp.catalogue_category),''), mc.name),
    lower(regexp_replace(regexp_replace(coalesce(nullif(trim(mp.catalogue_category),''),mc.name),'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')),
    'TradeFlow master catalogue category',
    true,
    false,
    false,
    row_number() over (
      order by coalesce(nullif(trim(mp.catalogue_category),''),mc.name)
    )::integer
  from public.catalogue_master_products mp
  join public.catalogue_master_categories mc on mc.id=mp.category_id
  where mp.id=any(v_ids)
    and not exists (
      select 1
      from public.categories c
      where c.tenant_id=p_tenant_id
        and lower(c.slug)=lower(
          regexp_replace(
            regexp_replace(coalesce(nullif(trim(mp.catalogue_category),''),mc.name),'[^a-zA-Z0-9]+','-','g'),
            '^-+|-+$','','g'
          )
        )
    )
  on conflict do nothing;

  -- Branch names remain the standalone TradeFlow master branch labels,
  -- but are created under the newly selected subscriber category.
  insert into public.category_branches
    (tenant_id,category_id,name,slug,description,active,buying_enabled,selling_enabled,sort_order)
  select distinct
    p_tenant_id,
    c.id,
    mb.name,
    lower(regexp_replace(regexp_replace(mb.name,'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')),
    'TradeFlow master catalogue branch',
    true,
    false,
    false,
    row_number() over (partition by c.id order by mb.name)::integer
  from public.catalogue_master_products mp
  join public.catalogue_master_categories mc on mc.id=mp.category_id
  left join public.catalogue_master_branches mb on mb.id=mp.branch_id
  join public.categories c
    on c.tenant_id=p_tenant_id
   and lower(c.slug)=lower(
     regexp_replace(
       regexp_replace(coalesce(nullif(trim(mp.catalogue_category),''),mc.name),'[^a-zA-Z0-9]+','-','g'),
       '^-+|-+$','','g'
     )
   )
  where mp.id=any(v_ids)
    and mb.id is not null
    and not exists (
      select 1
      from public.category_branches b
      where b.tenant_id=p_tenant_id
        and b.category_id=c.id
        and lower(b.slug)=lower(
          regexp_replace(regexp_replace(mb.name,'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')
        )
    )
  on conflict do nothing;

  insert into public.tenant_buying_manufacturers(tenant_id,name,active)
  select distinct p_tenant_id,m.name,m.active
  from public.catalogue_master_products mp
  join public.catalogue_master_manufacturers m on m.id=mp.manufacturer_id
  where mp.id=any(v_ids)
    and not exists (
      select 1
      from public.tenant_buying_manufacturers tm
      where tm.tenant_id=p_tenant_id
        and lower(tm.name)=lower(m.name)
    );

  insert into public.tenant_catalogue_selections
    (tenant_id,master_product_id,category_id,branch_id,manufacturer,model,package_name,buying_enabled,selling_enabled,active,updated_at)
  select
    p_tenant_id,
    mp.id,
    c.id,
    b.id,
    m.name,
    mp.model,
    mp.package_name,
    p_buying_enabled,
    p_selling_enabled,
    true,
    now()
  from public.catalogue_master_products mp
  join public.catalogue_master_categories mc on mc.id=mp.category_id
  join public.categories c
    on c.tenant_id=p_tenant_id
   and lower(c.slug)=lower(
     regexp_replace(
       regexp_replace(coalesce(nullif(trim(mp.catalogue_category),''),mc.name),'[^a-zA-Z0-9]+','-','g'),
       '^-+|-+$','','g'
     )
   )
  left join public.catalogue_master_branches mb on mb.id=mp.branch_id
  left join public.category_branches b
    on b.tenant_id=p_tenant_id
   and b.category_id=c.id
   and mb.id is not null
   and lower(b.slug)=lower(
     regexp_replace(regexp_replace(mb.name,'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')
   )
  join public.catalogue_master_manufacturers m on m.id=mp.manufacturer_id
  where mp.id=any(v_ids)
  on conflict (tenant_id,master_product_id) do update set
    category_id=excluded.category_id,
    branch_id=excluded.branch_id,
    manufacturer=excluded.manufacturer,
    model=excluded.model,
    package_name=excluded.package_name,
    buying_enabled=excluded.buying_enabled,
    selling_enabled=excluded.selling_enabled,
    active=true,
    updated_at=now();

  if p_buying_enabled then
    insert into public.tenant_buying_products
      (tenant_id,category_id,branch_id,manufacturer,model,package_name,active,automatic_percentage,manual_offer_price,pricing_notes)
    select
      s.tenant_id,
      s.category_id,
      s.branch_id,
      s.manufacturer,
      s.model,
      s.package_name,
      true,
      null,
      null,
      'TradeFlow catalogue selection; no buying price is configured until the subscriber adds research-based pricing or a manual override.'
    from public.tenant_catalogue_selections s
    where s.tenant_id=p_tenant_id
      and s.master_product_id=any(v_ids)
      and s.buying_enabled
      and not exists (
        select 1
        from public.tenant_buying_products tp
        where tp.tenant_id=s.tenant_id
          and tp.category_id=s.category_id
          and tp.branch_id is not distinct from s.branch_id
          and lower(tp.manufacturer)=lower(s.manufacturer)
          and lower(tp.model)=lower(s.model)
          and lower(coalesce(tp.package_name,''))=lower(coalesce(s.package_name,''))
      );
  else
    update public.tenant_buying_products tp
    set active=false,updated_at=now()
    where tp.tenant_id=p_tenant_id
      and exists (
        select 1
        from public.tenant_catalogue_selections s
        where s.tenant_id=p_tenant_id
          and s.master_product_id=any(v_ids)
          and s.category_id=tp.category_id
          and s.branch_id is not distinct from tp.branch_id
          and lower(s.manufacturer)=lower(tp.manufacturer)
          and lower(s.model)=lower(tp.model)
          and lower(coalesce(s.package_name,''))=lower(coalesce(tp.package_name,''))
          and not s.buying_enabled
      );
  end if;

  update public.categories c
  set buying_enabled = exists (
        select 1 from public.tenant_catalogue_selections s
        where s.tenant_id=p_tenant_id and s.category_id=c.id and s.buying_enabled and s.active
      ),
      selling_enabled = exists (
        select 1 from public.tenant_catalogue_selections s
        where s.tenant_id=p_tenant_id and s.category_id=c.id and s.selling_enabled and s.active
      ),
      updated_at=now()
  where c.tenant_id=p_tenant_id
    and exists (
      select 1 from public.tenant_catalogue_selections s
      where s.tenant_id=p_tenant_id and s.category_id=c.id
    );

  update public.category_branches b
  set buying_enabled = exists (
        select 1 from public.tenant_catalogue_selections s
        where s.tenant_id=p_tenant_id and s.branch_id=b.id and s.buying_enabled and s.active
      ),
      selling_enabled = exists (
        select 1 from public.tenant_catalogue_selections s
        where s.tenant_id=p_tenant_id and s.branch_id=b.id and s.selling_enabled and s.active
      ),
      updated_at=now()
  where b.tenant_id=p_tenant_id
    and exists (
      select 1 from public.tenant_catalogue_selections s
      where s.tenant_id=p_tenant_id and s.branch_id=b.id
    );

  select count(*) into v_product_count
  from public.tenant_catalogue_selections
  where tenant_id=p_tenant_id and master_product_id=any(v_ids);

  select count(distinct category_id) into v_category_count
  from public.tenant_catalogue_selections
  where tenant_id=p_tenant_id and master_product_id=any(v_ids);

  select count(distinct branch_id) into v_branch_count
  from public.tenant_catalogue_selections
  where tenant_id=p_tenant_id and master_product_id=any(v_ids) and branch_id is not null;

  select count(*) into v_buying_count
  from public.tenant_catalogue_selections
  where tenant_id=p_tenant_id and master_product_id=any(v_ids) and buying_enabled;

  select count(*) into v_selling_count
  from public.tenant_catalogue_selections
  where tenant_id=p_tenant_id and master_product_id=any(v_ids) and selling_enabled;

  return jsonb_build_object(
    'products',v_product_count,
    'categories',v_category_count,
    'branches',v_branch_count,
    'buying_products',v_buying_count,
    'selling_products',v_selling_count
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."activate_master_catalogue_products"(uuid, uuid[], boolean, boolean) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.add_master_buying_products_bulk (
  p_tenant_id                      uuid,
  p_master_product_ids             uuid[],
  p_mode                           text    DEFAULT 'manual'::text,
  p_sealed_percentage              numeric DEFAULT NULL::numeric,
  p_opened_never_used_percentage   numeric DEFAULT NULL::numeric,
  p_excellent_percentage           numeric DEFAULT NULL::numeric,
  p_good_percentage                numeric DEFAULT NULL::numeric,
  p_poor_percentage                numeric DEFAULT NULL::numeric,
  p_sealed_manual_price            numeric DEFAULT NULL::numeric,
  p_opened_never_used_manual_price numeric DEFAULT NULL::numeric,
  p_excellent_manual_price         numeric DEFAULT NULL::numeric,
  p_good_manual_price              numeric DEFAULT NULL::numeric,
  p_poor_manual_price              numeric DEFAULT NULL::numeric
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_id uuid;v_count int:=0;v_skipped int:=0;v_mode text:=lower(trim(coalesce(p_mode,'manual')));
begin
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.view') then raise exception 'Tenant user is not authorised to configure Buying catalogue';end if;
 if not private.has_tenant_feature(p_tenant_id,'module.buying') then raise exception 'Buying is not enabled for this subscription';end if;
 if v_mode not in ('manual','automatic') then raise exception 'Bulk add supports Manual valuation or Automatic pricing only';end if;
 if v_mode='automatic' and (p_sealed_percentage is null or p_opened_never_used_percentage is null or p_excellent_percentage is null or p_good_percentage is null or p_poor_percentage is null) then raise exception 'Automatic pricing requires five percentages between 0 and 100';end if;
 foreach v_id in array coalesce(p_master_product_ids,array[]::uuid[]) loop
  if exists(select 1 from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and s.master_product_id=v_id and s.buying_enabled and s.active) then v_skipped:=v_skipped+1;
  else
   perform public.configure_master_catalogue_buying_product(p_tenant_id,v_id,v_mode,null,p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,p_good_percentage,p_poor_percentage);
   if v_mode='automatic' then
    update public.tenant_buying_condition_rules r set sealed_manual_price=p_sealed_manual_price,opened_never_used_manual_price=p_opened_never_used_manual_price,excellent_manual_price=p_excellent_manual_price,good_manual_price=p_good_manual_price,poor_manual_price=p_poor_manual_price,updated_at=now()
    where r.tenant_id=p_tenant_id and r.buying_product_id in(select bp.id from public.tenant_buying_products bp join public.tenant_catalogue_selections s on s.tenant_id=bp.tenant_id and s.category_id=bp.category_id and s.branch_id is not distinct from bp.branch_id and lower(s.manufacturer)=lower(bp.manufacturer) and lower(s.model)=lower(bp.model) and lower(coalesce(s.package_name,''))=lower(coalesce(bp.package_name,'')) where s.tenant_id=p_tenant_id and s.master_product_id=v_id and s.active);
   end if;
   v_count:=v_count+1;
  end if;
 end loop;
 return jsonb_build_object('added',v_count,'skipped',v_skipped,'mode',case when v_mode='automatic' then 'automatic' else 'manual_valuation' end);
end;$function$;

REVOKE ALL
  ON FUNCTION "public"."add_master_buying_products_bulk"(uuid, uuid[], text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.add_master_buying_products_filtered (
  p_tenant_id                      uuid,
  p_category_id                    uuid    DEFAULT NULL::uuid,
  p_branch_id                      uuid    DEFAULT NULL::uuid,
  p_manufacturer_id                uuid    DEFAULT NULL::uuid,
  p_search                         text    DEFAULT NULL::text,
  p_mode                           text    DEFAULT 'manual'::text,
  p_sealed_percentage              numeric DEFAULT NULL::numeric,
  p_opened_never_used_percentage   numeric DEFAULT NULL::numeric,
  p_excellent_percentage           numeric DEFAULT NULL::numeric,
  p_good_percentage                numeric DEFAULT NULL::numeric,
  p_poor_percentage                numeric DEFAULT NULL::numeric,
  p_sealed_manual_price            numeric DEFAULT NULL::numeric,
  p_opened_never_used_manual_price numeric DEFAULT NULL::numeric,
  p_excellent_manual_price         numeric DEFAULT NULL::numeric,
  p_good_manual_price              numeric DEFAULT NULL::numeric,
  p_poor_manual_price              numeric DEFAULT NULL::numeric
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare ids uuid[];v_search text:=nullif(trim(coalesce(p_search,'')),'');
begin
 select coalesce(array_agg(p.id),'{}'::uuid[]) into ids from public.catalogue_master_products p
 where p.active and p.customer_visible
 and(p_category_id is null or p.category_id=p_category_id) and(p_branch_id is null or p.branch_id=p_branch_id) and(p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
 and(v_search is null or lower(coalesce(p.model,'')) like '%'||lower(v_search)||'%' or lower(coalesce(p.package_name,'')) like '%'||lower(v_search)||'%' or lower(coalesce(p.product_type,'')) like '%'||lower(v_search)||'%' or lower(coalesce(p.notes,'')) like '%'||lower(v_search)||'%')
 and not exists(select 1 from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and s.master_product_id=p.id and s.active and s.buying_enabled);
 return public.add_master_buying_products_bulk(p_tenant_id,ids,p_mode,p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,p_good_percentage,p_poor_percentage,p_sealed_manual_price,p_opened_never_used_manual_price,p_excellent_manual_price,p_good_manual_price,p_poor_manual_price);
end;$function$;

REVOKE ALL
  ON FUNCTION
    "public"."add_master_buying_products_filtered"(uuid, uuid, uuid, uuid, text, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.admin_complete_test_registration (
  p_tenant_slug text
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$ declare v_uid uuid := auth.uid(); v_tenant_id uuid; v_membership_id uuid; v_email text; begin if v_uid is null then raise exception 'Authentication required'; end if; if p_tenant_slug not in ('test-business-a','test-business-b') then raise exception 'Test tenant not permitted'; end if; select email into v_email from auth.users where id=v_uid and email_confirmed_at is not null; if v_email is null then raise exception 'Confirmed email required'; end if; select id into v_tenant_id from public.tenants where slug=p_tenant_slug and status='active'; if v_tenant_id is null then raise exception 'Test tenant not found'; end if; if exists (select 1 from public.customers where auth_user_id=v_uid) then raise exception 'Auth account is already linked to a customer'; end if; if exists (select 1 from public.tenant_memberships where user_id=v_uid) then raise exception 'Auth account already has a tenant membership'; end if; insert into public.tenant_memberships (tenant_id,user_id,role_code,status) values (v_tenant_id,v_uid,'admin','active') returning id into v_membership_id; return v_membership_id; end; $function$;

REVOKE ALL ON FUNCTION "public"."admin_complete_test_registration"(text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.apply_buying_catalogue_bulk (
  p_tenant_id                      uuid,
  p_master_product_ids             uuid[]  DEFAULT NULL::uuid[],
  p_mode                           text    DEFAULT 'automatic'::text,
  p_sealed_percentage              numeric DEFAULT NULL::numeric,
  p_opened_never_used_percentage   numeric DEFAULT NULL::numeric,
  p_excellent_percentage           numeric DEFAULT NULL::numeric,
  p_good_percentage                numeric DEFAULT NULL::numeric,
  p_poor_percentage                numeric DEFAULT NULL::numeric,
  p_sealed_manual_price            numeric DEFAULT NULL::numeric,
  p_opened_never_used_manual_price numeric DEFAULT NULL::numeric,
  p_excellent_manual_price         numeric DEFAULT NULL::numeric,
  p_good_manual_price              numeric DEFAULT NULL::numeric,
  p_poor_manual_price              numeric DEFAULT NULL::numeric,
  p_all_matching                   boolean DEFAULT false,
  p_category_id                    uuid    DEFAULT NULL::uuid,
  p_branch_id                      uuid    DEFAULT NULL::uuid,
  p_manufacturer_id                uuid    DEFAULT NULL::uuid,
  p_search                         text    DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_id uuid;
  v_mode text := lower(trim(coalesce(p_mode,'automatic')));
  v_count integer := 0;
  v_skipped integer := 0;
  v_search text := nullif(trim(coalesce(p_search,'')),'');
  v_bp_id uuid;
  v_category_id uuid;
  v_branch_id uuid;
  v_manufacturer text;
  v_model text;
  v_package text;
begin
  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'categories.manage') then
    raise exception 'Tenant user is not authorised to configure Buying catalogue';
  end if;
  if not private.has_tenant_feature(p_tenant_id, 'module.buying') then
    raise exception 'Buying is not enabled for this subscription';
  end if;
  if v_mode not in ('manual','automatic','off') then
    raise exception 'Bulk action must be manual, automatic or off';
  end if;

  for v_id in
    select distinct s.master_product_id
    from public.tenant_catalogue_selections s
    join public.catalogue_master_products p on p.id=s.master_product_id
    where s.tenant_id=p_tenant_id
      and s.buying_enabled and s.active
      and p.active and p.customer_visible
      and (
        (not coalesce(p_all_matching,false)
         and s.master_product_id = any(coalesce(p_master_product_ids,array[]::uuid[])))
        or
        (coalesce(p_all_matching,false)
         and (p_category_id is null or p.category_id=p_category_id)
         and (p_branch_id is null or p.branch_id=p_branch_id)
         and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
         and (
           v_search is null
           or lower(coalesce(p.model,'')) like '%'||lower(v_search)||'%'
           or lower(coalesce(p.package_name,'')) like '%'||lower(v_search)||'%'
           or lower(coalesce(p.product_type,'')) like '%'||lower(v_search)||'%'
           or lower(coalesce(p.notes,'')) like '%'||lower(v_search)||'%'
         )
        )
      )
  loop
    select s.category_id,s.branch_id,s.manufacturer,s.model,s.package_name
      into v_category_id,v_branch_id,v_manufacturer,v_model,v_package
    from public.tenant_catalogue_selections s
    where s.tenant_id=p_tenant_id and s.master_product_id=v_id
      and s.buying_enabled and s.active
    limit 1;

    select bp.id into v_bp_id
    from public.tenant_buying_products bp
    where bp.tenant_id=p_tenant_id
      and bp.category_id=v_category_id
      and bp.branch_id is not distinct from v_branch_id
      and lower(bp.manufacturer)=lower(v_manufacturer)
      and lower(bp.model)=lower(v_model)
      and lower(coalesce(bp.package_name,''))=lower(coalesce(v_package,''))
    order by bp.active desc, bp.updated_at desc
    limit 1;

    if v_bp_id is null then
      v_skipped := v_skipped + 1;
      continue;
    end if;

    if v_mode='off' then
      update public.tenant_catalogue_selections
      set buying_enabled=false, updated_at=now()
      where tenant_id=p_tenant_id and master_product_id=v_id;

      update public.tenant_buying_products
      set active=false, automatic_percentage=null, manual_offer_price=null, updated_at=now()
      where id=v_bp_id and tenant_id=p_tenant_id;

      delete from public.tenant_buying_condition_rules
      where tenant_id=p_tenant_id and buying_product_id=v_bp_id;
    elsif v_mode='manual' then
      update public.tenant_catalogue_selections
      set buying_enabled=true, active=true, updated_at=now()
      where tenant_id=p_tenant_id and master_product_id=v_id;

      update public.tenant_buying_products
      set active=true, automatic_percentage=null, manual_offer_price=null,
          pricing_notes='Manual valuation. No fixed buying price or automatic rule configured.',
          updated_at=now()
      where id=v_bp_id and tenant_id=p_tenant_id;

      delete from public.tenant_buying_condition_rules
      where tenant_id=p_tenant_id and buying_product_id=v_bp_id;
    else
      if p_sealed_percentage is null or p_opened_never_used_percentage is null
         or p_excellent_percentage is null or p_good_percentage is null or p_poor_percentage is null
         or p_sealed_percentage < 0 or p_sealed_percentage > 100
         or p_opened_never_used_percentage < 0 or p_opened_never_used_percentage > 100
         or p_excellent_percentage < 0 or p_excellent_percentage > 100
         or p_good_percentage < 0 or p_good_percentage > 100
         or p_poor_percentage < 0 or p_poor_percentage > 100 then
        raise exception 'Automatic pricing requires five percentages between 0 and 100';
      end if;

      update public.tenant_catalogue_selections
      set buying_enabled=true, active=true, updated_at=now()
      where tenant_id=p_tenant_id and master_product_id=v_id;

      update public.tenant_buying_products
      set active=true, automatic_percentage=null, manual_offer_price=null,
          pricing_notes='Automatic condition pricing controlled from the Buying Catalogue.',
          updated_at=now()
      where id=v_bp_id and tenant_id=p_tenant_id;

      insert into public.tenant_buying_condition_rules
        (tenant_id,buying_product_id,
         sealed_percentage,opened_never_used_percentage,excellent_percentage,good_percentage,poor_percentage,
         sealed_reference_type,opened_never_used_reference_type,excellent_reference_type,good_reference_type,poor_reference_type,
         sealed_manual_price,opened_never_used_manual_price,excellent_manual_price,good_manual_price,poor_manual_price)
      values
        (p_tenant_id,v_bp_id,
         p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,p_good_percentage,p_poor_percentage,
         'uk_new','uk_new','uk_used','uk_used','uk_used',
         p_sealed_manual_price,p_opened_never_used_manual_price,p_excellent_manual_price,p_good_manual_price,p_poor_manual_price)
      on conflict (tenant_id,buying_product_id) do update set
        sealed_percentage=excluded.sealed_percentage,
        opened_never_used_percentage=excluded.opened_never_used_percentage,
        excellent_percentage=excluded.excellent_percentage,
        good_percentage=excluded.good_percentage,
        poor_percentage=excluded.poor_percentage,
        sealed_reference_type=excluded.sealed_reference_type,
        opened_never_used_reference_type=excluded.opened_never_used_reference_type,
        excellent_reference_type=excluded.excellent_reference_type,
        good_reference_type=excluded.good_reference_type,
        poor_reference_type=excluded.poor_reference_type,
        sealed_manual_price=excluded.sealed_manual_price,
        opened_never_used_manual_price=excluded.opened_never_used_manual_price,
        excellent_manual_price=excluded.excellent_manual_price,
        good_manual_price=excluded.good_manual_price,
        poor_manual_price=excluded.poor_manual_price,
        updated_at=now();
    end if;

    v_count := v_count + 1;
  end loop;

  return jsonb_build_object('updated',v_count,'skipped',v_skipped,'mode',v_mode,'all_matching',coalesce(p_all_matching,false));
end;
$function$;

REVOKE ALL
  ON FUNCTION
    "public"."apply_buying_catalogue_bulk"(uuid, uuid[], text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, boolean, uuid, uuid, uuid,
    text)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.calculate_buying_item_valuation (
  p_tenant_id      uuid,
  p_buying_item_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
 v_item record;
 v_product record;
 v_rule record;
 v_research_new record;
 v_pct numeric;
 v_base numeric;
 v_manual numeric;
 v_trade_pct numeric;
 v_trade_manual numeric;
 v_condition text;
 v_source text;
 v_url text;
begin
 if not private.can_tenant(p_tenant_id,'valuation.manage','module.valuation') then raise exception 'Not authorised to calculate buying valuation'; end if;

 select bi.id,bi.tenant_id,bi.buying_product_id,bi.item_condition
 into v_item
 from public.buying_items bi
 where bi.id=p_buying_item_id and bi.tenant_id=p_tenant_id;
 if not found then raise exception 'Buying item not found'; end if;

 if v_item.buying_product_id is null then
   return jsonb_build_object('mode','manual','reason','product_not_selected');
 end if;

 select bp.id,bp.manufacturer,bp.model,bp.package_name,bp.branch_id,bp.manual_offer_price
 into v_product
 from public.tenant_buying_products bp
 where bp.id=v_item.buying_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
 if not found then return jsonb_build_object('mode','manual','reason','buying_product_not_found'); end if;

 if v_product.manual_offer_price is not null then
   return jsonb_build_object('mode','manual_override','reason','manual_product_price_configured','amount',v_product.manual_offer_price,'trade_in_amount',null,'currency','GBP','manufacturer',v_product.manufacturer,'model',v_product.model);
 end if;

 v_condition:=case v_item.item_condition
   when 'factory-sealed' then 'sealed'
   when 'opened-unused' then 'opened_never_used'
   when 'opened_never_used' then 'opened_never_used'
   when 'sealed' then 'sealed'
   when 'excellent' then 'excellent'
   when 'good' then 'good'
   when 'fair' then 'poor'
   when 'damaged' then 'poor'
   when 'not-working' then 'poor'
   when 'not_working' then 'poor'
   when 'poor' then 'poor'
   else v_item.item_condition
 end;

 if v_condition is null then return jsonb_build_object('mode','manual','reason','condition_required'); end if;

 select * into v_rule
 from public.tenant_buying_condition_rules r
 where r.tenant_id=p_tenant_id and r.buying_product_id=v_product.id
 limit 1;
 if not found then return jsonb_build_object('mode','manual','reason','condition_pricing_not_configured','condition',v_condition); end if;

 v_pct:=case v_condition
   when 'sealed' then v_rule.sealed_percentage
   when 'opened_never_used' then v_rule.opened_never_used_percentage
   when 'excellent' then v_rule.excellent_percentage
   when 'good' then v_rule.good_percentage
   when 'poor' then v_rule.poor_percentage
 end;

 v_manual:=case v_condition
   when 'sealed' then v_rule.sealed_manual_price
   when 'opened_never_used' then v_rule.opened_never_used_manual_price
   when 'excellent' then v_rule.excellent_manual_price
   when 'good' then v_rule.good_manual_price
   when 'poor' then v_rule.poor_manual_price
 end;

 v_trade_pct:=case v_condition
   when 'sealed' then v_rule.sealed_trade_in_percentage
   when 'opened_never_used' then v_rule.opened_never_used_trade_in_percentage
   when 'excellent' then v_rule.excellent_trade_in_percentage
   when 'good' then v_rule.good_trade_in_percentage
   when 'poor' then v_rule.poor_trade_in_percentage
 end;

 v_trade_manual:=case v_condition
   when 'sealed' then v_rule.sealed_trade_in_manual_price
   when 'opened_never_used' then v_rule.opened_never_used_trade_in_manual_price
   when 'excellent' then v_rule.excellent_trade_in_manual_price
   when 'good' then v_rule.good_trade_in_manual_price
   when 'poor' then v_rule.poor_trade_in_manual_price
 end;

 if v_manual is not null or v_trade_manual is not null then
   return jsonb_build_object(
     'mode','manual_override',
     'reason','manual_condition_price_configured',
     'condition',v_condition,
     'amount',v_manual,
     'trade_in_amount',v_trade_manual,
     'currency','GBP',
     'percentage',v_pct,
     'trade_in_percentage',v_trade_pct,
     'reference_type','uk_new',
     'manufacturer',v_product.manufacturer,
     'model',v_product.model
   );
 end if;

 select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at
 into v_research_new
 from public.tenant_buying_research tr
 where tr.tenant_id=p_tenant_id
   and tr.buying_product_id=v_product.id
   and tr.evidence_type='uk_new'
   and tr.observed_price is not null
   and upper(coalesce(tr.price_currency,'GBP'))='GBP'
 order by tr.checked_at desc
 limit 1;

 if not found or v_research_new.observed_price is null then
   return jsonb_build_object(
     'mode','manual',
     'reason','no_research_for_uk_new',
     'condition',v_condition,
     'percentage',v_pct,
     'trade_in_percentage',v_trade_pct,
     'reference_type','uk_new'
   );
 end if;

 v_base:=v_research_new.observed_price;
 v_source:=v_research_new.source_name;
 v_url:=v_research_new.source_url;

 if v_pct is null then
   return jsonb_build_object(
     'mode','manual',
     'reason','condition_percentage_not_set',
     'condition',v_condition,
     'base_price',v_base,
     'reference_type','uk_new',
     'trade_in_percentage',v_trade_pct
   );
 end if;

 return jsonb_build_object(
   'mode','automatic',
   'reason','percentage_of_uk_new_reference',
   'condition',v_condition,
   'amount',round(v_base*v_pct/100,2),
   'trade_in_amount',case when v_trade_pct is null then null else round(v_base*v_trade_pct/100,2) end,
   'percentage',v_pct,
   'trade_in_percentage',v_trade_pct,
   'base_price',v_base,
   'currency','GBP',
   'reference_type','uk_new',
   'source_name',v_source,
   'source_url',v_url,
   'manufacturer',v_product.manufacturer,
   'model',v_product.model
 );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."calculate_buying_item_valuation"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.claim_notification_queue_batch (
  p_limit integer DEFAULT 20
)
  RETURNS TABLE (
    id              uuid,
    tenant_id       uuid,
    recipient_email text,
    recipient_name  text,
    subject         text,
    template_code   text,
    body_template   text,
    payload         jsonb,
    idempotency_key text,
    email_settings  jsonb
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
 return query with picked as (
 select q.id from public.notification_queue q
 join public.tenant_email_settings ts on ts.tenant_id=q.tenant_id
 cross join public.platform_email_settings ps
 where q.status='queued' and coalesce(q.scheduled_for,now())<=now() and q.attempts<5
   and ts.email_enabled=true and ts.sender_email is not null
   and ps.email_enabled=true and ps.sender_email is not null
   and ps.sender_verification_status='verified'
 order by q.created_at for update skip locked
 limit greatest(1,least(coalesce(p_limit,20),100))
 ), claimed as (
 update public.notification_queue q set status='processing',attempts=q.attempts+1,updated_at=now() from picked p where q.id=p.id returning q.*
 )
 select c.id,c.tenant_id,c.recipient_email,c.recipient_name,c.subject,c.template_code,coalesce(t.body_template,''),c.payload,c.idempotency_key,
 jsonb_build_object(
   'sender_email',ps.sender_email,'sender_name',ps.sender_name,'email_enabled',ps.email_enabled,
   'sender_verification_status',ps.sender_verification_status,
   'reply_to_email',ts.sender_email
 )
 from claimed c
 join public.tenant_email_settings ts on ts.tenant_id=c.tenant_id
 cross join public.platform_email_settings ps
 left join public.notification_templates t on t.template_code=c.template_code and t.enabled=true
 order by c.created_at;
end $function$;

REVOKE ALL ON FUNCTION "public"."claim_notification_queue_batch"(integer) FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.configure_master_catalogue_buying_product (
  p_tenant_id                    uuid,
  p_master_product_id            uuid,
  p_mode                         text,
  p_manual_price                 numeric DEFAULT NULL::numeric,
  p_sealed_percentage            numeric DEFAULT NULL::numeric,
  p_opened_never_used_percentage numeric DEFAULT NULL::numeric,
  p_excellent_percentage         numeric DEFAULT NULL::numeric,
  p_good_percentage              numeric DEFAULT NULL::numeric,
  p_poor_percentage              numeric DEFAULT NULL::numeric
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare mp record;mc record;mb record;mm record;v_category_id uuid;v_branch_id uuid;v_buying_product_id uuid;v_mode text:=lower(trim(coalesce(p_mode,'')));
begin
if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.manage') then raise exception 'Tenant user is not authorised to manage catalogue pricing'; end if;
if not private.has_tenant_feature(p_tenant_id,'module.buying') then raise exception 'Buying is not enabled for this subscription'; end if;
if not private.has_tenant_feature(p_tenant_id,'catalogue.pre_filled') then raise exception 'Pre-filled catalogue is not enabled for this subscription'; end if;
if v_mode not in ('off','manual','automatic') then raise exception 'Invalid buying mode. Use off, manual or automatic'; end if;
if v_mode='automatic' and (p_sealed_percentage is null or p_opened_never_used_percentage is null or p_excellent_percentage is null or p_good_percentage is null or p_poor_percentage is null or p_sealed_percentage<0 or p_sealed_percentage>100 or p_opened_never_used_percentage<0 or p_opened_never_used_percentage>100 or p_excellent_percentage<0 or p_excellent_percentage>100 or p_good_percentage<0 or p_good_percentage>100 or p_poor_percentage<0 or p_poor_percentage>100) then raise exception 'Automatic pricing requires five percentages between 0 and 100'; end if;
select p.*,c.name master_category_name,b.name master_branch_name,m.name manufacturer_name into mp from public.catalogue_master_products p join public.catalogue_master_categories c on c.id=p.category_id left join public.catalogue_master_branches b on b.id=p.branch_id join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id where p.id=p_master_product_id and p.active and p.customer_visible;
if not found then raise exception 'Master catalogue product not found'; end if;
select id,name into mm from public.tenant_buying_manufacturers where tenant_id=p_tenant_id and lower(name)=lower(mp.manufacturer_name) limit 1;
if not found then insert into public.tenant_buying_manufacturers(tenant_id,name,active) values(p_tenant_id,mp.manufacturer_name,true) returning id,name into mm; end if;
insert into public.categories(tenant_id,name,slug,description,active,buying_enabled,selling_enabled,sort_order) values(p_tenant_id,coalesce(nullif(trim(mp.catalogue_category),''),mp.master_category_name),lower(regexp_replace(regexp_replace(coalesce(nullif(trim(mp.catalogue_category),''),mp.master_category_name),'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')),'TradeFlow master catalogue category',true,true,false,0) on conflict do nothing;
select id into v_category_id from public.categories where tenant_id=p_tenant_id and lower(slug)=lower(regexp_replace(regexp_replace(coalesce(nullif(trim(mp.catalogue_category),''),mp.master_category_name),'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')) limit 1;
if mp.branch_id is not null then
insert into public.category_branches(tenant_id,category_id,name,slug,description,active,buying_enabled,selling_enabled,sort_order) values(p_tenant_id,v_category_id,mp.master_branch_name,lower(regexp_replace(regexp_replace(mp.master_branch_name,'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')),'TradeFlow master catalogue branch',true,true,false,0) on conflict do nothing;
select id into v_branch_id from public.category_branches where tenant_id=p_tenant_id and category_id=v_category_id and lower(slug)=lower(regexp_replace(regexp_replace(mp.master_branch_name,'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')) limit 1; end if;
insert into public.tenant_catalogue_selections(tenant_id,master_product_id,category_id,branch_id,manufacturer,model,package_name,buying_enabled,selling_enabled,active,updated_at) values(p_tenant_id,p_master_product_id,v_category_id,v_branch_id,mp.manufacturer_name,mp.model,mp.package_name,v_mode<>'off',false,true,now()) on conflict(tenant_id,master_product_id) do update set category_id=excluded.category_id,branch_id=excluded.branch_id,manufacturer=excluded.manufacturer,model=excluded.model,package_name=excluded.package_name,buying_enabled=excluded.buying_enabled,updated_at=now(),active=true;
select id into v_buying_product_id from public.tenant_buying_products where tenant_id=p_tenant_id and category_id=v_category_id and branch_id is not distinct from v_branch_id and lower(manufacturer)=lower(mp.manufacturer_name) and lower(model)=lower(mp.model) and lower(coalesce(package_name,''))=lower(coalesce(mp.package_name,'')) order by active desc,updated_at desc limit 1;
if v_mode='off' then
 if v_buying_product_id is not null then update public.tenant_buying_products set active=false,automatic_percentage=null,manual_offer_price=null,updated_at=now() where id=v_buying_product_id and tenant_id=p_tenant_id; delete from public.tenant_buying_condition_rules where tenant_id=p_tenant_id and buying_product_id=v_buying_product_id; end if;
else
 if v_buying_product_id is null then insert into public.tenant_buying_products(tenant_id,category_id,branch_id,manufacturer,model,package_name,active,automatic_percentage,manual_offer_price,pricing_notes) values(p_tenant_id,v_category_id,v_branch_id,mp.manufacturer_name,mp.model,mp.package_name,true,null,null,'TradeFlow master catalogue selection.') returning id into v_buying_product_id; else update public.tenant_buying_products set active=true,updated_at=now() where id=v_buying_product_id and tenant_id=p_tenant_id; end if;
 if v_mode='manual' then update public.tenant_buying_products set manual_offer_price=p_manual_price,automatic_percentage=null,pricing_notes='Manual buying price controlled from the master catalogue pricing page.',updated_at=now() where id=v_buying_product_id; delete from public.tenant_buying_condition_rules where tenant_id=p_tenant_id and buying_product_id=v_buying_product_id;
 else update public.tenant_buying_products set manual_offer_price=p_manual_price,automatic_percentage=null,pricing_notes='Automatic condition pricing controlled from the master catalogue pricing page.',updated_at=now() where id=v_buying_product_id;
 insert into public.tenant_buying_condition_rules(tenant_id,buying_product_id,sealed_percentage,opened_never_used_percentage,excellent_percentage,good_percentage,poor_percentage,sealed_reference_type,opened_never_used_reference_type,excellent_reference_type,good_reference_type,poor_reference_type,sealed_manual_price,opened_never_used_manual_price,excellent_manual_price,good_manual_price,poor_manual_price) values(p_tenant_id,v_buying_product_id,p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,p_good_percentage,p_poor_percentage,'uk_new','uk_new','uk_used','uk_used','uk_used',null,null,null,null,null) on conflict(tenant_id,buying_product_id) do update set sealed_percentage=excluded.sealed_percentage,opened_never_used_percentage=excluded.opened_never_used_percentage,excellent_percentage=excluded.excellent_percentage,good_percentage=excluded.good_percentage,poor_percentage=excluded.poor_percentage,sealed_reference_type=excluded.sealed_reference_type,opened_never_used_reference_type=excluded.opened_never_used_reference_type,excellent_reference_type=excluded.excellent_reference_type,good_reference_type=excluded.good_reference_type,poor_reference_type=excluded.poor_reference_type,updated_at=now();
 end if;
end if;
update public.categories c set buying_enabled=exists(select 1 from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and s.category_id=c.id and s.buying_enabled and s.active),updated_at=now() where c.tenant_id=p_tenant_id and c.id=v_category_id;
if v_branch_id is not null then update public.category_branches b set buying_enabled=exists(select 1 from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and s.branch_id=b.id and s.buying_enabled and s.active),updated_at=now() where b.tenant_id=p_tenant_id and b.id=v_branch_id; end if;
return jsonb_build_object('mode',v_mode,'master_product_id',p_master_product_id,'buying_product_id',v_buying_product_id,'category_id',v_category_id,'branch_id',v_branch_id);
end;$function$;

REVOKE ALL ON FUNCTION "public"."configure_master_catalogue_buying_product"(uuid, uuid, text, numeric, numeric, numeric, numeric, numeric, numeric) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.configure_master_catalogue_buying_product_pricing (
  p_tenant_id                               uuid,
  p_master_product_id                       uuid,
  p_mode                                    text,
  p_manual_price                            numeric DEFAULT NULL::numeric,
  p_sealed_percentage                       numeric DEFAULT NULL::numeric,
  p_opened_never_used_percentage            numeric DEFAULT NULL::numeric,
  p_excellent_percentage                    numeric DEFAULT NULL::numeric,
  p_good_percentage                         numeric DEFAULT NULL::numeric,
  p_poor_percentage                         numeric DEFAULT NULL::numeric,
  p_sealed_manual_price                     numeric DEFAULT NULL::numeric,
  p_opened_never_used_manual_price          numeric DEFAULT NULL::numeric,
  p_excellent_manual_price                  numeric DEFAULT NULL::numeric,
  p_good_manual_price                       numeric DEFAULT NULL::numeric,
  p_poor_manual_price                       numeric DEFAULT NULL::numeric,
  p_sealed_reference_type                   text    DEFAULT 'uk_new'::text,
  p_opened_never_used_reference_type        text    DEFAULT 'uk_new'::text,
  p_excellent_reference_type                text    DEFAULT 'uk_new'::text,
  p_good_reference_type                     text    DEFAULT 'uk_new'::text,
  p_poor_reference_type                     text    DEFAULT 'uk_new'::text,
  p_sealed_trade_in_percentage              numeric DEFAULT NULL::numeric,
  p_opened_never_used_trade_in_percentage   numeric DEFAULT NULL::numeric,
  p_excellent_trade_in_percentage           numeric DEFAULT NULL::numeric,
  p_good_trade_in_percentage                numeric DEFAULT NULL::numeric,
  p_poor_trade_in_percentage                numeric DEFAULT NULL::numeric,
  p_sealed_trade_in_manual_price            numeric DEFAULT NULL::numeric,
  p_opened_never_used_trade_in_manual_price numeric DEFAULT NULL::numeric,
  p_excellent_trade_in_manual_price         numeric DEFAULT NULL::numeric,
  p_good_trade_in_manual_price              numeric DEFAULT NULL::numeric,
  p_poor_trade_in_manual_price              numeric DEFAULT NULL::numeric
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
 v_result jsonb;
begin
 if lower(trim(coalesce(p_mode,'')))='automatic' then
   if (p_sealed_trade_in_percentage is not null and (p_sealed_trade_in_percentage<0 or p_sealed_trade_in_percentage>100))
   or (p_opened_never_used_trade_in_percentage is not null and (p_opened_never_used_trade_in_percentage<0 or p_opened_never_used_trade_in_percentage>100))
   or (p_excellent_trade_in_percentage is not null and (p_excellent_trade_in_percentage<0 or p_excellent_trade_in_percentage>100))
   or (p_good_trade_in_percentage is not null and (p_good_trade_in_percentage<0 or p_good_trade_in_percentage>100))
   or (p_poor_trade_in_percentage is not null and (p_poor_trade_in_percentage<0 or p_poor_trade_in_percentage>100)
   ) then
     raise exception 'Trade-in percentages must be between 0 and 100';
   end if;
 end if;

 v_result:=public.configure_master_catalogue_buying_product(
   p_tenant_id,p_master_product_id,p_mode,p_manual_price,
   p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,
   p_good_percentage,p_poor_percentage
 );

 if lower(trim(coalesce(p_mode,'')))='automatic' then
   update public.tenant_buying_condition_rules r
   set sealed_manual_price=p_sealed_manual_price,
       opened_never_used_manual_price=p_opened_never_used_manual_price,
       excellent_manual_price=p_excellent_manual_price,
       good_manual_price=p_good_manual_price,
       poor_manual_price=p_poor_manual_price,
       sealed_reference_type='uk_new',
       opened_never_used_reference_type='uk_new',
       excellent_reference_type='uk_new',
       good_reference_type='uk_new',
       poor_reference_type='uk_new',
       sealed_trade_in_percentage=p_sealed_trade_in_percentage,
       opened_never_used_trade_in_percentage=p_opened_never_used_trade_in_percentage,
       excellent_trade_in_percentage=p_excellent_trade_in_percentage,
       good_trade_in_percentage=p_good_trade_in_percentage,
       poor_trade_in_percentage=p_poor_trade_in_percentage,
       sealed_trade_in_manual_price=p_sealed_trade_in_manual_price,
       opened_never_used_trade_in_manual_price=p_opened_never_used_trade_in_manual_price,
       excellent_trade_in_manual_price=p_excellent_trade_in_manual_price,
       good_trade_in_manual_price=p_good_trade_in_manual_price,
       poor_trade_in_manual_price=p_poor_trade_in_manual_price,
       updated_at=now()
   where r.tenant_id=p_tenant_id
     and r.buying_product_id=(v_result->>'buying_product_id')::uuid;
 end if;

 return v_result;
end;
$function$;

REVOKE ALL
  ON FUNCTION
    "public"."configure_master_catalogue_buying_product_pricing"(uuid, uuid, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric,
    numeric, text, text, text, text, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.configure_master_catalogue_buying_products_bulk (
  p_tenant_id                    uuid,
  p_master_product_ids           uuid[],
  p_mode                         text    DEFAULT 'manual'::text,
  p_sealed_percentage            numeric DEFAULT NULL::numeric,
  p_opened_never_used_percentage numeric DEFAULT NULL::numeric,
  p_excellent_percentage         numeric DEFAULT NULL::numeric,
  p_good_percentage              numeric DEFAULT NULL::numeric,
  p_poor_percentage              numeric DEFAULT NULL::numeric
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_id uuid;
  v_count integer := 0;
  v_skipped integer := 0;
  v_mode text := lower(trim(coalesce(p_mode,'manual')));
begin
  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'categories.view') then
    raise exception 'Tenant user is not authorised to configure Buying catalogue';
  end if;
  if not private.has_tenant_feature(p_tenant_id, 'module.buying') then
    raise exception 'Buying is not enabled for this subscription';
  end if;
  if v_mode not in ('manual','automatic') then
    raise exception 'Bulk add supports Manual valuation or Automatic pricing only';
  end if;

  foreach v_id in array coalesce(p_master_product_ids, array[]::uuid[]) loop
    if exists (
      select 1 from public.tenant_catalogue_selections s
      where s.tenant_id=p_tenant_id
        and s.master_product_id=v_id
        and s.buying_enabled
        and s.active
    ) then
      v_skipped := v_skipped + 1;
    else
      perform public.configure_master_catalogue_buying_product(
        p_tenant_id,
        v_id,
        v_mode,
        null,
        p_sealed_percentage,
        p_opened_never_used_percentage,
        p_excellent_percentage,
        p_good_percentage,
        p_poor_percentage
      );
      v_count := v_count + 1;
    end if;
  end loop;

  return jsonb_build_object(
    'added',v_count,
    'skipped',v_skipped,
    'mode',case when v_mode='automatic' then 'automatic' else 'manual_valuation' end
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."configure_master_catalogue_buying_products_bulk"(uuid, uuid[], text, numeric, numeric, numeric, numeric, numeric) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.configure_master_catalogue_buying_products_bulk (
  p_tenant_id                      uuid,
  p_master_product_ids             uuid[],
  p_mode                           text    DEFAULT 'manual'::text,
  p_sealed_percentage              numeric DEFAULT NULL::numeric,
  p_opened_never_used_percentage   numeric DEFAULT NULL::numeric,
  p_excellent_percentage           numeric DEFAULT NULL::numeric,
  p_good_percentage                numeric DEFAULT NULL::numeric,
  p_poor_percentage                numeric DEFAULT NULL::numeric,
  p_sealed_manual_price            numeric DEFAULT NULL::numeric,
  p_opened_never_used_manual_price numeric DEFAULT NULL::numeric,
  p_excellent_manual_price         numeric DEFAULT NULL::numeric,
  p_good_manual_price              numeric DEFAULT NULL::numeric,
  p_poor_manual_price              numeric DEFAULT NULL::numeric
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_result jsonb;
begin
  v_result := public.configure_master_catalogue_buying_products_bulk(
    p_tenant_id,p_master_product_ids,p_mode,
    p_sealed_percentage,p_opened_never_used_percentage,
    p_excellent_percentage,p_good_percentage,p_poor_percentage
  );
  if lower(trim(coalesce(p_mode,'')))='automatic' then
    update public.tenant_buying_condition_rules r
    set sealed_manual_price=p_sealed_manual_price,
        opened_never_used_manual_price=p_opened_never_used_manual_price,
        excellent_manual_price=p_excellent_manual_price,
        good_manual_price=p_good_manual_price,
        poor_manual_price=p_poor_manual_price,
        updated_at=now()
    from public.tenant_catalogue_selections s
    where s.tenant_id=p_tenant_id
      and s.master_product_id=any(coalesce(p_master_product_ids,array[]::uuid[]))
      and s.buying_enabled and s.active
      and r.tenant_id=s.tenant_id
      and r.buying_product_id in (
        select bp.id from public.tenant_buying_products bp
        where bp.tenant_id=p_tenant_id
          and bp.category_id=s.category_id
          and bp.branch_id is not distinct from s.branch_id
          and lower(bp.manufacturer)=lower(s.manufacturer)
          and lower(bp.model)=lower(s.model)
          and lower(coalesce(bp.package_name,''))=lower(coalesce(s.package_name,''))
      );
  end if;
  return v_result;
end;
$function$;

REVOKE ALL
  ON FUNCTION
    "public"."configure_master_catalogue_buying_products_bulk"(uuid, uuid[], text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.configure_master_catalogue_buying_products_filtered (
  p_tenant_id                    uuid,
  p_category_id                  uuid    DEFAULT NULL::uuid,
  p_branch_id                    uuid    DEFAULT NULL::uuid,
  p_manufacturer_id              uuid    DEFAULT NULL::uuid,
  p_search                       text    DEFAULT NULL::text,
  p_mode                         text    DEFAULT 'manual'::text,
  p_sealed_percentage            numeric DEFAULT NULL::numeric,
  p_opened_never_used_percentage numeric DEFAULT NULL::numeric,
  p_excellent_percentage         numeric DEFAULT NULL::numeric,
  p_good_percentage              numeric DEFAULT NULL::numeric,
  p_poor_percentage              numeric DEFAULT NULL::numeric
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_id uuid;
  v_count integer := 0;
  v_skipped integer := 0;
  v_mode text := lower(trim(coalesce(p_mode,'manual')));
  v_search text := nullif(trim(coalesce(p_search,'')),'');
begin
  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'categories.view') then
    raise exception 'Tenant user is not authorised to configure Buying catalogue';
  end if;
  if not private.has_tenant_feature(p_tenant_id, 'module.buying') then
    raise exception 'Buying is not enabled for this subscription';
  end if;
  if not private.has_tenant_feature(p_tenant_id, 'catalogue.pre_filled') then
    raise exception 'Pre-filled catalogue is not enabled for this subscription';
  end if;
  if v_mode not in ('manual','automatic') then
    raise exception 'Bulk add supports Manual valuation or Automatic pricing only';
  end if;

  for v_id in
    select p.id
    from public.catalogue_master_products p
    where p.active and p.customer_visible
      and (p_category_id is null or p.category_id=p_category_id)
      and (p_branch_id is null or p.branch_id=p_branch_id)
      and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
      and (
        v_search is null
        or lower(coalesce(p.model,'')) like '%'||lower(v_search)||'%'
        or lower(coalesce(p.package_name,'')) like '%'||lower(v_search)||'%'
        or lower(coalesce(p.product_type,'')) like '%'||lower(v_search)||'%'
        or lower(coalesce(p.catalogue_category,'')) like '%'||lower(v_search)||'%'
        or lower(coalesce(p.notes,'')) like '%'||lower(v_search)||'%'
      )
  loop
    if exists (
      select 1 from public.tenant_catalogue_selections s
      where s.tenant_id=p_tenant_id and s.master_product_id=v_id and s.buying_enabled and s.active
    ) then
      v_skipped := v_skipped + 1;
    else
      perform public.configure_master_catalogue_buying_product(
        p_tenant_id,v_id,v_mode,null,
        p_sealed_percentage,p_opened_never_used_percentage,
        p_excellent_percentage,p_good_percentage,p_poor_percentage
      );
      v_count := v_count + 1;
    end if;
  end loop;

  return jsonb_build_object('added',v_count,'skipped',v_skipped,'mode',case when v_mode='automatic' then 'automatic' else 'manual_valuation' end);
end;
$function$;

REVOKE ALL
  ON FUNCTION "public"."configure_master_catalogue_buying_products_filtered"(uuid, uuid, uuid, uuid, text, text, numeric, numeric, numeric, numeric, numeric)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.configure_master_catalogue_buying_products_filtered (
  p_tenant_id                      uuid,
  p_category_id                    uuid    DEFAULT NULL::uuid,
  p_branch_id                      uuid    DEFAULT NULL::uuid,
  p_manufacturer_id                uuid    DEFAULT NULL::uuid,
  p_search                         text    DEFAULT NULL::text,
  p_mode                           text    DEFAULT 'manual'::text,
  p_sealed_percentage              numeric DEFAULT NULL::numeric,
  p_opened_never_used_percentage   numeric DEFAULT NULL::numeric,
  p_excellent_percentage           numeric DEFAULT NULL::numeric,
  p_good_percentage                numeric DEFAULT NULL::numeric,
  p_poor_percentage                numeric DEFAULT NULL::numeric,
  p_sealed_manual_price            numeric DEFAULT NULL::numeric,
  p_opened_never_used_manual_price numeric DEFAULT NULL::numeric,
  p_excellent_manual_price         numeric DEFAULT NULL::numeric,
  p_good_manual_price              numeric DEFAULT NULL::numeric,
  p_poor_manual_price              numeric DEFAULT NULL::numeric
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_result jsonb;
begin
  v_result := public.configure_master_catalogue_buying_products_filtered(
    p_tenant_id,p_category_id,p_branch_id,p_manufacturer_id,p_search,p_mode,
    p_sealed_percentage,p_opened_never_used_percentage,
    p_excellent_percentage,p_good_percentage,p_poor_percentage
  );
  if lower(trim(coalesce(p_mode,'')))='automatic' then
    update public.tenant_buying_condition_rules r
    set sealed_manual_price=p_sealed_manual_price,
        opened_never_used_manual_price=p_opened_never_used_manual_price,
        excellent_manual_price=p_excellent_manual_price,
        good_manual_price=p_good_manual_price,
        poor_manual_price=p_poor_manual_price,
        updated_at=now()
    from public.tenant_catalogue_selections s
    join public.catalogue_master_products p on p.id=s.master_product_id
    where s.tenant_id=p_tenant_id
      and s.buying_enabled and s.active and p.active and p.customer_visible
      and (p_category_id is null or p.category_id=p_category_id)
      and (p_branch_id is null or p.branch_id=p_branch_id)
      and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
      and (
        nullif(trim(coalesce(p_search,'')),'') is null
        or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%'
      )
      and r.tenant_id=s.tenant_id
      and r.buying_product_id in (
        select bp.id from public.tenant_buying_products bp
        where bp.tenant_id=p_tenant_id
          and bp.category_id=s.category_id
          and bp.branch_id is not distinct from s.branch_id
          and lower(bp.manufacturer)=lower(s.manufacturer)
          and lower(bp.model)=lower(s.model)
          and lower(coalesce(bp.package_name,''))=lower(coalesce(s.package_name,''))
      );
  end if;
  return v_result;
end;
$function$;

REVOKE ALL
  ON FUNCTION
    "public"."configure_master_catalogue_buying_products_filtered"(uuid, uuid, uuid, uuid, text, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric,
    numeric, numeric)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_accept_offer (
  p_tenant_id      uuid,
  p_offer_id       uuid,
  p_response_notes text DEFAULT NULL::text
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_customer_id uuid; v_item_id uuid; v_offer_type text; v_offer_status text;
  v_offer_amount numeric; v_offer_mode text; v_expires_at timestamptz; v_item_stage text;
  v_other record;
begin
  perform private.require_tenant_feature(p_tenant_id,'module.offers');
  if auth.uid() is null then raise exception 'authentication required'; end if;
  v_customer_id:=private.customer_id_for_current_user(p_tenant_id);
  if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;
  select o.buying_item_id,o.offer_type,o.offer_mode,o.status,o.amount,o.expires_at
    into v_item_id,v_offer_type,v_offer_mode,v_offer_status,v_offer_amount,v_expires_at
  from public.offers o
  join public.buying_items bi on bi.tenant_id=o.tenant_id and bi.id=o.buying_item_id
  join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  where o.tenant_id=p_tenant_id and o.id=p_offer_id and br.customer_id=v_customer_id
  for update of o;
  if v_item_id is null then raise exception 'offer not found or not owned by current customer'; end if;
  if v_offer_status<>'published' then raise exception 'offer is not available for acceptance'; end if;
  if v_expires_at is not null and v_expires_at<=now() then raise exception 'offer has expired'; end if;
  select purchase_stage into v_item_stage from public.buying_items where tenant_id=p_tenant_id and id=v_item_id for update;
  update public.offers set status='accepted',responded_at=now(),response_notes=p_response_notes,updated_at=now()
  where tenant_id=p_tenant_id and id=p_offer_id;
  insert into public.offer_events(tenant_id,offer_id,event_type,from_status,to_status,amount,notes,actor_user_id)
  values(p_tenant_id,p_offer_id,'accepted','published','accepted',v_offer_amount,p_response_notes,auth.uid());
  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'offer',p_offer_id,'published','accepted',auth.uid(),p_response_notes,
         jsonb_build_object('source','customer_action','offer_mode',v_offer_mode));
  if v_offer_type in ('initial','revised') then
    if v_item_stage not in ('offer_ready','none','final_offer_refused') then
      raise exception 'This item is not available to begin the receipt workflow';
    end if;
    for v_other in
      select id from public.offers
      where tenant_id=p_tenant_id and buying_item_id=v_item_id and id<>p_offer_id
        and offer_type in ('initial','revised') and status='published'
      order by created_at
    loop
      perform public.transition_workflow_entity(
        p_tenant_id,'offer',v_other.id,'published','superseded',
        'Superseded because the customer accepted another initial offer.',
        jsonb_build_object('source','customer_action','accepted_offer_id',p_offer_id)
      );
    end loop;
    update public.buying_items set purchase_stage='awaiting_item',purchase_stage_updated_at=now(),updated_at=now()
    where tenant_id=p_tenant_id and id=v_item_id;
  elsif v_offer_type='final' then
    if v_item_stage<>'final_offer_sent' then raise exception 'Final offer cannot be accepted at the current purchase stage'; end if;
    update public.buying_items set purchase_stage='final_offer_accepted',final_offer_accepted_at=now(),purchase_stage_updated_at=now(),updated_at=now()
    where tenant_id=p_tenant_id and id=v_item_id;
  else
    raise exception 'Unsupported offer type for purchase workflow';
  end if;
  return null;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_accept_offer"(uuid, uuid, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_accept_offer_choice (
  p_tenant_id      uuid,
  p_offer_id       uuid,
  p_offer_mode     text,
  p_response_notes text DEFAULT NULL::text
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_customer_id uuid;
  v_item_id uuid;
  v_offer_type text;
  v_offer_status text;
  v_offer_mode text;
  v_offer_amount numeric;
  v_cash_amount numeric;
  v_trade_amount numeric;
  v_expires_at timestamptz;
  v_item_stage text;
  v_other record;
begin
  perform private.require_tenant_feature(p_tenant_id,'module.offers');
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if p_offer_mode not in ('cash','trade_in') then raise exception 'Invalid offer choice'; end if;

  v_customer_id:=private.customer_id_for_current_user(p_tenant_id);
  if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;

  select
    o.buying_item_id,
    o.offer_type,
    o.offer_mode,
    o.status,
    o.amount,
    o.expires_at,
    tv.cash_price,
    tv.trade_in_price
  into
    v_item_id,
    v_offer_type,
    v_offer_mode,
    v_offer_status,
    v_offer_amount,
    v_expires_at,
    v_cash_amount,
    v_trade_amount
  from public.offers o
  join public.buying_items bi
    on bi.tenant_id=o.tenant_id and bi.id=o.buying_item_id
  join public.buying_requests br
    on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  left join public.trading_values tv
    on tv.tenant_id=o.tenant_id and tv.id=o.trading_value_id
  where o.tenant_id=p_tenant_id
    and o.id=p_offer_id
    and br.customer_id=v_customer_id
  for update of o;

  if v_item_id is null then raise exception 'offer not found or not owned by current customer'; end if;
  if v_offer_status<>'published' then raise exception 'offer is not available for acceptance'; end if;
  if v_expires_at is not null and v_expires_at<=now() then raise exception 'offer has expired'; end if;

  if v_offer_type in ('initial','revised') then
    if p_offer_mode='cash' then
      v_offer_amount:=v_cash_amount;
    else
      v_offer_amount:=v_trade_amount;
    end if;
    if v_offer_amount is null then
      raise exception 'The selected offer option is not available';
    end if;
    v_offer_mode:=p_offer_mode;
  else
    -- Final offers remain the exact amount published by the business.
    v_offer_mode:=coalesce(v_offer_mode,'cash');
  end if;

  select purchase_stage into v_item_stage
  from public.buying_items
  where tenant_id=p_tenant_id and id=v_item_id
  for update;

  update public.offers
  set status='accepted',
      amount=v_offer_amount,
      offer_mode=v_offer_mode,
      responded_at=now(),
      response_notes=p_response_notes,
      updated_at=now()
  where tenant_id=p_tenant_id and id=p_offer_id;

  insert into public.offer_events(
    tenant_id,offer_id,event_type,from_status,to_status,amount,notes,actor_user_id
  )
  values(
    p_tenant_id,p_offer_id,'accepted','published','accepted',
    v_offer_amount,
    p_response_notes,
    auth.uid()
  );

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
  )
  values(
    p_tenant_id,'offer',p_offer_id,'published','accepted',auth.uid(),p_response_notes,
    jsonb_build_object(
      'source','customer_action',
      'offer_mode',v_offer_mode
    )
  );

  if v_offer_type in ('initial','revised') then
    if v_item_stage not in ('offer_ready','none','final_offer_refused') then
      raise exception 'This item is not available to begin the receipt workflow';
    end if;

    for v_other in
      select id
      from public.offers
      where tenant_id=p_tenant_id
        and buying_item_id=v_item_id
        and id<>p_offer_id
        and offer_type in ('initial','revised')
        and status='published'
      order by created_at
    loop
      perform public.transition_workflow_entity(
        p_tenant_id,
        'offer',
        v_other.id,
        'published',
        'superseded',
        'Superseded because the customer accepted the combined offer.',
        jsonb_build_object('source','customer_action','accepted_offer_id',p_offer_id)
      );
    end loop;

    update public.buying_items
    set purchase_stage='awaiting_item',
        purchase_stage_updated_at=now(),
        updated_at=now()
    where tenant_id=p_tenant_id and id=v_item_id;
  elsif v_offer_type='final' then
    if v_item_stage<>'final_offer_sent' then
      raise exception 'Final offer cannot be accepted at the current purchase stage';
    end if;
    update public.buying_items
    set purchase_stage='final_offer_accepted',
        final_offer_accepted_at=now(),
        purchase_stage_updated_at=now(),
        updated_at=now()
    where tenant_id=p_tenant_id and id=v_item_id;
  else
    raise exception 'Unsupported offer type for purchase workflow';
  end if;

  return null;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_accept_offer_choice"(uuid, uuid, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_apply_retail_credit (
  p_tenant_id uuid,
  p_order_id  uuid
)
  RETURNS TABLE (
    applied_credit numeric,
    remaining_due  numeric,
    completed      boolean,
    currency       text
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
 v_actor uuid:=auth.uid(); v_customer_id uuid; v_order public.retail_orders%rowtype;
 v_account public.customer_credit_accounts%rowtype; v_available numeric; v_apply numeric;
 v_payment_id uuid; v_ledger_id uuid; v_remaining numeric; v_hold public.customer_credit_holds%rowtype;
begin
 if v_actor is null then raise exception 'Authentication required'; end if;
 perform private.require_tenant_feature(p_tenant_id,'module.orders');
 select c.id into v_customer_id from public.customers c
 where c.tenant_id=p_tenant_id and c.auth_user_id=v_actor and c.status='active' limit 1;
 if v_customer_id is null then raise exception 'Active customer account required'; end if;

 select o.* into v_order from public.retail_orders o
 where o.tenant_id=p_tenant_id and o.id=p_order_id and o.customer_id=v_customer_id
 for update;
 if not found then raise exception 'Order not found'; end if;
 if v_order.status<>'pending_payment' then raise exception 'Order is not awaiting payment'; end if;
 if coalesce(v_order.amount_due,0)<=0 then
   return query select 0::numeric,0::numeric,true,v_order.currency; return;
 end if;

 select h.* into v_hold from public.customer_credit_holds h
 where h.tenant_id=p_tenant_id and h.retail_order_id=p_order_id and h.status='active'
 for update;
 if found then
   return query select h.amount,v_order.amount_due,false,v_order.currency; return;
 end if;

 if exists(
   select 1 from public.payment_records p
   where p.tenant_id=p_tenant_id and p.retail_order_id=p_order_id and p.status in ('pending','processing')
 ) then
   raise exception 'An existing card payment attempt is active. Cancel that attempt before applying customer credit.';
 end if;

 select a.* into v_account from public.customer_credit_accounts a
 where a.tenant_id=p_tenant_id and a.customer_id=v_customer_id for update;
 if not found then raise exception 'Customer credit account not found'; end if;
 if upper(coalesce(v_account.currency,'GBP'))<>upper(coalesce(v_order.currency,'GBP')) then
   raise exception 'Customer credit currency does not match the order';
 end if;

 v_available:=coalesce(v_account.balance,0)-coalesce((
   select sum(h.amount) from public.customer_credit_holds h
   where h.tenant_id=p_tenant_id and h.customer_id=v_customer_id and h.status='active'
 ),0);
 v_apply:=least(greatest(v_available,0),v_order.amount_due);
 if v_apply<=0 then raise exception 'No customer credit is available for this purchase'; end if;

 insert into public.customer_credit_holds(tenant_id,customer_id,retail_order_id,amount)
 values(p_tenant_id,v_customer_id,p_order_id,v_apply)
 returning * into v_hold;

 update public.retail_orders
 set trade_in_credit_total=coalesce(trade_in_credit_total,0)+v_apply,
     amount_due=amount_due-v_apply,
     updated_at=now()
 where tenant_id=p_tenant_id and id=p_order_id
 returning amount_due into v_remaining;

 if v_remaining>0 then
   return query select v_apply,v_remaining,false,v_order.currency;
   return;
 end if;

 update public.customer_credit_accounts
 set balance=balance-v_apply,updated_at=now()
 where id=v_account.id returning balance into v_remaining;

 insert into public.payment_records(
   tenant_id,payment_reference,payment_type,status,direction,amount,currency,payment_method,
   customer_id,retail_order_id,notes,created_by,processed_at
 ) values(
   p_tenant_id,'PAY-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
   'customer_payment','paid','inbound',v_apply,v_order.currency,'customer_credit',
   v_customer_id,p_order_id,'Retail order paid using customer credit account.',v_actor,now()
 ) returning id into v_payment_id;

 insert into public.ledger_entries(
   tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,retail_order_id,
   description,reference_type,reference_id,created_by,posted_at
 ) values(
   p_tenant_id,'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
   'payment','credit','posted',v_apply,v_order.currency,v_customer_id,p_order_id,
   'Retail order paid using customer credit','payment_record',v_payment_id,v_actor,now()
 ) returning id into v_ledger_id;

 update public.customer_credit_holds set status='applied',applied_at=now() where id=v_hold.id;
 update public.retail_orders set status='paid',payment_status='paid',paid_at=now(),amount_due=0,updated_at=now()
 where tenant_id=p_tenant_id and id=p_order_id;

 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
 values(p_tenant_id,'retail_order',p_order_id,'pending_payment','paid',v_actor,
   'Retail order paid using customer credit',
   jsonb_build_object('source','customer_credit','payment_id',v_payment_id,'ledger_id',v_ledger_id));

 update public.listings l set status='sold',sold_at=coalesce(l.sold_at,now()),updated_at=now()
 where l.tenant_id=p_tenant_id and l.id in (
   select i.listing_id from public.retail_order_items i
   where i.tenant_id=p_tenant_id and i.order_id=p_order_id and i.listing_id is not null
 ) and l.status='published';

 update public.inventory_assets ia set status='sold',sold_at=coalesce(sold_at,now()),updated_at=now()
 where ia.tenant_id=p_tenant_id and ia.id in (
   select i.inventory_asset_id from public.retail_order_items i
   where i.tenant_id=p_tenant_id and i.order_id=p_order_id and i.inventory_asset_id is not null
 ) and ia.status in ('listed','reserved');

 return query select v_apply,0::numeric,true,v_order.currency;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_apply_retail_credit"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_cancel_retail_order (
  p_tenant_id uuid,
  p_order_id  uuid,
  p_reason    text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare v_customer_id uuid; v_order public.retail_orders%rowtype; v_hold public.customer_credit_holds%rowtype;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 perform private.require_tenant_feature(p_tenant_id,'module.orders');
 select c.id into v_customer_id from public.customers c
 where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() and c.status='active' limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;

 select * into v_order from public.retail_orders
 where tenant_id=p_tenant_id and id=p_order_id and customer_id=v_customer_id for update;
 if v_order.id is null then raise exception 'Order not found or not owned by current customer'; end if;
 if v_order.status not in ('initiated','pending_payment') then raise exception 'This order can no longer be cancelled'; end if;

 select h.* into v_hold from public.customer_credit_holds h
 where h.tenant_id=p_tenant_id and h.retail_order_id=p_order_id and h.status='active'
 for update;
 if found then
   update public.retail_orders
   set amount_due=amount_due+v_hold.amount,
       trade_in_credit_total=greatest(coalesce(trade_in_credit_total,0)-v_hold.amount,0),
       updated_at=now()
   where tenant_id=p_tenant_id and id=p_order_id;
   update public.customer_credit_holds set status='released',released_at=now() where id=v_hold.id;
 end if;

 update public.retail_orders
 set status='cancelled',cancelled_at=now(),updated_at=now()
 where tenant_id=p_tenant_id and id=p_order_id;

 update public.listings l set status='published',reserved_at=null,updated_at=now()
 where l.tenant_id=p_tenant_id and l.status='reserved' and l.id in (
   select i.listing_id from public.retail_order_items i
   where i.tenant_id=p_tenant_id and i.order_id=p_order_id and i.listing_id is not null
 );

 update public.inventory_assets ia set status='listed',updated_at=now()
 where ia.tenant_id=p_tenant_id and ia.status='reserved' and ia.id in (
   select i.inventory_asset_id from public.retail_order_items i
   where i.tenant_id=p_tenant_id and i.order_id=p_order_id and i.inventory_asset_id is not null
 );

 update public.payment_records pr set status='cancelled',processed_at=coalesce(pr.processed_at,now()),updated_at=now()
 where pr.tenant_id=p_tenant_id and pr.retail_order_id=p_order_id and pr.status in ('pending','processing');

 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
 values(p_tenant_id,'retail_order',p_order_id,v_order.status,'cancelled',auth.uid(),nullif(trim(p_reason),''),
        jsonb_build_object('source','customer_action'));

 return jsonb_build_object('order_id',v_order.id,'order_reference',v_order.order_reference,'status','cancelled');
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_cancel_retail_order"(uuid, uuid, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_complete_test_registration (
  p_tenant_slug text,
  p_first_name  text,
  p_last_name   text DEFAULT NULL::text
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_user_id uuid := auth.uid();
  v_tenant_id uuid;
  v_customer_id uuid;
  v_email text;
  v_first_name text := btrim(coalesce(p_first_name, ''));
  v_last_name text := nullif(btrim(coalesce(p_last_name, '')), '');
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  if v_first_name = '' then
    raise exception 'First name is required';
  end if;

  select t.id into v_tenant_id
  from public.tenants t
  where t.slug = lower(btrim(p_tenant_slug))
    and t.status = 'active'
    and coalesce((t.settings->>'test_lab')::boolean, false) = true;

  if v_tenant_id is null then
    raise exception 'Test tenant not found';
  end if;

  if exists (
    select 1 from public.customers c
    where c.auth_user_id = v_user_id
  ) then
    raise exception 'This Auth account is already linked to a customer';
  end if;

  select email into v_email from auth.users where id = v_user_id;

  insert into public.customers (
    tenant_id, auth_user_id, first_name, last_name, email, status
  ) values (
    v_tenant_id, v_user_id, v_first_name, v_last_name, v_email, 'active'
  )
  returning id into v_customer_id;

  return v_customer_id;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_complete_test_registration"(text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_create_order_payment (
  p_tenant_id       uuid,
  p_order_id        uuid,
  p_idempotency_key text DEFAULT NULL::text
)
  RETURNS TABLE (
    payment_id        uuid,
    payment_reference text,
    status            text,
    amount            numeric,
    currency          text
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_actor uuid := auth.uid();
  v_customer_id uuid;
  v_order public.retail_orders%rowtype;
  v_payment public.payment_records%rowtype;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=v_actor and c.status='active'
  limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;

  select o.* into v_order
  from public.retail_orders o
  where o.tenant_id=p_tenant_id and o.id=p_order_id and o.customer_id=v_customer_id
  for update;
  if not found then raise exception 'Order not found'; end if;
  if v_order.status <> 'pending_payment' then raise exception 'Order is not awaiting payment'; end if;
  if v_order.amount_due <= 0 then raise exception 'Order has no amount due'; end if;

  -- An explicit idempotency key only deduplicates an individual attempt.
  -- Failed/cancelled attempts must never block a later retry with a new key.
  if p_idempotency_key is not null then
    select p.* into v_payment
    from public.payment_records p
    where p.tenant_id=p_tenant_id and p.idempotency_key=p_idempotency_key
    limit 1;
    if found then
      return query select v_payment.id,v_payment.payment_reference,v_payment.status,v_payment.amount,v_payment.currency;
      return;
    end if;
  end if;

  -- While an attempt is still active, reuse it so repeated clicks cannot create duplicates.
  select p.* into v_payment
  from public.payment_records p
  where p.tenant_id=p_tenant_id
    and p.retail_order_id=p_order_id
    and p.status in ('pending','processing')
  order by p.created_at desc
  limit 1;
  if found then
    return query select v_payment.id,v_payment.payment_reference,v_payment.status,v_payment.amount,v_payment.currency;
    return;
  end if;

  insert into public.payment_records(
    tenant_id,payment_type,status,direction,amount,currency,customer_id,retail_order_id,
    idempotency_key,metadata,created_by
  )
  values(
    p_tenant_id,'customer_payment','pending','inbound',v_order.amount_due,v_order.currency,
    v_customer_id,v_order.id,p_idempotency_key,
    jsonb_build_object('source','customer_portal','order_reference',v_order.order_reference),v_actor
  )
  returning * into v_payment;

  return query select v_payment.id,v_payment.payment_reference,v_payment.status,v_payment.amount,v_payment.currency;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_create_order_payment"(uuid, uuid, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_create_retail_order (
  p_tenant_id        uuid,
  p_listing_id       uuid,
  p_shipping_address jsonb DEFAULT '{}'::jsonb,
  p_billing_address  jsonb DEFAULT '{}'::jsonb,
  p_notes            text  DEFAULT NULL::text
)
  RETURNS TABLE (
    order_id        uuid,
    order_reference text,
    status          text,
    total           numeric,
    currency        text
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_actor uuid:=auth.uid(); v_customer_id uuid; v_listing public.listings%rowtype;
  v_order_id uuid; v_order_reference text;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  select c.id into v_customer_id from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=v_actor and c.status='active' limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;

  select l.* into v_listing from public.listings l
  where l.tenant_id=p_tenant_id and l.id=p_listing_id
  for update;
  if not found then raise exception 'Listing not found'; end if;
  if v_listing.status <> 'published' then raise exception 'Listing is no longer available'; end if;
  if coalesce(v_listing.quantity,0)<1 then raise exception 'Listing has no available quantity'; end if;

  insert into public.retail_orders as ro(
    tenant_id,customer_id,channel_id,status,currency,subtotal,shipping_total,tax_total,discount_total,total,
    payment_status,customer_email,customer_name,shipping_address,billing_address,notes,metadata,
    trade_in_credit_total,amount_due
  ) values(
    p_tenant_id,v_customer_id,v_listing.channel_id,'pending_payment',v_listing.currency,v_listing.asking_price,0,0,0,
    v_listing.asking_price,'unpaid',
    (select email from public.customers where id=v_customer_id and tenant_id=p_tenant_id),
    trim((select first_name||' '||coalesce(last_name,'') from public.customers where id=v_customer_id and tenant_id=p_tenant_id)),
    coalesce(p_shipping_address,'{}'::jsonb),coalesce(p_billing_address,'{}'::jsonb),p_notes,
    jsonb_build_object('source','customer_checkout'),0,v_listing.asking_price
  ) returning ro.id,ro.order_reference into v_order_id,v_order_reference;

  insert into public.retail_order_items(
    tenant_id,order_id,listing_id,inventory_asset_id,quantity,title,unit_price,discount_amount,tax_amount,line_total,currency,metadata
  ) values(
    p_tenant_id,v_order_id,v_listing.id,v_listing.asset_id,1,v_listing.title,v_listing.asking_price,0,0,
    v_listing.asking_price,v_listing.currency,jsonb_build_object('source','customer_checkout')
  );

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
  ) values(
    p_tenant_id,'retail_order',v_order_id,'initiated','pending_payment',v_actor,'Customer checkout',
    jsonb_build_object('source','customer_checkout')
  );

  return query select v_order_id,v_order_reference,'pending_payment'::text,v_listing.asking_price,v_listing.currency;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_create_retail_order"(uuid, uuid, jsonb, jsonb, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_create_retail_order_from_basket (
  p_tenant_id        uuid,
  p_listing_ids      jsonb,
  p_shipping_address jsonb DEFAULT '{}'::jsonb,
  p_billing_address  jsonb DEFAULT '{}'::jsonb,
  p_notes            text  DEFAULT NULL::text
)
  RETURNS TABLE (
    order_id        uuid,
    order_reference text,
    status          text,
    total           numeric,
    currency        text
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_actor uuid:=auth.uid(); v_customer_id uuid; v_order_id uuid; v_order_reference text;
  v_currency text; v_total numeric:=0; v_count integer:=0; v_listing public.listings%rowtype;
  v_listing_id uuid;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if p_listing_ids is null or jsonb_typeof(p_listing_ids)<>'array' or jsonb_array_length(p_listing_ids)=0 then
    raise exception 'Basket is empty';
  end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  select c.id into v_customer_id from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=v_actor and c.status='active' limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;

  for v_listing_id in select value::uuid from jsonb_array_elements_text(p_listing_ids)
  loop
    select l.* into v_listing from public.listings l
    where l.tenant_id=p_tenant_id and l.id=v_listing_id for update;
    if not found or v_listing.status<>'published' or coalesce(v_listing.quantity,0)<1 then
      raise exception 'A basket item is no longer available';
    end if;
    if v_currency is null then v_currency:=v_listing.currency;
    elsif v_currency is distinct from v_listing.currency then raise exception 'Basket items must use the same currency'; end if;
    v_total:=v_total+coalesce(v_listing.asking_price,0); v_count:=v_count+1;
  end loop;

  insert into public.retail_orders as ro(
    tenant_id,customer_id,channel_id,status,currency,subtotal,shipping_total,tax_total,discount_total,total,
    payment_status,customer_email,customer_name,shipping_address,billing_address,notes,metadata,trade_in_credit_total,amount_due
  ) values(
    p_tenant_id,v_customer_id,null,'pending_payment',v_currency,v_total,0,0,0,v_total,'unpaid',
    (select email from public.customers where id=v_customer_id and tenant_id=p_tenant_id),
    trim((select first_name||' '||coalesce(last_name,'') from public.customers where id=v_customer_id and tenant_id=p_tenant_id)),
    coalesce(p_shipping_address,'{}'::jsonb),coalesce(p_billing_address,'{}'::jsonb),p_notes,
    jsonb_build_object('source','customer_basket_checkout','basket_count',v_count),0,v_total
  ) returning ro.id,ro.order_reference into v_order_id,v_order_reference;

  for v_listing_id in select value::uuid from jsonb_array_elements_text(p_listing_ids)
  loop
    select l.* into v_listing from public.listings l
    where l.tenant_id=p_tenant_id and l.id=v_listing_id for update;
    if not found or v_listing.status<>'published' or coalesce(v_listing.quantity,0)<1 then
      raise exception 'A basket item became unavailable during checkout';
    end if;
    insert into public.retail_order_items(
      tenant_id,order_id,listing_id,inventory_asset_id,quantity,title,unit_price,discount_amount,tax_amount,line_total,currency,metadata
    ) values(
      p_tenant_id,v_order_id,v_listing.id,v_listing.asset_id,1,v_listing.title,v_listing.asking_price,0,0,
      v_listing.asking_price,v_listing.currency,jsonb_build_object('source','customer_basket_checkout')
    );
  end loop;

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
  ) values(
    p_tenant_id,'retail_order',v_order_id,'initiated','pending_payment',v_actor,'Customer basket checkout',
    jsonb_build_object('source','customer_basket_checkout')
  );

  return query select v_order_id,v_order_reference,'pending_payment'::text,v_total,v_currency;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_create_retail_order_from_basket"(uuid, jsonb, jsonb, jsonb, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_delete_address (
  p_tenant_id  uuid,
  p_address_id uuid
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_user uuid:=auth.uid(); v_customer uuid;
begin
 if v_user is null then raise exception 'Authentication required'; end if;
 select id into v_customer from public.customers where tenant_id=p_tenant_id and auth_user_id=v_user limit 1;
 if v_customer is null then raise exception 'Customer account not found for this subscriber'; end if;
 delete from public.customer_addresses where id=p_address_id and tenant_id=p_tenant_id and customer_id=v_customer;
 if not found then raise exception 'Address not found'; end if;
end $function$;

REVOKE ALL ON FUNCTION "public"."customer_delete_address"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_acquisition_shipping (
  p_tenant_id uuid
)
  RETURNS TABLE (
    acquisition_id              uuid,
    acquisition_reference       text,
    status                      text,
    currency                    text,
    agreed_total                numeric,
    accepted_at                 timestamp with time zone,
    received_at                 timestamp with time zone,
    finalised_at                timestamp with time zone,
    paid_at                     timestamp with time zone,
    completed_at                timestamp with time zone,
    customer_sent_at            timestamp with time zone,
    shipping_method             text,
    shipping_provider           text,
    shipping_provider_order_id  text,
    shipping_status             text,
    shipping_status_updated_at  timestamp with time zone,
    shipping_tracking_url       text,
    shipping_payment_url        text,
    shipping_label_url          text,
    shipping_label_storage_path text,
    shipping_qr_url             text,
    shipping_qr_storage_path    text,
    shipping_carrier            text,
    shipping_service            text,
    shipping_tracking_number    text,
    shipping_instructions       text,
    posted_at                   timestamp with time zone
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_customer_id uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 return query
 select a.id,a.acquisition_reference,a.status,a.currency,a.agreed_total,a.accepted_at,a.received_at,a.finalised_at,a.paid_at,a.completed_at,
        a.customer_sent_at,a.shipping_method,a.shipping_provider,a.shipping_provider_order_id,a.shipping_status,a.shipping_status_updated_at,
        a.shipping_tracking_url,a.shipping_payment_url,a.shipping_label_url,a.shipping_label_storage_path,a.shipping_qr_url,a.shipping_qr_storage_path,
        a.shipping_carrier,a.shipping_service,a.shipping_tracking_number,a.shipping_instructions,a.posted_at
 from public.acquisitions a where a.tenant_id=p_tenant_id and a.customer_id=v_customer_id order by a.created_at desc;
end;$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_acquisition_shipping"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_acquisitions (
  p_tenant_id uuid
)
  RETURNS TABLE (
    acquisition_id        uuid,
    acquisition_reference text,
    status                text,
    currency              text,
    agreed_total          numeric,
    payment_total         numeric,
    accepted_at           timestamp with time zone,
    received_at           timestamp with time zone,
    finalised_at          timestamp with time zone,
    paid_at               timestamp with time zone,
    completed_at          timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id,'module.buying');
  return query
  select a.id,a.acquisition_reference,a.status,a.currency,a.agreed_total,a.payment_total,a.accepted_at,a.received_at,a.finalised_at,a.paid_at,a.completed_at
  from public.acquisitions a join public.customers c on c.tenant_id=a.tenant_id and c.id=a.customer_id
  where a.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() and a.status in ('paid','completed')
  order by a.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_acquisitions"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_addresses (
  p_tenant_id uuid
)
  RETURNS TABLE (
    address_id     uuid,
    address_type   text,
    recipient_name text,
    company_name   text,
    line1          text,
    line2          text,
    city           text,
    county         text,
    postcode       text,
    country_code   text,
    is_default     boolean
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.customer_portal');
  return query
  select a.id, a.address_type, a.recipient_name, a.company_name, a.line1, a.line2,
         a.city, a.county, a.postcode, a.country_code, a.is_default
  from public.customer_addresses a
  join public.customers c
    on c.tenant_id = a.tenant_id and c.id = a.customer_id
  where a.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  order by a.is_default desc, a.created_at;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_addresses"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_bank_details (
  p_tenant_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_customer_id uuid;
  v_row public.customer_bank_details%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  limit 1;
  if v_customer_id is null then raise exception 'Customer account not found'; end if;
  select * into v_row
  from public.customer_bank_details
  where tenant_id=p_tenant_id and customer_id=v_customer_id;
  if v_row.id is null then
    return jsonb_build_object('has_details',false);
  end if;
  return jsonb_build_object(
    'has_details',true,
    'account_holder_name',v_row.account_holder_name,
    'sort_code',v_row.sort_code,
    'account_number',v_row.account_number,
    'bank_name',v_row.bank_name
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_bank_details"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_buying_categories (
  p_tenant_id uuid
)
  RETURNS TABLE (
    category_id uuid,
    name        text,
    slug        text,
    description text
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.buying');
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if private.customer_id_for_current_user(p_tenant_id) is null then raise exception 'customer account not linked to tenant'; end if;
  return query
    select c.id, c.name, c.slug, c.description
    from public.categories c
    where c.tenant_id = p_tenant_id and c.active and c.buying_enabled
    order by c.sort_order nulls last, c.name;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_buying_categories"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_buying_category_fields (
  p_tenant_id   uuid,
  p_category_id uuid
)
  RETURNS TABLE (
    field_id            uuid,
    field_key           text,
    label               text,
    field_type          text,
    required_for_buying boolean,
    options             jsonb
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
 perform private.require_tenant_feature(p_tenant_id,'module.buying'); if auth.uid() is null then raise exception 'authentication required'; end if;
 if private.customer_id_for_current_user(p_tenant_id) is null then raise exception 'customer account not linked to tenant'; end if;
 return query select f.id,f.field_key,f.label,f.field_type,f.required_for_buying,
 coalesce((select jsonb_agg(jsonb_build_object('value',o.value,'label',o.label) order by o.sort_order nulls last,o.label) from public.category_field_options o where o.tenant_id=f.tenant_id and o.category_id=f.category_id and o.field_id=f.id and o.active),'[]'::jsonb)
 from public.category_fields f where f.tenant_id=p_tenant_id and f.category_id=p_category_id and f.customer_visible and f.enabled_for_buying order by f.sort_order nulls last,f.label;
end;$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_buying_category_fields"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_buying_items (
  p_tenant_id uuid
)
  RETURNS TABLE (
    item_id        uuid,
    request_id     uuid,
    category_id    uuid,
    item_reference text,
    status         text,
    title          text,
    description    text,
    quantity       integer,
    sort_order     integer,
    created_at     timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.buying');
  return query
  select i.id, i.buying_request_id, i.category_id, i.item_reference, i.status,
         i.title, i.description, i.quantity, i.sort_order, i.created_at
  from public.buying_items i
  join public.buying_requests r
    on r.tenant_id = i.tenant_id and r.id = i.buying_request_id
  join public.customers c
    on c.tenant_id = r.tenant_id and c.id = r.customer_id
  where i.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  order by i.created_at desc, i.sort_order;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_buying_items"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_buying_requests (
  p_tenant_id uuid
)
  RETURNS TABLE (
    request_id        uuid,
    request_reference text,
    status            text,
    source            text,
    submitted_at      timestamp with time zone,
    closed_at         timestamp with time zone,
    created_at        timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.buying');
  return query
  select r.id, r.request_reference, r.status, r.source, r.submitted_at, r.closed_at, r.created_at
  from public.buying_requests r
  join public.customers c
    on c.tenant_id = r.tenant_id and c.id = r.customer_id
  where r.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  order by r.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_buying_requests"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_completed_sales (
  p_tenant_id uuid
)
  RETURNS TABLE (
    acquisition_id        uuid,
    acquisition_reference text,
    buying_item_id        uuid,
    request_reference     text,
    item_reference        text,
    item_title            text,
    status                text,
    currency              text,
    agreed_total          numeric,
    paid_at               timestamp with time zone,
    completed_at          timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id,'module.buying');
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  return query
  select a.id,a.acquisition_reference,bi.id,br.request_reference,bi.item_reference,bi.title,a.status,a.currency,a.agreed_total,a.paid_at,a.completed_at
  from public.acquisitions a
  join public.customers c on c.tenant_id=a.tenant_id and c.id=a.customer_id
  join public.acquisition_items ai on ai.tenant_id=a.tenant_id and ai.acquisition_id=a.id
  join public.buying_items bi on bi.tenant_id=ai.tenant_id and bi.id=ai.buying_item_id
  join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  where a.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() and a.status in ('paid','completed')
  order by coalesce(a.paid_at,a.completed_at,a.created_at) desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_completed_sales"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_credit_account (
  p_tenant_id uuid
)
  RETURNS TABLE (
    account_id uuid,
    balance    numeric,
    currency   text
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 return query
 select a.id,
        a.balance-coalesce((
          select sum(h.amount) from public.customer_credit_holds h
          where h.tenant_id=a.tenant_id and h.customer_id=a.customer_id and h.status='active'
        ),0) as balance,
        a.currency
 from public.customer_credit_accounts a
 join public.customers c on c.tenant_id=a.tenant_id and c.id=a.customer_id
 where a.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
 limit 1;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_credit_account"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_fulfilments (
  p_tenant_id uuid
)
  RETURNS TABLE (
    fulfilment_id        uuid,
    retail_order_id      uuid,
    fulfilment_reference text,
    status               text,
    carrier              text,
    service              text,
    tracking_number      text,
    tracking_url         text,
    recipient_name       text,
    dispatched_at        timestamp with time zone,
    delivered_at         timestamp with time zone,
    returned_at          timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.fulfilment');
  return query
  select f.id, f.retail_order_id, f.fulfilment_reference, f.status, f.carrier, f.service,
         f.tracking_number, f.tracking_url, f.recipient_name, f.dispatched_at,
         f.delivered_at, f.returned_at
  from public.fulfilments f
  join public.retail_orders o on o.tenant_id=f.tenant_id and o.id=f.retail_order_id
  join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  where f.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by f.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_fulfilments"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_offer_choices (
  p_tenant_id uuid
)
  RETURNS TABLE (
    offer_id         uuid,
    buying_item_id   uuid,
    trading_value_id uuid,
    offer_reference  text,
    offer_type       text,
    offer_mode       text,
    status           text,
    amount           numeric,
    cash_amount      numeric,
    trade_in_amount  numeric,
    currency         text,
    expires_at       timestamp with time zone,
    published_at     timestamp with time zone,
    responded_at     timestamp with time zone,
    response_notes   text
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id,'module.offers');
  return query
  select
    o.id,
    o.buying_item_id,
    o.trading_value_id,
    o.offer_reference,
    o.offer_type,
    o.offer_mode,
    o.status,
    o.amount,
    tv.cash_price,
    tv.trade_in_price,
    o.currency,
    o.expires_at,
    o.published_at,
    o.responded_at,
    o.response_notes
  from public.offers o
  join public.buying_items i
    on i.tenant_id=o.tenant_id and i.id=o.buying_item_id
  join public.buying_requests r
    on r.tenant_id=i.tenant_id and r.id=i.buying_request_id
  join public.customers c
    on c.tenant_id=r.tenant_id and c.id=r.customer_id
  left join public.trading_values tv
    on tv.tenant_id=o.tenant_id and tv.id=o.trading_value_id
  where o.tenant_id=p_tenant_id
    and c.auth_user_id=auth.uid()
  order by o.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_offer_choices"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_offers (
  p_tenant_id uuid
)
  RETURNS TABLE (
    offer_id        uuid,
    buying_item_id  uuid,
    offer_reference text,
    offer_type      text,
    status          text,
    amount          numeric,
    currency        text,
    expires_at      timestamp with time zone,
    published_at    timestamp with time zone,
    responded_at    timestamp with time zone,
    response_notes  text
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.offers');
  return query
  select o.id, o.buying_item_id, o.offer_reference, o.offer_type, o.status, o.amount,
         o.currency, o.expires_at, o.published_at, o.responded_at, o.response_notes
  from public.offers o
  join public.buying_items i
    on i.tenant_id = o.tenant_id and i.id = o.buying_item_id
  join public.buying_requests r
    on r.tenant_id = i.tenant_id and r.id = i.buying_request_id
  join public.customers c
    on c.tenant_id = r.tenant_id and c.id = r.customer_id
  where o.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  order by o.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_offers"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_offers_v2 (
  p_tenant_id uuid
)
  RETURNS TABLE (
    offer_id        uuid,
    buying_item_id  uuid,
    offer_reference text,
    offer_type      text,
    offer_mode      text,
    status          text,
    amount          numeric,
    currency        text,
    expires_at      timestamp with time zone,
    published_at    timestamp with time zone,
    responded_at    timestamp with time zone,
    response_notes  text,
    cash_price      numeric,
    trade_in_price  numeric
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id,'module.offers');
  return query
  select o.id,o.buying_item_id,o.offer_reference,o.offer_type,o.offer_mode,o.status,
         o.amount,o.currency,o.expires_at,o.published_at,o.responded_at,o.response_notes,
         tv.cash_price,tv.trade_in_price
  from public.offers o
  join public.buying_items i on i.tenant_id=o.tenant_id and i.id=o.buying_item_id
  join public.buying_requests r on r.tenant_id=i.tenant_id and r.id=i.buying_request_id
  join public.customers c on c.tenant_id=r.tenant_id and c.id=r.customer_id
  left join public.trading_values tv on tv.tenant_id=o.tenant_id and tv.id=o.trading_value_id
  where o.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by o.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_offers_v2"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_order_details (
  p_tenant_id uuid
)
  RETURNS TABLE (
    order_id             uuid,
    order_reference      text,
    order_status         text,
    payment_status       text,
    currency             text,
    subtotal             numeric,
    shipping_total       numeric,
    total                numeric,
    amount_due           numeric,
    paid_at              timestamp with time zone,
    placed_at            timestamp with time zone,
    completed_at         timestamp with time zone,
    item_id              uuid,
    listing_id           uuid,
    inventory_asset_id   uuid,
    item_title           text,
    item_quantity        integer,
    item_unit_price      numeric,
    item_line_total      numeric,
    fulfilment_id        uuid,
    fulfilment_reference text,
    fulfilment_status    text,
    carrier              text,
    service              text,
    tracking_number      text,
    tracking_url         text,
    label_url            text,
    dispatched_at        timestamp with time zone,
    delivered_at         timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_customer_id uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() and c.status='active'
  limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;

  return query
  select
    o.id,o.order_reference,o.status,o.payment_status,o.currency,o.subtotal,o.shipping_total,o.total,o.amount_due,
    o.paid_at,o.placed_at,o.completed_at,
    i.id,i.listing_id,i.inventory_asset_id,i.title,i.quantity,i.unit_price,i.line_total,
    f.id,f.fulfilment_reference,f.status,f.carrier,f.service,f.tracking_number,f.tracking_url,f.label_url,
    f.dispatched_at,f.delivered_at
  from public.retail_orders o
  join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  join public.retail_order_items i on i.tenant_id=o.tenant_id and i.order_id=o.id
  left join lateral (
    select f1.*
    from public.fulfilments f1
    where f1.tenant_id=o.tenant_id and f1.retail_order_id=o.id
    order by f1.created_at desc
    limit 1
  ) f on true
  where o.tenant_id=p_tenant_id
    and c.auth_user_id=auth.uid()
    and (o.payment_status='paid' or o.status in ('paid','fulfilment','completed','partially_refunded','refunded'))
  order by coalesce(o.paid_at,o.completed_at,o.created_at) desc,i.created_at;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_order_details"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_order_items (
  p_tenant_id uuid
)
  RETURNS TABLE (
    order_item_id      uuid,
    order_id           uuid,
    listing_id         uuid,
    inventory_asset_id uuid,
    quantity           integer,
    title              text,
    unit_price         numeric,
    discount_amount    numeric,
    tax_amount         numeric,
    line_total         numeric,
    currency           text,
    created_at         timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.orders');
  return query
  select oi.id, oi.order_id, oi.listing_id, oi.inventory_asset_id, oi.quantity, oi.title,
         oi.unit_price, oi.discount_amount, oi.tax_amount, oi.line_total, oi.currency, oi.created_at
  from public.retail_order_items oi
  join public.retail_orders o on o.tenant_id=oi.tenant_id and o.id=oi.order_id
  join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  where oi.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by oi.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_order_items"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_order_trade_ins (
  p_tenant_id uuid
)
  RETURNS TABLE (
    bridge_id               uuid,
    retail_order_id         uuid,
    trade_in_transaction_id uuid,
    credit_amount           numeric,
    currency                text,
    status                  text,
    applied_at              timestamp with time zone,
    reversed_at             timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.trade_in');
  return query
  select b.id, b.retail_order_id, b.trade_in_transaction_id, b.credit_amount, b.currency,
         b.status, b.applied_at, b.reversed_at
  from public.retail_order_trade_ins b
  join public.retail_orders o on o.tenant_id=b.tenant_id and o.id=b.retail_order_id
  join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  join public.trade_in_transactions t on t.tenant_id=b.tenant_id and t.id=b.trade_in_transaction_id and t.customer_id=c.id
  where b.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by b.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_order_trade_ins"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_orders (
  p_tenant_id uuid
)
  RETURNS TABLE (
    order_id              uuid,
    order_reference       text,
    channel_id            uuid,
    status                text,
    currency              text,
    subtotal              numeric,
    shipping_total        numeric,
    tax_total             numeric,
    discount_total        numeric,
    total                 numeric,
    payment_status        text,
    placed_at             timestamp with time zone,
    paid_at               timestamp with time zone,
    completed_at          timestamp with time zone,
    cancelled_at          timestamp with time zone,
    trade_in_credit_total numeric,
    amount_due            numeric,
    pricing_version       text
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  return query
  select o.id,o.order_reference,o.channel_id,o.status,o.currency,o.subtotal,o.shipping_total,o.tax_total,o.discount_total,o.total,o.payment_status,o.placed_at,o.paid_at,o.completed_at,o.cancelled_at,o.trade_in_credit_total,o.amount_due,o.pricing_version
  from public.retail_orders o
  join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  where o.tenant_id=p_tenant_id
    and c.auth_user_id=auth.uid()
    and (o.payment_status='paid' or o.status in ('paid','fulfilment','completed','partially_refunded','refunded'))
  order by coalesce(o.paid_at,o.completed_at,o.created_at) desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_orders"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_pre_acquisition_shipping (
  p_tenant_id uuid
)
  RETURNS TABLE (
    buying_item_id              uuid,
    buying_item_reference       text,
    offer_id                    uuid,
    offer_type                  text,
    purchase_stage              text,
    shipping_method             text,
    shipping_provider           text,
    shipping_provider_order_id  text,
    shipping_status             text,
    shipping_status_updated_at  timestamp with time zone,
    shipping_tracking_url       text,
    shipping_payment_url        text,
    shipping_label_url          text,
    shipping_label_storage_path text,
    shipping_qr_url             text,
    shipping_qr_storage_path    text,
    shipping_carrier            text,
    shipping_service            text,
    shipping_tracking_number    text,
    shipping_instructions       text,
    shipping_service_url        text,
    posted_at                   timestamp with time zone,
    customer_sent_at            timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_customer_id uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
  if v_customer_id is null then raise exception 'Customer account not found'; end if;
  return query
  select bi.id,bi.item_reference,o.id,o.offer_type,bi.purchase_stage,s.shipping_method,s.shipping_provider,s.shipping_provider_order_id,s.shipping_status,s.shipping_status_updated_at,s.shipping_tracking_url,s.shipping_payment_url,s.shipping_label_url,s.shipping_label_storage_path,s.shipping_qr_url,s.shipping_qr_storage_path,s.shipping_carrier,s.shipping_service,s.shipping_tracking_number,s.shipping_instructions,s.shipping_service_url,s.posted_at,s.customer_sent_at
  from public.buying_items bi join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  left join public.offers o on o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='accepted'
  left join public.buying_item_shipping s on s.tenant_id=bi.tenant_id and s.buying_item_id=bi.id
  where bi.tenant_id=p_tenant_id and br.customer_id=v_customer_id and bi.purchase_stage in ('awaiting_item','shipping','received','inspection','testing','repair','final_offer_required','final_offer_sent','final_offer_accepted','final_offer_refused','return_pending')
  order by bi.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_pre_acquisition_shipping"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_profile (
  p_tenant_id uuid
)
  RETURNS TABLE (
    customer_id        uuid,
    customer_reference text,
    first_name         text,
    last_name          text,
    email              text,
    phone              text,
    status             text
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.customer_portal');
  return query
  select c.id, c.customer_reference, c.first_name, c.last_name, c.email, c.phone, c.status
  from public.customers c
  where c.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  limit 1;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_profile"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_retail_fulfilment_shipping (
  p_tenant_id uuid
)
  RETURNS TABLE (
    fulfilment_id         uuid,
    retail_order_id       uuid,
    order_reference       text,
    fulfilment_reference  text,
    fulfilment_status     text,
    carrier               text,
    service               text,
    tracking_number       text,
    tracking_url          text,
    shipping_method       text,
    shipping_provider     text,
    shipping_service_url  text,
    shipping_instructions text,
    label_url             text,
    label_storage_path    text,
    qr_url                text,
    qr_storage_path       text,
    shipping_address      jsonb,
    items                 jsonb,
    parcel                jsonb
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 perform private.require_tenant_feature(p_tenant_id,'module.orders');
 return query
 select f.id,f.retail_order_id,o.order_reference,f.fulfilment_reference,f.status,f.carrier,f.service,f.tracking_number,f.tracking_url,
   f.shipping_method,f.shipping_provider,f.shipping_service_url,f.shipping_instructions,f.label_url,f.label_storage_path,f.qr_url,f.qr_storage_path,o.shipping_address,
   coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'title',i.title,'quantity',i.quantity,'unit_price',i.unit_price,'line_total',i.line_total) order by i.created_at)
     from public.retail_order_items i where i.tenant_id=o.tenant_id and i.order_id=o.id),'[]'::jsonb),
   (select jsonb_build_object('id',p.id,'parcel_reference',p.parcel_reference,'weight',p.weight,'length',p.length,'width',p.width,'height',p.height,'label_url',p.label_url,'notes',p.notes)
    from public.fulfilment_parcels p where p.tenant_id=f.tenant_id and p.fulfilment_id=f.id order by p.created_at limit 1)
 from public.fulfilments f join public.retail_orders o on o.tenant_id=f.tenant_id and o.id=f.retail_order_id
 join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
 where f.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
 order by f.created_at desc;
end;$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_retail_fulfilment_shipping"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_retail_order_for_checkout (
  p_tenant_id uuid,
  p_order_id  uuid
)
  RETURNS TABLE (
    order_id           uuid,
    order_reference    text,
    status             text,
    payment_status     text,
    currency           text,
    subtotal           numeric,
    shipping_total     numeric,
    tax_total          numeric,
    discount_total     numeric,
    total              numeric,
    amount_due         numeric,
    placed_at          timestamp with time zone,
    listing_id         uuid,
    inventory_asset_id uuid,
    title              text
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_customer_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  perform private.require_tenant_feature(p_tenant_id,'module.orders');

  select c.id
    into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id
    and c.auth_user_id=auth.uid()
    and c.status='active'
  limit 1;

  if v_customer_id is null then
    raise exception 'Active customer account required';
  end if;

  return query
  select
    o.id,
    o.order_reference,
    o.status,
    o.payment_status,
    o.currency,
    o.subtotal,
    o.shipping_total,
    o.tax_total,
    o.discount_total,
    o.total,
    o.amount_due,
    o.placed_at,
    roi.listing_id,
    roi.inventory_asset_id,
    roi.title
  from public.retail_orders o
  left join lateral (
    select i.listing_id, i.inventory_asset_id, i.title
    from public.retail_order_items i
    where i.tenant_id=o.tenant_id
      and i.order_id=o.id
    order by i.created_at
    limit 1
  ) roi on true
  where o.tenant_id=p_tenant_id
    and o.id=p_order_id
    and o.customer_id=v_customer_id
    and o.status='pending_payment';
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_retail_order_for_checkout"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_returns (
  p_tenant_id uuid
)
  RETURNS TABLE (
    return_id        uuid,
    return_reference text,
    return_type      text,
    status           text,
    order_id         uuid,
    order_item_id    uuid,
    reason_code      text,
    reason           text,
    requested_at     timestamp with time zone,
    authorised_at    timestamp with time zone,
    received_at      timestamp with time zone,
    inspected_at     timestamp with time zone,
    resolved_at      timestamp with time zone,
    closed_at        timestamp with time zone,
    refund_amount    numeric,
    currency         text,
    metadata         jsonb
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
 perform private.require_tenant_feature(p_tenant_id,'module.orders');
 return query select r.id,r.return_reference,r.return_type,r.status,r.order_id,r.order_item_id,r.reason_code,r.reason,r.requested_at,r.authorised_at,r.received_at,r.inspected_at,r.resolved_at,r.closed_at,r.refund_amount,r.currency,r.metadata
 from public.returns r join public.customers c on c.tenant_id=r.tenant_id and c.id=r.customer_id
 where r.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() order by r.created_at desc;
end; $function$;

REVOKE ALL ON FUNCTION "public"."customer_get_returns"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_selling_status (
  p_tenant_id uuid
)
  RETURNS TABLE (
    request_id                   uuid,
    request_reference            text,
    buying_item_id               uuid,
    item_reference               text,
    item_title                   text,
    request_status               text,
    item_status                  text,
    stage                        text,
    message                      text,
    manual_notification_sent     boolean,
    return_reason                text,
    return_shipping_status       text,
    return_carrier               text,
    return_service               text,
    return_tracking_number       text,
    return_tracking_url          text,
    return_label_storage_path    text,
    return_label_url             text,
    return_shipping_instructions text
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_customer_id uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c
 where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 return query
 select r.id,r.request_reference,bi.id,bi.item_reference,bi.title,r.status,bi.status,
   case
    when bi.purchase_stage='awaiting_item' and not exists(select 1 from public.buying_item_shipping s where s.tenant_id=bi.tenant_id and s.buying_item_id=bi.id and (nullif(s.shipping_label_url,'') is not null or nullif(s.shipping_label_storage_path,'') is not null or nullif(s.shipping_qr_url,'') is not null or nullif(s.shipping_qr_storage_path,'') is not null)) then 'awaiting_shipping_label'
    when bi.purchase_stage='final_offer_required' and exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='initial' and o.status='accepted') then 'final_offer_accepted'
    when bi.purchase_stage <> 'none' then bi.purchase_stage
    when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='initial' and o.status='refused') then 'offer_refused'
    when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published') then 'offer_ready'
    when exists(select 1 from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved') then 'valued'
    when exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id) then 'manual_valuation'
    when bi.status in ('submitted','under_review') then 'valuation_in_progress' else 'submitted'
   end,
   case
    when bi.purchase_stage='return_pending' then 'The business has refused the purchase because the item condition did not match the condition described when you submitted it. The item is being returned to you.'
    when bi.purchase_stage='offer_refused' or exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='initial' and o.status='refused') then 'We have decided not to proceed with this item. The purchase will not go ahead.'
    when bi.purchase_stage='awaiting_item' and not exists(select 1 from public.buying_item_shipping s where s.tenant_id=bi.tenant_id and s.buying_item_id=bi.id and (nullif(s.shipping_label_url,'') is not null or nullif(s.shipping_label_storage_path,'') is not null or nullif(s.shipping_qr_url,'') is not null or nullif(s.shipping_qr_storage_path,'') is not null)) then 'You have accepted the offer. The business must now create your shipping label and instructions before you send the item.'
    when bi.purchase_stage='awaiting_item' then 'Your shipping label and instructions are ready. Send the item and confirm when it has been handed to the courier.'
    when bi.purchase_stage='shipping' then 'You have confirmed that the item has been sent. The business is now awaiting receipt.'
    when bi.purchase_stage='received' then 'The business has received your item. It is waiting for inspection.'
    when bi.purchase_stage='inspection' then 'Your item is currently being inspected.'
    when bi.purchase_stage='testing' then 'Your item has been routed for testing. It has not been purchased yet.'
    when bi.purchase_stage='repair' then 'Your item has been routed for repair. It has not been purchased yet.'
    when bi.purchase_stage='final_offer_required' and exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='initial' and o.status='accepted') then case when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='initial' and o.offer_mode='trade_in' and o.status='accepted') then 'Your item has passed inspection. The agreed trade-in value is being added to your customer credit account.' else 'Your item has passed inspection. The business is now completing payment to your bank.' end
    when bi.purchase_stage='final_offer_sent' then 'A revised final offer has been sent. Review it and accept or refuse it.'
    when bi.purchase_stage='final_offer_accepted' then 'You accepted the revised final offer. The business is now completing payment.'
    when bi.purchase_stage='final_offer_refused' then 'The revised final offer was refused. The item remains outside the purchase and inventory process.'
    when bi.purchase_stage='purchased' then 'The item has been purchased and added to the business inventory.'
    when exists(select 1 from public.offers o where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published') then 'Your offer is ready to review.'
    when exists(select 1 from public.trading_values tv where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved') then 'Your valuation has been completed.'
    when exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id) then 'We cannot automatically value this item. Your item has been sent for manual valuation.'
    else 'We have received your selling request and it is currently being reviewed.'
   end,
   exists(select 1 from public.notification_event_log nel where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required' and nel.entity_type='buying_item' and nel.entity_id=bi.id),
   rs.return_reason,rs.shipping_status,rs.shipping_carrier,rs.shipping_service,rs.shipping_tracking_number,rs.shipping_tracking_url,rs.shipping_label_storage_path,rs.shipping_label_url,rs.shipping_instructions
 from public.buying_items bi
 join public.buying_requests r on r.tenant_id=bi.tenant_id and r.id=bi.buying_request_id
 left join public.buying_item_return_shipping rs on rs.tenant_id=bi.tenant_id and rs.buying_item_id=bi.id
 where bi.tenant_id=p_tenant_id and r.customer_id=v_customer_id
 order by bi.created_at desc,bi.sort_order;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_selling_status"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_selling_valuations (
  p_tenant_id uuid
)
  RETURNS TABLE (
    trading_value_id  uuid,
    request_id        uuid,
    request_reference text,
    buying_item_id    uuid,
    method            text,
    status            text,
    amount            numeric,
    cash_price        numeric,
    trade_in_price    numeric,
    currency          text,
    confidence        numeric,
    calculated_at     timestamp with time zone,
    approved_at       timestamp with time zone,
    effective_from    timestamp with time zone,
    effective_to      timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_customer_id uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 return query
 select tv.id, r.id, r.request_reference, bi.id, tv.method, tv.status, tv.amount, tv.cash_price,
        tv.trade_in_price, tv.currency, tv.confidence, tv.calculated_at, tv.approved_at,
        tv.effective_from, tv.effective_to
 from public.trading_values tv
 join public.buying_items bi on bi.tenant_id=tv.tenant_id and bi.id=tv.buying_item_id
 join public.buying_requests r on r.tenant_id=bi.tenant_id and r.id=bi.buying_request_id
 where tv.tenant_id=p_tenant_id and r.customer_id=v_customer_id
 order by tv.calculated_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_selling_valuations"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_store_listings (
  p_tenant_id uuid
)
  RETURNS TABLE (
    listing_id        uuid,
    listing_reference text,
    title             text,
    description       text,
    asking_price      numeric,
    currency          text,
    quantity          integer,
    category_id       uuid,
    channel_id        uuid,
    asset_id          uuid
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.orders');
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not exists (select 1 from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() and c.status='active') then raise exception 'Active customer account required'; end if;
  return query
  select l.id,l.listing_reference,l.title,l.description,l.asking_price,l.currency,l.quantity,l.category_id,l.channel_id,l.asset_id
  from public.listings l
  where l.tenant_id=p_tenant_id and l.status='published' and l.quantity>0
  order by l.updated_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_store_listings"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_trade_ins (
  p_tenant_id uuid
)
  RETURNS TABLE (
    trade_in_id        uuid,
    trade_in_reference text,
    status             text,
    valuation_method   text,
    trading_value      numeric,
    cash_price         numeric,
    trade_in_price     numeric,
    credit_amount      numeric,
    currency           text,
    requested_at       timestamp with time zone,
    valued_at          timestamp with time zone,
    accepted_at        timestamp with time zone,
    received_at        timestamp with time zone,
    credited_at        timestamp with time zone,
    completed_at       timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.trade_in');
  return query
  select t.id, t.trade_in_reference, t.status, t.valuation_method, t.trading_value,
         t.cash_price, t.trade_in_price, t.credit_amount, t.currency, t.requested_at,
         t.valued_at, t.accepted_at, t.received_at, t.credited_at, t.completed_at
  from public.trade_in_transactions t
  join public.customers c on c.tenant_id=t.tenant_id and c.id=t.customer_id
  where t.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by t.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_trade_ins"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_get_trading_values (
  p_tenant_id uuid
)
  RETURNS TABLE (
    trading_value_id uuid,
    buying_item_id   uuid,
    method           text,
    status           text,
    amount           numeric,
    cash_price       numeric,
    trade_in_price   numeric,
    currency         text,
    confidence       numeric,
    calculated_at    timestamp with time zone,
    approved_at      timestamp with time zone,
    effective_from   timestamp with time zone,
    effective_to     timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.valuation');
  return query
  select tv.id, tv.buying_item_id, tv.method, tv.status, tv.amount, tv.cash_price,
         tv.trade_in_price, tv.currency, tv.confidence, tv.calculated_at, tv.approved_at,
         tv.effective_from, tv.effective_to
  from public.trading_values tv
  join public.buying_items i
    on i.tenant_id = tv.tenant_id and i.id = tv.buying_item_id
  join public.buying_requests r
    on r.tenant_id = i.tenant_id and r.id = i.buying_request_id
  join public.customers c
    on c.tenant_id = r.tenant_id and c.id = r.customer_id
  where tv.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
    and tv.status in ('approved','superseded')
  order by tv.calculated_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_get_trading_values"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_mark_acquisition_posted (
  p_tenant_id      uuid,
  p_acquisition_id uuid
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_customer_id uuid; v_status text; v_posted_at timestamptz;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
  if v_customer_id is null then raise exception 'Customer account not found'; end if;

  select a.status,a.posted_at into v_status,v_posted_at
  from public.acquisitions a
  where a.tenant_id=p_tenant_id and a.id=p_acquisition_id and a.customer_id=v_customer_id
  for update;

  if v_status is null then raise exception 'Acquisition not found'; end if;
  if v_status <> 'awaiting_item' then raise exception 'This acquisition is not currently awaiting the item'; end if;

  update public.acquisitions
  set posted_at=coalesce(posted_at,now()),
      customer_sent_at=coalesce(customer_sent_at,now()),
      shipping_status='in_transit',
      shipping_status_updated_at=now(),
      updated_at=now()
  where tenant_id=p_tenant_id and id=p_acquisition_id;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_mark_acquisition_posted"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_mark_buying_item_posted (
  p_tenant_id      uuid,
  p_buying_item_id uuid
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_customer_id uuid; v_stage text;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
  if v_customer_id is null then raise exception 'Customer account not found'; end if;
  select bi.purchase_stage into v_stage from public.buying_items bi join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id and br.customer_id=v_customer_id for update;
  if v_stage is null then raise exception 'Selling item not found'; end if;
  if v_stage<>'awaiting_item' then raise exception 'This item is not currently awaiting the item from you'; end if;
  insert into public.buying_item_shipping(tenant_id,buying_item_id,shipping_status,shipping_status_updated_at,posted_at,customer_sent_at)
  values(p_tenant_id,p_buying_item_id,'in_transit',now(),now(),now())
  on conflict (buying_item_id) do update set shipping_status='in_transit',shipping_status_updated_at=now(),posted_at=coalesce(public.buying_item_shipping.posted_at,now()),customer_sent_at=coalesce(public.buying_item_shipping.customer_sent_at,now()),updated_at=now();
  update public.buying_items set purchase_stage='shipping',purchase_stage_updated_at=now(),updated_at=now() where tenant_id=p_tenant_id and id=p_buying_item_id;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_mark_buying_item_posted"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_pay_retail_order_with_credit (
  p_tenant_id uuid,
  p_order_id  uuid
)
  RETURNS TABLE (
    order_id         uuid,
    order_reference  text,
    status           text,
    amount           numeric,
    currency         text,
    remaining_credit numeric
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_actor uuid := auth.uid();
  v_customer_id uuid;
  v_order public.retail_orders%rowtype;
  v_account public.customer_credit_accounts%rowtype;
  v_item record;
  v_payment_id uuid;
  v_ledger_id uuid;
  v_remaining numeric;
  v_bad boolean := false;
  v_item_count integer := 0;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id
    and c.auth_user_id=v_actor
    and c.status='active'
  limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;

  select o.* into v_order
  from public.retail_orders o
  where o.tenant_id=p_tenant_id
    and o.id=p_order_id
    and o.customer_id=v_customer_id
  for update;
  if not found then raise exception 'Order not found'; end if;
  if v_order.status<>'pending_payment' then raise exception 'Order is not awaiting payment'; end if;
  if coalesce(v_order.amount_due,0)<=0 then raise exception 'Order has no amount due'; end if;

  -- Lock and validate every physical item before taking any credit.
  for v_item in
    select i.id as item_id, i.listing_id, i.inventory_asset_id
    from public.retail_order_items i
    where i.tenant_id=p_tenant_id and i.order_id=p_order_id
    order by i.listing_id
    for update
  loop
    v_item_count := v_item_count + 1;
    if v_item.listing_id is null then
      v_bad := true;
      continue;
    end if;

    perform 1
    from public.listings l
    where l.tenant_id=p_tenant_id
      and l.id=v_item.listing_id
      and l.status='published'
      and coalesce(l.quantity,0)>=1
    for update;

    if not found then v_bad := true; end if;
  end loop;

  if v_item_count=0 then raise exception 'Order contains no products'; end if;
  if v_bad then
    raise exception 'One or more products in this order are no longer available';
  end if;

  select a.* into v_account
  from public.customer_credit_accounts a
  where a.tenant_id=p_tenant_id
    and a.customer_id=v_customer_id
  for update;
  if not found then raise exception 'Customer credit account not found'; end if;
  if upper(coalesce(v_account.currency,'GBP'))<>upper(coalesce(v_order.currency,'GBP')) then
    raise exception 'Customer credit currency does not match the order';
  end if;
  if coalesce(v_account.balance,0)<v_order.amount_due then
    raise exception 'Insufficient customer credit';
  end if;

  insert into public.payment_records(
    tenant_id,payment_reference,payment_type,status,direction,amount,currency,payment_method,
    customer_id,retail_order_id,notes,created_by,processed_at
  ) values(
    p_tenant_id,
    'PAY-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
    'customer_payment','paid','inbound',v_order.amount_due,v_order.currency,'customer_credit',
    v_customer_id,v_order.id,'Retail order paid using customer credit account.',v_actor,now()
  )
  returning id into v_payment_id;

  insert into public.ledger_entries(
    tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,retail_order_id,
    description,reference_type,reference_id,created_by,posted_at
  ) values(
    p_tenant_id,
    'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
    'payment','credit','posted',v_order.amount_due,v_order.currency,v_customer_id,v_order.id,
    'Retail order paid using customer credit','payment_record',v_payment_id,v_actor,now()
  )
  returning id into v_ledger_id;

  update public.customer_credit_accounts
  set balance=balance-v_order.amount_due,updated_at=now()
  where id=v_account.id
  returning balance into v_remaining;

  update public.retail_orders
  set status='paid',payment_status='paid',paid_at=now(),amount_due=0,updated_at=now()
  where tenant_id=p_tenant_id and id=v_order.id;

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
  ) values(
    p_tenant_id,'retail_order',v_order.id,'pending_payment','paid',v_actor,
    'Retail order paid using customer credit',
    jsonb_build_object('source','customer_credit','payment_id',v_payment_id,'ledger_id',v_ledger_id)
  );

  -- Payment claims every item atomically; no partial basket sale.
  for v_item in
    select i.listing_id, i.inventory_asset_id
    from public.retail_order_items i
    where i.tenant_id=p_tenant_id and i.order_id=p_order_id
    order by i.listing_id
  loop
    update public.listings l
    set status='sold',sold_at=coalesce(l.sold_at,now()),updated_at=now()
    where l.tenant_id=p_tenant_id and l.id=v_item.listing_id and l.status='published';

    if v_item.inventory_asset_id is not null then
      update public.inventory_assets ia
      set status='sold',sold_at=coalesce(ia.sold_at,now()),updated_at=now()
      where ia.tenant_id=p_tenant_id and ia.id=v_item.inventory_asset_id and ia.status in ('received','inspection','testing','repair','ready_for_sale','listed','reserved');
    end if;
  end loop;

  -- Create the customer fulfilment record at payment time so the subscriber
  -- has a concrete order to prepare for dispatch.
  insert into public.fulfilments(
    tenant_id,retail_order_id,fulfilment_reference,status,recipient_name,recipient_email,
    shipping_address,notes,metadata
  )
  select
    p_tenant_id,v_order.id,
    'FUL-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
    'awaiting',
    v_order.customer_name,v_order.customer_email,
    coalesce(v_order.shipping_address,'{}'::jsonb),
    'Retail order paid; fulfilment awaiting shipping label.',
    jsonb_build_object('source','retail_payment','payment_id',v_payment_id)
  where not exists (
    select 1 from public.fulfilments f
    where f.tenant_id=p_tenant_id and f.retail_order_id=v_order.id
  );

  return query
  select v_order.id,v_order.order_reference,'paid'::text,v_order.total,v_order.currency,v_remaining;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_pay_retail_order_with_credit"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_refuse_offer (
  p_tenant_id      uuid,
  p_offer_id       uuid,
  p_response_notes text DEFAULT NULL::text
)
  RETURNS boolean
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare v_customer_id uuid; v_status text; v_item_id uuid; v_offer_type text;
begin
 perform private.require_tenant_feature(p_tenant_id,'module.offers');
 if auth.uid() is null then raise exception 'authentication required'; end if;
 v_customer_id:=private.customer_id_for_current_user(p_tenant_id);
 if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;
 select o.status,o.buying_item_id,o.offer_type into v_status,v_item_id,v_offer_type
 from public.offers o
 join public.buying_items bi on bi.tenant_id=o.tenant_id and bi.id=o.buying_item_id
 join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
 where o.tenant_id=p_tenant_id and o.id=p_offer_id and br.customer_id=v_customer_id for update of o;
 if v_item_id is null then raise exception 'offer not found or not owned by current customer'; end if;
 if v_status<>'published' then raise exception 'offer is not available for refusal'; end if;
 update public.offers set status='refused',responded_at=now(),response_notes=p_response_notes,updated_at=now()
 where tenant_id=p_tenant_id and id=p_offer_id;
 insert into public.offer_events(tenant_id,offer_id,event_type,from_status,to_status,notes,actor_user_id)
 values(p_tenant_id,p_offer_id,'refused','published','refused',p_response_notes,auth.uid());
 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
 values(p_tenant_id,'offer',p_offer_id,'published','refused',auth.uid(),p_response_notes,jsonb_build_object('source','customer_action'));
 update public.buying_items
 set purchase_stage=case when v_offer_type='final' then 'final_offer_refused' else 'offer_refused' end,
     purchase_stage_updated_at=now(),updated_at=now()
 where tenant_id=p_tenant_id and id=v_item_id;
 return true;
end;$function$;

REVOKE ALL ON FUNCTION "public"."customer_refuse_offer"(uuid, uuid, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_register_for_tenant (
  p_tenant_id  uuid,
  p_first_name text,
  p_last_name  text DEFAULT NULL::text,
  p_phone      text DEFAULT NULL::text
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
 v_user_id uuid:=auth.uid(); v_customer_id uuid; v_email text;
 v_first_name text:=btrim(coalesce(p_first_name,'')); v_last_name text:=nullif(btrim(coalesce(p_last_name,'')),''); v_phone text:=nullif(btrim(coalesce(p_phone,'')),'');
begin
 if v_user_id is null then raise exception 'Authentication required'; end if;
 if p_tenant_id is null then raise exception 'Subscriber business is required'; end if;
 if v_first_name='' then raise exception 'First name is required'; end if;
 if not exists(select 1 from public.tenants t where t.id=p_tenant_id and t.status='active') then raise exception 'Subscriber business is not available'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=v_user_id limit 1;
 if v_customer_id is not null then
   insert into public.customer_credit_accounts(tenant_id,customer_id,balance,currency) values(p_tenant_id,v_customer_id,0,'GBP') on conflict(tenant_id,customer_id) do nothing;
   return v_customer_id;
 end if;
 select u.email into v_email from auth.users u where u.id=v_user_id;
 insert into public.customers(tenant_id,auth_user_id,first_name,last_name,email,phone,status)
 values(p_tenant_id,v_user_id,v_first_name,v_last_name,v_email,v_phone,'active') returning id into v_customer_id;
 insert into public.customer_credit_accounts(tenant_id,customer_id,balance,currency) values(p_tenant_id,v_customer_id,0,'GBP');
 return v_customer_id;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_register_for_tenant"(uuid, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_request_return (
  p_tenant_id      uuid,
  p_order_item_id  uuid,
  p_reason_code    text,
  p_reason         text,
  p_customer_notes text
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_customer_id uuid;
  v_order_id uuid;
  v_asset_id uuid;
  v_return_id uuid;
  v_fulfilment_status text;
begin
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  if auth.uid() is null then raise exception 'Authentication required'; end if;

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() and c.status='active'
  limit 1;
  if v_customer_id is null then raise exception 'Customer account not found'; end if;

  select oi.order_id,oi.inventory_asset_id into v_order_id,v_asset_id
  from public.retail_order_items oi
  join public.retail_orders o on o.tenant_id=oi.tenant_id and o.id=oi.order_id
  where oi.tenant_id=p_tenant_id
    and oi.id=p_order_item_id
    and o.customer_id=v_customer_id
    and o.status in ('paid','fulfilment','completed')
  limit 1;
  if v_order_id is null then raise exception 'Order item is not eligible for return'; end if;

  select f.status into v_fulfilment_status
  from public.fulfilments f
  where f.tenant_id=p_tenant_id and f.retail_order_id=v_order_id
  order by f.created_at desc limit 1;

  if v_fulfilment_status not in ('dispatched','delivered') then
    raise exception 'A return can be requested once the order has been shipped';
  end if;

  if exists(
    select 1 from public.returns r
    where r.tenant_id=p_tenant_id and r.order_item_id=p_order_item_id
      and r.return_type='customer_retail'
      and r.status not in ('rejected','refunded','replaced','closed')
  ) then
    raise exception 'A return request already exists for this item';
  end if;

  insert into public.returns(
    tenant_id,return_type,status,customer_id,order_id,order_item_id,
    inventory_asset_id,reason_code,reason,customer_notes,created_by
  )
  values(
    p_tenant_id,'customer_retail','requested',v_customer_id,v_order_id,p_order_item_id,
    v_asset_id,p_reason_code,p_reason,p_customer_notes,auth.uid()
  )
  returning id into v_return_id;

  insert into public.return_events(
    tenant_id,return_id,event_type,from_status,to_status,notes,actor_user_id
  )
  values(
    p_tenant_id,v_return_id,'requested',null,'requested',
    'Customer retail return requested from customer portal.',auth.uid()
  );

  return v_return_id;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_request_return"(uuid, uuid, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_save_bank_details (
  p_tenant_id           uuid,
  p_account_holder_name text,
  p_sort_code           text,
  p_account_number      text,
  p_bank_name           text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_customer_id uuid;
  v_holder text := btrim(coalesce(p_account_holder_name,''));
  v_sort text := regexp_replace(coalesce(p_sort_code,''),'[^0-9]','','g');
  v_account text := regexp_replace(coalesce(p_account_number,''),'[^0-9]','','g');
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  limit 1;
  if v_customer_id is null then raise exception 'Customer account not found'; end if;
  if v_holder='' then raise exception 'Account holder name is required'; end if;
  if length(v_sort)<>6 then raise exception 'UK sort code must contain 6 digits'; end if;
  if length(v_account)<>8 then raise exception 'UK account number must contain 8 digits'; end if;

  insert into public.customer_bank_details(
    tenant_id,customer_id,account_holder_name,sort_code,account_number,bank_name
  )
  values(
    p_tenant_id,v_customer_id,v_holder,v_sort,v_account,nullif(btrim(coalesce(p_bank_name,'')),'')
  )
  on conflict (tenant_id,customer_id) do update set
    account_holder_name=excluded.account_holder_name,
    sort_code=excluded.sort_code,
    account_number=excluded.account_number,
    bank_name=excluded.bank_name,
    updated_at=now();

  return jsonb_build_object('saved',true);
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_save_bank_details"(uuid, text, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_set_default_address (
  p_tenant_id  uuid,
  p_address_id uuid
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_user uuid:=auth.uid(); v_customer uuid;
begin
 if v_user is null then raise exception 'Authentication required'; end if;
 select id into v_customer from public.customers where tenant_id=p_tenant_id and auth_user_id=v_user limit 1;
 if v_customer is null then raise exception 'Customer account not found for this subscriber'; end if;
 update public.customer_addresses set is_default=false where tenant_id=p_tenant_id and customer_id=v_customer;
 update public.customer_addresses set is_default=true,updated_at=now() where id=p_address_id and tenant_id=p_tenant_id and customer_id=v_customer;
 if not found then raise exception 'Address not found'; end if;
end $function$;

REVOKE ALL ON FUNCTION "public"."customer_set_default_address"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_submit_buying_request (
  p_tenant_id uuid,
  p_notes     text  DEFAULT NULL::text,
  p_items     jsonb DEFAULT '[]'::jsonb
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_customer_id uuid; v_request_id uuid; v_item jsonb; v_field jsonb;
  v_category_id uuid; v_field_id uuid; v_item_id uuid; v_product_id uuid;
  v_product record; v_rule record; v_research record; v_sort integer := 0;
  v_reference text; v_field_type text; v_value jsonb; v_required_count integer; v_supplied_count integer;
  v_condition text; v_reference_type text; v_percentage numeric; v_manual_price numeric;
  v_base_price numeric; v_amount numeric; v_trade_amount numeric; v_trade_percentage numeric;
  v_trade_manual_price numeric; v_valuation_id uuid; v_offer_id uuid; v_offer_amount numeric;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if exists (select 1 from public.tenant_memberships tm where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active') then raise exception 'subscriber accounts cannot submit customer buying requests for their own business'; end if;
  perform private.require_tenant_feature(p_tenant_id,'module.buying');
  v_customer_id := private.customer_id_for_current_user(p_tenant_id);
  if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items)=0 then raise exception 'at least one item is required'; end if;

  v_reference := 'BR-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
  insert into public.buying_requests(tenant_id,customer_id,request_reference,status,source,notes,submitted_at)
  values(p_tenant_id,v_customer_id,v_reference,'submitted','customer_portal',nullif(btrim(coalesce(p_notes,'')),''),now())
  returning id into v_request_id;

  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'buying_request',v_request_id,'draft','submitted',auth.uid(),null,'{"source":"customer_portal"}'::jsonb);

  for v_item in select value from jsonb_array_elements(p_items) loop
    v_sort := v_sort + 1;
    begin v_category_id := (v_item->>'category_id')::uuid; exception when others then raise exception 'invalid category id'; end;
    if not exists(select 1 from public.categories c where c.tenant_id=p_tenant_id and c.id=v_category_id and c.active and c.buying_enabled) then raise exception 'invalid buying category'; end if;

    v_product_id := null;
    if nullif(btrim(coalesce(v_item->>'buying_product_id','')),'') is not null then
      begin v_product_id := (v_item->>'buying_product_id')::uuid; exception when others then raise exception 'invalid buying product id'; end;
      select bp.* into v_product from public.tenant_buying_products bp where bp.id=v_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
      if not found then raise exception 'selected buying product is not active for this subscriber'; end if;
      if v_product.category_id is distinct from v_category_id then raise exception 'selected buying product does not belong to the selected buying category'; end if;
    end if;

    insert into public.buying_items(tenant_id,buying_request_id,category_id,item_reference,status,title,description,quantity,sort_order,item_condition,buying_product_id,branch_id)
    values(p_tenant_id,v_request_id,v_category_id,'BI-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),'submitted',
      nullif(btrim(coalesce(v_item->>'title','')),''),nullif(btrim(coalesce(v_item->>'description','')),''),
      greatest(coalesce((v_item->>'quantity')::integer,1),1),v_sort,nullif(btrim(coalesce(v_item->>'condition','')),''),
      v_product_id,case when v_product_id is null then null else v_product.branch_id end)
    returning id into v_item_id;

    insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
    values(p_tenant_id,'buying_item',v_item_id,'draft','submitted',auth.uid(),null,'{"source":"customer_portal"}'::jsonb);

    if jsonb_typeof(coalesce(v_item->'fields','[]'::jsonb)) <> 'array' then raise exception 'item fields must be an array'; end if;
    select count(*) into v_required_count from public.category_fields f where f.tenant_id=p_tenant_id and f.category_id=v_category_id and f.required_for_buying and f.customer_visible;
    select count(*) into v_supplied_count from jsonb_array_elements(coalesce(v_item->'fields','[]'::jsonb)) x where nullif(x->>'field_id','') is not null;
    if v_supplied_count > (select count(*) from public.category_fields f where f.tenant_id=p_tenant_id and f.category_id=v_category_id and f.customer_visible) then raise exception 'too many category fields supplied'; end if;

    for v_field in select value from jsonb_array_elements(coalesce(v_item->'fields','[]'::jsonb)) loop
      begin v_field_id := (v_field->>'field_id')::uuid; exception when others then raise exception 'invalid field id'; end;
      select f.field_type into v_field_type from public.category_fields f where f.tenant_id=p_tenant_id and f.id=v_field_id and f.category_id=v_category_id and f.customer_visible;
      if not found then raise exception 'invalid field for category'; end if;
      v_value := v_field->'value';
      if v_value is null or v_value='null'::jsonb then raise exception 'field value is required'; end if;
      if v_field_type='select' then
        if jsonb_typeof(v_value)<>'string' or not exists(select 1 from public.category_field_options o where o.tenant_id=p_tenant_id and o.category_id=v_category_id and o.field_id=v_field_id and o.value=(v_value #>> '{}') and o.active) then raise exception 'invalid select option'; end if;
      elsif v_field_type='multiselect' then
        if jsonb_typeof(v_value)<>'array' then raise exception 'multiselect value must be an array'; end if;
        if exists(select 1 from jsonb_array_elements_text(v_value) selected(value) where not exists(select 1 from public.category_field_options o where o.tenant_id=p_tenant_id and o.category_id=v_category_id and o.field_id=v_field_id and o.value=selected.value and o.active)) then raise exception 'invalid multiselect option'; end if;
      end if;
      if v_field_type in ('text','textarea','email','phone','url','select','multiselect') then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_text) values(p_tenant_id,v_item_id,v_field_id,case when jsonb_typeof(v_value)='string' then v_value #>> '{}' else v_value::text end);
      elsif v_field_type in ('number','currency') then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_number) values(p_tenant_id,v_item_id,v_field_id,(v_value #>> '{}')::numeric);
      elsif v_field_type='boolean' then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_boolean) values(p_tenant_id,v_item_id,v_field_id,(v_value #>> '{}')::boolean);
      elsif v_field_type='date' then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_date) values(p_tenant_id,v_item_id,v_field_id,(v_value #>> '{}')::date);
      else
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_json) values(p_tenant_id,v_item_id,v_field_id,v_value);
      end if;
    end loop;

    if v_required_count > 0 then
      select count(*) into v_supplied_count
      from public.buying_item_field_values v join public.category_fields f on f.tenant_id=v.tenant_id and f.id=v.field_id
      where v.tenant_id=p_tenant_id and v.buying_item_id=v_item_id and f.required_for_buying and f.customer_visible
        and (v.value_text is not null or v.value_number is not null or v.value_boolean is not null or v.value_date is not null or v.value_json is not null);
      if v_supplied_count <> v_required_count then raise exception 'required category fields are missing'; end if;
    end if;

    if v_product_id is not null then
      select bp.* into v_product from public.tenant_buying_products bp where bp.id=v_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
      v_amount := null; v_trade_amount := null; v_base_price := null; v_reference_type := null; v_percentage := null; v_trade_percentage := null;

      if v_product.manual_offer_price is not null then
        v_amount := v_product.manual_offer_price;
      else
        select * into v_rule from public.tenant_buying_condition_rules r where r.tenant_id=p_tenant_id and r.buying_product_id=v_product_id limit 1;
        if found then
          v_condition := lower(nullif(btrim(coalesce(v_item->>'condition','')),''));
          v_condition := case v_condition
            when 'factory-sealed' then 'sealed' when 'opened-unused' then 'opened_never_used' when 'opened_never_used' then 'opened_never_used'
            when 'sealed' then 'sealed' when 'excellent' then 'excellent' when 'good' then 'good'
            when 'fair' then 'poor' when 'damaged' then 'poor' when 'not-working' then 'poor'
            when 'not_working' then 'poor' when 'poor' then 'poor' else v_condition end;

          v_percentage := case v_condition when 'sealed' then v_rule.sealed_percentage when 'opened_never_used' then v_rule.opened_never_used_percentage when 'excellent' then v_rule.excellent_percentage when 'good' then v_rule.good_percentage when 'poor' then v_rule.poor_percentage end;
          v_trade_percentage := case v_condition when 'sealed' then v_rule.sealed_trade_in_percentage when 'opened_never_used' then v_rule.opened_never_used_trade_in_percentage when 'excellent' then v_rule.excellent_trade_in_percentage when 'good' then v_rule.good_trade_in_percentage when 'poor' then v_rule.poor_trade_in_percentage end;
          v_manual_price := case v_condition when 'sealed' then v_rule.sealed_manual_price when 'opened_never_used' then v_rule.opened_never_used_manual_price when 'excellent' then v_rule.excellent_manual_price when 'good' then v_rule.good_manual_price when 'poor' then v_rule.poor_manual_price end;
          v_trade_manual_price := case v_condition when 'sealed' then v_rule.sealed_trade_in_manual_price when 'opened_never_used' then v_rule.opened_never_used_trade_in_manual_price when 'excellent' then v_rule.excellent_trade_in_manual_price when 'good' then v_rule.good_trade_in_manual_price when 'poor' then v_rule.poor_trade_in_manual_price end;
          v_reference_type := 'uk_new';

          if v_manual_price is not null or v_trade_manual_price is not null then
            v_amount := v_manual_price; v_trade_amount := v_trade_manual_price;
          elsif v_percentage is not null then
            select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research
            from public.tenant_buying_research tr
            where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product_id and tr.evidence_type='uk_new'
              and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
            order by tr.checked_at desc limit 1;
            if found then
              v_base_price := v_research.observed_price;
              v_amount := round(v_base_price*v_percentage/100,2);
              v_trade_amount := case when v_trade_percentage is null then null else round(v_base_price*v_trade_percentage/100,2) end;
            end if;
          end if;
        end if;
      end if;

      if v_amount is not null or v_trade_amount is not null then
        v_offer_amount := coalesce(v_amount,v_trade_amount);
        insert into public.trading_values(tenant_id,buying_item_id,method,status,amount,currency,confidence,calculated_at,cash_price,trade_in_price,notes,metadata)
        values(p_tenant_id,v_item_id,'rule','draft',v_offer_amount,'GBP',null,now(),v_amount,v_trade_amount,'Automatic buying catalogue valuation',
          jsonb_build_object('source','customer_submission','buying_product_id',v_product_id,'reference_type',v_reference_type,'base_price',v_base_price,'percentage',v_percentage,'trade_in_percentage',v_trade_percentage))
        returning id into v_valuation_id;

        update public.trading_values set status='approved',approved_at=now(),approved_by=null,updated_at=now() where id=v_valuation_id and tenant_id=p_tenant_id;
        insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
        values(p_tenant_id,'trading_value',v_valuation_id,'draft','approved',auth.uid(),'Automatic valuation approved from customer submission','{"source":"customer_submission","valuation":"automatic"}'::jsonb);

        insert into public.offers(tenant_id,buying_item_id,trading_value_id,offer_reference,offer_type,status,amount,currency,created_by,offer_mode)
        values(p_tenant_id,v_item_id,v_valuation_id,'OF-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),'initial','draft',v_offer_amount,'GBP',auth.uid(),case when v_amount is not null then 'cash' else 'trade_in' end)
        returning id into v_offer_id;

        update public.offers set status='published',published_at=now(),updated_at=now() where id=v_offer_id and tenant_id=p_tenant_id;
        insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
        values(p_tenant_id,'offer',v_offer_id,'draft','published',auth.uid(),'Automatic offer published from customer submission','{"source":"customer_submission","valuation":"automatic"}'::jsonb);
      end if;
    end if;
  end loop;
  return v_request_id;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_submit_buying_request"(uuid, text, jsonb) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_test_registration_status()
  RETURNS TABLE (
    customer_id uuid,
    tenant_id   uuid,
    tenant_slug text
  )
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select c.id, c.tenant_id, t.slug
  from public.customers c
  join public.tenants t on t.id = c.tenant_id
  where c.auth_user_id = auth.uid()
    and t.slug in ('test-business-a','test-business-b')
    and t.status = 'active'
    and coalesce((t.settings->>'test_lab')::boolean, false) = true
  order by t.slug;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_test_registration_status"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_update_profile (
  p_tenant_id  uuid,
  p_first_name text,
  p_last_name  text DEFAULT NULL::text,
  p_phone      text DEFAULT NULL::text
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_user_id uuid := auth.uid();
  v_first_name text := btrim(coalesce(p_first_name, ''));
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;
  if v_first_name = '' then
    raise exception 'First name is required';
  end if;

  update public.customers
  set first_name = v_first_name,
      last_name = nullif(btrim(coalesce(p_last_name, '')), ''),
      phone = nullif(btrim(coalesce(p_phone, '')), '')
  where tenant_id = p_tenant_id
    and auth_user_id = v_user_id;

  if not found then
    raise exception 'Customer account not found for this subscriber';
  end if;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."customer_update_profile"(uuid, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.customer_upsert_address (
  p_tenant_id      uuid,
  p_address_id     uuid    DEFAULT NULL::uuid,
  p_address_type   text    DEFAULT 'shipping'::text,
  p_recipient_name text    DEFAULT NULL::text,
  p_company_name   text    DEFAULT NULL::text,
  p_line1          text    DEFAULT NULL::text,
  p_line2          text    DEFAULT NULL::text,
  p_city           text    DEFAULT NULL::text,
  p_county         text    DEFAULT NULL::text,
  p_postcode       text    DEFAULT NULL::text,
  p_country_code   text    DEFAULT 'GB'::text,
  p_is_default     boolean DEFAULT false
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_user uuid:=auth.uid(); v_customer uuid; v_id uuid;
begin
 if v_user is null then raise exception 'Authentication required'; end if;
 select id into v_customer from public.customers where tenant_id=p_tenant_id and auth_user_id=v_user limit 1;
 if v_customer is null then raise exception 'Customer account not found for this subscriber'; end if;
 if nullif(btrim(coalesce(p_line1,'')),'') is null or nullif(btrim(coalesce(p_city,'')),'') is null or nullif(btrim(coalesce(p_postcode,'')),'') is null then raise exception 'Address line 1, city and postcode are required'; end if;
 if p_is_default then update public.customer_addresses set is_default=false where tenant_id=p_tenant_id and customer_id=v_customer; end if;
 if p_address_id is null then
   insert into public.customer_addresses(tenant_id,customer_id,address_type,recipient_name,company_name,line1,line2,city,county,postcode,country_code,is_default)
   values(p_tenant_id,v_customer,p_address_type,nullif(btrim(p_recipient_name),''),nullif(btrim(p_company_name),''),btrim(p_line1),nullif(btrim(p_line2),''),btrim(p_city),nullif(btrim(p_county),''),btrim(p_postcode),upper(coalesce(p_country_code,'GB')),p_is_default)
   returning id into v_id;
 else
   update public.customer_addresses set address_type=p_address_type,recipient_name=nullif(btrim(p_recipient_name),''),company_name=nullif(btrim(p_company_name),''),
   line1=btrim(p_line1),line2=nullif(btrim(p_line2),''),city=btrim(p_city),county=nullif(btrim(p_county),''),postcode=btrim(p_postcode),
   country_code=upper(coalesce(p_country_code,'GB')),is_default=p_is_default,updated_at=now()
   where id=p_address_id and tenant_id=p_tenant_id and customer_id=v_customer returning id into v_id;
   if v_id is null then raise exception 'Address not found'; end if;
 end if;
 return v_id;
end $function$;

REVOKE ALL ON FUNCTION "public"."customer_upsert_address"(uuid, uuid, text, text, text, text, text, text, text, text, text, boolean) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.ensure_category_default_branch()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'pg_catalog'
  AS $function$
begin
  if not exists (
    select 1 from public.category_branches b
    where b.tenant_id = new.tenant_id
      and b.category_id = new.id
  ) then
    insert into public.category_branches
      (tenant_id, category_id, name, slug, description, active, buying_enabled, selling_enabled, sort_order)
    values
      (new.tenant_id, new.id, new.name, new.slug, new.description, new.active, new.buying_enabled, new.selling_enabled, 0);
  end if;
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."ensure_category_default_branch"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.ensure_retail_order_fulfilment()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
  if new.status='paid' and coalesce(old.status,'')<>'paid' then
    insert into public.fulfilments(
      tenant_id,retail_order_id,fulfilment_reference,status,recipient_name,recipient_email,
      shipping_address,notes,metadata
    )
    values(
      new.tenant_id,new.id,
      'FUL-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
      'awaiting',
      new.customer_name,new.customer_email,
      coalesce(new.shipping_address,'{}'::jsonb),
      'Retail order paid; fulfilment awaiting shipping label.',
      jsonb_build_object('source','retail_payment','order_id',new.id)
    )
    on conflict do nothing;
  end if;
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."ensure_retail_order_fulfilment"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.generate_acquisition_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if new.acquisition_reference is null or btrim(new.acquisition_reference) = '' then
    new.acquisition_reference := 'ACQ-' || to_char(clock_timestamp(),'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8));
  end if; return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.generate_asset_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$ begin if new.asset_reference is null or btrim(new.asset_reference)='' then new.asset_reference := 'AST-' || to_char(clock_timestamp(),'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8)); end if; return new; end; $function$;

CREATE OR REPLACE FUNCTION public.generate_buying_item_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if new.item_reference is null or btrim(new.item_reference) = '' then
    new.item_reference := 'ITEM-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.generate_buying_request_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if new.request_reference is null or btrim(new.request_reference) = '' then
    new.request_reference := 'REQ-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.generate_customer_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if new.customer_reference is null or btrim(new.customer_reference) = '' then
    new.customer_reference := 'CUS-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.generate_ledger_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
 if new.entry_reference is null or btrim(new.entry_reference)='' then new.entry_reference := 'LED-' || to_char(clock_timestamp(),'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8)); end if;
 return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.generate_listing_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
 if new.listing_reference is null or btrim(new.listing_reference)='' then new.listing_reference := 'LST-' || to_char(clock_timestamp(),'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8)); end if;
 return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.generate_offer_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if new.offer_reference is null or btrim(new.offer_reference) = '' then
    new.offer_reference := 'OFF-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.generate_order_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
 if new.order_reference is null or btrim(new.order_reference)='' then new.order_reference := 'ORD-' || to_char(clock_timestamp(),'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8)); end if;
 return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.generate_payment_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
 if new.payment_reference is null or btrim(new.payment_reference)='' then new.payment_reference := 'PAY-' || to_char(clock_timestamp(),'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8)); end if;
 return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.generate_return_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
 if new.return_reference is null or btrim(new.return_reference)='' then new.return_reference := 'RET-' || to_char(clock_timestamp(),'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8)); end if;
 return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.generate_trade_in_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
 if new.trade_in_reference is null or btrim(new.trade_in_reference)='' then new.trade_in_reference := 'TRD-' || to_char(clock_timestamp(),'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,8)); end if;
 return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.get_buying_catalogue_status_counts (
  p_tenant_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_available int;v_live int;v_auto int;v_manual int;v_inactive int;
begin
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.view') then raise exception 'Tenant user is not authorised to view Buying catalogue';end if;
 if not private.has_tenant_feature(p_tenant_id,'module.buying') then raise exception 'Buying is not enabled for this subscription';end if;
 select count(*) into v_available from public.catalogue_master_products p where p.active and p.customer_visible and not exists(select 1 from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and s.master_product_id=p.id and s.active and s.buying_enabled);
 select count(*) into v_live from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and s.active and s.buying_enabled and coalesce(s.website_visible,true);
 select count(*) into v_inactive from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and (not s.active or not s.buying_enabled or not coalesce(s.website_visible,true));
 select count(*) into v_auto from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and s.active and s.buying_enabled and coalesce(s.website_visible,true) and exists(select 1 from public.tenant_buying_products bp join public.tenant_buying_condition_rules r on r.tenant_id=bp.tenant_id and r.buying_product_id=bp.id where bp.tenant_id=s.tenant_id and bp.category_id=s.category_id and bp.branch_id is not distinct from s.branch_id and lower(bp.manufacturer)=lower(s.manufacturer) and lower(bp.model)=lower(s.model) and lower(coalesce(bp.package_name,''))=lower(coalesce(s.package_name,'')) and bp.active);
 select count(*) into v_manual from public.tenant_catalogue_selections s where s.tenant_id=p_tenant_id and s.active and s.buying_enabled and coalesce(s.website_visible,true) and not exists(select 1 from public.tenant_buying_products bp join public.tenant_buying_condition_rules r on r.tenant_id=bp.tenant_id and r.buying_product_id=bp.id where bp.tenant_id=s.tenant_id and bp.category_id=s.category_id and bp.branch_id is not distinct from s.branch_id and lower(bp.manufacturer)=lower(s.manufacturer) and lower(bp.model)=lower(s.model) and lower(coalesce(bp.package_name,''))=lower(coalesce(s.package_name,'')) and bp.active);
 return jsonb_build_object('available',v_available,'live',v_live,'automatic',v_auto,'manual_valuation',v_manual,'inactive',v_inactive);
end;$function$;

REVOKE ALL ON FUNCTION "public"."get_buying_catalogue_status_counts"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.get_inventory_product_catalogue (
  p_tenant_id uuid
)
  RETURNS TABLE (
    master_product_id  uuid,
    category_id        uuid,
    category_name      text,
    branch_id          uuid,
    branch_name        text,
    manufacturer_id    uuid,
    manufacturer_name  text,
    model              text,
    package_key        text,
    package_name       text,
    catalogue_category text,
    main_category      text,
    product_type       text
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select
    s.master_product_id,
    s.category_id,
    c.name,
    s.branch_id,
    b.name,
    m.id,
    m.name,
    p.model,
    p.package_key,
    p.package_name,
    p.catalogue_category,
    p.main_category,
    p.product_type
  from public.tenant_catalogue_selections s
  join public.catalogue_master_products p on p.id=s.master_product_id
  join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
  left join public.categories c on c.id=s.category_id and c.tenant_id=p_tenant_id
  left join public.category_branches b on b.id=s.branch_id and b.tenant_id=p_tenant_id
  where s.tenant_id=p_tenant_id
    and s.active
    and p.active
    and p.customer_visible
    and private.has_tenant_feature(p_tenant_id,'module.inventory')
    and private.has_tenant_permission(p_tenant_id,auth.uid(),'inventory.manage')
  order by m.name,p.model,p.package_name;
$function$;

REVOKE ALL ON FUNCTION "public"."get_inventory_product_catalogue"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.get_master_buying_catalogue_facets (
  p_tenant_id   uuid,
  p_category_id uuid DEFAULT NULL::uuid,
  p_branch_id   uuid DEFAULT NULL::uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_categories jsonb;
  v_branches jsonb;
  v_manufacturers jsonb;
begin
  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'categories.view') then
    raise exception 'Tenant user is not authorised to view catalogue';
  end if;

  if not private.has_tenant_feature(p_tenant_id, 'module.buying') then
    raise exception 'Buying is not enabled for this subscription';
  end if;

  if not private.has_tenant_feature(p_tenant_id, 'catalogue.pre_filled') then
    raise exception 'Pre-filled catalogue is not enabled for this subscription';
  end if;

  select coalesce(jsonb_agg(to_jsonb(x) order by x.name),'[]'::jsonb)
  into v_categories
  from (
    select c.id,c.name,count(p.id)::integer as count
    from public.catalogue_master_categories c
    join public.catalogue_master_products p on p.category_id=c.id
    where p.active and p.customer_visible
    group by c.id,c.name
  ) x;

  select coalesce(jsonb_agg(to_jsonb(x) order by x.name),'[]'::jsonb)
  into v_branches
  from (
    select b.id,b.name,count(p.id)::integer as count
    from public.catalogue_master_branches b
    join public.catalogue_master_products p on p.branch_id=b.id
    where p.active and p.customer_visible
      and (p_category_id is null or p.category_id=p_category_id)
    group by b.id,b.name
  ) x;

  select coalesce(jsonb_agg(to_jsonb(x) order by x.name),'[]'::jsonb)
  into v_manufacturers
  from (
    select m.id,m.name,count(p.id)::integer as count
    from public.catalogue_master_manufacturers m
    join public.catalogue_master_products p on p.manufacturer_id=m.id
    where p.active and p.customer_visible
      and (p_category_id is null or p.category_id=p_category_id)
      and (p_branch_id is null or p.branch_id=p_branch_id)
    group by m.id,m.name
  ) x;

  return jsonb_build_object(
    'categories',v_categories,
    'branches',v_branches,
    'manufacturers',v_manufacturers
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."get_master_buying_catalogue_facets"(uuid, uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.get_master_buying_catalogue_page (
  p_tenant_id       uuid,
  p_category_id     uuid    DEFAULT NULL::uuid,
  p_branch_id       uuid    DEFAULT NULL::uuid,
  p_manufacturer_id uuid    DEFAULT NULL::uuid,
  p_search          text    DEFAULT NULL::text,
  p_page            integer DEFAULT 1,
  p_page_size       integer DEFAULT 50
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_page integer := greatest(coalesce(p_page,1),1);
  v_size integer := least(greatest(coalesce(p_page_size,50),1),75);
  v_offset integer := (v_page-1)*v_size;
  v_total integer;
  v_products jsonb;
begin
  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'categories.view') then
    raise exception 'Tenant user is not authorised to view catalogue';
  end if;

  if not private.has_tenant_feature(p_tenant_id, 'module.buying') then
    raise exception 'Buying is not enabled for this subscription';
  end if;

  if not private.has_tenant_feature(p_tenant_id, 'catalogue.pre_filled') then
    raise exception 'Pre-filled catalogue is not enabled for this subscription';
  end if;

  with filtered as (
    select p.id
    from public.catalogue_master_products p
    where p.active and p.customer_visible
      and (p_category_id is null or p.category_id=p_category_id)
      and (p_branch_id is null or p.branch_id=p_branch_id)
      and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
      and (
        nullif(trim(coalesce(p_search,'')),'') is null
        or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%'
      )
  )
  select count(*) into v_total from filtered;

  select coalesce(jsonb_agg(to_jsonb(x) order by x.manufacturer_name,x.model,x.package_name), '[]'::jsonb)
  into v_products
  from (
    select
      p.id as product_id,
      p.category_id,
      coalesce(nullif(trim(p.catalogue_category),''),c.name) as category_name,
      p.branch_id,
      b.name as branch_name,
      p.manufacturer_id,
      m.name as manufacturer_name,
      p.model,
      p.package_name,
      p.product_type,
      p.notes,
      s.buying_enabled,
      s.active as selection_active,
      bp.id as buying_product_id,
      bp.active as buying_product_active,
      bp.manual_offer_price,
      r.id as rule_id,
      r.sealed_percentage,
      r.opened_never_used_percentage,
      r.excellent_percentage,
      r.good_percentage,
      r.poor_percentage
    from public.catalogue_master_products p
    join public.catalogue_master_categories c on c.id=p.category_id
    left join public.catalogue_master_branches b on b.id=p.branch_id
    join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
    left join public.tenant_catalogue_selections s
      on s.tenant_id=p_tenant_id and s.master_product_id=p.id
    left join public.tenant_buying_products bp
      on bp.tenant_id=p_tenant_id
      and bp.branch_id is not distinct from s.branch_id
      and lower(bp.manufacturer)=lower(m.name)
      and lower(bp.model)=lower(p.model)
      and lower(coalesce(bp.package_name,''))=lower(coalesce(p.package_name,''))
    left join public.tenant_buying_condition_rules r
      on r.tenant_id=p_tenant_id and r.buying_product_id=bp.id
    where p.id in (
      select id from public.catalogue_master_products p2
      where p2.active and p2.customer_visible
        and (p_category_id is null or p2.category_id=p_category_id)
        and (p_branch_id is null or p2.branch_id=p_branch_id)
        and (p_manufacturer_id is null or p2.manufacturer_id=p_manufacturer_id)
        and (
          nullif(trim(coalesce(p_search,'')),'') is null
          or lower(coalesce(p2.model,'')) like '%'||lower(trim(p_search))||'%'
          or lower(coalesce(p2.package_name,'')) like '%'||lower(trim(p_search))||'%'
          or lower(coalesce(p2.product_type,'')) like '%'||lower(trim(p_search))||'%'
          or lower(coalesce(p2.notes,'')) like '%'||lower(trim(p_search))||'%'
        )
    )
    order by m.name,p.model,p.package_name
    offset v_offset limit v_size
  ) x;

  return jsonb_build_object(
    'page',v_page,
    'page_size',v_size,
    'total',v_total,
    'products',v_products
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."get_master_buying_catalogue_page"(uuid, uuid, uuid, uuid, text, integer, integer) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.get_master_buying_catalogue_page_filtered (
  p_tenant_id       uuid,
  p_category_id     uuid    DEFAULT NULL::uuid,
  p_branch_id       uuid    DEFAULT NULL::uuid,
  p_manufacturer_id uuid    DEFAULT NULL::uuid,
  p_search          text    DEFAULT NULL::text,
  p_page            integer DEFAULT 1,
  p_page_size       integer DEFAULT 50,
  p_hide_added      boolean DEFAULT true
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
 v_page integer:=greatest(coalesce(p_page,1),1);
 v_size integer:=least(greatest(coalesce(p_page_size,50),1),75);
 v_offset integer:=(v_page-1)*v_size;
 v_total integer; v_products jsonb;
begin
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.view') then raise exception 'Tenant user is not authorised to view Buying catalogue'; end if;
 if not private.has_tenant_feature(p_tenant_id,'module.buying') then raise exception 'Buying is not enabled for this subscription'; end if;

 select count(*) into v_total
 from public.catalogue_master_products p
 where p.active and p.customer_visible
 and (p_category_id is null or p.category_id=p_category_id)
 and (p_branch_id is null or p.branch_id=p_branch_id)
 and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
 and (nullif(trim(coalesce(p_search,'')),'') is null
      or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%'
      or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%'
      or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%'
      or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%')
 and (not coalesce(p_hide_added,true)
      or not exists(select 1 from public.tenant_catalogue_selections s
                   where s.tenant_id=p_tenant_id and s.master_product_id=p.id and s.active and s.buying_enabled));

 select coalesce(jsonb_agg(to_jsonb(x) order by x.manufacturer_name,x.model,x.package_name),'[]'::jsonb)
 into v_products
 from (
   select p.id product_id,p.category_id,coalesce(nullif(trim(p.catalogue_category),''),c.name) category_name,
          p.branch_id,b.name branch_name,p.manufacturer_id,m.name manufacturer_name,p.model,p.package_name,p.product_type,p.notes,
          coalesce(s.buying_enabled,false) buying_enabled,coalesce(s.active,false) selection_active,s.website_visible,
          bp.id buying_product_id,bp.active buying_product_active,bp.manual_offer_price,
          r.id rule_id,r.sealed_percentage,r.opened_never_used_percentage,r.excellent_percentage,r.good_percentage,r.poor_percentage,
          r.sealed_reference_type,r.opened_never_used_reference_type,r.excellent_reference_type,r.good_reference_type,r.poor_reference_type,
          r.sealed_manual_price,r.opened_never_used_manual_price,r.excellent_manual_price,r.good_manual_price,r.poor_manual_price,r.sealed_trade_in_percentage,r.opened_never_used_trade_in_percentage,r.excellent_trade_in_percentage,r.good_trade_in_percentage,r.poor_trade_in_percentage,r.sealed_trade_in_manual_price,r.opened_never_used_trade_in_manual_price,r.excellent_trade_in_manual_price,r.good_trade_in_manual_price,r.poor_trade_in_manual_price,
          rn.observed_price uk_new_research_price,rn.source_name uk_new_research_source,rn.source_url uk_new_research_url,rn.checked_at uk_new_research_checked_at,
          ru.observed_price uk_used_research_price,ru.source_name uk_used_research_source,ru.source_url uk_used_research_url,ru.checked_at uk_used_research_checked_at
   from public.catalogue_master_products p
   join public.catalogue_master_categories c on c.id=p.category_id
   left join public.catalogue_master_branches b on b.id=p.branch_id
   join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
   left join public.tenant_catalogue_selections s on s.tenant_id=p_tenant_id and s.master_product_id=p.id
   left join public.tenant_buying_products bp on bp.tenant_id=p_tenant_id and bp.category_id=p.category_id
      and bp.branch_id is not distinct from p.branch_id and lower(bp.manufacturer)=lower(m.name)
      and lower(bp.model)=lower(p.model) and lower(coalesce(bp.package_name,''))=lower(coalesce(p.package_name,''))
   left join public.tenant_buying_condition_rules r on r.tenant_id=p_tenant_id and r.buying_product_id=bp.id
   left join lateral(
      select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at
      from public.tenant_buying_research tr
      where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_new'
        and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
      order by tr.checked_at desc nulls last,tr.created_at desc nulls last,tr.id desc limit 1
   ) rn on true
   left join lateral(
      select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at
      from public.tenant_buying_research tr
      where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_used'
        and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
      order by tr.checked_at desc nulls last,tr.created_at desc nulls last,tr.id desc limit 1
   ) ru on true
   where p.active and p.customer_visible
   and (p_category_id is null or p.category_id=p_category_id)
   and (p_branch_id is null or p.branch_id=p_branch_id)
   and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
   and (nullif(trim(coalesce(p_search,'')),'') is null
        or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%'
        or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%')
   and (not coalesce(p_hide_added,true)
        or not exists(select 1 from public.tenant_catalogue_selections sx
                     where sx.tenant_id=p_tenant_id and sx.master_product_id=p.id and sx.active and sx.buying_enabled))
   order by m.name,p.model,p.package_name
   offset v_offset limit v_size
 ) x;

 return jsonb_build_object('page',v_page,'page_size',v_size,'total',v_total,'products',v_products);
end;$function$;

REVOKE ALL ON FUNCTION "public"."get_master_buying_catalogue_page_filtered"(uuid, uuid, uuid, uuid, text, integer, integer, boolean) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.get_master_catalogue (
  p_tenant_id uuid
)
  RETURNS TABLE (
    category_id        uuid,
    category_name      text,
    category_slug      text,
    branch_id          uuid,
    branch_name        text,
    branch_slug        text,
    manufacturer_id    uuid,
    manufacturer_name  text,
    product_id         uuid,
    model              text,
    package_key        text,
    package_name       text,
    catalogue_category text,
    main_category      text,
    product_type       text,
    notes              text
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select
    c.id,c.name,c.slug,
    b.id,b.name,b.slug,
    m.id,m.name,
    p.id,p.model,p.package_key,p.package_name,p.catalogue_category,p.main_category,p.product_type,p.notes
  from public.catalogue_master_products p
  join public.catalogue_master_categories c on c.id=p.category_id
  left join public.catalogue_master_branches b on b.id=p.branch_id
  join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
  where p.active and p.customer_visible
    and (select private.can_tenant(p_tenant_id,'buying.view','module.buying'))
    and (select private.has_tenant_feature(p_tenant_id,'catalogue.pre_filled'));
$function$;

REVOKE ALL ON FUNCTION "public"."get_master_catalogue"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.get_master_catalogue_for_selection (
  p_tenant_id uuid
)
  RETURNS TABLE (
    product_id         uuid,
    category_id        uuid,
    category_name      text,
    category_slug      text,
    branch_id          uuid,
    branch_name        text,
    branch_slug        text,
    manufacturer_id    uuid,
    manufacturer_name  text,
    model              text,
    package_key        text,
    package_name       text,
    catalogue_category text,
    main_category      text,
    product_type       text,
    notes              text
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select
    p.id,
    p.category_id,
    coalesce(nullif(trim(p.catalogue_category),''), c.name),
    lower(regexp_replace(regexp_replace(coalesce(nullif(trim(p.catalogue_category),''),c.name),'[^a-zA-Z0-9]+','-','g'),'^-+|-+$','','g')),
    b.id,
    b.name,
    b.slug,
    m.id,
    m.name,
    p.model,
    p.package_key,
    p.package_name,
    p.catalogue_category,
    p.main_category,
    p.product_type,
    p.notes
  from public.catalogue_master_products p
  join public.catalogue_master_categories c on c.id=p.category_id
  left join public.catalogue_master_branches b on b.id=p.branch_id
  join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
  where p.active
    and p.customer_visible
    and (select private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.view'))
    and (
      select private.has_tenant_feature(p_tenant_id,'module.buying')
      or private.has_tenant_feature(p_tenant_id,'module.selling')
    )
    and (
      select private.has_tenant_feature(p_tenant_id,'catalogue.pre_filled')
    );
$function$;

REVOKE ALL ON FUNCTION "public"."get_master_catalogue_for_selection"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.get_public_buying_catalogue (
  p_tenant_id uuid
)
  RETURNS TABLE (
    product_id           uuid,
    category_id          uuid,
    category_name        text,
    category_slug        text,
    category_description text,
    branch_name          text,
    manufacturer         text,
    model                text,
    package_name         text,
    product_type         text,
    catalogue_category   text
  )
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
select
  bp.id,
  s.category_id,
  c.name,
  c.slug,
  c.description,
  cb.name,
  bp.manufacturer,
  bp.model,
  bp.package_name,
  mp.product_type,
  mp.catalogue_category
from public.tenant_catalogue_selections s
join public.tenants t
  on t.id=s.tenant_id
 and t.status='active'
join public.categories c
  on c.id=s.category_id
 and c.tenant_id=s.tenant_id
 and c.active
 and c.buying_enabled
left join public.category_branches cb
  on cb.id=s.branch_id
 and cb.tenant_id=s.tenant_id
left join public.catalogue_master_products mp
  on mp.id=s.master_product_id
 and mp.active
 and mp.customer_visible
join public.tenant_buying_products bp
  on bp.tenant_id=s.tenant_id
 and bp.category_id=s.category_id
 and bp.branch_id=s.branch_id
 and bp.active=true
 and lower(bp.manufacturer)=lower(coalesce(nullif(s.manufacturer,''),(select cm.name from public.catalogue_master_manufacturers cm where cm.id=mp.manufacturer_id)))
 and lower(bp.model)=lower(coalesce(nullif(s.model,''),mp.model))
 and lower(coalesce(bp.package_name,''))=lower(coalesce(nullif(s.package_name,''),mp.package_name,''))
where s.tenant_id=p_tenant_id
  and s.active
  and s.buying_enabled
  and s.website_visible
order by
  c.sort_order nulls last,
  c.name,
  bp.manufacturer,
  bp.model,
  bp.package_name;
$function$;

CREATE OR REPLACE FUNCTION public.get_published_site_preview (
  p_tenant_id uuid
)
  RETURNS TABLE (
    tenant_id       uuid,
    revision_number integer,
    content         jsonb,
    published_at    timestamp with time zone
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$ select sr.tenant_id, sr.revision_number, sr.content, sr.published_at from public.site_revisions sr join public.tenant_site_state ts on ts.published_revision_id=sr.id and ts.tenant_id=sr.tenant_id where sr.tenant_id=p_tenant_id and sr.status='published' limit 1 $function$;

CREATE OR REPLACE FUNCTION public.get_published_sites()
  RETURNS TABLE (
    tenant_id       uuid,
    revision_number integer,
    content         jsonb,
    published_at    timestamp with time zone
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$ select ts.tenant_id, sr.revision_number, sr.content, sr.published_at from public.tenant_site_state ts join public.site_revisions sr on sr.id=ts.published_revision_id and sr.tenant_id=ts.tenant_id and sr.status='published' $function$;

CREATE OR REPLACE FUNCTION public.get_published_store_listing_media (
  p_tenant_id uuid
)
  RETURNS TABLE (
    listing_id        uuid,
    storage_bucket    text,
    storage_path      text,
    original_filename text,
    sort_order        integer
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO 'public'
  AS $function$
  select
    lm.listing_id,
    ma.storage_bucket,
    ma.storage_path,
    ma.original_filename,
    lm.sort_order
  from public.listing_media lm
  join public.listings l
    on l.id = lm.listing_id
   and l.tenant_id = lm.tenant_id
   and l.status = 'published'
  join public.media_assets ma
    on ma.id = lm.media_asset_id
   and ma.tenant_id = lm.tenant_id
  join public.categories c
    on c.id = l.category_id
   and c.tenant_id = l.tenant_id
   and c.active = true
   and c.selling_enabled = true
  join public.sales_channels sc
    on sc.id = l.channel_id
   and sc.tenant_id = l.tenant_id
   and sc.active = true
  join public.tenant_site_state ts
    on ts.tenant_id = l.tenant_id
  join public.site_revisions sr
    on sr.id = ts.published_revision_id
   and sr.tenant_id = l.tenant_id
   and sr.status = 'published'
  where l.tenant_id = p_tenant_id
  order by lm.listing_id, lm.sort_order, ma.created_at;
$function$;

CREATE OR REPLACE FUNCTION public.get_published_store_listings (
  p_tenant_id uuid
)
  RETURNS TABLE (
    listing_id        uuid,
    listing_reference text,
    title             text,
    description       text,
    asking_price      numeric,
    currency          text,
    quantity          integer,
    category_name     text,
    listing_data      jsonb
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO 'public'
  AS $function$
  select
    l.id,
    l.listing_reference,
    l.title,
    l.description,
    l.asking_price,
    l.currency,
    l.quantity,
    c.name,
    l.listing_data
  from public.listings l
  join public.categories c
    on c.id = l.category_id
   and c.tenant_id = l.tenant_id
  join public.sales_channels sc
    on sc.id = l.channel_id
   and sc.tenant_id = l.tenant_id
  join public.tenant_site_state ts
    on ts.tenant_id = l.tenant_id
  join public.site_revisions sr
    on sr.id = ts.published_revision_id
   and sr.tenant_id = l.tenant_id
   and sr.status = 'published'
  where l.tenant_id = p_tenant_id
    and l.status = 'published'
    and c.active = true
    and c.selling_enabled = true
    and sc.active = true
  order by l.created_at desc;
$function$;

CREATE OR REPLACE FUNCTION public.get_tenant_buying_catalogue_page (
  p_tenant_id       uuid,
  p_category_id     uuid    DEFAULT NULL::uuid,
  p_branch_id       uuid    DEFAULT NULL::uuid,
  p_manufacturer_id uuid    DEFAULT NULL::uuid,
  p_search          text    DEFAULT NULL::text,
  p_page            integer DEFAULT 1,
  p_page_size       integer DEFAULT 50
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_page integer:=greatest(coalesce(p_page,1),1);v_size integer:=least(greatest(coalesce(p_page_size,50),1),75);v_offset integer:=(v_page-1)*v_size;v_total integer;v_products jsonb;
begin
if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.view') then raise exception 'Tenant user is not authorised to view Buying catalogue'; end if;
if not private.has_tenant_feature(p_tenant_id,'module.buying') then raise exception 'Buying is not enabled for this subscription'; end if;
with filtered as(select distinct s.master_product_id from public.tenant_catalogue_selections s join public.catalogue_master_products p on p.id=s.master_product_id where s.tenant_id=p_tenant_id and s.active and p.active and p.customer_visible and(p_category_id is null or p.category_id=p_category_id)and(p_branch_id is null or p.branch_id=p_branch_id)and(p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)and(nullif(trim(coalesce(p_search,'')),'') is null or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%')) select count(*) into v_total from filtered;
select coalesce(jsonb_agg(to_jsonb(x) order by x.manufacturer_name,x.model,x.package_name),'[]'::jsonb) into v_products from(
select p.id product_id,p.category_id,coalesce(nullif(trim(p.catalogue_category),''),c.name) category_name,p.branch_id,b.name branch_name,p.manufacturer_id,m.name manufacturer_name,p.model,p.package_name,p.product_type,p.notes,s.buying_enabled,s.active selection_active,s.website_visible,bp.id buying_product_id,bp.active buying_product_active,bp.manual_offer_price,r.id rule_id,r.sealed_percentage,r.opened_never_used_percentage,r.excellent_percentage,r.good_percentage,r.poor_percentage,r.sealed_reference_type,r.opened_never_used_reference_type,r.excellent_reference_type,r.good_reference_type,r.poor_reference_type,r.sealed_manual_price,r.opened_never_used_manual_price,r.excellent_manual_price,r.good_manual_price,r.poor_manual_price,r.sealed_trade_in_percentage,r.opened_never_used_trade_in_percentage,r.excellent_trade_in_percentage,r.good_trade_in_percentage,r.poor_trade_in_percentage,r.sealed_trade_in_manual_price,r.opened_never_used_trade_in_manual_price,r.excellent_trade_in_manual_price,r.good_trade_in_manual_price,r.poor_trade_in_manual_price,
rn.observed_price uk_new_research_price,rn.source_name uk_new_research_source,rn.source_url uk_new_research_url,rn.checked_at uk_new_research_checked_at,ru.observed_price uk_used_research_price,ru.source_name uk_used_research_source,ru.source_url uk_used_research_url,ru.checked_at uk_used_research_checked_at
from public.tenant_catalogue_selections s join public.catalogue_master_products p on p.id=s.master_product_id join public.catalogue_master_categories c on c.id=p.category_id left join public.catalogue_master_branches b on b.id=p.branch_id join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
left join public.tenant_buying_products bp on bp.tenant_id=p_tenant_id and bp.branch_id is not distinct from s.branch_id and lower(bp.manufacturer)=lower(m.name) and lower(bp.model)=lower(p.model) and lower(coalesce(bp.package_name,''))=lower(coalesce(p.package_name,''))
left join public.tenant_buying_condition_rules r on r.tenant_id=p_tenant_id and r.buying_product_id=bp.id
left join lateral(select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_new' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP' order by tr.checked_at desc nulls last,tr.created_at desc nulls last,tr.id desc limit 1) rn on true
left join lateral(select tr.observed_price,tr.source_name,tr.source_url,tr.checked_at from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=bp.id and tr.evidence_type='uk_used' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP' order by tr.checked_at desc nulls last,tr.created_at desc nulls last,tr.id desc limit 1) ru on true
where s.tenant_id=p_tenant_id and s.active and p.active and p.customer_visible and(p_category_id is null or p.category_id=p_category_id)and(p_branch_id is null or p.branch_id=p_branch_id)and(p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)and(nullif(trim(coalesce(p_search,'')),'') is null or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%')
order by m.name,p.model,p.package_name offset v_offset limit v_size)x;
return jsonb_build_object('page',v_page,'page_size',v_size,'total',v_total,'products',v_products);
end;$function$;

REVOKE ALL ON FUNCTION "public"."get_tenant_buying_catalogue_page"(uuid, uuid, uuid, uuid, text, integer, integer) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.guard_acquisition_creation_boundary()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare
  v_offer record;
  v_payment_id uuid;
begin
  if new.status <> 'paid' and new.status <> 'completed' then
    raise exception 'Acquisition has an invalid completion status';
  end if;

  if new.paid_at is null then
    raise exception 'Acquisition must have a completion timestamp';
  end if;

  if new.source_offer_id is null then
    raise exception 'Acquisition must reference the accepted offer';
  end if;

  select o.id,o.offer_type,o.status,o.offer_mode,o.buying_item_id,o.amount,o.currency
    into v_offer
  from public.offers o
  where o.tenant_id=new.tenant_id
    and o.id=new.source_offer_id;

  if v_offer.id is null or v_offer.status <> 'accepted' then
    raise exception 'Acquisition source must be an accepted offer';
  end if;

  if new.metadata->>'source'='trade_in_credit' then
    if v_offer.offer_type <> 'initial' or v_offer.offer_mode <> 'trade_in' then
      raise exception 'Trade-in credit acquisition must reference the accepted initial trade-in offer';
    end if;
    return new;
  end if;

  if new.status <> 'paid' or v_offer.offer_mode <> 'cash' then
    raise exception 'Cash acquisitions require a paid cash offer and payment';
  end if;

  select p.id into v_payment_id
  from public.payment_records p
  where p.tenant_id=new.tenant_id
    and p.status='paid'
    and p.direction='outbound'
    and p.customer_id=new.customer_id
    and p.amount=new.payment_total
    and p.acquisition_id is null
    and (
      p.metadata->>'final_offer_id'=new.source_offer_id::text
      or p.metadata->>'offer_id'=new.source_offer_id::text
    )
  order by p.processed_at desc nulls last,p.created_at desc
  limit 1;

  if v_payment_id is null then
    raise exception 'Acquisition requires a recorded bank payment for the accepted cash offer';
  end if;

  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."guard_acquisition_creation_boundary"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.guard_acquisition_fulfilment_status_entry()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
BEGIN IF NEW.status IS DISTINCT FROM OLD.status AND current_user <> 'postgres' THEN RAISE EXCEPTION 'Acquisition fulfilment status changes must use transition_workflow_entity'; END IF; RETURN NEW; END; $function$;

REVOKE ALL ON FUNCTION "public"."guard_acquisition_fulfilment_status_entry"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.guard_acquisition_item_status_entry()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if tg_op = 'UPDATE' and new.status is distinct from old.status then
    if current_user <> 'postgres' then
      raise exception 'Acquisition item status must be changed through transition_workflow_entity';
    end if;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.guard_acquisition_status_entry()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if tg_op = 'UPDATE' and new.status is distinct from old.status then
    if current_user <> 'postgres' then
      raise exception 'Acquisition status must be changed through transition_workflow_entity';
    end if;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.guard_fulfilment_status_entry()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$ begin if old.status is distinct from new.status and current_user <> 'postgres' then raise exception 'Direct fulfilment status changes are not permitted; use transition_workflow_entity()'; end if; return new; end; $function$;

REVOKE ALL ON FUNCTION "public"."guard_fulfilment_status_entry"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.guard_inventory_asset_status_entry()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if tg_op = 'UPDATE' and new.status is distinct from old.status then
    if current_user <> 'postgres' then
      raise exception 'Inventory asset status must be changed through transition_workflow_entity';
    end if;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.guard_inventory_creation_boundary()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_acq record;
  v_item_stage text;
  v_source text:=coalesce(new.metadata->>'source','');
begin
  if new.acquisition_item_id is null then
    if v_source <> 'manual_inventory' then
      raise exception 'Inventory assets without an acquisition must use the manual inventory creation path';
    end if;
    if new.created_by is null or new.created_by <> auth.uid() then
      raise exception 'Manual inventory must be created by the authenticated subscriber user';
    end if;
    if not private.has_tenant_feature(new.tenant_id,'module.inventory')
       or not private.has_tenant_permission(new.tenant_id,auth.uid(),'inventory.manage') then
      raise exception 'Manual inventory creation is not authorised for this subscriber';
    end if;
    if new.catalogue_product_id is null then
      raise exception 'Manual inventory requires a catalogue product';
    end if;
    return new;
  end if;

  select a.id,a.status,a.paid_at,a.metadata,ai.buying_item_id
    into v_acq
  from public.acquisition_items ai
  join public.acquisitions a on a.tenant_id=ai.tenant_id and a.id=ai.acquisition_id
  where ai.tenant_id=new.tenant_id and ai.id=new.acquisition_item_id;

  if v_acq.id is null or v_acq.status not in ('paid','completed') or v_acq.paid_at is null then
    raise exception 'Inventory assets require a completed acquisition';
  end if;

  select purchase_stage into v_item_stage
  from public.buying_items
  where tenant_id=new.tenant_id and id=v_acq.buying_item_id;

  if v_item_stage not in ('final_offer_accepted','purchased','final_offer_required') then
    raise exception 'Inventory assets require an accepted offer and completed payment or trade-in credit';
  end if;

  if coalesce(v_acq.metadata->>'source','')='trade_in_credit' then
    if not exists(
      select 1 from public.trade_in_transactions t
      where t.tenant_id=new.tenant_id and t.acquisition_id=v_acq.id and t.status='credited'
    ) then
      raise exception 'Trade-in inventory requires a posted customer credit transaction';
    end if;
  elsif not exists(
    select 1 from public.payment_records p
    where p.tenant_id=new.tenant_id and p.acquisition_id=v_acq.id and p.status='paid' and p.direction='outbound'
  ) then
    raise exception 'Inventory assets require a recorded acquisition payment';
  end if;

  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."guard_inventory_creation_boundary"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.guard_ledger_entry_status_entry()
  RETURNS TRIGGER
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

CREATE OR REPLACE FUNCTION public.guard_listing_status_entry()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if new.status is distinct from old.status and current_user <> 'postgres' then
    raise exception 'Listing status changes must use transition_workflow_entity';
  end if;
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."guard_listing_status_entry"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.guard_payment_record_status_entry()
  RETURNS TRIGGER
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

CREATE OR REPLACE FUNCTION public.guard_retail_order_status_entry()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
BEGIN
  IF NEW.status IS DISTINCT FROM OLD.status AND current_user <> 'postgres' THEN
    RAISE EXCEPTION 'Retail order status changes must use transition_workflow_entity';
  END IF;
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION "public"."guard_retail_order_status_entry"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.guard_return_status_entry()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$ begin if old.status is distinct from new.status and current_user <> 'postgres' then raise exception 'Direct return status changes are not permitted; use transition_workflow_entity()'; end if; return new; end; $function$;

REVOKE ALL ON FUNCTION "public"."guard_return_status_entry"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.is_published_tradeflow_media (
  p_bucket_id text,
  p_name      text
)
  RETURNS boolean
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO 'public'
  AS $function$
  select exists (
    select 1
    from public.media_assets ma
    join public.listing_media lm
      on lm.media_asset_id = ma.id
     and lm.tenant_id = ma.tenant_id
    join public.listings l
      on l.id = lm.listing_id
     and l.tenant_id = lm.tenant_id
     and l.status = 'published'
    join public.categories c
      on c.id = l.category_id
     and c.tenant_id = l.tenant_id
     and c.active = true
     and c.selling_enabled = true
    join public.sales_channels sc
      on sc.id = l.channel_id
     and sc.tenant_id = l.tenant_id
     and sc.active = true
    join public.tenant_site_state ts
      on ts.tenant_id = l.tenant_id
    join public.site_revisions sr
      on sr.id = ts.published_revision_id
     and sr.tenant_id = l.tenant_id
     and sr.status = 'published'
    where ma.storage_bucket = p_bucket_id
      and ma.storage_path = p_name
  );
$function$;

CREATE OR REPLACE FUNCTION public.mark_notification_failed (
  p_id    uuid,
  p_error text
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_attempts integer;
begin
 select attempts into v_attempts from public.notification_queue where id=p_id for update;
 update public.notification_queue set status=case when coalesce(v_attempts,0)>=5 then 'failed' else 'queued' end,
 scheduled_for=case when coalesce(v_attempts,0)>=5 then scheduled_for else now()+interval '5 minutes' end,
 last_error=left(coalesce(p_error,'Notification delivery failed'),2000),updated_at=now() where id=p_id;
end $function$;

REVOKE ALL ON FUNCTION "public"."mark_notification_failed"(uuid, text) FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.mark_notification_sent (
  p_id                  uuid,
  p_provider            text,
  p_provider_message_id text
)
  RETURNS void
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
 update public.notification_queue set status='sent',provider=p_provider,provider_message_id=p_provider_message_id,sent_at=now(),last_error=null,updated_at=now() where id=p_id;
$function$;

REVOKE ALL ON FUNCTION "public"."mark_notification_sent"(uuid, text, text) FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.media_assets_set_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog'
  AS $function$
begin new.updated_at = now(); return new; end; $function$;

CREATE OR REPLACE FUNCTION public.notification_processor_auth_secret()
  RETURNS text
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
 if current_user <> 'service_role' then raise exception 'Not authorised'; end if;
 return (select decrypted_secret from vault.decrypted_secrets where name='tradeflow_notification_processor_secret' limit 1);
end $function$;

REVOKE ALL ON FUNCTION "public"."notification_processor_auth_secret"() FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.platform_admin_create_tenant (
  p_name          text,
  p_slug          text,
  p_owner_user_id uuid,
  p_plan_code     text
)
  RETURNS uuid
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select private.platform_admin_create_tenant(p_name,p_slug,p_owner_user_id,p_plan_code);
$function$;

REVOKE ALL ON FUNCTION "public"."platform_admin_create_tenant"(text, text, uuid, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.platform_admin_find_user (
  p_email text
)
  RETURNS TABLE (
    user_id         uuid,
    email           text,
    email_confirmed boolean
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select * from private.platform_admin_find_user(p_email);
$function$;

REVOKE ALL ON FUNCTION "public"."platform_admin_find_user"(text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.platform_admin_list_subscriber_accounts()
  RETURNS TABLE (
    tenant_id               uuid,
    business_name           text,
    business_slug           text,
    business_status         text,
    owner_name              text,
    owner_email             text,
    owner_membership_status text,
    joined_at               timestamp with time zone
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select * from private.platform_admin_list_subscriber_accounts();
$function$;

REVOKE ALL ON FUNCTION "public"."platform_admin_list_subscriber_accounts"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.platform_admin_list_tenants()
  RETURNS TABLE (
    tenant_id           uuid,
    tenant_name         text,
    tenant_slug         text,
    tenant_status       text,
    plan_code           text,
    plan_name           text,
    subscription_status text,
    owner_count         bigint,
    member_count        bigint,
    created_at          timestamp with time zone
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select * from private.platform_admin_list_tenants();
$function$;

REVOKE ALL ON FUNCTION "public"."platform_admin_list_tenants"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.platform_admin_manage_subscription (
  p_tenant_id uuid,
  p_action    text,
  p_plan_code text DEFAULT NULL::text
)
  RETURNS TABLE (
    tenant_id           uuid,
    tenant_status       text,
    plan_code           text,
    subscription_status text
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select * from private.platform_admin_manage_subscription(p_tenant_id,p_action,p_plan_code);
$function$;

REVOKE ALL ON FUNCTION "public"."platform_admin_manage_subscription"(uuid, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.platform_owner_get_email()
  RETURNS jsonb
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
 select to_jsonb(p) from public.platform_email_settings p where p.id=true and private.is_platform_owner(auth.uid());
$function$;

REVOKE ALL ON FUNCTION "public"."platform_owner_get_email"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.platform_owner_get_plans()
  RETURNS SETOF public.plans
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select p from public.plans p
  where private.is_platform_owner(auth.uid())
    and p.active=true
  order by p.sort_order,p.name;
$function$;

REVOKE ALL ON FUNCTION "public"."platform_owner_get_plans"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.platform_owner_save_email (
  p_email text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
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

REVOKE ALL ON FUNCTION "public"."platform_owner_save_email"(text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.platform_owner_update_plan (
  p_plan_id                 uuid,
  p_name                    text,
  p_description             text,
  p_website_visible         boolean,
  p_monthly_price           numeric,
  p_annual_price            numeric,
  p_currency                text,
  p_stripe_product_id       text,
  p_stripe_monthly_price_id text,
  p_stripe_annual_price_id  text
)
  RETURNS public.plans
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_plan public.plans; v_currency text;
begin
  if not private.is_platform_owner(auth.uid()) then raise exception 'Not authorised'; end if;
  if p_plan_id is null then raise exception 'Plan is required'; end if;
  if nullif(trim(p_name),'') is null then raise exception 'Plan name is required'; end if;
  if p_monthly_price is not null and p_monthly_price < 0 then raise exception 'Monthly price cannot be negative'; end if;
  if p_annual_price is not null and p_annual_price < 0 then raise exception 'Annual price cannot be negative'; end if;
  v_currency := upper(nullif(trim(p_currency),''));
  if v_currency is null then v_currency := 'GBP'; end if;
  if v_currency !~ '^[A-Z]{3}$' then raise exception 'Currency must be a 3-letter code'; end if;
  if nullif(trim(coalesce(p_stripe_product_id,'')),'') is not null and trim(p_stripe_product_id) !~ '^prod_[A-Za-z0-9]+$' then raise exception 'Stripe Product ID must start with prod_'; end if;
  if nullif(trim(coalesce(p_stripe_monthly_price_id,'')),'') is not null and trim(p_stripe_monthly_price_id) !~ '^price_[A-Za-z0-9]+$' then raise exception 'Stripe monthly Price ID must start with price_'; end if;
  if nullif(trim(coalesce(p_stripe_annual_price_id,'')),'') is not null and trim(p_stripe_annual_price_id) !~ '^price_[A-Za-z0-9]+$' then raise exception 'Stripe annual Price ID must start with price_'; end if;

  update public.plans
  set name=trim(p_name),description=nullif(trim(coalesce(p_description,'')),''),
      website_visible=coalesce(p_website_visible,false),monthly_price=p_monthly_price,
      annual_price=p_annual_price,currency=v_currency,
      stripe_product_id=nullif(trim(coalesce(p_stripe_product_id,'')),''),
      stripe_monthly_price_id=nullif(trim(coalesce(p_stripe_monthly_price_id,'')),''),
      stripe_annual_price_id=nullif(trim(coalesce(p_stripe_annual_price_id,'')),''),
      updated_at=now()
  where id=p_plan_id and code='enhanced' and active=true
  returning * into v_plan;

  if v_plan.id is null then raise exception 'TradeFlow plan not found'; end if;
  return v_plan;
end
$function$;

REVOKE ALL ON FUNCTION "public"."platform_owner_update_plan"(uuid, text, text, boolean, numeric, numeric, text, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.process_external_payment_event (
  p_provider            text,
  p_event_id            text,
  p_event_type          text,
  p_tenant_id           uuid,
  p_payment_id          uuid,
  p_provider_payment_id text,
  p_new_status          text,
  p_amount              numeric,
  p_currency            text,
  p_metadata            jsonb   DEFAULT '{}'::jsonb
)
  RETURNS boolean
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
 v_payment public.payment_records%rowtype;
 v_order public.retail_orders%rowtype;
 v_listing public.listings%rowtype;
 v_existing uuid;
 v_hold public.customer_credit_holds%rowtype;
 v_account public.customer_credit_accounts%rowtype;
 v_credit_payment_id uuid;
 v_credit_ledger_id uuid;
begin
 if current_setting('request.jwt.claim.role',true)<>'service_role' then raise exception 'Service role required'; end if;
 if p_provider is null or p_event_id is null or p_event_type is null then raise exception 'Provider event identity required'; end if;
 if p_new_status not in ('paid','failed','cancelled') then raise exception 'Unsupported external payment status'; end if;

 select id into v_existing from public.payment_provider_events where provider=p_provider and event_id=p_event_id limit 1;
 if v_existing is not null then return true; end if;

 select * into v_payment from public.payment_records where tenant_id=p_tenant_id and id=p_payment_id for update;
 if not found then raise exception 'Payment record not found'; end if;
 if p_provider_payment_id is not null and coalesce(v_payment.provider_payment_id,'')<>p_provider_payment_id then raise exception 'Provider payment mismatch'; end if;
 if v_payment.amount<>p_amount or upper(v_payment.currency)<>upper(p_currency) then raise exception 'Payment amount or currency mismatch'; end if;

 -- A payment record that was cancelled locally can never be accepted as a
 -- successful payment. Return false so the Stripe webhook can refund it.
 if v_payment.status='cancelled' and p_new_status='paid' then
   return false;
 end if;

 if v_payment.status in ('paid','failed','cancelled','refunded','partially_refunded') then return true; end if;

 if v_payment.retail_order_id is not null then
   select * into v_order from public.retail_orders where tenant_id=p_tenant_id and id=v_payment.retail_order_id for update;
   if not found then raise exception 'Retail order not found'; end if;

   if p_new_status='paid' then
     if v_order.status<>'pending_payment' then raise exception 'Retail order is not awaiting payment'; end if;
     if v_order.amount_due<>p_amount then raise exception 'Retail order amount due does not match payment'; end if;
     select * into v_listing from public.listings l
     where l.tenant_id=p_tenant_id and l.id=(
       select i.listing_id from public.retail_order_items i
       where i.tenant_id=p_tenant_id and i.order_id=v_order.id order by i.created_at limit 1
     ) for update;
     if not found or v_listing.status<>'published' or coalesce(v_listing.quantity,0)<1 then return false; end if;

     select h.* into v_hold from public.customer_credit_holds h
     where h.tenant_id=p_tenant_id and h.retail_order_id=v_order.id and h.status='active'
     for update;

     if found then
       select a.* into v_account from public.customer_credit_accounts a
       where a.tenant_id=p_tenant_id and a.customer_id=v_order.customer_id for update;
       if not found or coalesce(v_account.balance,0)<v_hold.amount then
         raise exception 'Customer credit reserved for this order is no longer available';
       end if;

       update public.customer_credit_accounts
       set balance=balance-v_hold.amount,updated_at=now()
       where id=v_account.id;

       insert into public.payment_records(
         tenant_id,payment_reference,payment_type,status,direction,amount,currency,payment_method,
         customer_id,retail_order_id,notes,created_by,processed_at
       ) values(
         p_tenant_id,'PAY-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
         'customer_payment','paid','inbound',v_hold.amount,v_order.currency,'customer_credit',
         v_order.customer_id,v_order.id,'Retail order credit applied as part of mixed payment.',null,now()
       ) returning id into v_credit_payment_id;

       insert into public.ledger_entries(
         tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,retail_order_id,
         description,reference_type,reference_id,posted_at
       ) values(
         p_tenant_id,'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
         'payment','credit','posted',v_hold.amount,v_order.currency,v_order.customer_id,v_order.id,
         'Retail order customer credit portion','payment_record',v_credit_payment_id,now()
       ) returning id into v_credit_ledger_id;

       update public.customer_credit_holds set status='applied',applied_at=now() where id=v_hold.id;
     end if;
   elsif p_new_status in ('failed','cancelled') then
     select h.* into v_hold from public.customer_credit_holds h
     where h.tenant_id=p_tenant_id and h.retail_order_id=v_order.id and h.status='active'
     for update;
     if found then
       update public.retail_orders
       set amount_due=amount_due+v_hold.amount,
           trade_in_credit_total=greatest(coalesce(trade_in_credit_total,0)-v_hold.amount,0),
           updated_at=now()
       where tenant_id=p_tenant_id and id=v_order.id;
       update public.customer_credit_holds set status='released',released_at=now() where id=v_hold.id;
     end if;
   end if;
 end if;

 update public.payment_records
 set status=p_new_status,provider=p_provider,provider_payment_id=coalesce(provider_payment_id,p_provider_payment_id),
     processed_at=now(),updated_at=now(),metadata=coalesce(metadata,'{}'::jsonb)||coalesce(p_metadata,'{}'::jsonb)
 where tenant_id=p_tenant_id and id=p_payment_id;

 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
 values(p_tenant_id,'payment_record',v_payment.id,v_payment.status,p_new_status,null,'External payment provider status update',
        jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id));

 if v_payment.retail_order_id is not null and p_new_status='paid' then
   update public.retail_orders
   set status='paid',payment_status='paid',paid_at=coalesce(paid_at,now()),amount_due=0,placed_at=coalesce(placed_at,now()),updated_at=now()
   where tenant_id=p_tenant_id and id=v_order.id;

   insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
   values(p_tenant_id,'retail_order',v_order.id,'pending_payment','paid',null,'External payment provider confirmed payment',
          jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id));

   insert into public.ledger_entries(tenant_id,entry_type,direction,status,amount,currency,customer_id,retail_order_id,description,reference_type,reference_id,metadata)
   values(p_tenant_id,'payment','credit','posted',p_amount,p_currency,v_order.customer_id,v_order.id,'Retail order payment','retail_order',v_order.id,
          jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id));

   update public.listings set status='sold',sold_at=coalesce(sold_at,now()),updated_at=now()
   where tenant_id=p_tenant_id and id=v_listing.id and status='published';

   update public.inventory_assets set status='sold',sold_at=coalesce(sold_at,now()),updated_at=now()
   where tenant_id=p_tenant_id and id=v_listing.asset_id and status in ('listed','reserved');

 elsif v_payment.retail_order_id is not null and p_new_status='cancelled' then
   if v_order.status in ('initiated','pending_payment') then
     update public.retail_orders set status='cancelled',cancelled_at=coalesce(cancelled_at,now()),updated_at=now()
     where tenant_id=p_tenant_id and id=v_order.id;

     insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
     values(p_tenant_id,'retail_order',v_order.id,v_order.status,'cancelled',null,'External payment provider cancelled or expired unpaid retail order',
            jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id));

     update public.listings l set status='published',reserved_at=null,updated_at=now()
     where l.tenant_id=p_tenant_id and l.status='reserved' and l.id in (
       select i.listing_id from public.retail_order_items i where i.tenant_id=p_tenant_id and i.order_id=v_order.id and i.listing_id is not null
     );
     update public.inventory_assets ia set status='listed',updated_at=now()
     where ia.tenant_id=p_tenant_id and ia.status='reserved' and ia.id in (
       select i.inventory_asset_id from public.retail_order_items i where i.tenant_id=p_tenant_id and i.order_id=v_order.id and i.inventory_asset_id is not null
     );
   end if;
 end if;

 insert into public.payment_provider_events(provider,event_id,event_type,metadata)
 values(p_provider,p_event_id,p_event_type,coalesce(p_metadata,'{}'::jsonb))
 on conflict(provider,event_id) do nothing;
 return true;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."process_external_payment_event"(text, text, text, uuid, uuid, text, text, numeric, text, jsonb) FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.public_get_available_plans()
  RETURNS TABLE (
    id            uuid,
    code          text,
    name          text,
    description   text,
    monthly_price numeric,
    annual_price  numeric,
    currency      text,
    sort_order    integer
  )
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select p.id,p.code,p.name,p.description,p.monthly_price,p.annual_price,p.currency,p.sort_order
  from public.plans p
  where p.active=true and p.website_visible=true
  order by p.sort_order,p.name;
$function$;

CREATE OR REPLACE FUNCTION public.publish_site_revision (
  p_tenant_id   uuid,
  p_revision_id uuid
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_user_id uuid := auth.uid();
  v_revision public.site_revisions%rowtype;
  v_state public.tenant_site_state%rowtype;
  v_published_id uuid;
  v_new_draft_id uuid;
  v_domain record;
  v_schema_version integer;
begin
  if v_user_id is null then raise exception 'Authentication required'; end if;
  if not private.can_tenant(p_tenant_id, 'website.publish', 'website.publish') then
    raise exception 'Website publishing is not permitted for this tenant';
  end if;

  select * into v_state from public.tenant_site_state where tenant_id=p_tenant_id for update;
  if not found then raise exception 'Tenant website state not initialised'; end if;

  select * into v_revision from public.site_revisions
  where tenant_id=p_tenant_id and id=p_revision_id and status='draft' for update;
  if not found then raise exception 'Only the current draft revision can be published'; end if;
  if v_state.draft_revision_id <> v_revision.id then raise exception 'Revision is not the current tenant draft'; end if;

  v_schema_version := coalesce((v_revision.content->>'schema_version')::integer,0);
  if v_schema_version not in (1,2) then
    raise exception 'Unsupported website content schema version';
  end if;

  if v_state.published_revision_id is not null then
    update public.site_revisions set status='archived',updated_at=now()
    where tenant_id=p_tenant_id and id=v_state.published_revision_id;
  end if;

  update public.site_revisions
  set status='published',published_by=v_user_id,published_at=now(),updated_at=now()
  where tenant_id=p_tenant_id and id=v_revision.id;

  v_published_id:=v_revision.id;

  insert into public.site_revisions(tenant_id,revision_number,status,content,created_by)
  values(p_tenant_id,v_revision.revision_number+1,'draft',v_revision.content,v_user_id)
  returning id into v_new_draft_id;

  update public.tenant_site_state
  set draft_revision_id=v_new_draft_id,published_revision_id=v_published_id,updated_at=now()
  where tenant_id=p_tenant_id;

  for v_domain in
    select id,hostname from public.tenant_domains
    where tenant_id=p_tenant_id and status='active'
  loop
    insert into public.published_site_index(hostname,tenant_id,domain_id,revision_id,revision_number,content,published_at)
    values(v_domain.hostname,p_tenant_id,v_domain.id,v_published_id,v_revision.revision_number,v_revision.content,now())
    on conflict(hostname) do update set
      tenant_id=excluded.tenant_id,domain_id=excluded.domain_id,revision_id=excluded.revision_id,
      revision_number=excluded.revision_number,content=excluded.content,published_at=excluded.published_at,updated_at=now();
  end loop;
  return v_published_id;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."publish_site_revision"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.queue_customer_manual_valuation_notification (
  p_tenant_id      uuid,
  p_buying_item_id uuid
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare v_actor uuid:=auth.uid(); v_item record; v_request record; v_customer record; v_payload jsonb;
begin
 if v_actor is null or not private.is_tenant_member(p_tenant_id,v_actor) then raise exception 'Tenant membership required'; end if;
 if not private.has_tenant_permission(p_tenant_id,v_actor,'valuation.manage') then raise exception 'Permission required: valuation.manage'; end if;
 select bi.id,bi.title,bi.item_reference,bi.buying_request_id into v_item from public.buying_items bi where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;
 if not found then raise exception 'Buying item not found'; end if;
 select r.id,r.request_reference,r.customer_id into v_request from public.buying_requests r where r.tenant_id=p_tenant_id and r.id=v_item.buying_request_id;
 select c.email,c.first_name,c.last_name into v_customer from public.customers c where c.tenant_id=p_tenant_id and c.id=v_request.customer_id;
 v_payload:=jsonb_build_object('customer_name',trim(coalesce(v_customer.first_name,'')||' '||coalesce(v_customer.last_name,'')),'item_title',coalesce(v_item.title,'your item'),'item_reference',v_item.item_reference,'request_reference',v_request.request_reference);
 insert into public.notification_event_log(tenant_id,event_code,entity_type,entity_id,payload)
 values(p_tenant_id,'valuation_manual_required','buying_item',v_item.id,v_payload)
 on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;
 if v_customer.email is null then return null; end if;
 return private.queue_customer_notification(p_tenant_id,'valuation_manual_required','buying_item',v_item.id,v_customer.email,
   trim(coalesce(v_customer.first_name,'')||' '||coalesce(v_customer.last_name,'')),v_payload);
end; $function$;

REVOKE ALL ON FUNCTION "public"."queue_customer_manual_valuation_notification"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.record_retail_order_payment (
  p_tenant_id           uuid,
  p_order_id            uuid,
  p_amount              numeric,
  p_payment_method      text    DEFAULT NULL::text,
  p_provider            text    DEFAULT NULL::text,
  p_provider_payment_id text    DEFAULT NULL::text,
  p_notes               text    DEFAULT NULL::text
)
  RETURNS TABLE (
    payment_id     uuid,
    order_id       uuid,
    order_status   text,
    payment_status text,
    ledger_id      uuid
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare v_order public.retail_orders%rowtype; v_payment_id uuid; v_ledger_id uuid; v_user uuid := auth.uid();
begin
 if v_user is null then raise exception 'Authentication required'; end if;
 perform private.require_tenant_feature(p_tenant_id,'module.orders');
 if not private.has_tenant_permission(p_tenant_id,'finance.manage') then raise exception 'Finance permission required'; end if;
 if not private.has_tenant_permission(p_tenant_id,'orders.manage') then raise exception 'Orders permission required'; end if;
 if p_amount is null or p_amount <= 0 then raise exception 'Payment amount must be greater than zero'; end if;
 select * into v_order from public.retail_orders where tenant_id=p_tenant_id and id=p_order_id for update;
 if not found then raise exception 'Retail order not found'; end if;
 if v_order.status <> 'pending_payment' then raise exception 'Order must be pending_payment before payment capture'; end if;
 if p_amount <> v_order.amount_due then raise exception 'Payment amount must equal the current amount due'; end if;
 insert into public.payment_records(tenant_id,payment_reference,payment_type,status,direction,amount,currency,provider,provider_payment_id,payment_method,customer_id,retail_order_id,notes,created_by,processed_at)
 values(p_tenant_id,'PAY-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'customer_payment','paid','inbound',p_amount,v_order.currency,p_provider,p_provider_payment_id,p_payment_method,v_order.customer_id,p_order_id,p_notes,v_user,now()) returning id into v_payment_id;
 insert into public.ledger_entries(tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,retail_order_id,description,reference_type,reference_id,created_by,posted_at)
 values(p_tenant_id,'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'payment','credit','posted',p_amount,v_order.currency,v_order.customer_id,p_order_id,'Retail order payment','payment_record',v_payment_id,v_user,now()) returning id into v_ledger_id;
 update public.retail_orders set payment_status='paid',paid_at=now(),amount_due=0,updated_at=now() where tenant_id=p_tenant_id and id=p_order_id;
 perform public.transition_workflow_entity(p_tenant_id,'retail_order',p_order_id,'pending_payment','paid','Payment captured',jsonb_build_object('source','record_retail_order_payment','payment_id',v_payment_id));
 return query select v_payment_id,p_order_id,'paid'::text,'paid'::text,v_ledger_id;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."record_retail_order_payment"(uuid, uuid, numeric, text, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.seed_tenant_master_catalogue (
  p_tenant_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_master_version integer := 2;
  v_seeded_at timestamptz;
  v_category_count integer := 0;
  v_branch_count integer := 0;
  v_manufacturer_count integer := 0;
  v_product_count integer := 0;
  v_existing_version integer := 0;
begin
  if not (select private.can_tenant(p_tenant_id, 'buying.manage', 'module.buying')) then
    raise exception 'Tenant is not authorised to manage the buying catalogue';
  end if;

  if not (select private.has_tenant_feature(p_tenant_id, 'catalogue.pre_filled')) then
    raise exception 'The pre-filled catalogue is not enabled for this subscription';
  end if;

  select
    coalesce(tcs.master_version, 0),
    tcs.seeded_at
  into
    v_existing_version,
    v_seeded_at
  from public.tenant_catalogue_state tcs
  where tcs.tenant_id = p_tenant_id
  limit 1;

  if v_existing_version >= v_master_version and v_seeded_at is not null then
    return jsonb_build_object(
      'master_version', v_master_version,
      'seeded_at', v_seeded_at,
      'categories', (
        select count(*) from public.categories
        where tenant_id = p_tenant_id
          and lower(slug) in (select lower(slug) from public.catalogue_master_categories)
      ),
      'branches', (
        select count(*)
        from public.category_branches cb
        join public.categories c on c.id = cb.category_id
        where cb.tenant_id = p_tenant_id
          and lower(c.slug) in (select lower(slug) from public.catalogue_master_categories)
      ),
      'manufacturers', (
        select count(*)
        from public.tenant_buying_manufacturers tm
        where tm.tenant_id = p_tenant_id
          and exists (
            select 1 from public.catalogue_master_manufacturers mm
            where lower(mm.name) = lower(tm.name)
          )
      ),
      'products', (
        select count(*)
        from public.tenant_buying_products tp
        where tp.tenant_id = p_tenant_id
          and tp.pricing_notes = 'TradeFlow master catalogue seed; buying price must be configured independently.'
      ),
      'already_seeded', true
    );
  end if;

  insert into public.categories
    (tenant_id, name, slug, description, active, buying_enabled, selling_enabled, sort_order)
  select
    p_tenant_id, mc.name, mc.slug, 'TradeFlow master catalogue category',
    mc.active, true, true, mc.sort_order
  from public.catalogue_master_categories mc
  where not exists (
    select 1
    from public.categories tc
    where tc.tenant_id = p_tenant_id
      and lower(tc.slug) = lower(mc.slug)
  );

  insert into public.category_branches
    (tenant_id, category_id, name, slug, description, active, buying_enabled, selling_enabled, sort_order)
  select
    p_tenant_id, tc.id, mb.name, mb.slug, 'TradeFlow master catalogue branch',
    mb.active, true, true, mb.sort_order
  from public.catalogue_master_branches mb
  join public.catalogue_master_categories mc on mc.id = mb.category_id
  join public.categories tc
    on tc.tenant_id = p_tenant_id
   and lower(tc.slug) = lower(mc.slug)
  where not exists (
    select 1
    from public.category_branches tb
    where tb.tenant_id = p_tenant_id
      and tb.category_id = tc.id
      and lower(tb.slug) = lower(mb.slug)
  );

  insert into public.tenant_buying_manufacturers (tenant_id, name, active)
  select p_tenant_id, mm.name, mm.active
  from public.catalogue_master_manufacturers mm
  where not exists (
    select 1
    from public.tenant_buying_manufacturers tm
    where tm.tenant_id = p_tenant_id
      and lower(tm.name) = lower(mm.name)
  );

  insert into public.tenant_buying_products
    (tenant_id, category_id, branch_id, manufacturer, model, package_name, active,
     automatic_percentage, manual_offer_price, pricing_notes)
  select
    p_tenant_id,
    tc.id,
    tb.id,
    tm.name,
    mp.model,
    mp.package_name,
    mp.active,
    null,
    null,
    'TradeFlow master catalogue seed; buying price must be configured independently.'
  from public.catalogue_master_products mp
  join public.catalogue_master_categories mc on mc.id = mp.category_id
  join public.categories tc
    on tc.tenant_id = p_tenant_id
   and lower(tc.slug) = lower(mc.slug)
  left join public.catalogue_master_branches mb on mb.id = mp.branch_id
  left join public.category_branches tb
    on tb.tenant_id = p_tenant_id
   and tb.category_id = tc.id
   and lower(tb.slug) = lower(mb.slug)
  join public.catalogue_master_manufacturers mm on mm.id = mp.manufacturer_id
  join public.tenant_buying_manufacturers tm
    on tm.tenant_id = p_tenant_id
   and lower(tm.name) = lower(mm.name)
  where not exists (
    select 1
    from public.tenant_buying_products tp
    where tp.tenant_id = p_tenant_id
      and tp.branch_id is not distinct from tb.id
      and lower(tp.manufacturer) = lower(tm.name)
      and lower(tp.model) = lower(mp.model)
      and lower(coalesce(tp.package_name, '')) = lower(coalesce(mp.package_name, ''))
  );

  select count(*)
    into v_category_count
  from public.categories tc
  where tc.tenant_id = p_tenant_id
    and exists (
      select 1 from public.catalogue_master_categories mc
      where lower(mc.slug) = lower(tc.slug)
    );

  select count(*)
    into v_branch_count
  from public.category_branches tb
  join public.categories tc on tc.id = tb.category_id
  where tb.tenant_id = p_tenant_id
    and exists (
      select 1
      from public.catalogue_master_categories mc
      join public.catalogue_master_branches mb on mb.category_id = mc.id
      where lower(mc.slug) = lower(tc.slug)
        and lower(mb.slug) = lower(tb.slug)
    );

  select count(*)
    into v_manufacturer_count
  from public.tenant_buying_manufacturers tm
  where tm.tenant_id = p_tenant_id
    and exists (
      select 1
      from public.catalogue_master_manufacturers mm
      where lower(mm.name) = lower(tm.name)
    );

  select count(*)
    into v_product_count
  from public.tenant_buying_products tp
  where tp.tenant_id = p_tenant_id
    and tp.pricing_notes = 'TradeFlow master catalogue seed; buying price must be configured independently.';

  insert into public.tenant_catalogue_state
    (tenant_id, master_version, seeded_at, category_count, branch_count, manufacturer_count, product_count, updated_at)
  values
    (p_tenant_id, v_master_version, coalesce(v_seeded_at, now()), v_category_count, v_branch_count, v_manufacturer_count, v_product_count, now())
  on conflict (tenant_id) do update set
    master_version = excluded.master_version,
    seeded_at = coalesce(public.tenant_catalogue_state.seeded_at, excluded.seeded_at),
    category_count = excluded.category_count,
    branch_count = excluded.branch_count,
    manufacturer_count = excluded.manufacturer_count,
    product_count = excluded.product_count,
    updated_at = now();

  return jsonb_build_object(
    'master_version', v_master_version,
    'seeded_at', coalesce(v_seeded_at, now()),
    'categories', v_category_count,
    'branches', v_branch_count,
    'manufacturers', v_manufacturer_count,
    'products', v_product_count,
    'already_seeded', v_seeded_at is not null
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."seed_tenant_master_catalogue"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.set_buying_catalogue_website_visibility (
  p_tenant_id         uuid,
  p_master_product_id uuid,
  p_visible           boolean
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_bp uuid;
begin
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.manage') then raise exception 'Tenant user is not authorised to manage catalogue visibility'; end if;
 if not private.has_tenant_feature(p_tenant_id,'module.buying') then raise exception 'Buying is not enabled for this subscription'; end if;
 update public.tenant_catalogue_selections
 set website_visible=p_visible,updated_at=now()
 where tenant_id=p_tenant_id and master_product_id=p_master_product_id and active=true;
 if not found then raise exception 'Buying catalogue product not found'; end if;
 return jsonb_build_object('master_product_id',p_master_product_id,'website_visible',p_visible);
end;$function$;

REVOKE ALL ON FUNCTION "public"."set_buying_catalogue_website_visibility"(uuid, uuid, boolean) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.set_listing_media_retention_after_sale()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if new.status = 'sold' and coalesce(old.status,'') <> 'sold' then
    update public.media_assets m
       set retention_policy = 'sold_90_days_after_sale',
           retention_expires_at = coalesce(new.sold_at, now()) + interval '90 days',
           updated_at = now()
     where m.id in (
       select lm.media_asset_id from public.listing_media lm where lm.tenant_id = new.tenant_id and lm.listing_id = new.id
       union
       select iam.media_asset_id from public.inventory_asset_media iam where iam.tenant_id = new.tenant_id and iam.inventory_asset_id = new.asset_id
     );
  elsif new.status <> 'sold' and old.status = 'sold' then
    update public.media_assets m
       set retention_expires_at = null,
           updated_at = now()
     where m.id in (
       select lm.media_asset_id from public.listing_media lm where lm.tenant_id = new.tenant_id and lm.listing_id = new.id
       union
       select iam.media_asset_id from public.inventory_asset_media iam where iam.tenant_id = new.tenant_id and iam.inventory_asset_id = new.asset_id
     );
  end if;
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."set_listing_media_retention_after_sale"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.set_media_retention_after_sale()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if new.status = 'sold' and coalesce(old.status,'') <> 'sold' then
    update public.media_assets m
       set retention_policy = 'sold_90_days_after_sale',
           retention_expires_at = coalesce(new.sold_at, now()) + interval '90 days',
           updated_at = now()
     where m.id in (
       select iam.media_asset_id from public.inventory_asset_media iam
        where iam.tenant_id = new.tenant_id and iam.inventory_asset_id = new.id
       union
       select lim.media_asset_id from public.listing_media lim
        where lim.tenant_id = new.tenant_id and lim.listing_id in (
          select l.id from public.listings l where l.tenant_id = new.tenant_id and l.asset_id = new.id
        )
       union
       select bim.media_asset_id from public.buying_item_media bim
        where bim.tenant_id = new.tenant_id and bim.buying_item_id = new.buying_item_id
     );
  elsif new.status <> 'sold' and old.status = 'sold' then
    update public.media_assets m
       set retention_expires_at = null,
           retention_policy = case when m.asset_kind = 'customer_upload' then 'manual' else m.retention_policy end,
           updated_at = now()
     where m.id in (
       select iam.media_asset_id from public.inventory_asset_media iam
        where iam.tenant_id = new.tenant_id and iam.inventory_asset_id = new.id
       union
       select lim.media_asset_id from public.listing_media lim
        where lim.tenant_id = new.tenant_id and lim.listing_id in (
          select l.id from public.listings l where l.tenant_id = new.tenant_id and l.asset_id = new.id
        )
     );
  end if;
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."set_media_retention_after_sale"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.set_trading_value_approved_timestamp()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if new.status = 'approved' and old.status is distinct from 'approved' then
    new.approved_at := coalesce(new.approved_at, now());
  elsif new.status <> 'approved' then
    new.approved_at := null;
  end if;
  if new.status = 'superseded' and old.status is distinct from 'superseded' then
    new.superseded_at := coalesce(new.superseded_at, now());
  elsif new.status <> 'superseded' then
    new.superseded_at := null;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.set_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog'
  AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."set_updated_at"() FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.shipping_provider_credentials_for_service (
  p_connection_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private', 'vault'
  AS $function$
declare v_secret text;
begin
  if current_user <> 'service_role' then raise exception 'Not authorised'; end if;
  select ds.decrypted_secret into v_secret
  from vault.decrypted_secrets ds
  join public.shipping_provider_connections c on c.credentials_vault_id=ds.id
  where c.id=p_connection_id;
  if v_secret is null then raise exception 'Provider credentials not found'; end if;
  return v_secret::jsonb;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."shipping_provider_credentials_for_service"(uuid) FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.shipping_provider_secret_for_service (
  p_connection_id uuid
)
  RETURNS text
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private', 'vault'
  AS $function$
declare
  v_secret text;
begin
  select ds.decrypted_secret into v_secret
  from vault.decrypted_secrets ds
  join public.shipping_provider_connections c
    on c.api_client_secret_vault_id=ds.id
  where c.id=p_connection_id;

  if v_secret is null then
    raise exception 'Provider credential not found';
  end if;

  return v_secret;
end
$function$;

REVOKE ALL ON FUNCTION "public"."shipping_provider_secret_for_service"(uuid) FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.staff_complete_test_registration (
  p_tenant_slug text
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_uid uuid := auth.uid();
  v_tenant_id uuid;
  v_membership_id uuid;
  v_email_confirmed boolean;
begin
  if v_uid is null then raise exception 'Authentication required'; end if;
  if p_tenant_slug not in ('test-business-a','test-business-b') then raise exception 'Test tenant only'; end if;
  select email_confirmed_at is not null into v_email_confirmed from auth.users where id = v_uid;
  if coalesce(v_email_confirmed,false) = false then raise exception 'Email confirmation is required before staff registration'; end if;
  select id into v_tenant_id from public.tenants where slug = p_tenant_slug and status = 'active';
  if v_tenant_id is null then raise exception 'Test tenant not found'; end if;
  if exists (select 1 from public.customers where auth_user_id = v_uid) then raise exception 'This Auth account is already registered as a customer'; end if;
  if exists (select 1 from public.tenant_memberships where user_id = v_uid) then raise exception 'This Auth account already has a tenant membership'; end if;
  insert into public.tenant_memberships (tenant_id, user_id, role_code, status, joined_at)
  values (v_tenant_id, v_uid, 'staff', 'active', now())
  returning id into v_membership_id;
  return v_membership_id;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."staff_complete_test_registration"(text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_complete_buying_item_followup (
  p_tenant_id      uuid,
  p_buying_item_id uuid,
  p_followup_type  text,
  p_outcome        text,
  p_notes          text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare v_actor uuid:=auth.uid(); v_item public.buying_items%rowtype; v_next text;
begin
  if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
  if p_followup_type not in ('testing','repair') then raise exception 'Invalid follow-up type'; end if;
  if p_outcome not in ('completed','refused') then raise exception 'Invalid follow-up outcome'; end if;
  select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
  if v_item.id is null then raise exception 'Buying item not found'; end if;
  if v_item.purchase_stage<>p_followup_type then raise exception 'Buying item is not currently in %',p_followup_type; end if;
  v_next:=case when p_outcome='completed' then 'inspection' else 'offer_refused' end;
  insert into public.buying_item_inspections(tenant_id,buying_item_id,inspection_type,outcome,condition_grade,notes,passed,inspected_by,inspected_at,metadata)
  values(p_tenant_id,p_buying_item_id,p_followup_type,p_outcome,nullif(trim(v_item.item_condition),''),nullif(trim(p_notes),''),p_outcome='completed',v_actor,now(),jsonb_build_object('source','buying_item_followup','completed_by',v_actor,'completed_at',now()));
  update public.buying_items set purchase_stage=v_next,purchase_stage_updated_at=now(),updated_at=now() where tenant_id=p_tenant_id and id=p_buying_item_id;
  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id)
  values(p_tenant_id,'buying_item',p_buying_item_id,p_followup_type,v_next,coalesce(p_notes,initcap(p_followup_type)||' follow-up completed.'),jsonb_build_object('source','buying_item_followup','followup_type',p_followup_type),v_actor);
  return jsonb_build_object('buying_item_id',p_buying_item_id,'from_stage',p_followup_type,'next_stage',v_next,'outcome',p_outcome);
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_complete_buying_item_followup"(uuid, uuid, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_complete_buying_item_inspection (
  p_tenant_id       uuid,
  p_buying_item_id  uuid,
  p_condition_grade text,
  p_passed          boolean,
  p_outcome         text,
  p_notes           text,
  p_metadata        jsonb
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare
  v_actor uuid:=auth.uid();
  v_item public.buying_items%rowtype;
  v_id uuid;
  v_meta jsonb:=coalesce(p_metadata,'{}'::jsonb);
  v_next text;
  v_reason text;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then
   raise exception 'Permission required: buying.manage';
 end if;
 if p_outcome not in ('accepted','testing_required','repair_required','refused') then
   raise exception 'Invalid inspection outcome';
 end if;

 -- For a refusal because the item is not as described, the mismatch is the
 -- reason for refusal; do not require the normal "description confirmed" tick.
 if p_outcome<>'refused' then
   if coalesce((v_meta->>'customer_description_confirmed')::boolean,false) is not true then
     raise exception 'Confirm that the item matches the customer description before completing inspection';
   end if;
 else
   if coalesce((v_meta->>'condition_not_as_described')::boolean,false) is not true then
     raise exception 'Confirm that the item condition is not as described before refusing the purchase';
   end if;
 end if;

 if coalesce((v_meta->>'condition_confirmed')::boolean,false) is not true then
   raise exception 'Confirm the inspected condition before completing the inspection';
 end if;

 select * into v_item
 from public.buying_items
 where tenant_id=p_tenant_id and id=p_buying_item_id
 for update;

 if v_item.id is null then raise exception 'Buying item not found'; end if;
 if v_item.purchase_stage<>'inspection' then raise exception 'Buying item is not currently in inspection'; end if;

 v_reason:=case
   when p_outcome='refused' and coalesce((v_meta->>'condition_not_as_described')::boolean,false)
     then coalesce(nullif(trim(p_notes),''),'Condition not as described.')
   else null
 end;

 v_meta:=v_meta||jsonb_build_object(
   'completed_by',v_actor,'completed_at',now(),'buying_item_id',p_buying_item_id,
   'customer_description_snapshot',coalesce(v_item.description,''),
   'customer_condition_snapshot',coalesce(v_item.item_condition,'')
 );

 insert into public.buying_item_inspections(
   tenant_id,buying_item_id,inspection_type,outcome,condition_grade,notes,passed,
   inspected_by,inspected_at,metadata
 )
 values(
   p_tenant_id,p_buying_item_id,'condition',p_outcome,
   nullif(trim(p_condition_grade),''),nullif(trim(p_notes),''),p_passed,
   v_actor,now(),v_meta
 ) returning id into v_id;

 v_next:=case
   when p_outcome='accepted' then 'final_offer_required'
   when p_outcome='testing_required' then 'testing'
   when p_outcome='repair_required' then 'repair'
   else 'return_pending'
 end;

 update public.buying_items
 set inspection_completed_at=now(),purchase_stage=v_next,
     purchase_stage_updated_at=now(),updated_at=now()
 where tenant_id=p_tenant_id and id=p_buying_item_id;

 if p_outcome='refused' then
   insert into public.buying_item_return_shipping(
     tenant_id,buying_item_id,return_reason,shipping_status
   )
   values(
     p_tenant_id,p_buying_item_id,
     coalesce(v_reason,'Purchase refused after inspection.'),
     'return_required'
   )
   on conflict (buying_item_id) do update
   set return_reason=excluded.return_reason,
       shipping_status='return_required',
       shipping_status_updated_at=now(),
       updated_at=now();
 end if;

 insert into public.workflow_transitions(
   tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id
 )
 values(
   p_tenant_id,'buying_item',p_buying_item_id,'inspection',v_next,
   coalesce(p_notes,'Inspection completed.'),
   jsonb_build_object('source','inspection','condition_not_as_described',
     coalesce((v_meta->>'condition_not_as_described')::boolean,false)),
   v_actor
 );

 return jsonb_build_object(
   'inspection_id',v_id,'buying_item_id',p_buying_item_id,
   'outcome',p_outcome,'next_stage',v_next,
   'return_required',p_outcome='refused'
 );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_complete_buying_item_inspection"(uuid, uuid, text, boolean, text, text, jsonb) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_complete_purchase (
  p_tenant_id         uuid,
  p_buying_item_id    uuid,
  p_payment_method    text,
  p_payment_reference text,
  p_payment_notes     text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare
  v_actor uuid:=auth.uid(); v_item public.buying_items%rowtype; v_offer public.offers%rowtype;
  v_customer_id uuid; v_customer_email text; v_customer_name text; v_bank public.customer_bank_details%rowtype;
  v_acq uuid; v_acq_item uuid; v_asset uuid; v_payment uuid; v_currency text; v_amount numeric;
  v_item_title text; v_item_reference text; v_payment_payload jsonb;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
  if not private.has_tenant_permission(p_tenant_id,v_actor,'finance.manage') then raise exception 'Permission required: finance.manage'; end if;

  select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
  if v_item.id is null then raise exception 'Buying item not found'; end if;
  if v_item.purchase_stage not in ('final_offer_required','final_offer_accepted') then raise exception 'The item must be ready for payment before payment can be recorded'; end if;

  select * into v_offer from public.offers
  where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id and status='accepted'
    and ((v_item.purchase_stage='final_offer_accepted' and offer_type='final')
      or (v_item.purchase_stage='final_offer_required' and offer_type='initial'))
  order by responded_at desc nulls last,created_at desc limit 1;
  if v_offer.id is null then raise exception 'No accepted offer exists for this item'; end if;

  select br.customer_id,c.email,trim(coalesce(c.first_name,'')||' '||coalesce(c.last_name,''))
    into v_customer_id,v_customer_email,v_customer_name
  from public.buying_requests br join public.customers c on c.tenant_id=br.tenant_id and c.id=br.customer_id
  where br.tenant_id=p_tenant_id and br.id=v_item.buying_request_id;
  if v_customer_id is null then raise exception 'Customer not found for buying item'; end if;

  select * into v_bank from public.customer_bank_details where tenant_id=p_tenant_id and customer_id=v_customer_id;
  if v_bank.id is null then raise exception 'Customer bank details are required before payment can be recorded'; end if;
  if nullif(trim(coalesce(p_payment_reference,'')),'') is null then raise exception 'Bank payment reference is required before payment can be recorded'; end if;

  v_amount:=v_offer.amount; v_currency:=coalesce(v_offer.currency,'GBP'); v_item_title:=coalesce(v_item.title,'your item'); v_item_reference:=v_item.item_reference;

  insert into public.payment_records(tenant_id,payment_reference,payment_type,status,direction,amount,currency,customer_id,payment_method,notes,metadata,requested_at,processed_at,created_by)
  values(p_tenant_id,trim(p_payment_reference),'seller_payment','paid','outbound',v_amount,v_currency,v_customer_id,nullif(trim(p_payment_method),''),
    nullif(trim(p_payment_notes),''),
    jsonb_build_object('source',case when v_offer.offer_type='final' then 'post_inspection_final_offer' else 'post_inspection_initial_offer' end,'buying_item_id',p_buying_item_id,'offer_id',v_offer.id,'offer_type',v_offer.offer_type,'bank_details_on_file',true,'account_holder_name',v_bank.account_holder_name,'sort_code_last4',right(v_bank.sort_code,2),'account_number_last4',right(v_bank.account_number,4)),
    now(),now(),v_actor) returning id into v_payment;

  insert into public.acquisitions(tenant_id,acquisition_reference,status,customer_id,source_offer_id,currency,agreed_total,payment_total,accepted_at,finalised_at,paid_at,metadata,created_by)
  values(p_tenant_id,'ACQ-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'paid',v_customer_id,v_offer.id,v_currency,v_amount,v_amount,now(),now(),now(),
    jsonb_build_object('source','final_offer_payment','buying_item_id',p_buying_item_id,'offer_id',v_offer.id,'payment_record_id',v_payment),v_actor) returning id into v_acq;

  insert into public.acquisition_items(tenant_id,acquisition_id,buying_item_id,offer_id,status,agreed_amount,final_amount,currency,paid_at,finalised_at,metadata)
  values(p_tenant_id,v_acq,p_buying_item_id,v_offer.id,'paid',v_amount,v_amount,v_currency,now(),now(),jsonb_build_object('source','final_offer_payment')) returning id into v_acq_item;

  update public.payment_records set acquisition_id=v_acq,updated_at=now() where id=v_payment;

  insert into public.inventory_assets(tenant_id,acquisition_item_id,buying_item_id,category_id,branch_id,asset_reference,status,title,description,condition_grade,customer_condition,quantity,purchase_price,current_value,currency,notes,metadata,received_at,created_by)
  values(p_tenant_id,v_acq_item,v_item.id,v_item.category_id,v_item.branch_id,null,'ready_for_sale',v_item.title,v_item.description,
    (select condition_grade from public.buying_item_inspections where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id order by created_at desc limit 1),
    v_item.item_condition,coalesce(v_item.quantity,1),v_amount,null,v_currency,'Created only after final offer acceptance, bank details and payment.',
    jsonb_build_object('source','final_offer_payment','buying_item_id',p_buying_item_id,'acquisition_id',v_acq,'offer_id',v_offer.id,'payment_record_id',v_payment),
    coalesce(v_item.item_received_at,now()),v_actor) returning id into v_asset;

  insert into public.inventory_asset_media(tenant_id,inventory_asset_id,media_asset_id,sort_order)
  select p_tenant_id,v_asset,bim.media_asset_id,bim.sort_order
  from public.buying_item_media bim
  where bim.tenant_id=p_tenant_id and bim.buying_item_id=p_buying_item_id
  on conflict (tenant_id,inventory_asset_id,media_asset_id) do nothing;

  update public.buying_items set purchase_stage='purchased',purchased_at=now(),purchase_stage_updated_at=now(),updated_at=now() where tenant_id=p_tenant_id and id=p_buying_item_id;

  v_payment_payload:=jsonb_build_object('customer_name',v_customer_name,'item_title',v_item_title,'item_reference',v_item_reference,'payment_amount',v_amount,'currency',v_currency,'payment_reference',trim(p_payment_reference),'payment_type','seller_payment');
  insert into public.notification_event_log(tenant_id,event_code,entity_type,entity_id,payload) values(p_tenant_id,'payment_sent','payment_record',v_payment,v_payment_payload)
    on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;
  if v_customer_email is not null and btrim(v_customer_email)<>'' then
    perform private.queue_customer_notification(p_tenant_id,'payment_sent','payment_record',v_payment,v_customer_email,v_customer_name,v_payment_payload);
  end if;

  return jsonb_build_object('payment_record_id',v_payment,'acquisition_id',v_acq,'acquisition_item_id',v_acq_item,'inventory_asset_id',v_asset,'status','purchased');
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_complete_purchase"(uuid, uuid, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_complete_retail_fulfilment_shipping (
  p_tenant_id                   uuid,
  p_fulfilment_id               uuid,
  p_shipping_method             text,
  p_shipping_provider           text    DEFAULT NULL::text,
  p_shipping_service_url        text    DEFAULT NULL::text,
  p_shipping_carrier            text    DEFAULT NULL::text,
  p_shipping_service            text    DEFAULT NULL::text,
  p_shipping_tracking_number    text    DEFAULT NULL::text,
  p_shipping_tracking_url       text    DEFAULT NULL::text,
  p_shipping_label_url          text    DEFAULT NULL::text,
  p_shipping_label_storage_path text    DEFAULT NULL::text,
  p_shipping_qr_url             text    DEFAULT NULL::text,
  p_shipping_qr_storage_path    text    DEFAULT NULL::text,
  p_shipping_instructions       text    DEFAULT NULL::text,
  p_weight                      numeric DEFAULT NULL::numeric,
  p_length                      numeric DEFAULT NULL::numeric,
  p_width                       numeric DEFAULT NULL::numeric,
  p_height                      numeric DEFAULT NULL::numeric,
  p_notes                       text    DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
 v_f public.fulfilments%rowtype; v_o public.retail_orders%rowtype; v_existing_status text; v_should_notify boolean:=false; v_parcel_id uuid; v_item_summary text; v_parcel_summary text; v_idempotency text; v_actor uuid:=auth.uid();
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'fulfilment.manage') then raise exception 'Not authorised to manage fulfilment'; end if;
 if p_shipping_method not in ('subscriber_override','automated') then raise exception 'Invalid shipping method'; end if;
 if p_shipping_method='automated' and (p_shipping_provider is null or p_shipping_service_url is null) then raise exception 'Integrated shipping requires a configured provider'; end if;
 select * into v_f from public.fulfilments where tenant_id=p_tenant_id and id=p_fulfilment_id for update;
 if not found then raise exception 'Fulfilment not found'; end if;
 select * into v_o from public.retail_orders where tenant_id=p_tenant_id and id=v_f.retail_order_id for update;
 if not found then raise exception 'Retail order not found'; end if;
 if v_o.payment_status<>'paid' or v_o.status not in ('paid','fulfilment','completed') then raise exception 'Retail order is not paid and ready for fulfilment'; end if;
 if p_shipping_method='subscriber_override' and coalesce(p_shipping_carrier,'')='' and coalesce(p_shipping_service,'')='' then raise exception 'Enter a shipping carrier or service before completing the shipment'; end if;
 if p_shipping_method='subscriber_override' and coalesce(p_shipping_tracking_number,'')='' then raise exception 'Enter the tracking number before completing the shipment'; end if;
 v_existing_status:=v_f.status;
 v_should_notify:=v_existing_status in ('awaiting','label');
 update public.fulfilments set shipping_method=p_shipping_method,shipping_provider=p_shipping_provider,shipping_service_url=p_shipping_service_url,shipping_instructions=p_shipping_instructions,carrier=p_shipping_carrier,service=p_shipping_service,tracking_number=p_shipping_tracking_number,tracking_url=p_shipping_tracking_url,label_url=coalesce(nullif(p_shipping_label_url,''),label_url),label_storage_path=coalesce(nullif(p_shipping_label_storage_path,''),label_storage_path),qr_url=coalesce(nullif(p_shipping_qr_url,''),qr_url),qr_storage_path=coalesce(nullif(p_shipping_qr_storage_path,''),qr_storage_path),recipient_name=coalesce(recipient_name,v_o.customer_name),recipient_email=coalesce(recipient_email,v_o.customer_email),shipping_address=coalesce(shipping_address,v_o.shipping_address),notes=coalesce(p_notes,notes),customer_sent_at=case when v_should_notify then now() else customer_sent_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_fulfilment_id;
 select p.id into v_parcel_id from public.fulfilment_parcels p where p.tenant_id=p_tenant_id and p.fulfilment_id=p_fulfilment_id order by p.created_at limit 1 for update;
 if v_parcel_id is null then
  insert into public.fulfilment_parcels(tenant_id,fulfilment_id,parcel_reference,status,carrier,service,tracking_number,tracking_url,weight,length,width,height,label_url,notes,metadata)
  values(p_tenant_id,p_fulfilment_id,'PAR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'dispatched',p_shipping_carrier,p_shipping_service,p_shipping_tracking_number,p_shipping_tracking_url,p_weight,p_length,p_width,p_height,coalesce(nullif(p_shipping_label_url,''),null),p_notes,jsonb_build_object('shipping_method',p_shipping_method,'provider',p_shipping_provider)) returning id into v_parcel_id;
 else
  update public.fulfilment_parcels set status='dispatched',carrier=coalesce(p_shipping_carrier,carrier),service=coalesce(p_shipping_service,service),tracking_number=coalesce(p_shipping_tracking_number,tracking_number),tracking_url=coalesce(p_shipping_tracking_url,tracking_url),weight=coalesce(p_weight,weight),length=coalesce(p_length,length),width=coalesce(p_width,width),height=coalesce(p_height,height),label_url=coalesce(nullif(p_shipping_label_url,''),label_url),notes=coalesce(p_notes,notes),metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object('shipping_method',p_shipping_method,'provider',p_shipping_provider),updated_at=now() where tenant_id=p_tenant_id and id=v_parcel_id;
 end if;
 if v_existing_status in ('awaiting','label') then
  update public.fulfilments set status='dispatched',updated_at=now() where tenant_id=p_tenant_id and id=p_fulfilment_id and status in ('awaiting','label');
  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'fulfilment',p_fulfilment_id,v_existing_status,'dispatched',v_actor,'Shipping details saved and order marked as shipped.',jsonb_build_object('source','retail_fulfilment_shipping','parcel_id',v_parcel_id));
 end if;
 select string_agg(case when i.quantity>1 then i.quantity::text||' × ' else '' end||i.title,', ' order by i.created_at) into v_item_summary from public.retail_order_items i where i.tenant_id=p_tenant_id and i.order_id=v_o.id;
 v_parcel_summary:=trim(coalesce(case when p_weight is not null then p_weight::text||' kg' end,'Parcel booked with the shipping provider')||case when p_length is not null or p_width is not null or p_height is not null then ' · '||coalesce(p_length::text,'?')||' × '||coalesce(p_width::text,'?')||' × '||coalesce(p_height::text,'?')||' cm' else '' end);
 if v_should_notify and v_o.customer_email is not null then
  v_idempotency:='order_dispatched:'||p_fulfilment_id::text;
  if not exists(select 1 from public.notification_queue q where q.idempotency_key=v_idempotency) then
   insert into public.notification_queue(tenant_id,event_code,recipient_email,recipient_name,subject,template_code,payload,status,attempts,idempotency_key,scheduled_for)
   values(p_tenant_id,'order_dispatched',v_o.customer_email,v_o.customer_name,'Your order is on its way','system_order_dispatched',jsonb_build_object('order_reference',v_o.order_reference,'item_summary',coalesce(v_item_summary,'Your order'),'shipping_service',coalesce(p_shipping_service,'—'),'carrier',coalesce(p_shipping_carrier,'—'),'tracking_number',coalesce(p_shipping_tracking_number,'—'),'tracking_url',coalesce(p_shipping_tracking_url,'—'),'parcel_summary',v_parcel_summary,'shipping_instructions',coalesce(p_shipping_instructions,'Your item is on its way. You can view the shipping details in your customer portal.'),'portal_url','https://laurendigitaluk.github.io/TradeFlow/customer-dashboard.html'),'queued',0,v_idempotency,now());
  end if;
 end if;
 return jsonb_build_object('ok',true,'fulfilment_id',p_fulfilment_id,'status','dispatched','parcel_id',v_parcel_id,'notification_queued',v_should_notify and v_o.customer_email is not null);
end;$function$;

REVOKE ALL
  ON FUNCTION
    "public"."subscriber_complete_retail_fulfilment_shipping"(uuid, uuid, text, text, text, text, text, text, text, text, text, text, text, text, numeric, numeric, numeric,
    numeric, text)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_connect_shipping_provider (
  p_tenant_id         uuid,
  p_provider          text,
  p_environment       text,
  p_api_client_id     text,
  p_api_client_secret text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private', 'vault'
  AS $function$
declare
  v_secret_id uuid;
  v_connection_id uuid;
  v_secret_name text := 'tradeflow_shipping_'||p_tenant_id::text||'_'||p_provider;
begin
  if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'tenant.manage') then
    raise exception 'Not authorised';
  end if;
  if p_provider <> 'parcel2go' then
    raise exception 'This connection flow currently supports Parcel2Go only';
  end if;
  if p_environment not in ('sandbox','live') then
    raise exception 'Invalid environment';
  end if;
  if coalesce(trim(p_api_client_id),'')='' or coalesce(trim(p_api_client_secret),'')='' then
    raise exception 'API client ID and secret are required';
  end if;

  select id,api_client_secret_vault_id
    into v_connection_id,v_secret_id
    from public.shipping_provider_connections
   where tenant_id=p_tenant_id and provider=p_provider;

  if v_secret_id is null then
    select id into v_secret_id
      from vault.secrets
     where name=v_secret_name
     limit 1;
  end if;

  if v_secret_id is null then
    v_secret_id:=vault.create_secret(
      p_api_client_secret,
      v_secret_name,
      'TradeFlow shipping provider credential'
    );
  else
    perform vault.update_secret(
      v_secret_id,
      p_api_client_secret,
      v_secret_name,
      'TradeFlow shipping provider credential'
    );
  end if;

  insert into public.shipping_provider_connections(
    tenant_id,provider,status,connection_type,api_client_id,
    api_client_secret_vault_id,credentials_vault_id,environment,
    auth_mode,updated_at
  )
  values(
    p_tenant_id,p_provider,'pending','subscriber_account',trim(p_api_client_id),
    v_secret_id,v_secret_id,p_environment,'client_credentials',now()
  )
  on conflict(tenant_id,provider) do update set
    status='pending',
    api_client_id=excluded.api_client_id,
    api_client_secret_vault_id=excluded.api_client_secret_vault_id,
    credentials_vault_id=excluded.credentials_vault_id,
    environment=excluded.environment,
    auth_mode=excluded.auth_mode,
    connected_at=null,
    disconnected_at=null,
    last_tested_at=null,
    updated_at=now()
  returning id into v_connection_id;

  return jsonb_build_object(
    'ok',true,
    'connection_id',v_connection_id,
    'status','pending'
  );
end
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_connect_shipping_provider"(uuid, text, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_create_business (
  p_name      text,
  p_slug      text,
  p_plan_code text
)
  RETURNS uuid
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_user uuid := auth.uid();
  v_plan uuid;
  v_tenant uuid;
  v_slug text;
  v_trial_end timestamptz;
begin
  if v_user is null then raise exception 'Authentication required'; end if;
  if nullif(trim(p_name),'') is null then raise exception 'Business name is required'; end if;
  if p_plan_code <> 'enhanced' then raise exception 'The TradeFlow subscription plan is required'; end if;

  select id into v_plan from public.plans where code='enhanced' and active=true limit 1;
  if v_plan is null then raise exception 'TradeFlow plan is not available'; end if;

  v_slug := lower(regexp_replace(trim(coalesce(p_slug,p_name)),'[^a-zA-Z0-9]+','-','g'));
  v_slug := trim(both '-' from v_slug);
  if v_slug='' then raise exception 'A valid business name or slug is required'; end if;

  if exists(select 1 from public.tenants where slug=v_slug) then
    v_slug := v_slug || '-' || substr(replace(gen_random_uuid()::text,'-',''),1,8);
  end if;

  v_trial_end := now() + interval '30 days';

  insert into public.tenants(name,slug,status,settings)
  values(trim(p_name),v_slug,'active','{}'::jsonb)
  returning id into v_tenant;

  insert into public.tenant_public_profiles(tenant_id,business_name)
  values(v_tenant,trim(p_name));

  insert into public.tenant_memberships(tenant_id,user_id,role_code,status,joined_at)
  values(v_tenant,v_user,'owner','active',now());

  insert into public.tenant_subscriptions(
    tenant_id,plan_id,status,started_at,trial_end,current_period_start,current_period_end,metadata
  )
  values(
    v_tenant,v_plan,'trialing',now(),v_trial_end,now(),v_trial_end,
    jsonb_build_object('source','subscriber_signup')
  );

  return v_tenant;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_create_business"(text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_create_manual_buying_valuation (
  p_tenant_id      uuid,
  p_buying_item_id uuid,
  p_cash_price     numeric,
  p_trade_in_price numeric,
  p_notes          text    DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
DECLARE v_actor uuid:=auth.uid(); v_stage text; v_old uuid; v_value uuid; v_offer uuid; v_amount numeric; v_mode text;
BEGIN
 IF v_actor IS NULL OR NOT private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') THEN RAISE EXCEPTION 'Permission required: buying.manage'; END IF;
 IF p_cash_price IS NULL AND p_trade_in_price IS NULL THEN RAISE EXCEPTION 'Enter a cash valuation or trade-in valuation'; END IF;
 IF p_cash_price IS NOT NULL AND p_cash_price<0 THEN RAISE EXCEPTION 'Cash valuation cannot be negative'; END IF;
 IF p_trade_in_price IS NOT NULL AND p_trade_in_price<0 THEN RAISE EXCEPTION 'Trade-in valuation cannot be negative'; END IF;
 SELECT purchase_stage INTO v_stage FROM public.buying_items WHERE tenant_id=p_tenant_id AND id=p_buying_item_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Buying item not found'; END IF;
 IF v_stage IN ('offer_refused','purchased','awaiting_item','shipping','received','inspection','testing','repair','final_offer_required','final_offer_sent','final_offer_accepted') THEN RAISE EXCEPTION 'Manual override is not available at this stage'; END IF;
 SELECT id INTO v_old FROM public.trading_values WHERE tenant_id=p_tenant_id AND buying_item_id=p_buying_item_id AND status='approved' ORDER BY approved_at DESC NULLS LAST,created_at DESC LIMIT 1;
 IF v_old IS NOT NULL THEN
   UPDATE public.trading_values SET status='superseded',superseded_at=coalesce(superseded_at,now()),updated_at=now() WHERE id=v_old;
   INSERT INTO public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id)
   VALUES(p_tenant_id,'trading_value',v_old,'approved','superseded','Manual valuation override replaced the previous valuation.',jsonb_build_object('source','buying_dashboard','override',true),v_actor);
 END IF;
 INSERT INTO public.trading_values(tenant_id,buying_item_id,method,status,amount,currency,confidence,calculated_at,cash_price,trade_in_price,notes,metadata)
 VALUES(p_tenant_id,p_buying_item_id,'manual','draft',coalesce(p_cash_price,p_trade_in_price),'GBP',null,now(),p_cash_price,p_trade_in_price,coalesce(p_notes,'Manual valuation override'),jsonb_build_object('source','buying_dashboard','manual_override',true))
 RETURNING id INTO v_value;
 UPDATE public.trading_values SET status='approved',approved_at=now(),approved_by=v_actor,updated_at=now() WHERE id=v_value;
 INSERT INTO public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id)
 VALUES(p_tenant_id,'trading_value',v_value,'draft','approved','Manual valuation approved.',jsonb_build_object('source','buying_dashboard','manual_override',true),v_actor);
 FOR v_offer IN SELECT id FROM public.offers WHERE tenant_id=p_tenant_id AND buying_item_id=p_buying_item_id AND offer_type='initial' AND status='published' LOOP
   UPDATE public.offers SET status='superseded',updated_at=now() WHERE id=v_offer;
   INSERT INTO public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id)
   VALUES(p_tenant_id,'offer',v_offer,'published','superseded','Previous initial offer replaced by manual valuation override.',jsonb_build_object('source','buying_dashboard','manual_override',true),v_actor);
 END LOOP;
 v_amount:=coalesce(p_cash_price,p_trade_in_price); v_mode:=case when p_cash_price is not null then 'cash' else 'trade_in' end;
 INSERT INTO public.offers(tenant_id,buying_item_id,trading_value_id,offer_reference,offer_type,status,amount,currency,created_by,offer_mode)
 VALUES(p_tenant_id,p_buying_item_id,v_value,'OF-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),'initial','draft',v_amount,'GBP',v_actor,v_mode)
 RETURNING id INTO v_offer;
 UPDATE public.offers SET status='published',published_at=now(),updated_at=now() WHERE id=v_offer;
 INSERT INTO public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id)
 VALUES(p_tenant_id,'offer',v_offer,'draft','published','Manual valuation override offer published.',jsonb_build_object('source','buying_dashboard','manual_override',true),v_actor);
 UPDATE public.buying_items SET purchase_stage='offer_ready',purchase_stage_updated_at=now(),updated_at=now() WHERE tenant_id=p_tenant_id AND id=p_buying_item_id;
 RETURN jsonb_build_object('buying_item_id',p_buying_item_id,'trading_value_id',v_value,'offer_id',v_offer,'purchase_stage','offer_ready','amount',v_amount,'offer_mode',v_mode);
END;$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_create_manual_buying_valuation"(uuid, uuid, numeric, numeric, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_credit_trade_in (
  p_tenant_id      uuid,
  p_buying_item_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare
 v_actor uuid:=auth.uid(); v_item public.buying_items%rowtype; v_offer public.offers%rowtype;
 v_customer_id uuid; v_currency text; v_amount numeric; v_trade uuid; v_acq uuid; v_acq_item uuid; v_ledger uuid; v_asset uuid; v_account uuid;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
 if v_item.id is null then raise exception 'Buying item not found'; end if;
 if v_item.purchase_stage<>'final_offer_required' then raise exception 'This item is not at the post-inspection trade-in decision stage'; end if;
 select * into v_offer from public.offers where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id and offer_type='initial' and offer_mode='trade_in' and status='accepted' order by responded_at desc nulls last,created_at desc limit 1;
 if v_offer.id is null then raise exception 'No accepted trade-in offer exists for this item'; end if;
 select br.customer_id into v_customer_id from public.buying_requests br where br.tenant_id=p_tenant_id and br.id=v_item.buying_request_id;
 v_amount:=v_offer.amount; v_currency:=coalesce(v_offer.currency,'GBP');
 if v_amount is null or v_amount<0 then raise exception 'Trade-in credit amount is invalid'; end if;
 if exists(select 1 from public.trade_in_transactions where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id and status in ('credited','completed')) then raise exception 'Trade-in credit has already been added'; end if;

 insert into public.customer_credit_accounts(tenant_id,customer_id,balance,currency) values(p_tenant_id,v_customer_id,0,v_currency)
 on conflict(tenant_id,customer_id) do update set currency=excluded.currency,updated_at=now()
 returning id into v_account;

 insert into public.acquisitions(tenant_id,acquisition_reference,status,customer_id,source_offer_id,currency,agreed_total,payment_total,accepted_at,finalised_at,paid_at,metadata,created_by)
 values(p_tenant_id,'ACQ-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'completed',v_customer_id,v_offer.id,v_currency,v_amount,v_amount,now(),now(),now(),jsonb_build_object('source','trade_in_credit','buying_item_id',p_buying_item_id,'offer_id',v_offer.id,'credit_account_id',v_account),v_actor)
 returning id into v_acq;

 insert into public.acquisition_items(tenant_id,acquisition_id,buying_item_id,offer_id,status,agreed_amount,final_amount,currency,paid_at,finalised_at,metadata)
 values(p_tenant_id,v_acq,p_buying_item_id,v_offer.id,'completed',v_amount,v_amount,v_currency,now(),now(),jsonb_build_object('source','trade_in_credit'))
 returning id into v_acq_item;

 insert into public.trade_in_transactions(tenant_id,trade_in_reference,customer_id,buying_request_id,buying_item_id,offer_id,acquisition_id,acquisition_item_id,status,valuation_method,trading_value,trade_in_price,credit_amount,currency,accepted_at,received_at,credited_at,completed_at,staff_notes,metadata,created_by)
 values(p_tenant_id,'TI-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),v_customer_id,v_item.buying_request_id,v_item.id,v_offer.id,v_acq,v_acq_item,'credited','manual',v_amount,v_amount,v_amount,v_currency,now(),coalesce(v_item.item_received_at,now()),now(),now(),'Added to customer trade-in credit after inspection.',jsonb_build_object('source','post_inspection_trade_in_credit','offer_id',v_offer.id,'credit_account_id',v_account),v_actor)
 returning id into v_trade;

 insert into public.ledger_entries(tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,acquisition_id,description,reference_type,reference_id,metadata,posted_at,created_by)
 values(p_tenant_id,'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'adjustment','credit','posted',v_amount,v_currency,v_customer_id,v_acq,'Trade-in credit added to customer account','trade_in_transaction',v_trade,jsonb_build_object('buying_item_id',p_buying_item_id,'acquisition_id',v_acq,'credit_account_id',v_account),now(),v_actor)
 returning id into v_ledger;

 update public.customer_credit_accounts set balance=balance+v_amount,updated_at=now() where id=v_account;

 insert into public.inventory_assets(tenant_id,acquisition_item_id,buying_item_id,category_id,branch_id,asset_reference,status,title,description,condition_grade,customer_condition,quantity,purchase_price,current_value,currency,notes,metadata,received_at,created_by)
 values(p_tenant_id,v_acq_item,v_item.id,v_item.category_id,v_item.branch_id,null,'ready_for_sale',v_item.title,v_item.description,
        (select condition_grade from public.buying_item_inspections where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id order by created_at desc limit 1),
        v_item.item_condition,coalesce(v_item.quantity,1),v_amount,null,v_currency,'Created when the accepted trade-in value was added as customer credit.',
        jsonb_build_object('source','trade_in_credit','trade_in_transaction_id',v_trade,'ledger_entry_id',v_ledger,'credit_account_id',v_account),coalesce(v_item.item_received_at,now()),v_actor)
 returning id into v_asset;

 update public.buying_items set purchase_stage='purchased',purchased_at=now(),purchase_stage_updated_at=now(),updated_at=now() where tenant_id=p_tenant_id and id=p_buying_item_id;
 return jsonb_build_object('trade_in_transaction_id',v_trade,'acquisition_id',v_acq,'acquisition_item_id',v_acq_item,'ledger_entry_id',v_ledger,'inventory_asset_id',v_asset,'credit_account_id',v_account,'credit_amount',v_amount,'status','credited');
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_credit_trade_in"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_decide_customer_return (
  p_tenant_id         uuid,
  p_return_id         uuid,
  p_decision          text,
  p_postage_payer     text DEFAULT NULL::text,
  p_return_label_path text DEFAULT NULL::text,
  p_notes             text DEFAULT NULL::text
)
  RETURNS boolean
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_actor uuid := auth.uid();
  v_status text;
  v_metadata jsonb;
begin
  if v_actor is null or not private.is_tenant_member(p_tenant_id,v_actor) then
    raise exception 'Tenant membership required';
  end if;

  if not private.has_tenant_permission(p_tenant_id,v_actor,'returns.manage') then
    raise exception 'Permission required: returns.manage';
  end if;

  if not (private.has_tenant_feature(p_tenant_id,'module.buying') or private.has_tenant_feature(p_tenant_id,'module.orders')) then
    raise exception 'Subscription capability required for returns';
  end if;

  if p_decision not in ('approved','denied') then
    raise exception 'Decision must be approved or denied';
  end if;

  if p_decision='approved' and p_postage_payer not in ('subscriber','customer') then
    raise exception 'Select who pays return postage';
  end if;

  if p_decision='approved' and coalesce(trim(p_return_label_path),'')='' then
    raise exception 'A return label must be supplied before approving the return';
  end if;

  select status, metadata
    into v_status, v_metadata
  from public.returns
  where id=p_return_id and tenant_id=p_tenant_id and return_type='customer_retail'
  for update;

  if not found then raise exception 'Return request not found'; end if;
  if v_status <> 'requested' then raise exception 'Return is no longer awaiting a decision'; end if;

  v_metadata := coalesce(v_metadata,'{}'::jsonb)
    || jsonb_build_object(
      'decision',p_decision,
      'decision_at',now(),
      'decision_by',v_actor,
      'postage_payer',case when p_decision='approved' then p_postage_payer else null end,
      'return_label_path',case when p_decision='approved' then p_return_label_path else null end
    );

  if coalesce(trim(p_notes),'')<>'' then
    v_metadata := v_metadata || jsonb_build_object('decision_notes',p_notes);
  end if;

  update public.returns
  set status=case when p_decision='approved' then 'authorised' else 'rejected' end,
      authorised_at=case when p_decision='approved' then coalesce(authorised_at,now()) else authorised_at end,
      resolved_at=case when p_decision='denied' then coalesce(resolved_at,now()) else resolved_at end,
      metadata=v_metadata,
      updated_at=now()
  where id=p_return_id and tenant_id=p_tenant_id and status='requested';

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
  ) values (
    p_tenant_id,'return',p_return_id,'requested',
    case when p_decision='approved' then 'authorised' else 'rejected' end,
    v_actor,p_notes,
    jsonb_build_object(
      'source','returns-dashboard',
      'decision',p_decision,
      'postage_payer',case when p_decision='approved' then p_postage_payer else null end,
      'return_label_path',case when p_decision='approved' then p_return_label_path else null end
    )
  );

  return true;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_decide_customer_return"(uuid, uuid, text, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_business_workflow (
  p_tenant_id uuid
)
  RETURNS TABLE (
    request_id            uuid,
    request_reference     text,
    request_status        text,
    buying_item_id        uuid,
    title                 text,
    purchase_stage        text,
    amount                numeric,
    currency              text,
    offer_status          text,
    offer_type            text,
    acquisition_id        uuid,
    acquisition_reference text,
    acquisition_status    text
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if auth.uid() is null or not exists(
    select 1
    from public.tenant_memberships tm
    join public.roles r on r.code=tm.role_code and r.active
    join public.role_permissions rp on rp.role_id=r.id
    join public.permissions p on p.id=rp.permission_id and p.active and p.code='buying.view'
    where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active'
  ) then
    raise exception 'Permission required: buying.view';
  end if;

  return query
  select
    br.id, br.request_reference, br.status, bi.id, bi.title, bi.purchase_stage,
    coalesce(final_offer.amount,initial_offer.amount,tv.cash_price,tv.amount),
    coalesce(final_offer.currency,initial_offer.currency,tv.currency,'GBP'),
    coalesce(final_offer.status,initial_offer.status),
    coalesce(final_offer.offer_type,initial_offer.offer_type),
    a.id, a.acquisition_reference, a.status
  from public.buying_requests br
  join public.buying_items bi
    on bi.tenant_id=br.tenant_id and bi.buying_request_id=br.id
  left join lateral (
    select o.* from public.offers o
    where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='final'
    order by o.created_at desc limit 1
  ) final_offer on true
  left join lateral (
    select o.* from public.offers o
    where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='initial'
    order by o.created_at desc limit 1
  ) initial_offer on true
  left join lateral (
    select tv.* from public.trading_values tv
    where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved'
    order by tv.approved_at desc nulls last,tv.created_at desc limit 1
  ) tv on true
  left join lateral (
    select a.* from public.acquisitions a
    where a.tenant_id=bi.tenant_id and a.source_offer_id=coalesce(final_offer.id,initial_offer.id)
    order by a.created_at desc limit 1
  ) a on true
  where br.tenant_id=p_tenant_id
    and bi.purchase_stage <> 'offer_refused'
    and not (
      bi.purchase_stage='return_pending'
      and exists(
        select 1 from public.buying_item_return_shipping rs
        where rs.tenant_id=bi.tenant_id
          and rs.buying_item_id=bi.id
          and rs.shipping_status='return_shipped'
      )
    )
    and (
      bi.purchase_stage <> 'none'
      or br.status in ('submitted','under_review','valued','offer_ready')
    )
  order by br.created_at desc,bi.sort_order;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_business_workflow"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_business_workflow_counts (
  p_tenant_id uuid
)
  RETURNS TABLE (
    active_buying              bigint,
    inventory_ready            bigint,
    active_listings            bigint,
    active_retail_orders       bigint,
    fulfilment_action_required bigint,
    active_fulfilments         bigint,
    active_returns             bigint
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if auth.uid() is null or not exists(
    select 1
    from public.tenant_memberships tm
    join public.roles r on r.code=tm.role_code and r.active
    join public.role_permissions rp on rp.role_id=r.id
    join public.permissions p on p.id=rp.permission_id and p.active and p.code='buying.view'
    where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active'
  ) then
    raise exception 'Permission required: buying.view';
  end if;

  return query
  select
    (
      select count(*)
      from public.buying_items b
      where b.tenant_id=p_tenant_id
        and coalesce(b.purchase_stage,'') not in ('purchased','offer_refused')
        and coalesce(b.status,'')<>'closed'
        and not (
          coalesce(b.purchase_stage,'')='return_pending'
          and exists(
            select 1
            from public.buying_item_return_shipping rs
            where rs.buying_item_id=b.id
              and rs.tenant_id=b.tenant_id
              and rs.shipping_status='return_shipped'
          )
        )
    )::bigint,
    (
      select count(*)
      from public.inventory_assets i
      where i.tenant_id=p_tenant_id and i.status='ready_for_sale'
    )::bigint,
    (
      select count(*)
      from public.listings l
      where l.tenant_id=p_tenant_id and l.status not in ('sold','delisted')
    )::bigint,
    (
      select count(*)
      from public.retail_orders ro
      where ro.tenant_id=p_tenant_id
        and ro.status not in ('cancelled','completed')
        and not exists(
          select 1
          from public.fulfilments f
          where f.retail_order_id=ro.id
            and f.status in ('dispatched','delivered')
        )
    )::bigint,
    (
      select count(*)
      from public.retail_orders ro
      left join public.fulfilments f on f.retail_order_id=ro.id
      where ro.tenant_id=p_tenant_id
        and ro.payment_status='paid'
        and ro.status not in ('cancelled','completed')
        and (f.id is null or f.status in ('awaiting','label'))
    )::bigint,
    (
      select count(*)
      from public.fulfilments f
      join public.retail_orders ro on ro.id=f.retail_order_id
      where ro.tenant_id=p_tenant_id
        and f.status not in ('completed','cancelled','dispatched','delivered')
    )::bigint,
    (
      select count(*)
      from public.returns r
      where r.tenant_id=p_tenant_id
        and r.status not in ('completed','closed','rejected','denied')
    )::bigint;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_business_workflow_counts"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_buying_item_customer_details (
  p_tenant_id      uuid,
  p_buying_item_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v jsonb;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not private.is_tenant_member(p_tenant_id, auth.uid()) then
    raise exception 'Tenant membership required';
  end if;

  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'buying.view') then
    raise exception 'Buying permission required';
  end if;

  select jsonb_build_object(
    'customer', jsonb_build_object(
      'customer_reference', c.customer_reference,
      'first_name', c.first_name,
      'last_name', c.last_name,
      'email', c.email,
      'phone', c.phone
    ),
    'request_notes', r.notes,
    'item', jsonb_build_object(
      'id', bi.id,
      'item_reference', bi.item_reference,
      'title', bi.title,
      'description', bi.description,
      'quantity', bi.quantity,
      'item_condition', bi.item_condition,
      'category_id', bi.category_id
    ),
    'fields', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'field_id', f.id,
            'label', f.label,
            'field_key', f.field_key,
            'field_type', f.field_type,
            'value',
              case
                when f.field_type in ('text','textarea','email','phone','url','select','multiselect')
                  then to_jsonb(vfv.value_text)
                when f.field_type in ('number','currency')
                  then to_jsonb(vfv.value_number)
                when f.field_type = 'boolean'
                  then to_jsonb(vfv.value_boolean)
                when f.field_type = 'date'
                  then to_jsonb(vfv.value_date)
                else vfv.value_json
              end
          )
          order by f.sort_order, f.label
        )
        from public.buying_item_field_values vfv
        join public.category_fields f
          on f.id = vfv.field_id
         and f.tenant_id = vfv.tenant_id
        where vfv.tenant_id = p_tenant_id
          and vfv.buying_item_id = bi.id
      ),
      '[]'::jsonb
    )
  )
  into v
  from public.buying_items bi
  join public.buying_requests r
    on r.id = bi.buying_request_id
   and r.tenant_id = bi.tenant_id
  join public.customers c
    on c.id = r.customer_id
   and c.tenant_id = r.tenant_id
  where bi.tenant_id = p_tenant_id
    and bi.id = p_buying_item_id;

  if v is null then
    raise exception 'Buying item not found';
  end if;

  return v;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_buying_item_customer_details"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_buying_item_payment_details (
  p_tenant_id      uuid,
  p_buying_item_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare
  v_actor uuid := auth.uid();
  v_customer_id uuid;
  v_item_stage text;
  v_offer_status text;
  v_offer_amount numeric;
  v_currency text;
  v_bank public.customer_bank_details%rowtype;
begin
  if v_actor is null then
    raise exception 'Authentication required';
  end if;
  if not private.has_tenant_permission(p_tenant_id,v_actor,'buying.view') then
    raise exception 'Permission required: buying.view';
  end if;
  if not private.has_tenant_permission(p_tenant_id,v_actor,'finance.manage') then
    raise exception 'Permission required: finance.manage';
  end if;

  select bi.purchase_stage, br.customer_id
    into v_item_stage, v_customer_id
  from public.buying_items bi
  join public.buying_requests br
    on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;

  if v_customer_id is null then
    raise exception 'Buying item or customer not found';
  end if;

  select o.status,o.amount,o.currency
    into v_offer_status,v_offer_amount,v_currency
  from public.offers o
  where o.tenant_id=p_tenant_id
    and o.buying_item_id=p_buying_item_id
    and o.offer_type='final'
    and o.status='accepted'
  order by o.responded_at desc nulls last,o.created_at desc
  limit 1;

  select * into v_bank
  from public.customer_bank_details
  where tenant_id=p_tenant_id and customer_id=v_customer_id
  limit 1;

  return jsonb_build_object(
    'ready_for_payment',
      v_item_stage='final_offer_accepted'
      and v_offer_status='accepted'
      and v_bank.id is not null,
    'purchase_stage',v_item_stage,
    'final_offer_status',coalesce(v_offer_status,''),
    'offer_amount',v_offer_amount,
    'currency',coalesce(v_currency,'GBP'),
    'bank_details_received',v_bank.id is not null,
    'account_holder_name',v_bank.account_holder_name,
    'bank_name',v_bank.bank_name,
    'sort_code',v_bank.sort_code,
    'account_number',v_bank.account_number
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_buying_item_payment_details"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_customer_addresses (
  p_tenant_id   uuid,
  p_customer_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_rows jsonb;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 select coalesce(jsonb_agg(jsonb_build_object(
   'id',a.id,'address_type',a.address_type,'recipient_name',a.recipient_name,
   'company_name',a.company_name,'line1',a.line1,'line2',a.line2,'city',a.city,
   'county',a.county,'postcode',a.postcode,'country_code',a.country_code,'is_default',a.is_default
   ) order by a.address_type,a.is_default desc,a.created_at desc),'[]'::jsonb)
 into v_rows
 from public.customer_addresses a
 where a.tenant_id=p_tenant_id and a.customer_id=p_customer_id;
 return v_rows;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_customer_addresses"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_customer_bank_details (
  p_tenant_id      uuid,
  p_buying_item_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_customer_id uuid;
  v_row public.customer_bank_details%rowtype;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
  if not private.has_tenant_permission(p_tenant_id,auth.uid(),'finance.view') then raise exception 'Finance permission required'; end if;

  select br.customer_id into v_customer_id
  from public.buying_items bi
  join public.buying_requests br on br.id=bi.buying_request_id and br.tenant_id=bi.tenant_id
  where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;

  if v_customer_id is null then raise exception 'Buying item not found'; end if;

  select * into v_row
  from public.customer_bank_details
  where tenant_id=p_tenant_id and customer_id=v_customer_id;

  if v_row.id is null then
    return jsonb_build_object('has_details',false);
  end if;

  return jsonb_build_object(
    'has_details',true,
    'account_holder_name',v_row.account_holder_name,
    'sort_code',v_row.sort_code,
    'account_number',v_row.account_number,
    'bank_name',v_row.bank_name
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_customer_bank_details"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_customer_bank_details_for_customer (
  p_tenant_id   uuid,
  p_customer_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_row public.customer_bank_details%rowtype;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'finance.view') then raise exception 'Finance permission required'; end if;
 select * into v_row
 from public.customer_bank_details
 where tenant_id=p_tenant_id and customer_id=p_customer_id;
 if v_row.id is null then return jsonb_build_object('has_details',false); end if;
 return jsonb_build_object(
   'has_details',true,
   'account_holder_name',v_row.account_holder_name,
   'sort_code',v_row.sort_code,
   'account_number',v_row.account_number,
   'bank_name',v_row.bank_name
 );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_customer_bank_details_for_customer"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_email_status (
  p_tenant_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_tenant record; v_platform record;
begin
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Not authorised'; end if;
 select sender_email,email_enabled,sender_verification_status into v_tenant from public.tenant_email_settings where tenant_id=p_tenant_id;
 select sender_email,email_enabled,sender_verification_status into v_platform from public.platform_email_settings where id=true;
 return jsonb_build_object(
  'business_email',v_tenant.sender_email,
  'business_email_enabled',coalesce(v_tenant.email_enabled,false),
  'platform_email',v_platform.sender_email,
  'platform_email_enabled',coalesce(v_platform.email_enabled,false),
  'platform_email_status',coalesce(v_platform.sender_verification_status,'not_configured'),
  'ready',coalesce(v_tenant.email_enabled,false) and coalesce(v_platform.email_enabled,false) and v_platform.sender_verification_status='verified'
 );
end $function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_email_status"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_fulfilment_orders (
  p_tenant_id uuid
)
  RETURNS TABLE (
    id               uuid,
    order_reference  text,
    status           text,
    customer_name    text,
    customer_email   text,
    shipping_address jsonb,
    total            numeric,
    currency         text,
    paid_at          timestamp with time zone
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 return query
 select o.id,o.order_reference,o.status,o.customer_name,o.customer_email,o.shipping_address,o.total,o.currency,o.paid_at
 from public.retail_orders o
 where o.tenant_id=p_tenant_id
   and o.status in ('paid','fulfilment')
   and o.payment_status='paid'
 order by o.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_fulfilment_orders"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_fulfilments (
  p_tenant_id uuid
)
  RETURNS TABLE (
    id                   uuid,
    fulfilment_reference text,
    retail_order_id      uuid,
    status               text,
    carrier              text,
    service              text,
    tracking_number      text,
    tracking_url         text,
    recipient_name       text,
    recipient_email      text,
    shipping_address     jsonb,
    label_url            text,
    dispatched_at        timestamp with time zone,
    delivered_at         timestamp with time zone,
    returned_at          timestamp with time zone,
    notes                text,
    created_at           timestamp with time zone
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 return query
 select f.id,f.fulfilment_reference,f.retail_order_id,f.status,f.carrier,f.service,
        f.tracking_number,f.tracking_url,f.recipient_name,f.recipient_email,
        f.shipping_address,f.label_url,f.dispatched_at,f.delivered_at,f.returned_at,
        f.notes,f.created_at
 from public.fulfilments f
 where f.tenant_id=p_tenant_id
 order by f.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_fulfilments"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_my_memberships()
  RETURNS TABLE (
    tenant_id   uuid,
    tenant_name text,
    role_code   text,
    status      text
  )
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select tm.tenant_id,t.name,tm.role_code,tm.status
  from public.tenant_memberships tm
  join public.tenants t on t.id=tm.tenant_id
  where tm.user_id=auth.uid() and tm.status='active' and t.status='active'
  order by t.name,tm.role_code;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_my_memberships"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_order_details (
  p_tenant_id uuid,
  p_order_id  uuid
)
  RETURNS TABLE (
    order_id             uuid,
    order_reference      text,
    order_status         text,
    payment_status       text,
    currency             text,
    subtotal             numeric,
    shipping_total       numeric,
    total                numeric,
    amount_due           numeric,
    customer_name        text,
    customer_email       text,
    shipping_address     jsonb,
    billing_address      jsonb,
    notes                text,
    placed_at            timestamp with time zone,
    paid_at              timestamp with time zone,
    completed_at         timestamp with time zone,
    cancelled_at         timestamp with time zone,
    item_id              uuid,
    listing_id           uuid,
    inventory_asset_id   uuid,
    item_title           text,
    item_quantity        integer,
    item_unit_price      numeric,
    item_line_total      numeric,
    fulfilment_id        uuid,
    fulfilment_reference text,
    fulfilment_status    text,
    carrier              text,
    service              text,
    tracking_number      text,
    tracking_url         text,
    dispatched_at        timestamp with time zone,
    delivered_at         timestamp with time zone
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'orders.view') then raise exception 'Orders view permission required'; end if;
 if not private.has_tenant_feature(p_tenant_id,'module.orders') then raise exception 'Orders module is not enabled for this tenant'; end if;
 return query
 select o.id,o.order_reference,o.status,o.payment_status,o.currency,o.subtotal,o.shipping_total,o.total,o.amount_due,
        o.customer_name,o.customer_email,o.shipping_address,o.billing_address,o.notes,
        o.placed_at,o.paid_at,o.completed_at,o.cancelled_at,
        i.id,i.listing_id,i.inventory_asset_id,i.title,i.quantity,i.unit_price,i.line_total,
        f.id,f.fulfilment_reference,f.status,f.carrier,f.service,f.tracking_number,f.tracking_url,
        f.dispatched_at,f.delivered_at
 from public.retail_orders o
 left join public.retail_order_items i on i.tenant_id=o.tenant_id and i.order_id=o.id
 left join lateral (
   select f1.* from public.fulfilments f1
   where f1.tenant_id=o.tenant_id and f1.retail_order_id=o.id
   order by f1.created_at desc limit 1
 ) f on true
 where o.tenant_id=p_tenant_id and o.id=p_order_id
 order by i.created_at;
end; $function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_order_details"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_orders (
  p_tenant_id uuid
)
  RETURNS TABLE (
    id               uuid,
    order_reference  text,
    customer_id      uuid,
    channel_id       uuid,
    status           text,
    currency         text,
    total            numeric,
    payment_status   text,
    customer_email   text,
    customer_name    text,
    shipping_address jsonb,
    billing_address  jsonb,
    notes            text,
    amount_due       numeric,
    placed_at        timestamp with time zone,
    paid_at          timestamp with time zone,
    completed_at     timestamp with time zone,
    cancelled_at     timestamp with time zone,
    created_at       timestamp with time zone
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'orders.view') then raise exception 'Orders view permission required'; end if;
 if not private.has_tenant_feature(p_tenant_id,'module.orders') then raise exception 'Orders module is not enabled for this tenant'; end if;
 return query
 select o.id,o.order_reference,o.customer_id,o.channel_id,o.status,o.currency,o.total,o.payment_status,
        o.customer_email,o.customer_name,o.shipping_address,o.billing_address,o.notes,o.amount_due,
        o.placed_at,o.paid_at,o.completed_at,o.cancelled_at,o.created_at
 from public.retail_orders o
 where o.tenant_id=p_tenant_id
 order by o.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_orders"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_retail_fulfilment_shipping (
  p_tenant_id uuid
)
  RETURNS TABLE (
    fulfilment_id         uuid,
    retail_order_id       uuid,
    fulfilment_reference  text,
    fulfilment_status     text,
    order_reference       text,
    customer_name         text,
    customer_email        text,
    shipping_address      jsonb,
    total                 numeric,
    currency              text,
    items                 jsonb,
    shipping_method       text,
    shipping_provider     text,
    shipping_service_url  text,
    carrier               text,
    service               text,
    tracking_number       text,
    tracking_url          text,
    label_url             text,
    label_storage_path    text,
    qr_url                text,
    qr_storage_path       text,
    shipping_instructions text,
    parcel                jsonb,
    created_at            timestamp with time zone
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
 if auth.uid() is null or not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 return query
 select f.id,f.retail_order_id,f.fulfilment_reference,f.status,o.order_reference,o.customer_name,o.customer_email,o.shipping_address,o.total,o.currency,
   coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'title',i.title,'quantity',i.quantity,'unit_price',i.unit_price,'line_total',i.line_total,
     'inventory_asset_id',i.inventory_asset_id,'asset_reference',ia.asset_reference,'condition',coalesce(ia.condition_grade,ia.customer_condition),
     'description',ia.description,'serial_number',ia.serial_number) order by i.created_at)
     from public.retail_order_items i left join public.inventory_assets ia on ia.tenant_id=i.tenant_id and ia.id=i.inventory_asset_id
     where i.tenant_id=o.tenant_id and i.order_id=o.id),'[]'::jsonb),
   f.shipping_method,f.shipping_provider,f.shipping_service_url,f.carrier,f.service,f.tracking_number,f.tracking_url,
   f.label_url,f.label_storage_path,f.qr_url,f.qr_storage_path,f.shipping_instructions,
   (select jsonb_build_object('id',p.id,'parcel_reference',p.parcel_reference,'status',p.status,'weight',p.weight,'length',p.length,'width',p.width,'height',p.height,'label_url',p.label_url,'notes',p.notes,'metadata',p.metadata)
    from public.fulfilment_parcels p where p.tenant_id=f.tenant_id and p.fulfilment_id=f.id order by p.created_at limit 1),
   f.created_at
 from public.fulfilments f join public.retail_orders o on o.tenant_id=f.tenant_id and o.id=f.retail_order_id
 where f.tenant_id=p_tenant_id order by f.created_at desc;
end;$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_retail_fulfilment_shipping"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_returns (
  p_tenant_id uuid
)
  RETURNS TABLE (
    id                  uuid,
    return_reference    text,
    return_type         text,
    status              text,
    customer_id         uuid,
    order_id            uuid,
    order_item_id       uuid,
    acquisition_id      uuid,
    acquisition_item_id uuid,
    inventory_asset_id  uuid,
    reason_code         text,
    reason              text,
    customer_notes      text,
    staff_notes         text,
    requested_at        timestamp with time zone,
    authorised_at       timestamp with time zone,
    received_at         timestamp with time zone,
    inspected_at        timestamp with time zone,
    resolved_at         timestamp with time zone,
    closed_at           timestamp with time zone,
    refund_amount       numeric,
    currency            text
  )
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'returns.view') then
    raise exception 'Permission required: returns.view';
  end if;

  if not (
    private.has_tenant_feature(p_tenant_id, 'module.buying')
    or private.has_tenant_feature(p_tenant_id, 'module.orders')
  ) then
    raise exception 'Returns module is not enabled for this business';
  end if;

  return query
  select r.id,r.return_reference,r.return_type,r.status,r.customer_id,r.order_id,
         r.order_item_id,r.acquisition_id,r.acquisition_item_id,r.inventory_asset_id,
         r.reason_code,r.reason,r.customer_notes,r.staff_notes,r.requested_at,
         r.authorised_at,r.received_at,r.inspected_at,r.resolved_at,r.closed_at,
         r.refund_amount,r.currency
  from public.returns r
  where r.tenant_id=p_tenant_id
  order by r.requested_at desc nulls last,r.created_at desc;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_returns"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_shipping_service_settings (
  p_tenant_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public'
  AS $function$
declare
  v_catalog jsonb;
  v_selected jsonb;
begin
  if not exists (
    select 1 from public.tenant_memberships m
    where m.tenant_id=p_tenant_id and m.user_id=auth.uid() and m.status='active'
  ) then
    raise exception 'You do not have access to this tenant.';
  end if;

  select coalesce(jsonb_agg(to_jsonb(c) order by c.sort_order,c.service_name),'[]'::jsonb)
    into v_catalog
  from public.shipping_service_catalog c
  where c.active=true;

  select coalesce(jsonb_agg(to_jsonb(s) order by s.sort_order,s.service_name),'[]'::jsonb)
    into v_selected
  from public.tenant_shipping_services s
  where s.tenant_id=p_tenant_id and s.enabled=true;

  return jsonb_build_object('catalog',v_catalog,'selected',v_selected);
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_shipping_service_settings"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_get_sold_retail_items (
  p_tenant_id uuid
)
  RETURNS TABLE (
    listing_id           uuid,
    listing_reference    text,
    title                text,
    asking_price         numeric,
    currency             text,
    sold_at              timestamp with time zone,
    order_id             uuid,
    order_reference      text,
    customer_name        text,
    customer_email       text,
    order_total          numeric,
    paid_at              timestamp with time zone,
    fulfilment_id        uuid,
    fulfilment_reference text,
    fulfilment_status    text,
    carrier              text,
    service              text,
    tracking_number      text,
    tracking_url         text,
    label_url            text,
    dispatched_at        timestamp with time zone
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 return query
 select l.id,l.listing_reference,l.title,l.asking_price,l.currency,l.sold_at,
        o.id,o.order_reference,o.customer_name,o.customer_email,o.total,o.paid_at,
        f.id,f.fulfilment_reference,f.status,f.carrier,f.service,f.tracking_number,f.tracking_url,f.label_url,f.dispatched_at
 from public.listings l
 join public.retail_order_items i on i.tenant_id=l.tenant_id and i.listing_id=l.id
 join public.retail_orders o on o.tenant_id=i.tenant_id and o.id=i.order_id
 left join lateral (
   select f1.* from public.fulfilments f1
   where f1.tenant_id=o.tenant_id and f1.retail_order_id=o.id
   order by f1.created_at desc limit 1
 ) f on true
 where l.tenant_id=p_tenant_id
   and l.status='sold'
   and o.payment_status='paid'
 order by l.sold_at desc nulls last;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_get_sold_retail_items"(uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_mark_buying_item_offer_ready (
  p_tenant_id      uuid,
  p_buying_item_id uuid,
  p_notes          text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
DECLARE v_actor uuid:=auth.uid(); v_stage text; v_offer_id uuid;
BEGIN
 IF v_actor IS NULL OR NOT private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') THEN RAISE EXCEPTION 'Permission required: buying.manage'; END IF;
 SELECT purchase_stage INTO v_stage FROM public.buying_items WHERE tenant_id=p_tenant_id AND id=p_buying_item_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Buying item not found'; END IF;
 IF v_stage IN ('offer_ready','awaiting_item','shipping','received','inspection','testing','repair','final_offer_required','final_offer_sent','final_offer_accepted','purchased') THEN
   RETURN jsonb_build_object('buying_item_id',p_buying_item_id,'purchase_stage',v_stage,'already_ready',true);
 END IF;
 IF v_stage='offer_refused' THEN RAISE EXCEPTION 'This buying item has been refused'; END IF;
 UPDATE public.buying_items SET purchase_stage='offer_ready',purchase_stage_updated_at=now(),updated_at=now()
 WHERE tenant_id=p_tenant_id AND id=p_buying_item_id;
 INSERT INTO public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id)
 VALUES(p_tenant_id,'buying_item',p_buying_item_id,coalesce(v_stage,'none'),'offer_ready',coalesce(p_notes,'Initial valuation/offer is ready.'),jsonb_build_object('source','buying_dashboard'),v_actor);
 RETURN jsonb_build_object('buying_item_id',p_buying_item_id,'purchase_stage','offer_ready','already_ready',false);
END;$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_mark_buying_item_offer_ready"(uuid, uuid, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_mark_buying_item_received (
  p_tenant_id      uuid,
  p_buying_item_id uuid
)
  RETURNS boolean
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
begin
  if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'buying.manage') then
    raise exception 'Not authorised to manage buying';
  end if;

  if not exists (
    select 1
    from public.buying_items bi
    where bi.tenant_id=p_tenant_id
      and bi.id=p_buying_item_id
      and bi.purchase_stage in ('shipping','received')
  ) then
    raise exception 'The item must be on its way before it can be received';
  end if;

  if not exists (
    select 1
    from public.buying_item_shipping s
    where s.tenant_id=p_tenant_id
      and s.buying_item_id=p_buying_item_id
      and s.shipping_status in ('in_transit','received')
  ) then
    raise exception 'Customer has not confirmed that the item is on its way';
  end if;

  update public.buying_items
  set purchase_stage='received',
      item_received_at=coalesce(item_received_at,now()),
      purchase_stage_updated_at=now(),
      updated_at=now()
  where tenant_id=p_tenant_id
    and id=p_buying_item_id;

  update public.buying_item_shipping
  set shipping_status='received',
      shipping_status_updated_at=now(),
      updated_at=now()
  where tenant_id=p_tenant_id
    and buying_item_id=p_buying_item_id;

  return true;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_mark_buying_item_received"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_publish_buying_item_return_shipping (
  p_tenant_id                   uuid,
  p_buying_item_id              uuid,
  p_shipping_method             text DEFAULT 'subscriber_override'::text,
  p_shipping_label_url          text DEFAULT NULL::text,
  p_shipping_label_storage_path text DEFAULT NULL::text,
  p_shipping_qr_url             text DEFAULT NULL::text,
  p_shipping_qr_storage_path    text DEFAULT NULL::text,
  p_shipping_carrier            text DEFAULT NULL::text,
  p_shipping_service            text DEFAULT NULL::text,
  p_shipping_tracking_number    text DEFAULT NULL::text,
  p_shipping_tracking_url       text DEFAULT NULL::text,
  p_shipping_instructions       text DEFAULT NULL::text,
  p_shipping_provider           text DEFAULT NULL::text,
  p_shipping_service_url        text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$ declare v_actor uuid:=auth.uid(); v_stage text; begin if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if; if p_shipping_method not in ('subscriber_override','automated') then raise exception 'Invalid shipping method'; end if; select purchase_stage into v_stage from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update; if v_stage is null then raise exception 'Buying item not found'; end if; if v_stage<>'return_pending' then raise exception 'Buying item is not awaiting return shipping'; end if; if coalesce(trim(p_shipping_tracking_number),'')='' then raise exception 'Enter the return tracking number before sending the return update'; end if; insert into public.buying_item_return_shipping(tenant_id,buying_item_id,shipping_method,shipping_label_url,shipping_label_storage_path,shipping_qr_url,shipping_qr_storage_path,shipping_carrier,shipping_service,shipping_tracking_number,shipping_tracking_url,shipping_instructions,shipping_provider,shipping_service_url,shipping_status,shipping_status_updated_at,shipped_at) values(p_tenant_id,p_buying_item_id,p_shipping_method,p_shipping_label_url,p_shipping_label_storage_path,p_shipping_qr_url,p_shipping_qr_storage_path,p_shipping_carrier,p_shipping_service,p_shipping_tracking_number,p_shipping_tracking_url,p_shipping_instructions,p_shipping_provider,p_shipping_service_url,'return_shipped',now(),now()) on conflict(buying_item_id) do update set shipping_method=excluded.shipping_method,shipping_label_url=coalesce(excluded.shipping_label_url,buying_item_return_shipping.shipping_label_url),shipping_label_storage_path=coalesce(excluded.shipping_label_storage_path,buying_item_return_shipping.shipping_label_storage_path),shipping_qr_url=coalesce(excluded.shipping_qr_url,buying_item_return_shipping.shipping_qr_url),shipping_qr_storage_path=coalesce(excluded.shipping_qr_storage_path,buying_item_return_shipping.shipping_qr_storage_path),shipping_carrier=excluded.shipping_carrier,shipping_service=excluded.shipping_service,shipping_tracking_number=excluded.shipping_tracking_number,shipping_tracking_url=excluded.shipping_tracking_url,shipping_instructions=excluded.shipping_instructions,shipping_provider=excluded.shipping_provider,shipping_service_url=excluded.shipping_service_url,shipping_status='return_shipped',shipping_status_updated_at=now(),shipped_at=now(),updated_at=now(); return jsonb_build_object('ok',true,'buying_item_id',p_buying_item_id,'status','return_shipped'); end;$function$;

REVOKE ALL
  ON FUNCTION "public"."subscriber_publish_buying_item_return_shipping"(uuid, uuid, text, text, text, text, text, text, text, text, text, text, text, text)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_publish_buying_item_shipping_handoff (
  p_tenant_id                       uuid,
  p_buying_item_id                  uuid,
  p_shipping_method                 text,
  p_shipping_label_url              text DEFAULT NULL::text,
  p_shipping_label_storage_path     text DEFAULT NULL::text,
  p_shipping_qr_url                 text DEFAULT NULL::text,
  p_shipping_qr_storage_path        text DEFAULT NULL::text,
  p_shipping_carrier                text DEFAULT NULL::text,
  p_shipping_service                text DEFAULT NULL::text,
  p_shipping_tracking_number        text DEFAULT NULL::text,
  p_shipping_instructions           text DEFAULT NULL::text,
  p_shipping_provider               text DEFAULT NULL::text,
  p_shipping_provider_connection_id uuid DEFAULT NULL::uuid,
  p_shipping_service_url            text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare v_stage text; v_label text; v_label_path text; v_qr text; v_qr_path text;
begin
  if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'buying.manage') then raise exception 'Not authorised to manage buying'; end if;
  if p_shipping_method not in ('subscriber_override','automated') then raise exception 'Invalid shipping method'; end if;
  select purchase_stage into v_stage from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
  if v_stage is null then raise exception 'Buying item not found'; end if;
  if v_stage not in ('awaiting_item','shipping') then raise exception 'Shipping handoff can only be published while awaiting the item'; end if;
  select shipping_label_url,shipping_label_storage_path,shipping_qr_url,shipping_qr_storage_path into v_label,v_label_path,v_qr,v_qr_path from public.buying_item_shipping where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id for update;
  v_label:=coalesce(nullif(p_shipping_label_url,''),v_label); v_label_path:=coalesce(nullif(p_shipping_label_storage_path,''),v_label_path); v_qr:=coalesce(nullif(p_shipping_qr_url,''),v_qr); v_qr_path:=coalesce(nullif(p_shipping_qr_storage_path,''),v_qr_path);
  if p_shipping_method='subscriber_override' and coalesce(v_label,'')='' and coalesce(v_label_path,'')='' and coalesce(v_qr,'')='' and coalesce(v_qr_path,'')='' then raise exception 'Add a shipping label or QR code before publishing the shipping handoff'; end if;
  if p_shipping_method='automated' and (p_shipping_provider is null or p_shipping_provider_connection_id is null) then raise exception 'Integrated shipping requires a connected provider'; end if;
  insert into public.buying_item_shipping(tenant_id,buying_item_id,shipping_method,shipping_label_url,shipping_label_storage_path,shipping_qr_url,shipping_qr_storage_path,shipping_service_url,shipping_carrier,shipping_service,shipping_tracking_number,shipping_instructions,shipping_provider,shipping_provider_connection_id,shipping_status,shipping_status_updated_at)
  values(p_tenant_id,p_buying_item_id,p_shipping_method,case when p_shipping_method='subscriber_override' then v_label end,case when p_shipping_method='subscriber_override' then v_label_path end,case when p_shipping_method='subscriber_override' then v_qr end,case when p_shipping_method='subscriber_override' then v_qr_path end,case when p_shipping_method='subscriber_override' then p_shipping_service_url end,p_shipping_carrier,p_shipping_service,p_shipping_tracking_number,p_shipping_instructions,p_shipping_provider,p_shipping_provider_connection_id,case when p_shipping_method='automated' then 'ready_for_customer_quote' else 'ready_for_customer' end,now())
  on conflict (buying_item_id) do update set shipping_method=excluded.shipping_method,shipping_label_url=coalesce(excluded.shipping_label_url,buying_item_shipping.shipping_label_url),shipping_label_storage_path=coalesce(excluded.shipping_label_storage_path,buying_item_shipping.shipping_label_storage_path),shipping_qr_url=coalesce(excluded.shipping_qr_url,buying_item_shipping.shipping_qr_url),shipping_qr_storage_path=coalesce(excluded.shipping_qr_storage_path,buying_item_shipping.shipping_qr_storage_path),shipping_service_url=excluded.shipping_service_url,shipping_carrier=excluded.shipping_carrier,shipping_service=excluded.shipping_service,shipping_tracking_number=excluded.shipping_tracking_number,shipping_instructions=excluded.shipping_instructions,shipping_provider=excluded.shipping_provider,shipping_provider_connection_id=excluded.shipping_provider_connection_id,shipping_status=excluded.shipping_status,shipping_status_updated_at=now(),updated_at=now();
  return jsonb_build_object('ok',true,'buying_item_id',p_buying_item_id,'status',v_stage);
end;
$function$;

REVOKE ALL
  ON FUNCTION "public"."subscriber_publish_buying_item_shipping_handoff"(uuid, uuid, text, text, text, text, text, text, text, text, text, text, uuid, text)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_publish_final_offer (
  p_tenant_id      uuid,
  p_buying_item_id uuid,
  p_amount         numeric,
  p_notes          text    DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare
  v_actor uuid:=auth.uid();
  v_stage text;
  v_currency text;
  v_value_id uuid;
  v_previous_value_id uuid;
  v_offer_id uuid;
  v_customer_id uuid;
  v_customer_email text;
  v_customer_name text;
  v_payload jsonb;
begin
  if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then
    raise exception 'Permission required: buying.manage';
  end if;
  if p_amount<0 then raise exception 'Final offer amount cannot be negative'; end if;

  select purchase_stage into v_stage
  from public.buying_items
  where tenant_id=p_tenant_id and id=p_buying_item_id
  for update;

  if v_stage is null then raise exception 'Buying item not found'; end if;
  if v_stage<>'final_offer_required' then
    raise exception 'Final offer can only be sent after a passed inspection';
  end if;

  select coalesce(
    (
      select o.currency
      from public.offers o
      where o.tenant_id=p_tenant_id
        and o.buying_item_id=p_buying_item_id
        and o.status='accepted'
      order by o.responded_at desc nulls last, o.created_at desc
      limit 1
    ),
    'GBP'
  ) into v_currency;

  select br.customer_id,c.email,trim(coalesce(c.first_name,'')||' '||coalesce(c.last_name,''))
    into v_customer_id,v_customer_email,v_customer_name
  from public.buying_items bi
  join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  join public.customers c on c.tenant_id=br.tenant_id and c.id=br.customer_id
  where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;

  if v_customer_id is null then raise exception 'Customer not found for buying item'; end if;

  -- A buying item may have only one approved trading value. The original
  -- valuation remains historical, so supersede it before approving the
  -- post-inspection valuation.
  select tv.id into v_previous_value_id
  from public.trading_values tv
  where tv.tenant_id=p_tenant_id
    and tv.buying_item_id=p_buying_item_id
    and tv.status='approved'
  order by tv.approved_at desc nulls last, tv.created_at desc
  limit 1
  for update;

  if v_previous_value_id is not null then
    perform public.transition_workflow_entity(
      p_tenant_id,'trading_value',v_previous_value_id,'approved','superseded',
      'Superseded by post-inspection final valuation.',
      jsonb_build_object('source','post_inspection_final_valuation')
    );
  end if;

  insert into public.trading_values(
    tenant_id,buying_item_id,method,status,amount,currency,
    cash_price,trade_in_price,confidence,calculated_at,notes,metadata
  )
  values(
    p_tenant_id,p_buying_item_id,'manual','draft',p_amount,coalesce(v_currency,'GBP'),
    p_amount,null,null,now(),coalesce(p_notes,'Final post-inspection valuation'),
    jsonb_build_object('source','post_inspection_final_valuation','inspection_required',true)
  )
  returning id into v_value_id;

  perform public.transition_workflow_entity(
    p_tenant_id,'trading_value',v_value_id,'draft','approved',
    coalesce(p_notes,'Final post-inspection valuation approved'),
    jsonb_build_object('source','post_inspection_final_valuation')
  );

  insert into public.offers(
    tenant_id,buying_item_id,trading_value_id,offer_reference,offer_type,
    status,amount,currency,created_by
  )
  values(
    p_tenant_id,p_buying_item_id,v_value_id,
    'OF-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),
    'final','draft',p_amount,coalesce(v_currency,'GBP'),v_actor
  )
  returning id into v_offer_id;

  perform public.transition_workflow_entity(
    p_tenant_id,'offer',v_offer_id,'draft','published',
    'Final post-inspection offer published to customer.',
    jsonb_build_object(
      'source','post_inspection_final_offer',
      'inspection_id',
      (select id from public.buying_item_inspections
       where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id
       order by created_at desc limit 1)
    )
  );

  update public.buying_items
  set purchase_stage='final_offer_sent',
      purchase_stage_updated_at=now(),
      updated_at=now()
  where tenant_id=p_tenant_id and id=p_buying_item_id;

  v_payload:=jsonb_build_object(
    'customer_name',v_customer_name,
    'item_title',(select coalesce(title,'your item') from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id),
    'item_reference',(select item_reference from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id),
    'offer_reference',(select offer_reference from public.offers where tenant_id=p_tenant_id and id=v_offer_id),
    'offer_amount',p_amount,
    'currency',coalesce(v_currency,'GBP'),
    'offer_type','final'
  );

  insert into public.notification_event_log(tenant_id,event_code,entity_type,entity_id,payload)
  values(p_tenant_id,'offer_sent','offer',v_offer_id,v_payload)
  on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;

  if v_customer_email is not null and btrim(v_customer_email)<>'' then
    perform private.queue_customer_notification(
      p_tenant_id,'offer_sent','offer',v_offer_id,
      v_customer_email,v_customer_name,v_payload
    );
  end if;

  return jsonb_build_object(
    'valuation_id',v_value_id,
    'offer_id',v_offer_id,
    'status','final_offer_sent'
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_publish_final_offer"(uuid, uuid, numeric, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_publish_shipping_handoff (
  p_tenant_id                       uuid,
  p_acquisition_id                  uuid,
  p_shipping_method                 text,
  p_shipping_label_url              text DEFAULT NULL::text,
  p_shipping_label_storage_path     text DEFAULT NULL::text,
  p_shipping_qr_url                 text DEFAULT NULL::text,
  p_shipping_qr_storage_path        text DEFAULT NULL::text,
  p_shipping_carrier                text DEFAULT NULL::text,
  p_shipping_service                text DEFAULT NULL::text,
  p_shipping_tracking_number        text DEFAULT NULL::text,
  p_shipping_instructions           text DEFAULT NULL::text,
  p_shipping_provider               text DEFAULT NULL::text,
  p_shipping_provider_connection_id uuid DEFAULT NULL::uuid,
  p_shipping_service_url            text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare
  v_status text;
  v_id uuid;
  v_label_url text;
  v_label_path text;
  v_qr_url text;
  v_qr_path text;
begin
  if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'acquisitions.manage') then
    raise exception 'Not authorised to manage acquisitions';
  end if;

  if p_shipping_method not in ('subscriber_override','automated') then
    raise exception 'Invalid shipping method';
  end if;

  select status,shipping_label_url,shipping_label_storage_path,shipping_qr_url,shipping_qr_storage_path
    into v_status,v_label_url,v_label_path,v_qr_url,v_qr_path
  from public.acquisitions
  where id=p_acquisition_id and tenant_id=p_tenant_id
  for update;

  if v_status is null then raise exception 'Acquisition not found'; end if;

  v_label_url:=coalesce(nullif(p_shipping_label_url,''),v_label_url);
  v_label_path:=coalesce(nullif(p_shipping_label_storage_path,''),v_label_path);
  v_qr_url:=coalesce(nullif(p_shipping_qr_url,''),v_qr_url);
  v_qr_path:=coalesce(nullif(p_shipping_qr_storage_path,''),v_qr_path);

  if p_shipping_method='subscriber_override'
     and coalesce(v_label_url,'')=''
     and coalesce(v_label_path,'')=''
     and coalesce(v_qr_url,'')=''
     and coalesce(v_qr_path,'')='' then
    raise exception 'Add a shipping label or QR code before publishing the shipping handoff';
  end if;

  if p_shipping_method='automated'
     and (p_shipping_provider is null or p_shipping_provider_connection_id is null) then
    raise exception 'Integrated shipping requires a connected provider';
  end if;

  update public.acquisitions set
    shipping_method=p_shipping_method,
    shipping_label_url=case when p_shipping_method='subscriber_override' then v_label_url else shipping_label_url end,
    shipping_label_storage_path=case when p_shipping_method='subscriber_override' then v_label_path else shipping_label_storage_path end,
    shipping_qr_url=case when p_shipping_method='subscriber_override' then v_qr_url else shipping_qr_url end,
    shipping_qr_storage_path=case when p_shipping_method='subscriber_override' then v_qr_path else shipping_qr_storage_path end,
    shipping_service_url=case when p_shipping_method='subscriber_override' then p_shipping_service_url else shipping_service_url end,
    shipping_carrier=case when p_shipping_method='subscriber_override' then p_shipping_carrier else shipping_carrier end,
    shipping_service=case when p_shipping_method='subscriber_override' then p_shipping_service else shipping_service end,
    shipping_tracking_number=case when p_shipping_method='subscriber_override' then p_shipping_tracking_number else shipping_tracking_number end,
    shipping_instructions=p_shipping_instructions,
    shipping_provider=p_shipping_provider,
    shipping_provider_connection_id=p_shipping_provider_connection_id,
    shipping_status=case when p_shipping_method='automated' then 'ready_for_customer_quote' else 'ready_for_customer' end,
    shipping_status_updated_at=now(),
    updated_at=now()
  where id=p_acquisition_id and tenant_id=p_tenant_id
  returning id into v_id;

  if v_status='accepted' then
    perform public.transition_workflow_entity('acquisition',p_acquisition_id,'accepted','awaiting_item','Subscriber shipping handoff published.');
  end if;

  return jsonb_build_object('ok',true,'acquisition_id',v_id,'status','awaiting_item');
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_publish_shipping_handoff"(uuid, uuid, text, text, text, text, text, text, text, text, text, text, uuid, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_refuse_after_inspection (
  p_tenant_id      uuid,
  p_buying_item_id uuid,
  p_notes          text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare v_actor uuid:=auth.uid();
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 update public.buying_items set purchase_stage='offer_refused',purchase_stage_updated_at=now(),updated_at=now()
 where tenant_id=p_tenant_id and id=p_buying_item_id and purchase_stage='final_offer_required';
 if not found then raise exception 'Item is not awaiting a post-inspection decision'; end if;
 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id)
 values(p_tenant_id,'buying_item',p_buying_item_id,'final_offer_required','offer_refused',coalesce(p_notes,'Trade-in refused after inspection.'),jsonb_build_object('source','post_inspection_refusal'),v_actor);
 return jsonb_build_object('buying_item_id',p_buying_item_id,'status','offer_refused');
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_refuse_after_inspection"(uuid, uuid, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_refuse_buying_item_valuation (
  p_tenant_id      uuid,
  p_buying_item_id uuid,
  p_notes          text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_actor uuid := auth.uid();
  v_stage text;
  v_offer_id uuid;
  v_offer_status text;
  v_customer_id uuid;
  v_customer_email text;
  v_customer_name text;
  v_item_title text;
  v_item_reference text;
  v_request_reference text;
  v_payload jsonb;
begin
  if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then
    raise exception 'Permission required: buying.manage';
  end if;

  select purchase_stage into v_stage
  from public.buying_items
  where tenant_id=p_tenant_id and id=p_buying_item_id
  for update;

  if not found then raise exception 'Buying item not found'; end if;

  if coalesce(v_stage,'none') not in (
    'none','submitted','under_review','valued','offer_ready','awaiting_item','shipping'
  ) then
    raise exception 'This transaction cannot be refused at its current stage';
  end if;

  select o.id,o.status into v_offer_id,v_offer_status
  from public.offers o
  where o.tenant_id=p_tenant_id
    and o.buying_item_id=p_buying_item_id
    and o.offer_type='initial'
  order by o.created_at desc
  limit 1;

  if v_offer_id is not null and v_offer_status='published' then
    update public.offers
       set status='refused',
           responded_at=coalesce(responded_at,now()),
           updated_at=now()
     where id=v_offer_id and tenant_id=p_tenant_id and status='published';

    insert into public.workflow_transitions(
      tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id
    )
    values(
      p_tenant_id,'offer',v_offer_id,'published','refused',
      coalesce(p_notes,'Valuation refused by subscriber.'),
      jsonb_build_object('source','buying_dashboard','reason','valuation_refused'),
      v_actor
    );
  end if;

  select
    br.customer_id,
    c.email,
    trim(coalesce(c.first_name,'')||' '||coalesce(c.last_name,'')),
    coalesce(bi.title,'your item'),
    bi.item_reference,
    br.request_reference
  into
    v_customer_id,v_customer_email,v_customer_name,v_item_title,v_item_reference,v_request_reference
  from public.buying_items bi
  join public.buying_requests br
    on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  join public.customers c
    on c.tenant_id=br.tenant_id and c.id=br.customer_id
  where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;

  update public.buying_items
     set purchase_stage='offer_refused',
         purchase_stage_updated_at=now(),
         updated_at=now()
   where tenant_id=p_tenant_id and id=p_buying_item_id;

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id
  )
  values(
    p_tenant_id,'buying_item',p_buying_item_id,coalesce(v_stage,'none'),'offer_refused',
    coalesce(p_notes,'Valuation refused by subscriber.'),
    jsonb_build_object('source','buying_dashboard','reason','valuation_refused','customer_notified',true),
    v_actor
  );

  v_payload := jsonb_build_object(
    'customer_name',coalesce(v_customer_name,''),
    'item_title',v_item_title,
    'item_reference',v_item_reference,
    'request_reference',v_request_reference,
    'reason',coalesce(p_notes,'The business has decided not to proceed with this item.'),
    'offer_reference',case when v_offer_id is not null then
      (select offer_reference from public.offers where id=v_offer_id) else null end
  );

  insert into public.notification_event_log(
    tenant_id,event_code,entity_type,entity_id,payload
  )
  values(p_tenant_id,'valuation_refused','buying_item',p_buying_item_id,v_payload)
  on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;

  if v_customer_email is not null and btrim(v_customer_email)<>'' then
    perform private.queue_customer_notification(
      p_tenant_id,'valuation_refused','buying_item',p_buying_item_id,
      v_customer_email,v_customer_name,v_payload
    );
  end if;

  return jsonb_build_object(
    'buying_item_id',p_buying_item_id,
    'status','offer_refused',
    'offer_id',v_offer_id,
    'customer_notified',true
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_refuse_buying_item_valuation"(uuid, uuid, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_request_customer_bank_details (
  p_tenant_id      uuid,
  p_buying_item_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare
  v_actor uuid := auth.uid();
  v_customer_id uuid;
  v_customer record;
  v_item record;
  v_request record;
  v_bank_exists boolean;
  v_notification_id uuid;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if not private.has_tenant_permission(p_tenant_id, v_actor, 'buying.view') then
    raise exception 'Permission required: buying.view';
  end if;
  if not private.has_tenant_permission(p_tenant_id, v_actor, 'finance.manage') then
    raise exception 'Permission required: finance.manage';
  end if;

  select bi.id, bi.purchase_stage, bi.buying_request_id, bi.item_reference
    into v_item
  from public.buying_items bi
  where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;

  if not found then raise exception 'Buying item not found'; end if;
  if v_item.purchase_stage <> 'final_offer_accepted' then
    raise exception 'Customer bank details can only be requested after the final offer has been accepted';
  end if;

  select br.customer_id, br.request_reference into v_request
  from public.buying_requests br
  where br.tenant_id=p_tenant_id and br.id=v_item.buying_request_id;

  if v_request.customer_id is null then raise exception 'Customer not found'; end if;

  select exists(
    select 1 from public.customer_bank_details cbd
    where cbd.tenant_id=p_tenant_id and cbd.customer_id=v_request.customer_id
  ) into v_bank_exists;

  if v_bank_exists then
    return jsonb_build_object('sent',false,'already_available',true,'message','Customer bank details are already on record.');
  end if;

  select c.email,c.first_name,c.last_name into v_customer
  from public.customers c
  where c.tenant_id=p_tenant_id and c.id=v_request.customer_id;

  if v_customer.email is null then
    return jsonb_build_object('sent',false,'already_available',false,'message','Customer has no email address on record.');
  end if;

  v_notification_id := private.queue_customer_notification(
    p_tenant_id,
    'payment_bank_details_required',
    'buying_item',
    v_item.id,
    v_customer.email,
    trim(coalesce(v_customer.first_name,'')||' '||coalesce(v_customer.last_name,'')),
    jsonb_build_object(
      'customer_name',trim(coalesce(v_customer.first_name,'')||' '||coalesce(v_customer.last_name,'')),
      'item_reference',v_item.item_reference,
      'request_reference',v_request.request_reference,
      'portal_url','https://laurendigitaluk.github.io/TradeFlow/customer-dashboard.html'
    )
  );

  if v_notification_id is null then
    return jsonb_build_object(
      'sent',false,
      'already_available',false,
      'message','Customer bank details reminder could not be queued because subscriber email notifications are not enabled.'
    );
  end if;

  return jsonb_build_object('sent',true,'already_available',false,'notification_id',v_notification_id,'message','Bank details request sent to the customer.');
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_request_customer_bank_details"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_save_business_email (
  p_tenant_id uuid,
  p_email     text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare v_name text; v_email text;
begin
 if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'tenant.manage') then raise exception 'Not authorised'; end if;
 v_email:=lower(trim(p_email));
 if v_email is null or v_email='' or v_email !~ '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$' then raise exception 'Please enter a valid business email address.'; end if;
 select name into v_name from public.tenants where id=p_tenant_id;
 insert into public.tenant_email_settings(tenant_id,sender_email,reply_to_email,sender_name,email_enabled,sender_verification_status,sender_verified_at,sender_provider,email_footer,business_name_override)
 values(p_tenant_id,v_email,v_email,v_name,true,'pending',null,'resend',null,v_name)
 on conflict(tenant_id) do update set sender_email=excluded.sender_email,reply_to_email=excluded.reply_to_email,sender_name=excluded.sender_name,email_enabled=true,
 sender_verification_status=case when public.tenant_email_settings.sender_email is distinct from excluded.sender_email then 'pending' else coalesce(public.tenant_email_settings.sender_verification_status,'pending') end,
 sender_verified_at=case when public.tenant_email_settings.sender_email is distinct from excluded.sender_email then null else public.tenant_email_settings.sender_verified_at end,
 sender_provider='resend',business_name_override=excluded.business_name_override,updated_at=now();
 return jsonb_build_object('email',v_email,'sender_name',v_name,'status',(select sender_verification_status from public.tenant_email_settings where tenant_id=p_tenant_id));
end $function$;

REVOKE ALL ON FUNCTION "public"."subscriber_save_business_email"(uuid, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_save_retail_fulfilment_shipping (
  p_tenant_id                   uuid,
  p_fulfilment_id               uuid,
  p_shipping_method             text,
  p_shipping_provider           text    DEFAULT NULL::text,
  p_shipping_service_url        text    DEFAULT NULL::text,
  p_shipping_carrier            text    DEFAULT NULL::text,
  p_shipping_service            text    DEFAULT NULL::text,
  p_shipping_tracking_number    text    DEFAULT NULL::text,
  p_shipping_tracking_url       text    DEFAULT NULL::text,
  p_shipping_label_url          text    DEFAULT NULL::text,
  p_shipping_label_storage_path text    DEFAULT NULL::text,
  p_shipping_qr_url             text    DEFAULT NULL::text,
  p_shipping_qr_storage_path    text    DEFAULT NULL::text,
  p_shipping_instructions       text    DEFAULT NULL::text,
  p_weight                      numeric DEFAULT NULL::numeric,
  p_length                      numeric DEFAULT NULL::numeric,
  p_width                       numeric DEFAULT NULL::numeric,
  p_height                      numeric DEFAULT NULL::numeric,
  p_notes                       text    DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
 v_f public.fulfilments%rowtype; v_o public.retail_orders%rowtype; v_existing_status text; v_should_notify boolean:=false; v_parcel_id uuid; v_item_summary text; v_parcel_summary text; v_idempotency text; v_actor uuid:=auth.uid();
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'fulfilment.manage') then raise exception 'Not authorised to manage fulfilment'; end if;
 if p_shipping_method not in ('subscriber_override','automated') then raise exception 'Invalid shipping method'; end if;
 if p_shipping_method='automated' and (p_shipping_provider is null or p_shipping_service_url is null) then raise exception 'Integrated shipping requires a configured provider'; end if;
 select * into v_f from public.fulfilments where tenant_id=p_tenant_id and id=p_fulfilment_id for update;
 if not found then raise exception 'Fulfilment not found'; end if;
 select * into v_o from public.retail_orders where tenant_id=p_tenant_id and id=v_f.retail_order_id for update;
 if not found then raise exception 'Retail order not found'; end if;
 if v_o.payment_status<>'paid' or v_o.status not in ('paid','fulfilment','completed') then raise exception 'Retail order is not paid and ready for fulfilment'; end if;
 if p_shipping_method='subscriber_override' and coalesce(p_shipping_carrier,'')='' and coalesce(p_shipping_service,'')='' then raise exception 'Enter a shipping carrier or service before completing the shipment'; end if;
 if p_shipping_method='subscriber_override' and coalesce(p_shipping_tracking_number,'')='' then raise exception 'Enter the tracking number before completing the shipment'; end if;
 v_existing_status:=v_f.status;
 v_should_notify:=v_existing_status in ('awaiting','label');
 update public.fulfilments set shipping_method=p_shipping_method,shipping_provider=p_shipping_provider,shipping_service_url=p_shipping_service_url,shipping_instructions=p_shipping_instructions,carrier=p_shipping_carrier,service=p_shipping_service,tracking_number=p_shipping_tracking_number,tracking_url=p_shipping_tracking_url,label_url=coalesce(nullif(p_shipping_label_url,''),label_url),label_storage_path=coalesce(nullif(p_shipping_label_storage_path,''),label_storage_path),qr_url=coalesce(nullif(p_shipping_qr_url,''),qr_url),qr_storage_path=coalesce(nullif(p_shipping_qr_storage_path,''),qr_storage_path),recipient_name=coalesce(recipient_name,v_o.customer_name),recipient_email=coalesce(recipient_email,v_o.customer_email),shipping_address=coalesce(shipping_address,v_o.shipping_address),notes=coalesce(p_notes,notes),customer_sent_at=case when v_should_notify then now() else customer_sent_at end,updated_at=now()
 where tenant_id=p_tenant_id and id=p_fulfilment_id;
 select p.id into v_parcel_id from public.fulfilment_parcels p where p.tenant_id=p_tenant_id and p.fulfilment_id=p_fulfilment_id order by p.created_at limit 1 for update;
 if v_parcel_id is null then
  insert into public.fulfilment_parcels(tenant_id,fulfilment_id,parcel_reference,status,carrier,service,tracking_number,tracking_url,weight,length,width,height,label_url,notes,metadata)
  values(p_tenant_id,p_fulfilment_id,'PAR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'dispatched',p_shipping_carrier,p_shipping_service,p_shipping_tracking_number,p_shipping_tracking_url,p_weight,p_length,p_width,p_height,coalesce(nullif(p_shipping_label_url,''),null),p_notes,jsonb_build_object('shipping_method',p_shipping_method,'provider',p_shipping_provider)) returning id into v_parcel_id;
 else
  update public.fulfilment_parcels set status='dispatched',carrier=coalesce(p_shipping_carrier,carrier),service=coalesce(p_shipping_service,service),tracking_number=coalesce(p_shipping_tracking_number,tracking_number),tracking_url=coalesce(p_shipping_tracking_url,tracking_url),weight=coalesce(p_weight,weight),length=coalesce(p_length,length),width=coalesce(p_width,width),height=coalesce(p_height,height),label_url=coalesce(nullif(p_shipping_label_url,''),label_url),notes=coalesce(p_notes,notes),metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object('shipping_method',p_shipping_method,'provider',p_shipping_provider),updated_at=now() where tenant_id=p_tenant_id and id=v_parcel_id;
 end if;
 if v_existing_status in ('awaiting','label') then
  update public.fulfilments set status='dispatched',updated_at=now() where tenant_id=p_tenant_id and id=p_fulfilment_id and status in ('awaiting','label');
  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'fulfilment',p_fulfilment_id,v_existing_status,'dispatched',v_actor,'Shipping details saved and order marked as shipped.',jsonb_build_object('source','retail_fulfilment_shipping','parcel_id',v_parcel_id));
 end if;
 select string_agg(case when i.quantity>1 then i.quantity::text||' × ' else '' end||i.title,', ' order by i.created_at) into v_item_summary from public.retail_order_items i where i.tenant_id=p_tenant_id and i.order_id=v_o.id;
 v_parcel_summary:=trim(coalesce(case when p_weight is not null then p_weight::text||' kg' end,'Parcel booked with the shipping provider')||case when p_length is not null or p_width is not null or p_height is not null then ' · '||coalesce(p_length::text,'?')||' × '||coalesce(p_width::text,'?')||' × '||coalesce(p_height::text,'?')||' cm' else '' end);
 if v_should_notify and v_o.customer_email is not null then
  v_idempotency:='order_dispatched:'||p_fulfilment_id::text;
  if not exists(select 1 from public.notification_queue q where q.idempotency_key=v_idempotency) then
   insert into public.notification_queue(tenant_id,event_code,recipient_email,recipient_name,subject,template_code,payload,status,attempts,idempotency_key,scheduled_for)
   values(p_tenant_id,'order_dispatched',v_o.customer_email,v_o.customer_name,'Your order is on its way','system_order_dispatched',jsonb_build_object('order_reference',v_o.order_reference,'item_summary',coalesce(v_item_summary,'Your order'),'shipping_service',coalesce(p_shipping_service,'—'),'carrier',coalesce(p_shipping_carrier,'—'),'tracking_number',coalesce(p_shipping_tracking_number,'—'),'tracking_url',coalesce(p_shipping_tracking_url,'—'),'parcel_summary',v_parcel_summary,'shipping_instructions',coalesce(p_shipping_instructions,'Your item is on its way. You can view the shipping details in your customer portal.'),'portal_url','https://laurendigitaluk.github.io/TradeFlow/customer-dashboard.html'),'queued',0,v_idempotency,now());
  end if;
 end if;
 return jsonb_build_object('ok',true,'fulfilment_id',p_fulfilment_id,'status','dispatched','parcel_id',v_parcel_id,'notification_queued',v_should_notify and v_o.customer_email is not null);
end;$function$;

REVOKE ALL
  ON FUNCTION
    "public"."subscriber_save_retail_fulfilment_shipping"(uuid, uuid, text, text, text, text, text, text, text, text, text, text, text, text, numeric, numeric, numeric, numeric,
    text)
  FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_save_shipping_provider_connection (
  p_tenant_id   uuid,
  p_provider    text,
  p_environment text,
  p_credentials jsonb,
  p_config      jsonb DEFAULT '{}'::jsonb
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private', 'vault'
  AS $function$
declare
  v_connection_id uuid;
  v_secret_id uuid;
  v_catalog record;
  v_secret jsonb;
  v_non_secret jsonb;
begin
  if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'tenant.manage') then
    raise exception 'Not authorised';
  end if;

  select * into v_catalog
  from public.shipping_provider_catalog
  where provider_code=p_provider and enabled=true
  limit 1;

  if not found then raise exception 'Shipping provider is not available'; end if;
  if p_environment not in ('sandbox','live') then raise exception 'Invalid environment'; end if;
  if coalesce(jsonb_typeof(p_credentials),'object') <> 'object' then raise exception 'Credentials must be an object'; end if;

  v_secret := coalesce(p_credentials,'{}'::jsonb);
  v_non_secret := coalesce(p_config,'{}'::jsonb) - 'credentials' - 'api_client_secret' - 'client_secret' - 'api_secret' - 'password' - 'secret_key' - 'api_key';

  v_secret_id := vault.create_secret(
    v_secret::text,
    'tradeflow_shipping_credentials_'||p_tenant_id::text||'_'||p_provider,
    'TradeFlow shipping credentials for '||v_catalog.provider_name
  );

  insert into public.shipping_provider_connections(
    tenant_id,provider,status,connection_type,display_name,auth_mode,metadata,
    environment,credentials_vault_id,updated_at
  )
  values(
    p_tenant_id,p_provider,'pending','subscriber_account',
    coalesce(nullif(trim(v_non_secret->>'display_name'),''),v_catalog.provider_name),
    v_catalog.connection_method,
    v_non_secret,
    p_environment,v_secret_id,now()
  )
  on conflict (tenant_id,provider) do update set
    status='pending',
    connection_type='subscriber_account',
    display_name=excluded.display_name,
    auth_mode=excluded.auth_mode,
    metadata=excluded.metadata,
    environment=excluded.environment,
    credentials_vault_id=excluded.credentials_vault_id,
    disconnected_at=null,
    updated_at=now()
  returning id into v_connection_id;

  return jsonb_build_object(
    'ok',true,
    'connection_id',v_connection_id,
    'provider',p_provider,
    'provider_name',v_catalog.provider_name,
    'status','pending',
    'adapter_status',v_catalog.adapter_status
  );
end
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_save_shipping_provider_connection"(uuid, text, text, jsonb, jsonb) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_save_shipping_services (
  p_tenant_id uuid,
  p_services  jsonb
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public'
  AS $function$
declare
  item jsonb;
  svc text;
  nm text;
  u text;
  enabled boolean;
  ord integer;
  saved integer := 0;
begin
  if not exists (
    select 1 from public.tenant_memberships m
    where m.tenant_id=p_tenant_id
      and m.user_id=auth.uid()
      and m.status='active'
      and m.role_code in ('owner','admin')
  ) then
    raise exception 'You do not have permission to change shipping settings.';
  end if;

  if jsonb_typeof(coalesce(p_services,'[]'::jsonb)) <> 'array' then
    raise exception 'Shipping services must be supplied as a list.';
  end if;

  delete from public.tenant_shipping_services where tenant_id=p_tenant_id;

  for item in select * from jsonb_array_elements(coalesce(p_services,'[]'::jsonb))
  loop
    svc := nullif(trim(item->>'service_code'),'');
    if svc is null then continue; end if;

    select service_name, service_url into nm, u
    from public.shipping_service_catalog
    where service_code=svc and active=true;

    if nm is null then
      continue;
    end if;

    u := coalesce(nullif(trim(item->>'service_url'),''), u);
    enabled := coalesce((item->>'enabled')::boolean, true);
    ord := coalesce((item->>'sort_order')::integer, 0);

    insert into public.tenant_shipping_services
      (tenant_id,service_code,service_name,service_url,enabled,sort_order)
    values
      (p_tenant_id,svc,nm,u,enabled,ord);

    saved := saved + 1;
  end loop;

  return jsonb_build_object('ok',true,'saved',saved);
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_save_shipping_services"(uuid, jsonb) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_start_buying_item_inspection (
  p_tenant_id      uuid,
  p_buying_item_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'public', 'private'
  AS $function$
declare v_stage text;
begin
  if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
  select purchase_stage into v_stage from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
  if v_stage is null then raise exception 'Buying item not found'; end if;
  if v_stage not in ('received','inspection') then raise exception 'Inspection can only start after the item has been received'; end if;
  update public.buying_items set purchase_stage='inspection',purchase_stage_updated_at=now(),updated_at=now() where tenant_id=p_tenant_id and id=p_buying_item_id;
  return jsonb_build_object('buying_item_id',p_buying_item_id,'status','inspection');
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_start_buying_item_inspection"(uuid, uuid) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.subscriber_transition_retail_fulfilment (
  p_tenant_id     uuid,
  p_fulfilment_id uuid,
  p_expected_from text,
  p_to_status     text,
  p_notes         text DEFAULT NULL::text
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_f public.fulfilments%rowtype;
  v_o public.retail_orders%rowtype;
  v_tracking_url text;
begin
  if auth.uid() is null
     or not private.has_tenant_permission(p_tenant_id,auth.uid(),'fulfilment.manage') then
    raise exception 'Not authorised to manage fulfilment';
  end if;

  select * into v_f
  from public.fulfilments
  where tenant_id=p_tenant_id and id=p_fulfilment_id
  for update;

  if not found then raise exception 'Fulfilment not found'; end if;

  if v_f.status<>p_expected_from then
    raise exception 'Fulfilment status changed. Refresh and try again.';
  end if;

  select * into v_o
  from public.retail_orders
  where tenant_id=p_tenant_id and id=v_f.retail_order_id
  for update;

  if not found then raise exception 'Retail order not found'; end if;

  if p_to_status not in ('dispatched','delivered','returned') then
    raise exception 'Invalid retail fulfilment transition: %',p_to_status;
  end if;

  if p_to_status='dispatched' then
    if v_o.status='paid' then
      perform public.transition_workflow_entity(
        p_tenant_id,
        'retail_order',
        v_o.id,
        'paid',
        'fulfilment',
        coalesce(p_notes,'Shipment dispatched.'),
        jsonb_build_object('source','selling-dashboard','fulfilment_id',p_fulfilment_id)
      );
    elsif v_o.status<>'fulfilment' then
      raise exception 'Retail order is not in a dispatchable state: %',v_o.status;
    end if;

    v_tracking_url:=nullif(trim(v_f.tracking_url),'');
    if v_tracking_url is null and nullif(trim(v_f.tracking_number),'') is not null then
      case lower(regexp_replace(coalesce(v_f.carrier,v_f.service,''),'[^a-z0-9]','','g'))
        when 'evri' then v_tracking_url:='https://www.evri.com/track-a-parcel';
        when 'royalmail' then v_tracking_url:='https://www.royalmail.com/track-your-item';
        when 'dpd' then v_tracking_url:='https://www.dpd.co.uk/track';
        when 'inpost' then v_tracking_url:='https://inpost.co.uk/tracking';
        when 'dhl' then v_tracking_url:='https://www.dhl.com/gb-en/home/tracking.html';
        when 'ups' then v_tracking_url:='https://www.ups.com/gb/en/track';
        when 'parcels2go' then v_tracking_url:='https://www.parcel2go.com/tracking';
        else null;
      end case;
    end if;

    perform public.transition_workflow_entity(
      p_tenant_id,
      'fulfilment',
      p_fulfilment_id,
      'label',
      'dispatched',
      coalesce(p_notes,'Shipment dispatched.'),
      jsonb_build_object('source','selling-dashboard','retail_order_id',v_o.id)
    );

    update public.fulfilments
    set tracking_url=coalesce(v_tracking_url,tracking_url),
        dispatched_at=coalesce(dispatched_at,now()),
        updated_at=now()
    where tenant_id=p_tenant_id and id=p_fulfilment_id;

    if v_o.customer_email is not null
       and not exists(
         select 1 from public.notification_queue q
         where q.idempotency_key='order_dispatched:'||p_fulfilment_id::text
       ) then
      insert into public.notification_queue(
        tenant_id,event_code,recipient_email,recipient_name,subject,template_code,
        payload,status,attempts,idempotency_key,scheduled_for
      )
      values(
        p_tenant_id,
        'order_dispatched',
        v_o.customer_email,
        v_o.customer_name,
        'Your order has been dispatched',
        'system_order_dispatched',
        jsonb_build_object(
          'order_reference',v_o.order_reference,
          'item_summary',(
            select string_agg(
              case when i.quantity>1 then i.quantity::text||' × ' else '' end||i.title,
              ', ' order by i.created_at
            )
            from public.retail_order_items i
            where i.tenant_id=p_tenant_id and i.order_id=v_o.id
          ),
          'shipping_service',coalesce(v_f.service,'—'),
          'carrier',coalesce(v_f.carrier,'—'),
          'tracking_number',coalesce(v_f.tracking_number,'—'),
          'tracking_url',coalesce(v_tracking_url,v_f.tracking_url,'—'),
          'shipping_instructions',coalesce(v_f.shipping_instructions,''),
          'portal_url','https://laurendigitaluk.github.io/TradeFlow/customer-dashboard.html'
        ),
        'queued',
        0,
        'order_dispatched:'||p_fulfilment_id::text,
        now()
      );
    end if;

  elsif p_to_status='delivered' then
    perform public.transition_workflow_entity(
      p_tenant_id,'fulfilment',p_fulfilment_id,
      'dispatched','delivered',
      coalesce(p_notes,'Fulfilment delivered.'),
      jsonb_build_object('source','retail_fulfilment_dashboard')
    );
  else
    perform public.transition_workflow_entity(
      p_tenant_id,'fulfilment',p_fulfilment_id,
      'dispatched','returned',
      coalesce(p_notes,'Fulfilment returned.'),
      jsonb_build_object('source','retail_fulfilment_dashboard')
    );
  end if;

  return jsonb_build_object(
    'ok',true,
    'fulfilment_id',p_fulfilment_id,
    'status',p_to_status,
    'retail_order_id',v_o.id,
    'retail_order_status',case when p_to_status='dispatched' then 'fulfilment' else v_o.status end,
    'tracking_url',coalesce(v_tracking_url,v_f.tracking_url)
  );
end;
$function$;

REVOKE ALL ON FUNCTION "public"."subscriber_transition_retail_fulfilment"(uuid, uuid, text, text, text) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.sync_category_branch_reference()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'public', 'pg_catalog'
  AS $function$
declare
  resolved_branch uuid;
begin
  if new.branch_id is null then
    select b.id into resolved_branch
    from public.category_branches b
    where b.tenant_id=new.tenant_id
      and b.category_id=new.category_id
      and b.active=true
    order by b.sort_order, b.created_at
    limit 1;
    if resolved_branch is null then
      raise exception 'No active branch exists for category %', new.category_id;
    end if;
    new.branch_id=resolved_branch;
  else
    if not exists (
      select 1 from public.category_branches b
      where b.tenant_id=new.tenant_id
        and b.category_id=new.category_id
        and b.id=new.branch_id
    ) then
      raise exception 'Branch % does not belong to category %', new.branch_id, new.category_id;
    end if;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.sync_retail_order_payment_status()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if NEW.status='paid' then NEW.payment_status:='paid';
  elsif NEW.status='partially_refunded' then NEW.payment_status:='partially_refunded';
  elsif NEW.status='refunded' then NEW.payment_status:='refunded';
  end if;
  return NEW;
end;
$function$;

CREATE OR REPLACE FUNCTION public.test_lab_current_customer()
  RETURNS TABLE (
    customer_id uuid,
    tenant_id   uuid,
    tenant_slug text,
    first_name  text,
    last_name   text,
    email       text
  )
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select c.id, c.tenant_id, t.slug, c.first_name, c.last_name, c.email
  from public.customers c
  join public.tenants t on t.id = c.tenant_id
  where c.auth_user_id = auth.uid()
    and c.status = 'active'
    and t.status = 'active'
    and coalesce((t.settings->>'test_lab')::boolean, false) = true
  limit 2;
$function$;

REVOKE ALL ON FUNCTION "public"."test_lab_current_customer"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.test_lab_current_customer_v2()
  RETURNS TABLE (
    customer_id uuid,
    tenant_id   uuid,
    tenant_slug text,
    first_name  text,
    last_name   text,
    email       text
  )
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
  select c.id, c.tenant_id, t.slug, c.first_name, c.last_name, c.email
  from public.customers c
  join public.tenants t on t.id = c.tenant_id
  where c.auth_user_id = auth.uid()
    and c.status = 'active'
    and t.status = 'active'
    and (t.slug = 'test-business-a' or t.slug = 'test-business-b')
  limit 2;
$function$;

REVOKE ALL ON FUNCTION "public"."test_lab_current_customer_v2"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.touch_tenant_buying_products_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."touch_tenant_buying_products_updated_at"() FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.touch_tenant_public_profile_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO ''
  AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.transition_workflow_entity (
  p_tenant_id     uuid,
  p_entity_type   text,
  p_entity_id     uuid,
  p_expected_from text,
  p_to_status     text,
  p_notes         text  DEFAULT NULL::text,
  p_metadata      jsonb DEFAULT '{}'::jsonb
)
  RETURNS boolean
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
declare
  v_actor uuid := auth.uid(); v_from text; v_permission text; v_feature_ok boolean := false;
begin
  if v_actor is null or not private.is_tenant_member(p_tenant_id,v_actor) then raise exception 'Tenant membership required'; end if;
  v_permission := case p_entity_type
    when 'buying_request' then 'buying.manage' when 'buying_item' then 'buying.manage' when 'trading_value' then 'valuation.manage' when 'offer' then 'offers.manage'
    when 'acquisition' then 'acquisitions.manage' when 'acquisition_item' then 'acquisitions.manage' when 'inventory_asset' then 'inventory.manage'
    when 'listing' then 'selling.manage' when 'retail_order' then 'orders.manage' when 'fulfilment' then 'fulfilment.manage' when 'acquisition_fulfilment' then 'fulfilment.manage'
    when 'return' then 'returns.manage' when 'trade_in' then 'buying.manage' when 'payment_record' then 'finance.manage' when 'ledger_entry' then 'finance.manage' else null end;
  if v_permission is null then raise exception 'Unsupported workflow entity type: %',p_entity_type; end if;
  if not private.has_tenant_permission(p_tenant_id,v_actor,v_permission) then raise exception 'Permission required: %',v_permission; end if;
  v_feature_ok := case p_entity_type
    when 'buying_request' then private.has_tenant_feature(p_tenant_id,'module.buying') when 'buying_item' then private.has_tenant_feature(p_tenant_id,'module.buying')
    when 'trading_value' then private.has_tenant_feature(p_tenant_id,'module.valuation') when 'offer' then private.has_tenant_feature(p_tenant_id,'module.offers')
    when 'acquisition' then private.has_tenant_feature(p_tenant_id,'module.buying') when 'acquisition_item' then private.has_tenant_feature(p_tenant_id,'module.buying')
    when 'inventory_asset' then private.has_tenant_feature(p_tenant_id,'module.inventory') when 'listing' then private.has_tenant_feature(p_tenant_id,'module.selling')
    when 'retail_order' then private.has_tenant_feature(p_tenant_id,'module.orders') when 'fulfilment' then private.has_tenant_feature(p_tenant_id,'module.fulfilment')
    when 'acquisition_fulfilment' then private.has_tenant_feature(p_tenant_id,'module.fulfilment') when 'return' then (private.has_tenant_feature(p_tenant_id,'module.buying') or private.has_tenant_feature(p_tenant_id,'module.orders'))
    when 'trade_in' then private.has_tenant_feature(p_tenant_id,'module.trade_in') when 'payment_record' then true when 'ledger_entry' then true else false end;
  if not v_feature_ok then raise exception 'Subscription capability required for workflow entity: %',p_entity_type; end if;
  if p_expected_from=p_to_status then raise exception 'Workflow status must change'; end if;
  if not (
    (p_entity_type='buying_request' and ((p_expected_from='draft' and p_to_status='submitted') or (p_expected_from='submitted' and p_to_status='under_review') or (p_expected_from='under_review' and p_to_status='valued') or (p_expected_from='valued' and p_to_status='offer_ready') or (p_expected_from in ('submitted','under_review','valued','offer_ready') and p_to_status='closed'))) or
    (p_entity_type='buying_item' and ((p_expected_from='draft' and p_to_status='submitted') or (p_expected_from='submitted' and p_to_status='under_review') or (p_expected_from='under_review' and p_to_status='valued') or (p_expected_from='valued' and p_to_status='offer_ready') or (p_expected_from in ('submitted','under_review','valued','offer_ready') and p_to_status='closed'))) or
    (p_entity_type='trading_value' and ((p_expected_from='draft' and p_to_status='approved') or (p_expected_from='approved' and p_to_status='superseded'))) or
    (p_entity_type='offer' and ((p_expected_from='draft' and p_to_status='published') or (p_expected_from='published' and p_to_status in ('accepted','refused','withdrawn','superseded')))) or
    (p_entity_type='acquisition' and ((p_expected_from='accepted' and p_to_status in ('awaiting_item','cancelled')) or (p_expected_from='awaiting_item' and p_to_status in ('received','cancelled')) or (p_expected_from='received' and p_to_status='inspection') or (p_expected_from='inspection' and p_to_status='finalised') or (p_expected_from='finalised' and p_to_status='paid') or (p_expected_from='paid' and p_to_status='completed'))) or
    (p_entity_type='acquisition_item' and ((p_expected_from='accepted' and p_to_status in ('awaiting_item','cancelled')) or (p_expected_from='awaiting_item' and p_to_status in ('received','cancelled')) or (p_expected_from='received' and p_to_status='inspection') or (p_expected_from='inspection' and p_to_status='finalised') or (p_expected_from='finalised' and p_to_status='paid') or (p_expected_from='paid' and p_to_status='completed'))) or
    (p_entity_type='inventory_asset' and ((p_expected_from='received' and p_to_status='inspection') or (p_expected_from='inspection' and p_to_status in ('testing','ready_for_sale')) or (p_expected_from='testing' and p_to_status in ('repair','ready_for_sale')) or (p_expected_from='repair' and p_to_status in ('testing','ready_for_sale')) or (p_expected_from='ready_for_sale' and p_to_status='listed') or (p_expected_from='listed' and p_to_status in ('reserved','sold')) or (p_expected_from='reserved' and p_to_status in ('listed','sold')) or (p_expected_from='sold' and p_to_status='returned') or (p_expected_from='returned' and p_to_status in ('inspection','written_off','archived')) or (p_expected_from='written_off' and p_to_status='archived'))) or
    (p_entity_type='listing' and ((p_expected_from='draft' and p_to_status='ready') or (p_expected_from='ready' and p_to_status='published') or (p_expected_from='published' and p_to_status in ('reserved','sold','delisted')) or (p_expected_from='reserved' and p_to_status in ('published','sold','delisted')))) or
    (p_entity_type='retail_order' and ((p_expected_from='initiated' and p_to_status='pending_payment') or (p_expected_from='pending_payment' and p_to_status in ('paid','cancelled')) or (p_expected_from='paid' and p_to_status in ('fulfilment','cancelled','refunded','partially_refunded')) or (p_expected_from='fulfilment' and p_to_status in ('completed','cancelled','refunded','partially_refunded')) or (p_expected_from='completed' and p_to_status in ('refunded','partially_refunded')) or (p_expected_from='partially_refunded' and p_to_status in ('refunded','completed')))) or
    (p_entity_type='fulfilment' and ((p_expected_from='awaiting' and p_to_status='label') or (p_expected_from='label' and p_to_status='dispatched') or (p_expected_from='dispatched' and p_to_status in ('delivered','returned')) or (p_expected_from='delivered' and p_to_status='returned'))) or
    (p_entity_type='acquisition_fulfilment' and ((p_expected_from='awaiting' and p_to_status='label') or (p_expected_from='label' and p_to_status='dispatched') or (p_expected_from='dispatched' and p_to_status in ('delivered','returned')) or (p_expected_from='delivered' and p_to_status='returned'))) or
    (p_entity_type='return' and ((p_expected_from='requested' and p_to_status in ('authorised','rejected','closed')) or (p_expected_from='authorised' and p_to_status='awaiting_return') or (p_expected_from='awaiting_return' and p_to_status='received') or (p_expected_from='received' and p_to_status='inspected') or (p_expected_from='inspected' and p_to_status in ('approved','rejected')) or (p_expected_from='approved' and p_to_status in ('refunded','replaced','closed')) or (p_expected_from in ('refunded','replaced','rejected') and p_to_status='closed'))) or
    (p_entity_type='trade_in' and ((p_expected_from='valuation_requested' and p_to_status='valued') or (p_expected_from='valued' and p_to_status='offer_pending') or (p_expected_from='offer_pending' and p_to_status in ('accepted','rejected','cancelled')) or (p_expected_from='accepted' and p_to_status='item_awaiting') or (p_expected_from='item_awaiting' and p_to_status='received') or (p_expected_from='received' and p_to_status='inspection') or (p_expected_from='inspection' and p_to_status in ('approved','rejected')) or (p_expected_from='approved' and p_to_status='credited') or (p_expected_from='credited' and p_to_status='completed'))) or
    (p_entity_type='payment_record' and ((p_expected_from='pending' and p_to_status in ('processing','cancelled')) or (p_expected_from='processing' and p_to_status in ('paid','failed','cancelled')) or (p_expected_from='paid' and p_to_status in ('refunded','partially_refunded')) or (p_expected_from='partially_refunded' and p_to_status='refunded'))) or
    (p_entity_type='ledger_entry' and ((p_expected_from='pending' and p_to_status='posted') or (p_expected_from='posted' and p_to_status in ('voided','reversed'))))
  ) then raise exception 'Invalid workflow transition: % % -> %',p_entity_type,p_expected_from,p_to_status; end if;
  case p_entity_type
    when 'payment_record' then update public.payment_records set status=p_to_status, processed_at=case when p_to_status in ('paid','failed','cancelled','refunded','partially_refunded') then coalesce(processed_at,now()) else processed_at end, updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'ledger_entry' then update public.ledger_entries set status=p_to_status, posted_at=case when p_to_status='posted' then coalesce(posted_at,now()) else posted_at end, updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'buying_request' then update public.buying_requests set status=p_to_status,submitted_at=case when p_to_status='submitted' then coalesce(submitted_at,now()) else submitted_at end,closed_at=case when p_to_status='closed' then coalesce(closed_at,now()) else closed_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'buying_item' then update public.buying_items set status=p_to_status,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'trading_value' then update public.trading_values set status=p_to_status,approved_at=case when p_to_status='approved' then coalesce(approved_at,now()) else approved_at end,approved_by=case when p_to_status='approved' then v_actor else approved_by end,superseded_at=case when p_to_status='superseded' then coalesce(superseded_at,now()) else superseded_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'offer' then update public.offers set status=p_to_status,published_at=case when p_to_status='published' then coalesce(published_at,now()) else published_at end,responded_at=case when p_to_status in ('accepted','refused','withdrawn') then coalesce(responded_at,now()) else responded_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'acquisition' then update public.acquisitions set status=p_to_status,received_at=case when p_to_status='received' then coalesce(received_at,now()) else received_at end,finalised_at=case when p_to_status='finalised' then coalesce(finalised_at,now()) else finalised_at end,paid_at=case when p_to_status='paid' then coalesce(paid_at,now()) else paid_at end,completed_at=case when p_to_status='completed' then coalesce(completed_at,now()) else completed_at end,cancelled_at=case when p_to_status='cancelled' then coalesce(cancelled_at,now()) else cancelled_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'acquisition_item' then update public.acquisition_items set status=p_to_status,received_at=case when p_to_status='received' then coalesce(received_at,now()) else received_at end,finalised_at=case when p_to_status='finalised' then coalesce(finalised_at,now()) else finalised_at end,paid_at=case when p_to_status='paid' then coalesce(paid_at,now()) else paid_at end,completed_at=case when p_to_status='completed' then coalesce(completed_at,now()) else completed_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'inventory_asset' then update public.inventory_assets set status=p_to_status,received_at=case when p_to_status='received' then coalesce(received_at,now()) else received_at end,ready_for_sale_at=case when p_to_status='ready_for_sale' then coalesce(ready_for_sale_at,now()) else ready_for_sale_at end,sold_at=case when p_to_status='sold' then coalesce(sold_at,now()) else sold_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'listing' then update public.listings set status=p_to_status,published_at=case when p_to_status='published' then coalesce(published_at,now()) else published_at end,reserved_at=case when p_to_status='reserved' then coalesce(reserved_at,now()) else reserved_at end,sold_at=case when p_to_status='sold' then coalesce(sold_at,now()) else sold_at end,delisted_at=case when p_to_status='delisted' then coalesce(delisted_at,now()) else delisted_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'retail_order' then update public.retail_orders set status=p_to_status,placed_at=case when p_to_status not in ('initiated','pending_payment') then coalesce(placed_at,now()) else placed_at end,paid_at=case when p_to_status='paid' then coalesce(paid_at,now()) else paid_at end,completed_at=case when p_to_status='completed' then coalesce(completed_at,now()) else completed_at end,cancelled_at=case when p_to_status='cancelled' then coalesce(cancelled_at,now()) else cancelled_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'fulfilment' then update public.fulfilments set status=p_to_status,dispatched_at=case when p_to_status='dispatched' then coalesce(dispatched_at,now()) else dispatched_at end,delivered_at=case when p_to_status='delivered' then coalesce(delivered_at,now()) else delivered_at end,returned_at=case when p_to_status='returned' then coalesce(returned_at,now()) else returned_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'acquisition_fulfilment' then update public.acquisition_fulfilments set status=p_to_status,dispatched_at=case when p_to_status='dispatched' then coalesce(dispatched_at,now()) else dispatched_at end,delivered_at=case when p_to_status='delivered' then coalesce(delivered_at,now()) else delivered_at end,returned_at=case when p_to_status='returned' then coalesce(returned_at,now()) else returned_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'return' then update public.returns set status=p_to_status,authorised_at=case when p_to_status='authorised' then coalesce(authorised_at,now()) else authorised_at end,received_at=case when p_to_status='received' then coalesce(received_at,now()) else received_at end,inspected_at=case when p_to_status='inspected' then coalesce(inspected_at,now()) else inspected_at end,resolved_at=case when p_to_status in ('refunded','replaced','rejected') then coalesce(resolved_at,now()) else resolved_at end,closed_at=case when p_to_status='closed' then coalesce(closed_at,now()) else closed_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
    when 'trade_in' then update public.trade_in_transactions set status=p_to_status,valued_at=case when p_to_status='valued' then coalesce(valued_at,now()) else valued_at end,accepted_at=case when p_to_status='accepted' then coalesce(accepted_at,now()) else accepted_at end,received_at=case when p_to_status='received' then coalesce(received_at,now()) else received_at end,credited_at=case when p_to_status='credited' then coalesce(credited_at,now()) else credited_at end,completed_at=case when p_to_status='completed' then coalesce(completed_at,now()) else completed_at end,cancelled_at=case when p_to_status='cancelled' then coalesce(cancelled_at,now()) else cancelled_at end,updated_at=now() where tenant_id=p_tenant_id and id=p_entity_id and status=p_expected_from returning status into v_from;
  end case;
  if v_from is null then raise exception 'Workflow transition rejected: entity missing or current status is not %',p_expected_from; end if;
  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata) values(p_tenant_id,p_entity_type,p_entity_id,p_expected_from,p_to_status,v_actor,p_notes,coalesce(p_metadata,'{}'::jsonb));
  return true;
end;$function$;

REVOKE ALL ON FUNCTION "public"."transition_workflow_entity"(uuid, text, uuid, text, text, text, jsonb) FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.validate_published_offer_valuation()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SET search_path TO 'pg_catalog', 'public'
  AS $function$
begin
  if new.status = 'published' then
    if not exists (
      select 1
      from public.trading_values tv
      where tv.tenant_id = new.tenant_id
        and tv.id = new.trading_value_id
        and tv.buying_item_id = new.buying_item_id
        and tv.status = 'approved'
    ) then
      raise exception 'Published offer requires an approved valuation for the same buying item';
    end if;
  end if;
  return new;
end;
$function$;

ALTER TABLE "public"."acquisition_fulfilments"
  ADD CONSTRAINT "acquisition_fulfilments_tenant_id_acquisition_item_id_fkey" FOREIGN KEY (tenant_id, acquisition_item_id) REFERENCES public.acquisition_items(tenant_id, id)
    ON DELETE RESTRICT;

ALTER TABLE "public"."acquisitions"
  ADD CONSTRAINT "acquisitions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."acquisition_fulfilments"
  ADD CONSTRAINT "acquisition_fulfilments_tenant_id_acquisition_id_fkey" FOREIGN KEY (tenant_id, acquisition_id) REFERENCES public.acquisitions(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."acquisition_items"
  ADD CONSTRAINT "acquisition_items_tenant_id_acquisition_id_fkey" FOREIGN KEY (tenant_id, acquisition_id) REFERENCES public.acquisitions(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."buying_item_inspections"
  ADD CONSTRAINT "buying_item_inspections_buying_item_id_fkey" FOREIGN KEY (buying_item_id) REFERENCES public.buying_items(id) ON DELETE CASCADE;

ALTER TABLE "public"."buying_item_return_shipping"
  ADD CONSTRAINT "buying_item_return_shipping_buying_item_id_fkey" FOREIGN KEY (buying_item_id) REFERENCES public.buying_items(id) ON DELETE CASCADE;

ALTER TABLE "public"."buying_item_shipping"
  ADD CONSTRAINT "buying_item_shipping_buying_item_id_fkey" FOREIGN KEY (buying_item_id) REFERENCES public.buying_items(id) ON DELETE CASCADE;

ALTER TABLE "public"."acquisition_items"
  ADD CONSTRAINT "acquisition_items_tenant_id_buying_item_id_fkey" FOREIGN KEY (tenant_id, buying_item_id) REFERENCES public.buying_items(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."buying_item_field_values"
  ADD CONSTRAINT "buying_item_field_values_tenant_id_buying_item_id_fkey" FOREIGN KEY (tenant_id, buying_item_id) REFERENCES public.buying_items(tenant_id, id) ON DELETE CASCADE;

ALTER TABLE "public"."buying_item_media"
  ADD CONSTRAINT "buying_item_media_tenant_id_buying_item_id_fkey" FOREIGN KEY (tenant_id, buying_item_id) REFERENCES public.buying_items(tenant_id, id) ON DELETE CASCADE;

ALTER TABLE "public"."buying_items"
  ADD CONSTRAINT "buying_items_tenant_id_buying_request_id_fkey" FOREIGN KEY (tenant_id, buying_request_id) REFERENCES public.buying_requests(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."catalogue_master_branches"
  ADD CONSTRAINT "catalogue_master_branches_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.catalogue_master_categories(id) ON DELETE CASCADE;

ALTER TABLE "public"."catalogue_master_products"
  ADD CONSTRAINT "catalogue_master_products_branch_id_fkey" FOREIGN KEY (branch_id) REFERENCES public.catalogue_master_branches(id) ON DELETE RESTRICT;

ALTER TABLE "public"."catalogue_master_products"
  ADD CONSTRAINT "catalogue_master_products_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.catalogue_master_categories(id) ON DELETE RESTRICT;

ALTER TABLE "public"."catalogue_master_products"
  ADD CONSTRAINT "catalogue_master_products_manufacturer_id_fkey" FOREIGN KEY (manufacturer_id) REFERENCES public.catalogue_master_manufacturers(id) ON DELETE RESTRICT;

ALTER TABLE "public"."catalogue_master_product_identifiers"
  ADD CONSTRAINT "catalogue_master_product_identifiers_product_id_fkey" FOREIGN KEY (product_id) REFERENCES public.catalogue_master_products(id) ON DELETE CASCADE;

ALTER TABLE "public"."buying_items"
  ADD CONSTRAINT "buying_items_tenant_id_category_id_fkey" FOREIGN KEY (tenant_id, category_id) REFERENCES public.categories(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."category_branches"
  ADD CONSTRAINT "category_branches_tenant_id_category_id_fkey" FOREIGN KEY (tenant_id, category_id) REFERENCES public.categories(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."buying_items"
  ADD CONSTRAINT "buying_items_tenant_branch_fk" FOREIGN KEY (tenant_id, branch_id) REFERENCES public.category_branches(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."category_field_options"
  ADD CONSTRAINT "category_field_options_tenant_id_category_id_fkey" FOREIGN KEY (tenant_id, category_id) REFERENCES public.categories(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."category_fields"
  ADD CONSTRAINT "category_fields_tenant_branch_fk" FOREIGN KEY (tenant_id, branch_id) REFERENCES public.category_branches(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."category_fields"
  ADD CONSTRAINT "category_fields_tenant_id_category_id_fkey" FOREIGN KEY (tenant_id, category_id) REFERENCES public.categories(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."buying_item_field_values"
  ADD CONSTRAINT "buying_item_field_values_tenant_id_field_id_fkey" FOREIGN KEY (tenant_id, field_id) REFERENCES public.category_fields(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."category_field_options"
  ADD CONSTRAINT "category_field_options_tenant_id_field_id_fkey" FOREIGN KEY (tenant_id, field_id) REFERENCES public.category_fields(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."customers"
  ADD CONSTRAINT "customers_auth_user_id_fkey" FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."customer_bank_details"
  ADD CONSTRAINT "customer_bank_details_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;

ALTER TABLE "public"."customer_credit_holds"
  ADD CONSTRAINT "customer_credit_holds_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;

ALTER TABLE "public"."acquisitions"
  ADD CONSTRAINT "acquisitions_tenant_id_customer_id_fkey" FOREIGN KEY (tenant_id, customer_id) REFERENCES public.customers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."buying_requests"
  ADD CONSTRAINT "buying_requests_tenant_id_customer_id_fkey" FOREIGN KEY (tenant_id, customer_id) REFERENCES public.customers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."customer_addresses"
  ADD CONSTRAINT "customer_addresses_tenant_id_customer_id_fkey" FOREIGN KEY (tenant_id, customer_id) REFERENCES public.customers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."customer_credit_accounts"
  ADD CONSTRAINT "customer_credit_accounts_tenant_id_customer_id_fkey" FOREIGN KEY (tenant_id, customer_id) REFERENCES public.customers(tenant_id, id) ON DELETE CASCADE;

ALTER TABLE "public"."fulfilment_events"
  ADD CONSTRAINT "fulfilment_events_tenant_id_parcel_id_fkey" FOREIGN KEY (tenant_id, parcel_id) REFERENCES public.fulfilment_parcels(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."fulfilment_events"
  ADD CONSTRAINT "fulfilment_events_tenant_id_fulfilment_id_fkey" FOREIGN KEY (tenant_id, fulfilment_id) REFERENCES public.fulfilments(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."fulfilment_parcels"
  ADD CONSTRAINT "fulfilment_parcels_tenant_id_fulfilment_id_fkey" FOREIGN KEY (tenant_id, fulfilment_id) REFERENCES public.fulfilments(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."inventory_assets"
  ADD CONSTRAINT "inventory_assets_catalogue_product_id_fkey" FOREIGN KEY (catalogue_product_id) REFERENCES public.catalogue_master_products(id);

ALTER TABLE "public"."inventory_assets"
  ADD CONSTRAINT "inventory_assets_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."inventory_assets"
  ADD CONSTRAINT "inventory_assets_tenant_branch_fk" FOREIGN KEY (tenant_id, branch_id) REFERENCES public.category_branches(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."inventory_assets"
  ADD CONSTRAINT "inventory_assets_tenant_id_acquisition_item_id_fkey" FOREIGN KEY (tenant_id, acquisition_item_id) REFERENCES public.acquisition_items(tenant_id, id)
    ON DELETE RESTRICT;

ALTER TABLE "public"."inventory_assets"
  ADD CONSTRAINT "inventory_assets_tenant_id_buying_item_id_fkey" FOREIGN KEY (tenant_id, buying_item_id) REFERENCES public.buying_items(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."inventory_assets"
  ADD CONSTRAINT "inventory_assets_tenant_id_category_id_fkey" FOREIGN KEY (tenant_id, category_id) REFERENCES public.categories(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."inventory_asset_media"
  ADD CONSTRAINT "inventory_asset_media_tenant_inventory_fk" FOREIGN KEY (tenant_id, inventory_asset_id) REFERENCES public.inventory_assets(tenant_id, id) ON DELETE CASCADE;

ALTER TABLE "public"."inventory_costs"
  ADD CONSTRAINT "inventory_costs_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."inventory_costs"
  ADD CONSTRAINT "inventory_costs_tenant_id_inventory_asset_id_fkey" FOREIGN KEY (tenant_id, inventory_asset_id) REFERENCES public.inventory_assets(tenant_id, id)
    ON DELETE RESTRICT;

ALTER TABLE "public"."inventory_inspections"
  ADD CONSTRAINT "inventory_inspections_inspected_by_fkey" FOREIGN KEY (inspected_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."inventory_inspections"
  ADD CONSTRAINT "inventory_inspections_tenant_id_inventory_asset_id_fkey" FOREIGN KEY (tenant_id, inventory_asset_id) REFERENCES public.inventory_assets(tenant_id, id)
    ON DELETE RESTRICT;

ALTER TABLE "public"."inventory_movements"
  ADD CONSTRAINT "inventory_movements_actor_user_id_fkey" FOREIGN KEY (actor_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."inventory_movements"
  ADD CONSTRAINT "inventory_movements_tenant_id_inventory_asset_id_fkey" FOREIGN KEY (tenant_id, inventory_asset_id) REFERENCES public.inventory_assets(tenant_id, id)
    ON DELETE RESTRICT;

ALTER TABLE "public"."ledger_entries"
  ADD CONSTRAINT "ledger_entries_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."ledger_entries"
  ADD CONSTRAINT "ledger_entries_tenant_id_acquisition_id_fkey" FOREIGN KEY (tenant_id, acquisition_id) REFERENCES public.acquisitions(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."ledger_entries"
  ADD CONSTRAINT "ledger_entries_tenant_id_customer_id_fkey" FOREIGN KEY (tenant_id, customer_id) REFERENCES public.customers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."ledger_entries"
  ADD CONSTRAINT "ledger_entries_tenant_id_inventory_asset_id_fkey" FOREIGN KEY (tenant_id, inventory_asset_id) REFERENCES public.inventory_assets(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."listing_events"
  ADD CONSTRAINT "listing_events_actor_user_id_fkey" FOREIGN KEY (actor_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."listings"
  ADD CONSTRAINT "listings_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."listings"
  ADD CONSTRAINT "listings_tenant_branch_fk" FOREIGN KEY (tenant_id, branch_id) REFERENCES public.category_branches(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."listings"
  ADD CONSTRAINT "listings_tenant_id_asset_id_fkey" FOREIGN KEY (tenant_id, asset_id) REFERENCES public.inventory_assets(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."listings"
  ADD CONSTRAINT "listings_tenant_id_category_id_fkey" FOREIGN KEY (tenant_id, category_id) REFERENCES public.categories(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."listing_events"
  ADD CONSTRAINT "listing_events_tenant_id_listing_id_fkey" FOREIGN KEY (tenant_id, listing_id) REFERENCES public.listings(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."listing_media"
  ADD CONSTRAINT "listing_media_tenant_listing_fk" FOREIGN KEY (tenant_id, listing_id) REFERENCES public.listings(tenant_id, id) ON DELETE CASCADE;

ALTER TABLE "public"."media_assets"
  ADD CONSTRAINT "media_assets_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."buying_item_media"
  ADD CONSTRAINT "buying_item_media_tenant_id_media_asset_id_fkey" FOREIGN KEY (tenant_id, media_asset_id) REFERENCES public.media_assets(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."inventory_asset_media"
  ADD CONSTRAINT "inventory_asset_media_tenant_media_fk" FOREIGN KEY (tenant_id, media_asset_id) REFERENCES public.media_assets(tenant_id, id) ON DELETE CASCADE;

ALTER TABLE "public"."listing_media"
  ADD CONSTRAINT "listing_media_tenant_media_fk" FOREIGN KEY (tenant_id, media_asset_id) REFERENCES public.media_assets(tenant_id, id) ON DELETE CASCADE;

ALTER TABLE "public"."notification_events"
  ADD CONSTRAINT "notification_events_tenant_id_notification_id_fkey" FOREIGN KEY (tenant_id, notification_id) REFERENCES public.notification_queue(tenant_id, id) ON DELETE
    SET NULL;

ALTER TABLE "public"."offer_events"
  ADD CONSTRAINT "offer_events_actor_user_id_fkey" FOREIGN KEY (actor_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."offers"
  ADD CONSTRAINT "offers_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."offers"
  ADD CONSTRAINT "offers_tenant_id_buying_item_id_fkey" FOREIGN KEY (tenant_id, buying_item_id) REFERENCES public.buying_items(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."acquisition_items"
  ADD CONSTRAINT "acquisition_items_tenant_id_offer_id_fkey" FOREIGN KEY (tenant_id, offer_id) REFERENCES public.offers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."acquisitions"
  ADD CONSTRAINT "acquisitions_tenant_id_source_offer_id_fkey" FOREIGN KEY (tenant_id, source_offer_id) REFERENCES public.offers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."offer_events"
  ADD CONSTRAINT "offer_events_tenant_id_offer_id_fkey" FOREIGN KEY (tenant_id, offer_id) REFERENCES public.offers(tenant_id, id) ON DELETE CASCADE;

ALTER TABLE "public"."payment_provider_customers"
  ADD CONSTRAINT "payment_provider_customers_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;

ALTER TABLE "public"."payment_provider_customers"
  ADD CONSTRAINT "payment_provider_customers_tenant_id_connection_id_fkey" FOREIGN KEY (tenant_id, connection_id) REFERENCES public.payment_provider_connections(tenant_id, id)
    ON DELETE CASCADE;

ALTER TABLE "public"."payment_records"
  ADD CONSTRAINT "payment_records_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."payment_records"
  ADD CONSTRAINT "payment_records_tenant_id_acquisition_id_fkey" FOREIGN KEY (tenant_id, acquisition_id) REFERENCES public.acquisitions(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."payment_records"
  ADD CONSTRAINT "payment_records_tenant_id_customer_id_fkey" FOREIGN KEY (tenant_id, customer_id) REFERENCES public.customers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."plan_features"
  ADD CONSTRAINT "plan_features_plan_id_fkey" FOREIGN KEY (plan_id) REFERENCES public.plans(id) ON DELETE CASCADE;

ALTER TABLE "public"."platform_memberships"
  ADD CONSTRAINT "platform_memberships_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE RESTRICT;

ALTER TABLE "public"."retail_order_items"
  ADD CONSTRAINT "retail_order_items_tenant_id_inventory_asset_id_fkey" FOREIGN KEY (tenant_id, inventory_asset_id) REFERENCES public.inventory_assets(tenant_id, id)
    ON DELETE RESTRICT;

ALTER TABLE "public"."retail_order_items"
  ADD CONSTRAINT "retail_order_items_tenant_id_listing_id_fkey" FOREIGN KEY (tenant_id, listing_id) REFERENCES public.listings(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."customer_credit_holds"
  ADD CONSTRAINT "customer_credit_holds_retail_order_id_fkey" FOREIGN KEY (retail_order_id) REFERENCES public.retail_orders(id) ON DELETE CASCADE;

ALTER TABLE "public"."retail_orders"
  ADD CONSTRAINT "retail_orders_tenant_id_customer_id_fkey" FOREIGN KEY (tenant_id, customer_id) REFERENCES public.customers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."fulfilments"
  ADD CONSTRAINT "fulfilments_tenant_id_retail_order_id_fkey" FOREIGN KEY (tenant_id, retail_order_id) REFERENCES public.retail_orders(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."ledger_entries"
  ADD CONSTRAINT "ledger_entries_tenant_id_retail_order_id_fkey" FOREIGN KEY (tenant_id, retail_order_id) REFERENCES public.retail_orders(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."payment_records"
  ADD CONSTRAINT "payment_records_tenant_id_retail_order_id_fkey" FOREIGN KEY (tenant_id, retail_order_id) REFERENCES public.retail_orders(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."retail_order_items"
  ADD CONSTRAINT "retail_order_items_tenant_id_order_id_fkey" FOREIGN KEY (tenant_id, order_id) REFERENCES public.retail_orders(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."retail_order_trade_ins"
  ADD CONSTRAINT "retail_order_trade_ins_tenant_id_retail_order_id_fkey" FOREIGN KEY (tenant_id, retail_order_id) REFERENCES public.retail_orders(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."return_events"
  ADD CONSTRAINT "return_events_actor_user_id_fkey" FOREIGN KEY (actor_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."return_resolutions"
  ADD CONSTRAINT "return_resolutions_resolved_by_fkey" FOREIGN KEY (resolved_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."returns"
  ADD CONSTRAINT "returns_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."returns"
  ADD CONSTRAINT "returns_tenant_id_acquisition_id_fkey" FOREIGN KEY (tenant_id, acquisition_id) REFERENCES public.acquisitions(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."returns"
  ADD CONSTRAINT "returns_tenant_id_acquisition_item_id_fkey" FOREIGN KEY (tenant_id, acquisition_item_id) REFERENCES public.acquisition_items(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."returns"
  ADD CONSTRAINT "returns_tenant_id_customer_id_fkey" FOREIGN KEY (tenant_id, customer_id) REFERENCES public.customers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."ledger_entries"
  ADD CONSTRAINT "ledger_entries_tenant_id_return_id_fkey" FOREIGN KEY (tenant_id, return_id) REFERENCES public.returns(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."payment_records"
  ADD CONSTRAINT "payment_records_tenant_id_return_id_fkey" FOREIGN KEY (tenant_id, return_id) REFERENCES public.returns(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."return_events"
  ADD CONSTRAINT "return_events_tenant_id_return_id_fkey" FOREIGN KEY (tenant_id, return_id) REFERENCES public.returns(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."return_resolutions"
  ADD CONSTRAINT "return_resolutions_tenant_id_return_id_fkey" FOREIGN KEY (tenant_id, return_id) REFERENCES public.returns(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."returns"
  ADD CONSTRAINT "returns_tenant_id_inventory_asset_id_fkey" FOREIGN KEY (tenant_id, inventory_asset_id) REFERENCES public.inventory_assets(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."returns"
  ADD CONSTRAINT "returns_tenant_id_order_id_fkey" FOREIGN KEY (tenant_id, order_id) REFERENCES public.retail_orders(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."returns"
  ADD CONSTRAINT "returns_tenant_id_order_item_id_fkey" FOREIGN KEY (tenant_id, order_item_id) REFERENCES public.retail_order_items(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."role_permissions"
  ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;

ALTER TABLE "public"."role_permissions"
  ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;

ALTER TABLE "public"."listings"
  ADD CONSTRAINT "listings_tenant_id_channel_id_fkey" FOREIGN KEY (tenant_id, channel_id) REFERENCES public.sales_channels(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."retail_orders"
  ADD CONSTRAINT "retail_orders_tenant_id_channel_id_fkey" FOREIGN KEY (tenant_id, channel_id) REFERENCES public.sales_channels(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."acquisitions"
  ADD CONSTRAINT "acquisitions_shipping_provider_connection_id_fkey" FOREIGN KEY (shipping_provider_connection_id) REFERENCES public.shipping_provider_connections(id) ON DELETE
    SET NULL;

ALTER TABLE "public"."shipping_quote_sessions"
  ADD CONSTRAINT "shipping_quote_sessions_acquisition_id_fkey" FOREIGN KEY (acquisition_id) REFERENCES public.acquisitions(id) ON DELETE CASCADE;

ALTER TABLE "public"."shipping_quote_sessions"
  ADD CONSTRAINT "shipping_quote_sessions_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;

ALTER TABLE "public"."acquisitions"
  ADD CONSTRAINT "acquisitions_shipping_quote_session_id_fkey" FOREIGN KEY (shipping_quote_session_id) REFERENCES public.shipping_quote_sessions(id);

ALTER TABLE "public"."shipping_quote_sessions"
  ADD CONSTRAINT "shipping_quote_sessions_provider_connection_id_fkey" FOREIGN KEY (provider_connection_id) REFERENCES public.shipping_provider_connections(id);

ALTER TABLE "public"."site_revisions"
  ADD CONSTRAINT "site_revisions_created_by_fk" FOREIGN KEY (created_by) REFERENCES auth.users(id);

ALTER TABLE "public"."site_revisions"
  ADD CONSTRAINT "site_revisions_published_by_fk" FOREIGN KEY (published_by) REFERENCES auth.users(id);

ALTER TABLE "public"."published_site_index"
  ADD CONSTRAINT "published_site_index_revision_fk" FOREIGN KEY (tenant_id, revision_id) REFERENCES public.site_revisions(tenant_id, id);

ALTER TABLE "public"."tenant_buying_products"
  ADD CONSTRAINT "tenant_buying_products_branch_id_fkey" FOREIGN KEY (branch_id) REFERENCES public.category_branches(id) ON DELETE RESTRICT;

ALTER TABLE "public"."tenant_buying_products"
  ADD CONSTRAINT "tenant_buying_products_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE RESTRICT;

ALTER TABLE "public"."buying_items"
  ADD CONSTRAINT "buying_items_buying_product_id_fkey" FOREIGN KEY (buying_product_id) REFERENCES public.tenant_buying_products(id) ON DELETE SET NULL;

ALTER TABLE "public"."tenant_buying_condition_rules"
  ADD CONSTRAINT "tenant_buying_condition_rules_buying_product_id_fkey" FOREIGN KEY (buying_product_id) REFERENCES public.tenant_buying_products(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_buying_research"
  ADD CONSTRAINT "tenant_buying_research_buying_product_id_fkey" FOREIGN KEY (buying_product_id) REFERENCES public.tenant_buying_products(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_buying_research"
  ADD CONSTRAINT "tenant_buying_research_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."tenant_catalogue_selections"
  ADD CONSTRAINT "tenant_catalogue_selections_branch_id_fkey" FOREIGN KEY (branch_id) REFERENCES public.category_branches(id) ON DELETE SET NULL;

ALTER TABLE "public"."tenant_catalogue_selections"
  ADD CONSTRAINT "tenant_catalogue_selections_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_catalogue_selections"
  ADD CONSTRAINT "tenant_catalogue_selections_master_product_id_fkey" FOREIGN KEY (master_product_id) REFERENCES public.catalogue_master_products(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_domain_orders"
  ADD CONSTRAINT "tenant_domain_orders_domain_id_fkey" FOREIGN KEY (domain_id) REFERENCES public.tenant_domains(id) ON DELETE SET NULL;

ALTER TABLE "public"."published_site_index"
  ADD CONSTRAINT "published_site_index_domain_fk" FOREIGN KEY (tenant_id, domain_id) REFERENCES public.tenant_domains(tenant_id, id);

ALTER TABLE "public"."tenant_memberships"
  ADD CONSTRAINT "tenant_memberships_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE RESTRICT;

ALTER TABLE "public"."tenant_shipping_services"
  ADD CONSTRAINT "tenant_shipping_services_service_code_fkey" FOREIGN KEY (service_code) REFERENCES public.shipping_service_catalog(service_code) ON UPDATE CASCADE;

ALTER TABLE "public"."tenant_site_state"
  ADD CONSTRAINT "tenant_site_state_draft_fk" FOREIGN KEY (tenant_id, draft_revision_id) REFERENCES public.site_revisions(tenant_id, id);

ALTER TABLE "public"."tenant_site_state"
  ADD CONSTRAINT "tenant_site_state_published_fk" FOREIGN KEY (tenant_id, published_revision_id) REFERENCES public.site_revisions(tenant_id, id);

ALTER TABLE "public"."tenant_subscriptions"
  ADD CONSTRAINT "tenant_subscriptions_plan_id_fkey" FOREIGN KEY (plan_id) REFERENCES public.plans(id) ON DELETE RESTRICT;

ALTER TABLE "public"."acquisition_fulfilments"
  ADD CONSTRAINT "acquisition_fulfilments_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;

ALTER TABLE "public"."buying_item_return_shipping"
  ADD CONSTRAINT "buying_item_return_shipping_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."categories"
  ADD CONSTRAINT "categories_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;

ALTER TABLE "public"."customer_bank_details"
  ADD CONSTRAINT "customer_bank_details_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."customer_credit_accounts"
  ADD CONSTRAINT "customer_credit_accounts_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."customer_credit_holds"
  ADD CONSTRAINT "customer_credit_holds_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."customers"
  ADD CONSTRAINT "customers_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;

ALTER TABLE "public"."email_templates"
  ADD CONSTRAINT "email_templates_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."fulfilment_events"
  ADD CONSTRAINT "fulfilment_events_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;

ALTER TABLE "public"."fulfilment_parcels"
  ADD CONSTRAINT "fulfilment_parcels_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;

ALTER TABLE "public"."fulfilments"
  ADD CONSTRAINT "fulfilments_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;

ALTER TABLE "public"."media_assets"
  ADD CONSTRAINT "media_assets_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;

ALTER TABLE "public"."notification_event_log"
  ADD CONSTRAINT "notification_event_log_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."notification_events"
  ADD CONSTRAINT "notification_events_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."notification_queue"
  ADD CONSTRAINT "notification_queue_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."notification_templates"
  ADD CONSTRAINT "notification_templates_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."payment_provider_connections"
  ADD CONSTRAINT "payment_provider_connections_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."payment_provider_customers"
  ADD CONSTRAINT "payment_provider_customers_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."payment_webhook_events"
  ADD CONSTRAINT "payment_webhook_events_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE SET NULL;

ALTER TABLE "public"."published_site_index"
  ADD CONSTRAINT "published_site_index_tenant_fk" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);

ALTER TABLE "public"."sales_channels"
  ADD CONSTRAINT "sales_channels_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;

ALTER TABLE "public"."shipping_provider_connections"
  ADD CONSTRAINT "shipping_provider_connections_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."shipping_quote_sessions"
  ADD CONSTRAINT "shipping_quote_sessions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."site_revisions"
  ADD CONSTRAINT "site_revisions_tenant_fk" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id);

ALTER TABLE "public"."tenant_buying_condition_rules"
  ADD CONSTRAINT "tenant_buying_condition_rules_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_buying_manufacturers"
  ADD CONSTRAINT "tenant_buying_manufacturers_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_buying_products"
  ADD CONSTRAINT "tenant_buying_products_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_buying_research"
  ADD CONSTRAINT "tenant_buying_research_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_catalogue_selections"
  ADD CONSTRAINT "tenant_catalogue_selections_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_catalogue_state"
  ADD CONSTRAINT "tenant_catalogue_state_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_domain_orders"
  ADD CONSTRAINT "tenant_domain_orders_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_domains"
  ADD CONSTRAINT "tenant_domains_tenant_fk" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_email_notification_settings"
  ADD CONSTRAINT "tenant_email_notification_settings_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_email_settings"
  ADD CONSTRAINT "tenant_email_settings_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_memberships"
  ADD CONSTRAINT "tenant_memberships_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;

ALTER TABLE "public"."tenant_payment_methods"
  ADD CONSTRAINT "tenant_payment_methods_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_public_profiles"
  ADD CONSTRAINT "tenant_public_profiles_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_shipping_services"
  ADD CONSTRAINT "tenant_shipping_services_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_site_state"
  ADD CONSTRAINT "tenant_site_state_tenant_fk" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."tenant_subscriptions"
  ADD CONSTRAINT "tenant_subscriptions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE RESTRICT;

ALTER TABLE "public"."trade_in_transactions"
  ADD CONSTRAINT "trade_in_transactions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."trade_in_transactions"
  ADD CONSTRAINT "trade_in_transactions_tenant_id_acquisition_id_fkey" FOREIGN KEY (tenant_id, acquisition_id) REFERENCES public.acquisitions(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."trade_in_transactions"
  ADD CONSTRAINT "trade_in_transactions_tenant_id_acquisition_item_id_fkey" FOREIGN KEY (tenant_id, acquisition_item_id) REFERENCES public.acquisition_items(tenant_id, id)
    ON DELETE RESTRICT;

ALTER TABLE "public"."trade_in_transactions"
  ADD CONSTRAINT "trade_in_transactions_tenant_id_buying_item_id_fkey" FOREIGN KEY (tenant_id, buying_item_id) REFERENCES public.buying_items(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."trade_in_transactions"
  ADD CONSTRAINT "trade_in_transactions_tenant_id_buying_request_id_fkey" FOREIGN KEY (tenant_id, buying_request_id) REFERENCES public.buying_requests(tenant_id, id)
    ON DELETE RESTRICT;

ALTER TABLE "public"."trade_in_transactions"
  ADD CONSTRAINT "trade_in_transactions_tenant_id_customer_id_fkey" FOREIGN KEY (tenant_id, customer_id) REFERENCES public.customers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."retail_order_trade_ins"
  ADD CONSTRAINT "retail_order_trade_ins_tenant_id_trade_in_transaction_id_fkey" FOREIGN KEY (tenant_id, trade_in_transaction_id)
    REFERENCES public.trade_in_transactions(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."trade_in_transactions"
  ADD CONSTRAINT "trade_in_transactions_tenant_id_offer_id_fkey" FOREIGN KEY (tenant_id, offer_id) REFERENCES public.offers(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."trading_values"
  ADD CONSTRAINT "trading_values_approved_by_fkey" FOREIGN KEY (approved_by) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."trading_values"
  ADD CONSTRAINT "trading_values_tenant_id_buying_item_id_fkey" FOREIGN KEY (tenant_id, buying_item_id) REFERENCES public.buying_items(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."trading_values"
  ADD CONSTRAINT "trading_values_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

ALTER TABLE "public"."offers"
  ADD CONSTRAINT "offers_tenant_id_trading_value_id_fkey" FOREIGN KEY (tenant_id, trading_value_id) REFERENCES public.trading_values(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."trading_value_components"
  ADD CONSTRAINT "trading_value_components_tenant_id_trading_value_id_fkey" FOREIGN KEY (tenant_id, trading_value_id) REFERENCES public.trading_values(tenant_id, id)
    ON DELETE CASCADE;

ALTER TABLE "public"."offers"
  ADD CONSTRAINT "offers_tenant_item_valuation_fkey" FOREIGN KEY (tenant_id, buying_item_id, trading_value_id) REFERENCES public.trading_values(tenant_id, buying_item_id, id)
    ON DELETE RESTRICT;

ALTER TABLE "public"."valuation_rules"
  ADD CONSTRAINT "valuation_rules_tenant_id_category_id_fkey" FOREIGN KEY (tenant_id, category_id) REFERENCES public.categories(tenant_id, id) ON DELETE RESTRICT;

ALTER TABLE "public"."valuation_rules"
  ADD CONSTRAINT "valuation_rules_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;

CREATE VIEW "public"."published_site_preview" AS  SELECT ts.tenant_id,
    sr.revision_number,
    sr.content,
    sr.published_at
   FROM (public.tenant_site_state ts
     JOIN public.site_revisions sr ON (((sr.id = ts.published_revision_id) AND (sr.tenant_id = ts.tenant_id) AND (sr.status = 'published'::text))));

CREATE INDEX acquisition_items_tenant_acquisition_idx ON public.acquisition_items USING btree (tenant_id, acquisition_id, created_at);

CREATE INDEX acquisition_items_tenant_buying_item_idx ON public.acquisition_items USING btree (tenant_id, buying_item_id);

CREATE INDEX acquisition_items_tenant_status_idx ON public.acquisition_items USING btree (tenant_id, status, created_at DESC);

CREATE UNIQUE INDEX acquisitions_one_per_source_offer ON public.acquisitions USING btree (tenant_id, source_offer_id)
  WHERE (source_offer_id IS NOT NULL);

CREATE INDEX acquisitions_tenant_customer_created_idx ON public.acquisitions USING btree (tenant_id, customer_id, created_at DESC);

CREATE INDEX acquisitions_tenant_offer_idx ON public.acquisitions USING btree (tenant_id, source_offer_id);

CREATE INDEX acquisitions_tenant_status_created_idx ON public.acquisitions USING btree (tenant_id, status, created_at DESC);

CREATE INDEX buying_item_field_values_field_idx ON public.buying_item_field_values USING btree (tenant_id, field_id);

CREATE INDEX buying_item_field_values_item_idx ON public.buying_item_field_values USING btree (tenant_id, buying_item_id);

CREATE INDEX buying_item_media_item_idx ON public.buying_item_media USING btree (tenant_id, buying_item_id, sort_order);

CREATE INDEX buying_item_return_shipping_tenant_idx ON public.buying_item_return_shipping USING btree (tenant_id, buying_item_id);

CREATE INDEX buying_items_buying_product_idx ON public.buying_items USING btree (tenant_id, buying_product_id);

CREATE INDEX buying_items_category_idx ON public.buying_items USING btree (tenant_id, category_id);

CREATE INDEX buying_items_request_idx ON public.buying_items USING btree (tenant_id, buying_request_id, sort_order);

CREATE INDEX buying_items_tenant_branch_idx ON public.buying_items USING btree (tenant_id, branch_id);

CREATE INDEX buying_requests_customer_idx ON public.buying_requests USING btree (tenant_id, customer_id, created_at DESC);

CREATE INDEX buying_requests_tenant_status_idx ON public.buying_requests USING btree (tenant_id, status);

CREATE INDEX categories_tenant_active_sort_idx ON public.categories USING btree (tenant_id, active, sort_order, name);

CREATE UNIQUE INDEX categories_tenant_slug_key ON public.categories USING btree (tenant_id, lower(slug));

CREATE UNIQUE INDEX category_branches_tenant_category_slug_key ON public.category_branches USING btree (tenant_id, category_id, lower(slug));

CREATE INDEX category_branches_tenant_category_sort_idx ON public.category_branches USING btree (tenant_id, category_id, active, sort_order, name);

CREATE INDEX category_field_options_tenant_field_sort_idx ON public.category_field_options USING btree (tenant_id, field_id, sort_order, label);

CREATE INDEX category_fields_tenant_branch_sort_idx ON public.category_fields USING btree (tenant_id, branch_id, sort_order, label);

CREATE INDEX category_fields_tenant_category_sort_idx ON public.category_fields USING btree (tenant_id, category_id, sort_order, label);

CREATE INDEX customer_addresses_customer_idx ON public.customer_addresses USING btree (tenant_id, customer_id);

CREATE UNIQUE INDEX customer_addresses_one_default_per_type ON public.customer_addresses USING btree (tenant_id, customer_id, address_type)
  WHERE is_default;

CREATE INDEX customer_credit_accounts_customer_idx ON public.customer_credit_accounts USING btree (tenant_id, customer_id);

CREATE UNIQUE INDEX customer_credit_accounts_tenant_customer_uidx ON public.customer_credit_accounts USING btree (tenant_id, customer_id);

CREATE INDEX customer_credit_holds_customer_active_idx ON public.customer_credit_holds USING btree (tenant_id, customer_id, status);

CREATE INDEX customers_auth_user_idx ON public.customers USING btree (auth_user_id);

CREATE UNIQUE INDEX customers_tenant_auth_user_unique ON public.customers USING btree (tenant_id, auth_user_id)
  WHERE (auth_user_id IS NOT NULL);

CREATE INDEX customers_tenant_email_idx ON public.customers USING btree (tenant_id, lower(email));

CREATE INDEX customers_tenant_idx ON public.customers USING btree (tenant_id);

CREATE INDEX email_templates_tenant_event_idx ON public.email_templates USING btree (tenant_id, event_code, active);

CREATE INDEX idx_acq_fulfilments_tenant_acquisition ON public.acquisition_fulfilments USING btree (tenant_id, acquisition_id);

CREATE INDEX idx_acq_fulfilments_tenant_status ON public.acquisition_fulfilments USING btree (tenant_id, status);

CREATE INDEX idx_catalogue_master_products_branch ON public.catalogue_master_products USING btree (branch_id);

CREATE INDEX idx_catalogue_master_products_category ON public.catalogue_master_products USING btree (category_id);

CREATE INDEX idx_catalogue_master_products_manufacturer ON public.catalogue_master_products USING btree (manufacturer_id);

CREATE INDEX idx_catalogue_master_products_model ON public.catalogue_master_products USING btree (model);

CREATE INDEX idx_events_tenant_fulfilment ON public.fulfilment_events USING btree (tenant_id, fulfilment_id, event_at DESC);

CREATE INDEX idx_fulfilments_tenant_order ON public.fulfilments USING btree (tenant_id, retail_order_id);

CREATE INDEX idx_fulfilments_tenant_status ON public.fulfilments USING btree (tenant_id, status);

CREATE INDEX idx_parcels_tenant_fulfilment ON public.fulfilment_parcels USING btree (tenant_id, fulfilment_id);

CREATE INDEX idx_permissions_domain_active ON public.permissions USING btree (DOMAIN, active);

CREATE INDEX idx_plan_features_plan_code_enabled ON public.plan_features USING btree (plan_id, feature_code, enabled);

CREATE INDEX idx_published_site_index_tenant ON public.published_site_index USING btree (tenant_id);

CREATE INDEX idx_role_permissions_permission ON public.role_permissions USING btree (permission_id);

CREATE INDEX idx_site_revisions_tenant_status ON public.site_revisions USING btree (tenant_id, status, revision_number DESC);

CREATE INDEX idx_tenant_domains_lookup ON public.tenant_domains USING btree (hostname, status);

CREATE INDEX idx_tenant_memberships_tenant_role_status ON public.tenant_memberships USING btree (tenant_id, role_code, status);

CREATE INDEX idx_tenant_memberships_user_tenant_status ON public.tenant_memberships USING btree (user_id, tenant_id, status);

CREATE INDEX idx_tenant_subscriptions_tenant_status ON public.tenant_subscriptions USING btree (tenant_id, status);

CREATE INDEX inventory_asset_media_inventory_idx ON public.inventory_asset_media USING btree (tenant_id, inventory_asset_id, sort_order);

CREATE INDEX inventory_assets_tenant_acquisition_idx ON public.inventory_assets USING btree (tenant_id, acquisition_item_id);

CREATE INDEX inventory_assets_tenant_branch_idx ON public.inventory_assets USING btree (tenant_id, branch_id);

CREATE INDEX inventory_assets_tenant_buying_item_idx ON public.inventory_assets USING btree (tenant_id, buying_item_id);

CREATE INDEX inventory_assets_tenant_catalogue_product_idx ON public.inventory_assets USING btree (tenant_id, catalogue_product_id);

CREATE INDEX inventory_assets_tenant_category_idx ON public.inventory_assets USING btree (tenant_id, category_id, status);

CREATE UNIQUE INDEX inventory_assets_tenant_serial_idx ON public.inventory_assets USING btree (tenant_id, serial_number)
  WHERE (serial_number IS NOT NULL);

CREATE INDEX inventory_assets_tenant_status_idx ON public.inventory_assets USING btree (tenant_id, status, created_at DESC);

CREATE INDEX inventory_costs_tenant_asset_idx ON public.inventory_costs USING btree (tenant_id, inventory_asset_id, incurred_at DESC);

CREATE INDEX inventory_inspections_tenant_asset_idx ON public.inventory_inspections USING btree (tenant_id, inventory_asset_id, inspected_at DESC);

CREATE INDEX inventory_movements_tenant_asset_created_idx ON public.inventory_movements USING btree (tenant_id, inventory_asset_id, created_at DESC);

CREATE INDEX ledger_entries_tenant_acquisition_idx ON public.ledger_entries USING btree (tenant_id, acquisition_id);

CREATE INDEX ledger_entries_tenant_asset_idx ON public.ledger_entries USING btree (tenant_id, inventory_asset_id);

CREATE INDEX ledger_entries_tenant_occurred_idx ON public.ledger_entries USING btree (tenant_id, occurred_at DESC);

CREATE INDEX ledger_entries_tenant_order_idx ON public.ledger_entries USING btree (tenant_id, retail_order_id);

CREATE INDEX ledger_entries_tenant_type_status_idx ON public.ledger_entries USING btree (tenant_id, entry_type, status, occurred_at DESC);

CREATE INDEX listing_events_tenant_listing_created_idx ON public.listing_events USING btree (tenant_id, listing_id, created_at DESC);

CREATE INDEX listing_media_listing_idx ON public.listing_media USING btree (tenant_id, listing_id, sort_order);

CREATE UNIQUE INDEX listings_one_active_per_asset_channel ON public.listings USING btree (tenant_id, asset_id, channel_id)
  WHERE (status = ANY (ARRAY['ready'::text, 'published'::text, 'reserved'::text]));

CREATE UNIQUE INDEX listings_one_active_per_asset_idx ON public.listings USING btree (tenant_id, asset_id)
  WHERE (status <> ALL (ARRAY['sold'::text, 'delisted'::text]));

CREATE INDEX listings_tenant_asset_idx ON public.listings USING btree (tenant_id, asset_id, status);

CREATE INDEX listings_tenant_branch_idx ON public.listings USING btree (tenant_id, branch_id);

CREATE INDEX listings_tenant_category_idx ON public.listings USING btree (tenant_id, category_id, status);

CREATE INDEX listings_tenant_channel_idx ON public.listings USING btree (tenant_id, channel_id, status);

CREATE INDEX listings_tenant_status_idx ON public.listings USING btree (tenant_id, status, created_at DESC);

CREATE INDEX media_assets_retention_idx ON public.media_assets USING btree (retention_expires_at)
  WHERE ((retention_expires_at IS NOT NULL) AND (deleted_at IS NULL));

CREATE INDEX media_assets_tenant_created_idx ON public.media_assets USING btree (tenant_id, created_at DESC);

CREATE INDEX notification_event_log_entity_idx ON public.notification_event_log USING btree (tenant_id, entity_type, entity_id);

CREATE INDEX notification_event_log_tenant_time_idx ON public.notification_event_log USING btree (tenant_id, occurred_at DESC);

CREATE INDEX notification_events_notification_idx ON public.notification_events USING btree (tenant_id, notification_id);

CREATE INDEX notification_events_tenant_time_idx ON public.notification_events USING btree (tenant_id, occurred_at DESC);

CREATE INDEX notification_queue_processing_idx ON public.notification_queue USING btree (status, scheduled_for, created_at);

CREATE INDEX notification_queue_tenant_status_idx ON public.notification_queue USING btree (tenant_id, status, created_at DESC);

CREATE INDEX notification_templates_tenant_event_idx ON public.notification_templates USING btree (tenant_id, event_code, enabled);

CREATE INDEX offer_events_offer_idx ON public.offer_events USING btree (tenant_id, offer_id, created_at DESC);

CREATE UNIQUE INDEX offers_one_live_published_per_item ON public.offers USING btree (tenant_id, buying_item_id)
  WHERE (status = 'published'::text);

CREATE INDEX offers_tenant_item_idx ON public.offers USING btree (tenant_id, buying_item_id, created_at DESC);

CREATE INDEX offers_tenant_status_idx ON public.offers USING btree (tenant_id, status, created_at DESC);

CREATE UNIQUE INDEX payment_provider_connections_provider_account_idx ON public.payment_provider_connections USING btree (PROVIDER, provider_account_id)
  WHERE (provider_account_id IS NOT NULL);

CREATE INDEX payment_provider_connections_tenant_status_idx ON public.payment_provider_connections USING btree (tenant_id, status);

CREATE INDEX payment_provider_customers_tenant_customer_idx ON public.payment_provider_customers USING btree (tenant_id, customer_id);

CREATE INDEX payment_records_tenant_acquisition_idx ON public.payment_records USING btree (tenant_id, acquisition_id);

CREATE UNIQUE INDEX payment_records_tenant_id_idempotency_key_uidx ON public.payment_records USING btree (tenant_id, idempotency_key)
  WHERE (idempotency_key IS NOT NULL);

CREATE UNIQUE INDEX payment_records_tenant_idempotency_idx ON public.payment_records USING btree (tenant_id, idempotency_key)
  WHERE (idempotency_key IS NOT NULL);

CREATE INDEX payment_records_tenant_order_idx ON public.payment_records USING btree (tenant_id, retail_order_id);

CREATE UNIQUE INDEX payment_records_tenant_provider_id_idx ON public.payment_records USING btree (tenant_id, PROVIDER, provider_payment_id)
  WHERE ((PROVIDER IS NOT NULL) AND (provider_payment_id IS NOT NULL));

CREATE INDEX payment_records_tenant_status_idx ON public.payment_records USING btree (tenant_id, status, created_at DESC);

CREATE INDEX payment_webhook_events_provider_type_idx ON public.payment_webhook_events USING btree (PROVIDER, event_type, received_at DESC);

CREATE INDEX payment_webhook_events_tenant_status_idx ON public.payment_webhook_events USING btree (tenant_id, status, received_at DESC);

CREATE INDEX platform_memberships_user_status_idx ON public.platform_memberships USING btree (user_id, status);

CREATE INDEX retail_order_items_tenant_asset_idx ON public.retail_order_items USING btree (tenant_id, inventory_asset_id);

CREATE INDEX retail_order_items_tenant_listing_idx ON public.retail_order_items USING btree (tenant_id, listing_id);

CREATE INDEX retail_order_items_tenant_order_idx ON public.retail_order_items USING btree (tenant_id, order_id, created_at);

CREATE INDEX retail_order_trade_ins_tenant_order_idx ON public.retail_order_trade_ins USING btree (tenant_id, retail_order_id);

CREATE INDEX retail_order_trade_ins_tenant_trade_in_idx ON public.retail_order_trade_ins USING btree (tenant_id, trade_in_transaction_id);

CREATE INDEX retail_orders_tenant_channel_idx ON public.retail_orders USING btree (tenant_id, channel_id, created_at DESC);

CREATE INDEX retail_orders_tenant_customer_idx ON public.retail_orders USING btree (tenant_id, customer_id, created_at DESC);

CREATE INDEX retail_orders_tenant_status_idx ON public.retail_orders USING btree (tenant_id, status, created_at DESC);

CREATE INDEX return_events_tenant_return_created_idx ON public.return_events USING btree (tenant_id, return_id, created_at DESC);

CREATE INDEX return_resolutions_tenant_return_idx ON public.return_resolutions USING btree (tenant_id, return_id, resolved_at DESC);

CREATE INDEX returns_tenant_acquisition_item_idx ON public.returns USING btree (tenant_id, acquisition_item_id);

CREATE INDEX returns_tenant_asset_idx ON public.returns USING btree (tenant_id, inventory_asset_id);

CREATE INDEX returns_tenant_customer_idx ON public.returns USING btree (tenant_id, customer_id, created_at DESC);

CREATE INDEX returns_tenant_order_item_idx ON public.returns USING btree (tenant_id, order_item_id);

CREATE INDEX returns_tenant_status_idx ON public.returns USING btree (tenant_id, status, created_at DESC);

CREATE INDEX sales_channels_tenant_active_idx ON public.sales_channels USING btree (tenant_id, active, created_at);

CREATE INDEX shipping_quote_sessions_acquisition_idx ON public.shipping_quote_sessions USING btree (acquisition_id, created_at DESC);

CREATE INDEX shipping_quote_sessions_customer_idx ON public.shipping_quote_sessions USING btree (customer_id, created_at DESC);

CREATE UNIQUE INDEX site_revisions_one_draft_per_tenant ON public.site_revisions USING btree (tenant_id)
  WHERE (status = 'draft'::text);

CREATE UNIQUE INDEX site_revisions_one_published_per_tenant ON public.site_revisions USING btree (tenant_id)
  WHERE (status = 'published'::text);

CREATE UNIQUE INDEX tenant_buying_manufacturers_lower_name_uq ON public.tenant_buying_manufacturers USING btree (tenant_id, lower(name));

CREATE UNIQUE INDEX tenant_buying_products_identity_uq ON public.tenant_buying_products
  USING btree (tenant_id, branch_id, lower(manufacturer), lower(model), lower(COALESCE(package_name, ''::text)));

CREATE INDEX tenant_buying_products_tenant_branch_idx ON public.tenant_buying_products USING btree (tenant_id, branch_id);

CREATE INDEX tenant_buying_research_product_idx ON public.tenant_buying_research USING btree (tenant_id, buying_product_id, evidence_type, checked_at DESC);

CREATE INDEX tenant_catalogue_selections_master_product_idx ON public.tenant_catalogue_selections USING btree (master_product_id);

CREATE INDEX tenant_catalogue_selections_tenant_idx ON public.tenant_catalogue_selections USING btree (tenant_id);

CREATE INDEX tenant_domain_orders_domain_idx ON public.tenant_domain_orders USING btree (domain_id);

CREATE INDEX tenant_domain_orders_status_idx ON public.tenant_domain_orders USING btree (status);

CREATE INDEX tenant_domain_orders_tenant_created_idx ON public.tenant_domain_orders USING btree (tenant_id, created_at DESC);

CREATE UNIQUE INDEX tenant_domains_one_primary_per_tenant ON public.tenant_domains USING btree (tenant_id)
  WHERE ((is_primary = true) AND (status <> 'disabled'::text));

CREATE UNIQUE INDEX tenant_domains_one_primary ON public.tenant_domains USING btree (tenant_id)
  WHERE ((is_primary = true) AND (status <> 'disabled'::text));

CREATE UNIQUE INDEX tenant_domains_registrar_domain_id_uidx ON public.tenant_domains USING btree (registrar_provider, registrar_domain_id)
  WHERE (registrar_domain_id IS NOT NULL);

CREATE INDEX tenant_email_notification_settings_tenant_idx ON public.tenant_email_notification_settings USING btree (tenant_id, event_code, enabled);

CREATE INDEX tenant_memberships_tenant_status_idx ON public.tenant_memberships USING btree (tenant_id, status);

CREATE INDEX tenant_memberships_user_id_idx ON public.tenant_memberships USING btree (user_id);

CREATE INDEX tenant_payment_methods_tenant_idx ON public.tenant_payment_methods USING btree (tenant_id, sort_order);

CREATE INDEX tenant_shipping_services_tenant_idx ON public.tenant_shipping_services USING btree (tenant_id, enabled, sort_order);

CREATE UNIQUE INDEX tenant_subscriptions_one_current_idx ON public.tenant_subscriptions USING btree (tenant_id)
  WHERE (status = ANY (ARRAY['trialing'::text, 'active'::text, 'past_due'::text, 'paused'::text]));

CREATE INDEX tenant_subscriptions_plan_idx ON public.tenant_subscriptions USING btree (plan_id);

CREATE UNIQUE INDEX tenant_subscriptions_provider_customer_idx ON public.tenant_subscriptions USING btree (billing_provider, provider_customer_id)
  WHERE (provider_customer_id IS NOT NULL);

CREATE UNIQUE INDEX tenant_subscriptions_provider_subscription_idx ON public.tenant_subscriptions USING btree (billing_provider, provider_subscription_id)
  WHERE (provider_subscription_id IS NOT NULL);

CREATE INDEX tenant_subscriptions_tenant_idx ON public.tenant_subscriptions USING btree (tenant_id);

CREATE UNIQUE INDEX tenants_slug_key ON public.tenants USING btree (lower(slug));

CREATE INDEX trade_in_transactions_tenant_buying_item_idx ON public.trade_in_transactions USING btree (tenant_id, buying_item_id);

CREATE INDEX trade_in_transactions_tenant_customer_idx ON public.trade_in_transactions USING btree (tenant_id, customer_id, created_at DESC);

CREATE INDEX trade_in_transactions_tenant_status_idx ON public.trade_in_transactions USING btree (tenant_id, status, created_at DESC);

CREATE INDEX trading_value_components_value_idx ON public.trading_value_components USING btree (tenant_id, trading_value_id, sort_order, created_at);

CREATE INDEX trading_values_effective_window_idx ON public.trading_values USING btree (tenant_id, buying_item_id, effective_from, effective_to);

CREATE UNIQUE INDEX trading_values_one_approved_per_item_idx ON public.trading_values USING btree (tenant_id, buying_item_id)
  WHERE (status = 'approved'::text);

CREATE INDEX trading_values_tenant_item_idx ON public.trading_values USING btree (tenant_id, buying_item_id, created_at DESC);

CREATE INDEX trading_values_tenant_item_status_created_idx ON public.trading_values USING btree (tenant_id, buying_item_id, status, created_at DESC);

CREATE INDEX trading_values_tenant_status_idx ON public.trading_values USING btree (tenant_id, status);

CREATE UNIQUE INDEX valuation_rules_category_version_idx ON public.valuation_rules USING btree (tenant_id, category_id, name, VERSION);

CREATE INDEX valuation_rules_tenant_category_idx ON public.valuation_rules USING btree (tenant_id, category_id, active, priority, VERSION);

CREATE INDEX workflow_transitions_entity_idx ON public.workflow_transitions USING btree (tenant_id, entity_type, entity_id, created_at DESC);

CREATE INDEX workflow_transitions_tenant_created_idx ON public.workflow_transitions USING btree (tenant_id, created_at DESC);

CREATE TRIGGER acquisition_fulfilments_status_entry_guard
  BEFORE UPDATE OF status ON public.acquisition_fulfilments
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_acquisition_fulfilment_status_entry();

CREATE TRIGGER acquisition_fulfilments_updated_at
  BEFORE UPDATE ON public.acquisition_fulfilments
  FOR EACH ROW
  EXECUTE FUNCTION private.touch_fulfilment_updated_at();

CREATE TRIGGER acquisition_items_set_updated_at
  BEFORE UPDATE ON public.acquisition_items
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER acquisition_items_status_entry_guard
  BEFORE UPDATE OF status ON public.acquisition_items
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_acquisition_item_status_entry();

CREATE TRIGGER acquisitions_generate_reference
  BEFORE INSERT ON public.acquisitions
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_acquisition_reference();

CREATE TRIGGER acquisitions_set_updated_at
  BEFORE UPDATE ON public.acquisitions
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER acquisitions_status_entry_guard
  BEFORE UPDATE OF status ON public.acquisitions
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_acquisition_status_entry();

CREATE TRIGGER trg_guard_acquisition_creation_boundary
  BEFORE INSERT ON public.acquisitions
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_acquisition_creation_boundary();

CREATE TRIGGER buying_item_field_values_set_updated_at
  BEFORE UPDATE ON public.buying_item_field_values
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER buying_items_generate_reference
  BEFORE INSERT ON public.buying_items
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_buying_item_reference();

CREATE TRIGGER buying_items_set_updated_at
  BEFORE UPDATE ON public.buying_items
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER buying_items_sync_branch
  BEFORE INSERT OR UPDATE OF tenant_id, category_id, branch_id ON public.buying_items
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_category_branch_reference();

CREATE TRIGGER buying_requests_customer_valuation_received
  AFTER INSERT ON public.buying_requests
  FOR EACH ROW
  EXECUTE FUNCTION private.queue_buying_request_received_notification();

CREATE TRIGGER buying_requests_generate_reference
  BEFORE INSERT ON public.buying_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_buying_request_reference();

CREATE TRIGGER buying_requests_set_updated_at
  BEFORE UPDATE ON public.buying_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER categories_create_default_branch
  AFTER INSERT ON public.categories
  FOR EACH ROW
  EXECUTE FUNCTION public.ensure_category_default_branch();

CREATE TRIGGER categories_set_updated_at
  BEFORE UPDATE ON public.categories
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER category_branches_set_updated_at
  BEFORE UPDATE ON public.category_branches
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER category_field_options_set_updated_at
  BEFORE UPDATE ON public.category_field_options
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER category_fields_set_updated_at
  BEFORE UPDATE ON public.category_fields
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER category_fields_sync_branch
  BEFORE INSERT OR UPDATE OF tenant_id, category_id, branch_id ON public.category_fields
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_category_branch_reference();

CREATE TRIGGER customer_addresses_set_updated_at
  BEFORE UPDATE ON public.customer_addresses
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER customers_generate_reference
  BEFORE INSERT ON public.customers
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_customer_reference();

CREATE TRIGGER customers_set_updated_at
  BEFORE UPDATE ON public.customers
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER fulfilment_parcels_updated_at
  BEFORE UPDATE ON public.fulfilment_parcels
  FOR EACH ROW
  EXECUTE FUNCTION private.touch_fulfilment_updated_at();

CREATE TRIGGER fulfilments_status_entry_guard
  BEFORE UPDATE OF status ON public.fulfilments
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_fulfilment_status_entry();

CREATE TRIGGER fulfilments_updated_at
  BEFORE UPDATE ON public.fulfilments
  FOR EACH ROW
  EXECUTE FUNCTION private.touch_fulfilment_updated_at();

CREATE TRIGGER inventory_assets_generate_reference
  BEFORE INSERT ON public.inventory_assets
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_asset_reference();

CREATE TRIGGER inventory_assets_media_retention
  AFTER UPDATE OF status ON public.inventory_assets
  FOR EACH ROW
  EXECUTE FUNCTION public.set_media_retention_after_sale();

CREATE TRIGGER inventory_assets_set_updated_at
  BEFORE UPDATE ON public.inventory_assets
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER inventory_assets_status_entry_guard
  BEFORE UPDATE ON public.inventory_assets
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_inventory_asset_status_entry();

CREATE TRIGGER inventory_assets_sync_branch
  BEFORE INSERT OR UPDATE OF tenant_id, category_id, branch_id ON public.inventory_assets
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_category_branch_reference();

CREATE TRIGGER trg_guard_inventory_creation_boundary
  BEFORE INSERT ON public.inventory_assets
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_inventory_creation_boundary();

CREATE TRIGGER ledger_entries_generate_reference
  BEFORE INSERT ON public.ledger_entries
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_ledger_reference();

CREATE TRIGGER ledger_entries_set_updated_at
  BEFORE UPDATE ON public.ledger_entries
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER ledger_entries_status_entry_guard
  BEFORE UPDATE OF status ON public.ledger_entries
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_ledger_entry_status_entry();

CREATE TRIGGER listings_generate_reference
  BEFORE INSERT ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_listing_reference();

CREATE TRIGGER listings_media_retention
  AFTER UPDATE OF status ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.set_listing_media_retention_after_sale();

CREATE TRIGGER listings_set_updated_at
  BEFORE UPDATE ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER listings_status_entry_guard
  BEFORE UPDATE OF status ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_listing_status_entry();

CREATE TRIGGER listings_sync_branch
  BEFORE INSERT OR UPDATE OF tenant_id, category_id, branch_id ON public.listings
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_category_branch_reference();

CREATE TRIGGER media_assets_set_updated_at
  BEFORE UPDATE ON public.media_assets
  FOR EACH ROW
  EXECUTE FUNCTION public.media_assets_set_updated_at();

CREATE TRIGGER offers_generate_reference
  BEFORE INSERT ON public.offers
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_offer_reference();

CREATE TRIGGER offers_set_updated_at
  BEFORE UPDATE ON public.offers
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER offers_validate_published_valuation
  BEFORE INSERT OR UPDATE OF status, buying_item_id, trading_value_id, tenant_id ON public.offers
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_published_offer_valuation();

CREATE TRIGGER payment_records_generate_reference
  BEFORE INSERT ON public.payment_records
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_payment_reference();

CREATE TRIGGER payment_records_set_updated_at
  BEFORE UPDATE ON public.payment_records
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER payment_records_status_entry_guard
  BEFORE UPDATE OF status ON public.payment_records
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_payment_record_status_entry();

CREATE TRIGGER plan_features_set_updated_at
  BEFORE UPDATE ON public.plan_features
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER plans_set_updated_at
  BEFORE UPDATE ON public.plans
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER platform_memberships_set_updated_at
  BEFORE UPDATE ON public.platform_memberships
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_published_site_index_updated_at
  BEFORE UPDATE ON public.published_site_index
  FOR EACH ROW
  EXECUTE FUNCTION private.touch_site_publication_updated_at();

CREATE TRIGGER retail_order_items_set_updated_at
  BEFORE UPDATE ON public.retail_order_items
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER retail_order_trade_ins_set_updated_at
  BEFORE UPDATE ON public.retail_order_trade_ins
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER retail_orders_ensure_fulfilment
  AFTER UPDATE OF status ON public.retail_orders
  FOR EACH ROW
  WHEN ((new.status = 'paid'::text))
  EXECUTE FUNCTION public.ensure_retail_order_fulfilment();

CREATE TRIGGER retail_orders_generate_reference
  BEFORE INSERT ON public.retail_orders
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_order_reference();

CREATE TRIGGER retail_orders_set_updated_at
  BEFORE UPDATE ON public.retail_orders
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER retail_orders_status_entry_guard
  BEFORE UPDATE OF status ON public.retail_orders
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_retail_order_status_entry();

CREATE TRIGGER retail_orders_sync_payment_status
  BEFORE UPDATE OF status ON public.retail_orders
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_retail_order_payment_status();

CREATE TRIGGER returns_generate_reference
  BEFORE INSERT ON public.returns
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_return_reference();

CREATE TRIGGER returns_set_updated_at
  BEFORE UPDATE ON public.returns
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER returns_status_entry_guard
  BEFORE UPDATE OF status ON public.returns
  FOR EACH ROW
  EXECUTE FUNCTION public.guard_return_status_entry();

CREATE TRIGGER sales_channels_set_updated_at
  BEFORE UPDATE ON public.sales_channels
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_guard_site_revision_lifecycle
  BEFORE DELETE OR UPDATE ON public.site_revisions
  FOR EACH ROW
  EXECUTE FUNCTION private.guard_site_revision_lifecycle();

CREATE TRIGGER trg_site_revisions_updated_at
  BEFORE UPDATE ON public.site_revisions
  FOR EACH ROW
  EXECUTE FUNCTION private.touch_site_publication_updated_at();

CREATE TRIGGER tenant_buying_products_touch
  BEFORE UPDATE ON public.tenant_buying_products
  FOR EACH ROW
  EXECUTE FUNCTION public.touch_tenant_buying_products_updated_at();

CREATE TRIGGER trg_tenant_domains_updated_at
  BEFORE UPDATE ON public.tenant_domains
  FOR EACH ROW
  EXECUTE FUNCTION private.touch_site_publication_updated_at();

CREATE TRIGGER tenant_memberships_set_updated_at
  BEFORE UPDATE ON public.tenant_memberships
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER tenant_public_profiles_set_updated_at
  BEFORE UPDATE ON public.tenant_public_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.touch_tenant_public_profile_updated_at();

CREATE TRIGGER trg_tenant_site_state_updated_at
  BEFORE UPDATE ON public.tenant_site_state
  FOR EACH ROW
  EXECUTE FUNCTION private.touch_site_publication_updated_at();

CREATE TRIGGER tenant_subscriptions_set_updated_at
  BEFORE UPDATE ON public.tenant_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER tenants_set_updated_at
  BEFORE UPDATE ON public.tenants
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_bootstrap_tenant_site
  AFTER INSERT ON public.tenants
  FOR EACH ROW
  EXECUTE FUNCTION private.bootstrap_tenant_site();

CREATE TRIGGER trade_in_transactions_generate_reference
  BEFORE INSERT ON public.trade_in_transactions
  FOR EACH ROW
  EXECUTE FUNCTION public.generate_trade_in_reference();

CREATE TRIGGER trade_in_transactions_set_updated_at
  BEFORE UPDATE ON public.trade_in_transactions
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trading_values_set_updated_at
  BEFORE UPDATE ON public.trading_values
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trading_values_status_timestamps
  BEFORE INSERT OR UPDATE ON public.trading_values
  FOR EACH ROW
  EXECUTE FUNCTION public.set_trading_value_approved_timestamp();

CREATE TRIGGER valuation_rules_set_updated_at
  BEFORE UPDATE ON public.valuation_rules
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE POLICY "acquisition_fulfilments_subscription_delete" ON "public"."acquisition_fulfilments"
  FOR DELETE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "acquisition_fulfilments_subscription_insert" ON "public"."acquisition_fulfilments"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "acquisition_fulfilments_subscription_select" ON "public"."acquisition_fulfilments"
  FOR SELECT
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.view'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "acquisition_fulfilments_subscription_update" ON "public"."acquisition_fulfilments"
  FOR UPDATE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "acquisition_items_subscription_delete" ON "public"."acquisition_items"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'acquisitions.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "acquisition_items_subscription_insert" ON "public"."acquisition_items"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'acquisitions.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "acquisition_items_subscription_select" ON "public"."acquisition_items"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'acquisitions.view'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "acquisition_items_subscription_update" ON "public"."acquisition_items"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'acquisitions.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'acquisitions.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "acquisitions_select_members" ON "public"."acquisitions"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "acquisitions_subscription_delete" ON "public"."acquisitions"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'acquisitions.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "acquisitions_subscription_insert" ON "public"."acquisitions"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'acquisitions.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "acquisitions_subscription_select" ON "public"."acquisitions"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'acquisitions.view'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "acquisitions_subscription_update" ON "public"."acquisitions"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'acquisitions.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'acquisitions.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_item_field_values_delete_admins" ON "public"."buying_item_field_values"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "buying_item_field_values_insert_members" ON "public"."buying_item_field_values"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_item_field_values_select_members" ON "public"."buying_item_field_values"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_item_field_values_subscription_delete" ON "public"."buying_item_field_values"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_item_field_values_subscription_insert" ON "public"."buying_item_field_values"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_item_field_values_subscription_select" ON "public"."buying_item_field_values"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.view'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_item_field_values_subscription_update" ON "public"."buying_item_field_values"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_item_field_values_update_members" ON "public"."buying_item_field_values"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_item_inspections_delete_admins" ON "public"."buying_item_inspections"
  FOR DELETE
  TO PUBLIC
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "buying_item_inspections_insert_members" ON "public"."buying_item_inspections"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((private.is_tenant_member(tenant_id) AND ((inspected_by IS NULL) OR (inspected_by = auth.uid()))));

CREATE POLICY "buying_item_inspections_select_members" ON "public"."buying_item_inspections"
  FOR SELECT
  TO PUBLIC
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_item_inspections_update_members" ON "public"."buying_item_inspections"
  FOR UPDATE
  TO PUBLIC
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_item_media_delete_admins" ON "public"."buying_item_media"
  FOR DELETE
  TO PUBLIC
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "buying_item_media_delete_members" ON "public"."buying_item_media"
  FOR DELETE
  TO "authenticated"
  USING ((private.is_tenant_member(tenant_id) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_item_media_insert_members" ON "public"."buying_item_media"
  FOR INSERT
  TO PUBLIC
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_item_media_select_members" ON "public"."buying_item_media"
  FOR SELECT
  TO PUBLIC
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_item_media_update_members" ON "public"."buying_item_media"
  FOR UPDATE
  TO "authenticated"
  USING ((private.is_tenant_member(tenant_id) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)))
  WITH CHECK ((private.is_tenant_member(tenant_id) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_item_return_shipping_customer_select" ON "public"."buying_item_return_shipping"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM ((public.buying_items bi
     JOIN public.buying_requests br ON (((br.id = bi.buying_request_id) AND (br.tenant_id = bi.tenant_id))))
     JOIN public.customers c ON (((c.id = br.customer_id) AND (c.tenant_id = bi.tenant_id))))
  WHERE ((bi.tenant_id = buying_item_return_shipping.tenant_id) AND (bi.id = buying_item_return_shipping.buying_item_id) AND (c.auth_user_id = auth.uid())))));

CREATE POLICY "buying_item_return_shipping_subscriber_select" ON "public"."buying_item_return_shipping"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "buying_item_shipping_delete_admins" ON "public"."buying_item_shipping"
  FOR DELETE
  TO PUBLIC
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "buying_item_shipping_insert_members" ON "public"."buying_item_shipping"
  FOR INSERT
  TO PUBLIC
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_item_shipping_select_members" ON "public"."buying_item_shipping"
  FOR SELECT
  TO PUBLIC
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_item_shipping_update_members" ON "public"."buying_item_shipping"
  FOR UPDATE
  TO PUBLIC
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_items_delete_admins" ON "public"."buying_items"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "buying_items_insert_members" ON "public"."buying_items"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_items_select_members" ON "public"."buying_items"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_items_subscription_delete" ON "public"."buying_items"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_items_subscription_insert" ON "public"."buying_items"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_items_subscription_select" ON "public"."buying_items"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.view'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_items_subscription_update" ON "public"."buying_items"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_items_update_members" ON "public"."buying_items"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_requests_delete_admins" ON "public"."buying_requests"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "buying_requests_insert_members" ON "public"."buying_requests"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_requests_select_members" ON "public"."buying_requests"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "buying_requests_subscription_delete" ON "public"."buying_requests"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_requests_subscription_insert" ON "public"."buying_requests"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_requests_subscription_select" ON "public"."buying_requests"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.view'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_requests_subscription_update" ON "public"."buying_requests"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.buying'::text)));

CREATE POLICY "buying_requests_update_members" ON "public"."buying_requests"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "categories_delete_admins" ON "public"."categories"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "categories_insert_admins" ON "public"."categories"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "categories_select_members" ON "public"."categories"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "categories_subscription_delete" ON "public"."categories"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "categories_subscription_insert" ON "public"."categories"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "categories_subscription_select" ON "public"."categories"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.view'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "categories_subscription_update" ON "public"."categories"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))))
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "categories_update_admins" ON "public"."categories"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id))
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "category_branches_delete_admins" ON "public"."category_branches"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "category_branches_insert_admins" ON "public"."category_branches"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "category_branches_select_members" ON "public"."category_branches"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "category_branches_update_admins" ON "public"."category_branches"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id))
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "category_field_options_delete_admins" ON "public"."category_field_options"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "category_field_options_insert_admins" ON "public"."category_field_options"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "category_field_options_select_members" ON "public"."category_field_options"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "category_field_options_subscription_delete" ON "public"."category_field_options"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "category_field_options_subscription_insert" ON "public"."category_field_options"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "category_field_options_subscription_select" ON "public"."category_field_options"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.view'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "category_field_options_subscription_update" ON "public"."category_field_options"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))))
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "category_field_options_update_admins" ON "public"."category_field_options"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id))
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "category_fields_delete_admins" ON "public"."category_fields"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "category_fields_insert_admins" ON "public"."category_fields"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "category_fields_select_members" ON "public"."category_fields"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "category_fields_subscription_delete" ON "public"."category_fields"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "category_fields_subscription_insert" ON "public"."category_fields"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "category_fields_subscription_select" ON "public"."category_fields"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.view'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "category_fields_subscription_update" ON "public"."category_fields"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))))
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "category_fields_update_admins" ON "public"."category_fields"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id))
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "customer_addresses_delete_admins" ON "public"."customer_addresses"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "customer_addresses_insert_members" ON "public"."customer_addresses"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "customer_addresses_select_members" ON "public"."customer_addresses"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "customer_addresses_update_members" ON "public"."customer_addresses"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "customers_delete_admins" ON "public"."customers"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "customers_insert_members" ON "public"."customers"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "customers_select_members" ON "public"."customers"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "customers_update_members" ON "public"."customers"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "domain_tld_catalog_active_read_anon" ON "public"."domain_tld_catalog"
  FOR SELECT
  TO "anon"
  USING ((active = true));

CREATE POLICY "domain_tld_catalog_active_read_authenticated" ON "public"."domain_tld_catalog"
  FOR SELECT
  TO "authenticated"
  USING ((active = true));

CREATE POLICY "email_templates_admin_write" ON "public"."email_templates"
  FOR ALL
  TO "authenticated"
  USING (((tenant_id IS NOT NULL) AND private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text)))
  WITH CHECK (((tenant_id IS NOT NULL) AND private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text)));

CREATE POLICY "email_templates_member_read" ON "public"."email_templates"
  FOR SELECT
  TO "authenticated"
  USING (((tenant_id IS NULL) OR private.is_tenant_member(tenant_id, auth.uid())));

CREATE POLICY "fulfilment_events_delete" ON "public"."fulfilment_events"
  FOR DELETE
  TO PUBLIC
  USING ((private.is_tenant_admin(tenant_id) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilment_events_insert" ON "public"."fulfilment_events"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((private.is_tenant_member(tenant_id) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilment_events_select" ON "public"."fulfilment_events"
  FOR SELECT
  TO PUBLIC
  USING ((private.is_tenant_member(tenant_id) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilment_events_update" ON "public"."fulfilment_events"
  FOR UPDATE
  TO PUBLIC
  USING ((private.is_tenant_member(tenant_id) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)))
  WITH CHECK ((private.is_tenant_member(tenant_id) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilment_parcels_delete" ON "public"."fulfilment_parcels"
  FOR DELETE
  TO PUBLIC
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "fulfilment_parcels_insert" ON "public"."fulfilment_parcels"
  FOR INSERT
  TO PUBLIC
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "fulfilment_parcels_select" ON "public"."fulfilment_parcels"
  FOR SELECT
  TO PUBLIC
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "fulfilment_parcels_subscription_delete" ON "public"."fulfilment_parcels"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilment_parcels_subscription_insert" ON "public"."fulfilment_parcels"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilment_parcels_subscription_select" ON "public"."fulfilment_parcels"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.view'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilment_parcels_subscription_update" ON "public"."fulfilment_parcels"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilment_parcels_update" ON "public"."fulfilment_parcels"
  FOR UPDATE
  TO PUBLIC
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "fulfilments_subscription_delete" ON "public"."fulfilments"
  FOR DELETE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilments_subscription_insert" ON "public"."fulfilments"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilments_subscription_select" ON "public"."fulfilments"
  FOR SELECT
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.view'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "fulfilments_subscription_update" ON "public"."fulfilments"
  FOR UPDATE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'fulfilment.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.fulfilment'::text)));

CREATE POLICY "inventory_asset_media_delete" ON "public"."inventory_asset_media"
  FOR DELETE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_asset_media_insert" ON "public"."inventory_asset_media"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_asset_media_select" ON "public"."inventory_asset_media"
  FOR SELECT
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.view'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_assets_delete_members" ON "public"."inventory_assets"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "inventory_assets_insert_members" ON "public"."inventory_assets"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "inventory_assets_select_members" ON "public"."inventory_assets"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "inventory_assets_subscription_delete" ON "public"."inventory_assets"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_assets_subscription_insert" ON "public"."inventory_assets"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_assets_subscription_select" ON "public"."inventory_assets"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.view'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_assets_subscription_update" ON "public"."inventory_assets"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_assets_update_members" ON "public"."inventory_assets"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "inventory_costs_delete_admins" ON "public"."inventory_costs"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "inventory_costs_insert_members" ON "public"."inventory_costs"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.is_tenant_member(tenant_id) AND ((created_by IS NULL) OR (created_by = auth.uid()))));

CREATE POLICY "inventory_costs_select_members" ON "public"."inventory_costs"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "inventory_costs_subscription_delete" ON "public"."inventory_costs"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_costs_subscription_insert" ON "public"."inventory_costs"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_costs_subscription_select" ON "public"."inventory_costs"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.view'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_costs_subscription_update" ON "public"."inventory_costs"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_costs_update_members" ON "public"."inventory_costs"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "inventory_inspections_delete_admins" ON "public"."inventory_inspections"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "inventory_inspections_insert_members" ON "public"."inventory_inspections"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.is_tenant_member(tenant_id) AND ((inspected_by IS NULL) OR (inspected_by = auth.uid()))));

CREATE POLICY "inventory_inspections_select_members" ON "public"."inventory_inspections"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "inventory_inspections_subscription_delete" ON "public"."inventory_inspections"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_inspections_subscription_insert" ON "public"."inventory_inspections"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_inspections_subscription_select" ON "public"."inventory_inspections"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.view'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_inspections_subscription_update" ON "public"."inventory_inspections"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_inspections_update_members" ON "public"."inventory_inspections"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "inventory_movements_insert_members" ON "public"."inventory_movements"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.is_tenant_member(tenant_id) AND ((actor_user_id IS NULL) OR (actor_user_id = auth.uid()))));

CREATE POLICY "inventory_movements_select_members" ON "public"."inventory_movements"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "inventory_movements_subscription_insert" ON "public"."inventory_movements"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "inventory_movements_subscription_select" ON "public"."inventory_movements"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'inventory.view'::text) AND private.has_tenant_feature(tenant_id, 'module.inventory'::text)));

CREATE POLICY "ledger_entries_finance_delete" ON "public"."ledger_entries"
  FOR DELETE
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'::text));

CREATE POLICY "ledger_entries_finance_insert" ON "public"."ledger_entries"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'::text));

CREATE POLICY "ledger_entries_finance_select" ON "public"."ledger_entries"
  FOR SELECT
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.view'::text));

CREATE POLICY "ledger_entries_finance_update" ON "public"."ledger_entries"
  FOR UPDATE
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'::text))
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'::text));

CREATE POLICY "listing_events_subscription_delete" ON "public"."listing_events"
  FOR DELETE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "listing_events_subscription_insert" ON "public"."listing_events"
  FOR INSERT
  TO PUBLIC
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text) AND ((actor_user_id IS NULL) OR
    (actor_user_id = auth.uid()))));

CREATE POLICY "listing_events_subscription_select" ON "public"."listing_events"
  FOR SELECT
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.view'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "listing_media_delete" ON "public"."listing_media"
  FOR DELETE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "listing_media_insert" ON "public"."listing_media"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "listing_media_select" ON "public"."listing_media"
  FOR SELECT
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.view'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "listings_subscription_delete" ON "public"."listings"
  FOR DELETE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "listings_subscription_insert" ON "public"."listings"
  FOR INSERT
  TO PUBLIC
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text) AND ((created_by IS NULL) OR
    (created_by = auth.uid()))));

CREATE POLICY "listings_subscription_select" ON "public"."listings"
  FOR SELECT
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.view'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "listings_subscription_update" ON "public"."listings"
  FOR UPDATE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "media_assets_delete_admins" ON "public"."media_assets"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "media_assets_insert_members" ON "public"."media_assets"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.is_tenant_member(tenant_id) AND ((created_by IS NULL) OR (created_by = auth.uid()))));

CREATE POLICY "media_assets_select_members" ON "public"."media_assets"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "media_assets_update_members" ON "public"."media_assets"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "notification_event_log_member_read" ON "public"."notification_event_log"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "notification_events_member_read" ON "public"."notification_events"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "notification_queue_member_read" ON "public"."notification_queue"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "notification_templates_admin_write" ON "public"."notification_templates"
  FOR ALL
  TO "authenticated"
  USING (((tenant_id IS NOT NULL) AND private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text)))
  WITH CHECK (((tenant_id IS NOT NULL) AND private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text)));

CREATE POLICY "notification_templates_member_read" ON "public"."notification_templates"
  FOR SELECT
  TO "authenticated"
  USING (((tenant_id IS NULL) OR private.is_tenant_member(tenant_id, auth.uid())));

CREATE POLICY "offer_events_subscription_delete" ON "public"."offer_events"
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'offers.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.offers'::text)));

CREATE POLICY "offer_events_subscription_insert" ON "public"."offer_events"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'offers.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.offers'::text) AND ((actor_user_id IS NULL) OR
    (actor_user_id = auth.uid()))));

CREATE POLICY "offer_events_subscription_select" ON "public"."offer_events"
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'offers.view'::text) AND private.has_tenant_feature(tenant_id, 'module.offers'::text)));

CREATE POLICY "offers_select_members" ON "public"."offers"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "offers_subscription_delete" ON "public"."offers"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'offers.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.offers'::text)));

CREATE POLICY "offers_subscription_insert" ON "public"."offers"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'offers.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.offers'::text) AND (status = 'draft'::text)));

CREATE POLICY "offers_subscription_select" ON "public"."offers"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'offers.view'::text) AND private.has_tenant_feature(tenant_id, 'module.offers'::text)));

CREATE POLICY "offers_subscription_update" ON "public"."offers"
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'offers.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.offers'::text)))
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'offers.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.offers'::text) AND (status = 'draft'::text)));

CREATE POLICY "payment_provider_connections_admin_write" ON "public"."payment_provider_connections"
  FOR ALL
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text))
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text));

CREATE POLICY "payment_provider_connections_member_read" ON "public"."payment_provider_connections"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "payment_provider_customers_admin_write" ON "public"."payment_provider_customers"
  FOR ALL
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'::text))
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'::text));

CREATE POLICY "payment_provider_customers_member_read" ON "public"."payment_provider_customers"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "payment_records_finance_delete" ON "public"."payment_records"
  FOR DELETE
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'::text));

CREATE POLICY "payment_records_finance_insert" ON "public"."payment_records"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'::text));

CREATE POLICY "payment_records_finance_select" ON "public"."payment_records"
  FOR SELECT
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.view'::text));

CREATE POLICY "payment_records_finance_update" ON "public"."payment_records"
  FOR UPDATE
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'::text))
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'finance.manage'::text));

CREATE POLICY "payment_webhook_events_admin_read" ON "public"."payment_webhook_events"
  FOR SELECT
  TO "authenticated"
  USING (((tenant_id IS NOT NULL) AND private.has_tenant_permission(tenant_id, auth.uid(), 'finance.view'::text)));

CREATE POLICY "permissions_active_read" ON "public"."permissions"
  FOR SELECT
  TO "authenticated"
  USING ((active = true));

CREATE POLICY "plan_features_active_read" ON "public"."plan_features"
  FOR SELECT
  TO "authenticated"
  USING (((enabled = true) AND (EXISTS ( SELECT 1
   FROM public.plans pl
  WHERE ((pl.id = plan_features.plan_id) AND pl.active)))));

CREATE POLICY "plan_features_select_active_plans" ON "public"."plan_features"
  FOR SELECT
  TO "anon", "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.plans p
  WHERE ((p.id = plan_features.plan_id) AND (p.active = true)))));

CREATE POLICY "plans_active_read" ON "public"."plans"
  FOR SELECT
  TO "authenticated"
  USING ((active = true));

CREATE POLICY "plans_select_active" ON "public"."plans"
  FOR SELECT
  TO "anon", "authenticated"
  USING ((active = true));

CREATE POLICY "platform_email_settings_owner_read" ON "public"."platform_email_settings"
  FOR SELECT
  TO "authenticated"
  USING (private.is_platform_owner(auth.uid()));

CREATE POLICY "platform_email_settings_owner_write" ON "public"."platform_email_settings"
  FOR ALL
  TO "authenticated"
  USING (private.is_platform_owner(auth.uid()))
  WITH CHECK (private.is_platform_owner(auth.uid()));

CREATE POLICY "platform_memberships_select_self" ON "public"."platform_memberships"
  FOR SELECT
  TO "authenticated"
  USING ((user_id = auth.uid()));

CREATE POLICY "published_site_index_public_select" ON "public"."published_site_index"
  FOR SELECT
  TO "anon", "authenticated"
  USING (true);

CREATE POLICY "retail_order_items_subscription_delete" ON "public"."retail_order_items"
  FOR DELETE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.orders'::text)));

CREATE POLICY "retail_order_items_subscription_insert" ON "public"."retail_order_items"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.orders'::text)));

CREATE POLICY "retail_order_items_subscription_select" ON "public"."retail_order_items"
  FOR SELECT
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.view'::text) AND private.has_tenant_feature(tenant_id, 'module.orders'::text)));

CREATE POLICY "retail_order_items_subscription_update" ON "public"."retail_order_items"
  FOR UPDATE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.orders'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.orders'::text)));

CREATE POLICY "retail_order_trade_ins_subscription_delete" ON "public"."retail_order_trade_ins"
  FOR DELETE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.trade_in'::text)));

CREATE POLICY "retail_order_trade_ins_subscription_insert" ON "public"."retail_order_trade_ins"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.trade_in'::text)));

CREATE POLICY "retail_order_trade_ins_subscription_select" ON "public"."retail_order_trade_ins"
  FOR SELECT
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.view'::text) AND private.has_tenant_feature(tenant_id, 'module.trade_in'::text)));

CREATE POLICY "retail_order_trade_ins_subscription_update" ON "public"."retail_order_trade_ins"
  FOR UPDATE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.trade_in'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.trade_in'::text)));

CREATE POLICY "retail_orders_subscription_delete" ON "public"."retail_orders"
  FOR DELETE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.orders'::text)));

CREATE POLICY "retail_orders_subscription_insert" ON "public"."retail_orders"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.orders'::text)));

CREATE POLICY "retail_orders_subscription_select" ON "public"."retail_orders"
  FOR SELECT
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.view'::text) AND private.has_tenant_feature(tenant_id, 'module.orders'::text)));

CREATE POLICY "retail_orders_subscription_update" ON "public"."retail_orders"
  FOR UPDATE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.orders'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'orders.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.orders'::text)));

CREATE POLICY "return_events_delete_admins" ON "public"."return_events"
  FOR DELETE
  TO "authenticated"
  USING ((private.is_tenant_admin(tenant_id) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR private.has_tenant_feature(tenant_id, 'module.orders'::text))));

CREATE POLICY "return_events_insert_members" ON "public"."return_events"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    ((private.is_tenant_member(tenant_id) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR private.has_tenant_feature(tenant_id, 'module.orders'::text)) AND
    ((actor_user_id IS NULL) OR (actor_user_id = auth.uid()))));

CREATE POLICY "return_events_select_members" ON "public"."return_events"
  FOR SELECT
  TO "authenticated"
  USING ((private.is_tenant_member(tenant_id) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR private.has_tenant_feature(tenant_id, 'module.orders'::text))));

CREATE POLICY "return_resolutions_delete_admins" ON "public"."return_resolutions"
  FOR DELETE
  TO "authenticated"
  USING ((private.is_tenant_admin(tenant_id) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR private.has_tenant_feature(tenant_id, 'module.orders'::text))));

CREATE POLICY "return_resolutions_insert_members" ON "public"."return_resolutions"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    ((private.is_tenant_member(tenant_id) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR private.has_tenant_feature(tenant_id, 'module.orders'::text)) AND
    ((resolved_by IS NULL) OR (resolved_by = auth.uid()))));

CREATE POLICY "return_resolutions_select_members" ON "public"."return_resolutions"
  FOR SELECT
  TO "authenticated"
  USING ((private.is_tenant_member(tenant_id) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR private.has_tenant_feature(tenant_id, 'module.orders'::text))));

CREATE POLICY "return_resolutions_update_members" ON "public"."return_resolutions"
  FOR UPDATE
  TO "authenticated"
  USING ((private.is_tenant_member(tenant_id) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR private.has_tenant_feature(tenant_id, 'module.orders'::text))))
  WITH
    CHECK ((private.is_tenant_member(tenant_id) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR private.has_tenant_feature(tenant_id, 'module.orders'::text))));

CREATE POLICY "returns_subscription_delete" ON "public"."returns"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'returns.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.orders'::text))));

CREATE POLICY "returns_subscription_insert" ON "public"."returns"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'returns.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.orders'::text))));

CREATE POLICY "returns_subscription_select" ON "public"."returns"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'returns.view'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.orders'::text))));

CREATE POLICY "returns_subscription_update" ON "public"."returns"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'returns.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.orders'::text))))
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'returns.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.orders'::text))));

CREATE POLICY "role_permissions_read" ON "public"."role_permissions"
  FOR SELECT
  TO "authenticated"
  USING (((EXISTS ( SELECT 1
   FROM public.roles r
  WHERE ((r.id = role_permissions.role_id) AND r.active))) AND (EXISTS ( SELECT 1
   FROM public.permissions p
  WHERE ((p.id = role_permissions.permission_id) AND p.active)))));

CREATE POLICY "roles_active_read" ON "public"."roles"
  FOR SELECT
  TO "authenticated"
  USING ((active = true));

CREATE POLICY "sales_channels_subscription_delete" ON "public"."sales_channels"
  FOR DELETE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "sales_channels_subscription_insert" ON "public"."sales_channels"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "sales_channels_subscription_select" ON "public"."sales_channels"
  FOR SELECT
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.view'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "sales_channels_subscription_update" ON "public"."sales_channels"
  FOR UPDATE
  TO PUBLIC
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'selling.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.selling'::text)));

CREATE POLICY "shipping_provider_catalog_public_select" ON "public"."shipping_provider_catalog"
  FOR SELECT
  TO "authenticated"
  USING ((enabled = true));

CREATE POLICY "shipping_provider_connections_admin_write" ON "public"."shipping_provider_connections"
  FOR ALL
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text))
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text));

CREATE POLICY "shipping_provider_connections_member_read" ON "public"."shipping_provider_connections"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "shipping_quote_sessions_customer_select" ON "public"."shipping_quote_sessions"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.customers c
  WHERE ((c.id = shipping_quote_sessions.customer_id) AND (c.auth_user_id = auth.uid()) AND (c.tenant_id = shipping_quote_sessions.tenant_id)))));

CREATE POLICY "shipping_quote_sessions_member_select" ON "public"."shipping_quote_sessions"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "shipping_service_catalog_read" ON "public"."shipping_service_catalog"
  FOR SELECT
  TO "authenticated"
  USING ((active = true));

CREATE POLICY "site_revisions_manage_insert" ON "public"."site_revisions"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (((status = 'draft'::text) AND (created_by = ( SELECT auth.uid() AS uid)) AND private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text)));

CREATE POLICY "site_revisions_manage_update" ON "public"."site_revisions"
  FOR UPDATE
  TO "authenticated"
  USING (((status = 'draft'::text) AND private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text)))
  WITH CHECK (((status = 'draft'::text) AND private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text)));

CREATE POLICY "site_revisions_member_select" ON "public"."site_revisions"
  FOR SELECT
  TO "authenticated"
  USING ((private.is_tenant_member(tenant_id) AND private.has_tenant_feature(tenant_id, 'website.editor'::text)));

CREATE POLICY "tenant_buying_condition_rules_delete" ON "public"."tenant_buying_condition_rules"
  FOR DELETE
  TO PUBLIC
  USING (private.can_tenant(tenant_id, 'buying.manage'::text, 'module.buying'::text));

CREATE POLICY "tenant_buying_condition_rules_insert" ON "public"."tenant_buying_condition_rules"
  FOR INSERT
  TO PUBLIC
  WITH CHECK (private.can_tenant(tenant_id, 'buying.manage'::text, 'module.buying'::text));

CREATE POLICY "tenant_buying_condition_rules_select" ON "public"."tenant_buying_condition_rules"
  FOR SELECT
  TO PUBLIC
  USING (private.can_tenant(tenant_id, 'buying.manage'::text, 'module.buying'::text));

CREATE POLICY "tenant_buying_condition_rules_update" ON "public"."tenant_buying_condition_rules"
  FOR UPDATE
  TO PUBLIC
  USING (private.can_tenant(tenant_id, 'buying.manage'::text, 'module.buying'::text))
  WITH CHECK (private.can_tenant(tenant_id, 'buying.manage'::text, 'module.buying'::text));

CREATE POLICY "tenant_buying_manufacturers_delete" ON "public"."tenant_buying_manufacturers"
  FOR DELETE
  TO PUBLIC
  USING (private.can_tenant(tenant_id, 'buying.manage'::text, 'module.buying'::text));

CREATE POLICY "tenant_buying_manufacturers_insert" ON "public"."tenant_buying_manufacturers"
  FOR INSERT
  TO PUBLIC
  WITH CHECK (private.can_tenant(tenant_id, 'buying.manage'::text, 'module.buying'::text));

CREATE POLICY "tenant_buying_manufacturers_select" ON "public"."tenant_buying_manufacturers"
  FOR SELECT
  TO PUBLIC
  USING (private.can_tenant(tenant_id, 'buying.manage'::text, 'module.buying'::text));

CREATE POLICY "tenant_buying_manufacturers_update" ON "public"."tenant_buying_manufacturers"
  FOR UPDATE
  TO PUBLIC
  USING (private.can_tenant(tenant_id, 'buying.manage'::text, 'module.buying'::text))
  WITH CHECK (private.can_tenant(tenant_id, 'buying.manage'::text, 'module.buying'::text));

CREATE POLICY "tenant_buying_products_delete" ON "public"."tenant_buying_products"
  FOR DELETE
  TO "authenticated"
  USING (( SELECT private.can_tenant(tenant_buying_products.tenant_id, 'buying.manage'::text, 'module.buying'::text) AS can_tenant));

CREATE POLICY "tenant_buying_products_insert" ON "public"."tenant_buying_products"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (( SELECT private.can_tenant(tenant_buying_products.tenant_id, 'buying.manage'::text, 'module.buying'::text) AS can_tenant));

CREATE POLICY "tenant_buying_products_select" ON "public"."tenant_buying_products"
  FOR SELECT
  TO "authenticated"
  USING (( SELECT private.can_tenant(tenant_buying_products.tenant_id, 'buying.manage'::text, 'module.buying'::text) AS can_tenant));

CREATE POLICY "tenant_buying_products_update" ON "public"."tenant_buying_products"
  FOR UPDATE
  TO "authenticated"
  USING (( SELECT private.can_tenant(tenant_buying_products.tenant_id, 'buying.manage'::text, 'module.buying'::text) AS can_tenant))
  WITH CHECK (( SELECT private.can_tenant(tenant_buying_products.tenant_id, 'buying.manage'::text, 'module.buying'::text) AS can_tenant));

CREATE POLICY "tenant_buying_research_delete" ON "public"."tenant_buying_research"
  FOR DELETE
  TO "authenticated"
  USING (( SELECT private.can_tenant(tenant_buying_research.tenant_id, 'buying.manage'::text, 'module.buying'::text) AS can_tenant));

CREATE POLICY "tenant_buying_research_insert" ON "public"."tenant_buying_research"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    ((( SELECT private.can_tenant(tenant_buying_research.tenant_id, 'buying.manage'::text, 'module.buying'::text) AS can_tenant) AND (created_by = ( SELECT auth.uid() AS uid))));

CREATE POLICY "tenant_buying_research_select" ON "public"."tenant_buying_research"
  FOR SELECT
  TO "authenticated"
  USING (( SELECT private.can_tenant(tenant_buying_research.tenant_id, 'buying.manage'::text, 'module.buying'::text) AS can_tenant));

CREATE POLICY "tenant_buying_research_update" ON "public"."tenant_buying_research"
  FOR UPDATE
  TO "authenticated"
  USING (( SELECT private.can_tenant(tenant_buying_research.tenant_id, 'buying.manage'::text, 'module.buying'::text) AS can_tenant))
  WITH CHECK (( SELECT private.can_tenant(tenant_buying_research.tenant_id, 'buying.manage'::text, 'module.buying'::text) AS can_tenant));

CREATE POLICY "tenant_catalogue_selections_delete" ON "public"."tenant_catalogue_selections"
  FOR DELETE
  TO PUBLIC
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "tenant_catalogue_selections_insert" ON "public"."tenant_catalogue_selections"
  FOR INSERT
  TO PUBLIC
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "tenant_catalogue_selections_select" ON "public"."tenant_catalogue_selections"
  FOR SELECT
  TO PUBLIC
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.view'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "tenant_catalogue_selections_update" ON "public"."tenant_catalogue_selections"
  FOR UPDATE
  TO PUBLIC
  USING
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))))
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'categories.manage'::text) AND (private.has_tenant_feature(tenant_id, 'module.buying'::text) OR
    private.has_tenant_feature(tenant_id, 'module.selling'::text))));

CREATE POLICY "tenant_domain_orders_manage_delete" ON "public"."tenant_domain_orders"
  FOR DELETE
  TO "authenticated"
  USING (private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text));

CREATE POLICY "tenant_domain_orders_manage_insert" ON "public"."tenant_domain_orders"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text));

CREATE POLICY "tenant_domain_orders_manage_update" ON "public"."tenant_domain_orders"
  FOR UPDATE
  TO "authenticated"
  USING (private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text))
  WITH CHECK (private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text));

CREATE POLICY "tenant_domain_orders_member_select" ON "public"."tenant_domain_orders"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "tenant_domains_manage_delete" ON "public"."tenant_domains"
  FOR DELETE
  TO "authenticated"
  USING (private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text));

CREATE POLICY "tenant_domains_manage_insert" ON "public"."tenant_domains"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text));

CREATE POLICY "tenant_domains_manage_update" ON "public"."tenant_domains"
  FOR UPDATE
  TO "authenticated"
  USING (private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text))
  WITH CHECK (private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text));

CREATE POLICY "tenant_domains_member_select" ON "public"."tenant_domains"
  FOR SELECT
  TO "authenticated"
  USING ((private.is_tenant_member(tenant_id) AND private.has_tenant_feature(tenant_id, 'website.editor'::text)));

CREATE POLICY "tenant_email_notification_settings_admin_write" ON "public"."tenant_email_notification_settings"
  FOR ALL
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text))
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text));

CREATE POLICY "tenant_email_notification_settings_member_read" ON "public"."tenant_email_notification_settings"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "tenant_email_settings_admin_write" ON "public"."tenant_email_settings"
  FOR ALL
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text))
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text));

CREATE POLICY "tenant_email_settings_member_read" ON "public"."tenant_email_settings"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "memberships_delete_admins" ON "public"."tenant_memberships"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "memberships_insert_admins" ON "public"."tenant_memberships"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "memberships_select_self_or_admin" ON "public"."tenant_memberships"
  FOR SELECT
  TO "authenticated"
  USING (((user_id = auth.uid()) OR private.is_tenant_admin(tenant_id)));

CREATE POLICY "memberships_update_admins" ON "public"."tenant_memberships"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id))
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "tenant_payment_methods_select" ON "public"."tenant_payment_methods"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "tenant_payment_methods_write" ON "public"."tenant_payment_methods"
  FOR ALL
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id))
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "tenant_public_profiles_manage_insert" ON "public"."tenant_public_profiles"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text));

CREATE POLICY "tenant_public_profiles_manage_update" ON "public"."tenant_public_profiles"
  FOR UPDATE
  TO "authenticated"
  USING (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text))
  WITH CHECK (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'::text));

CREATE POLICY "tenant_public_profiles_public_read" ON "public"."tenant_public_profiles"
  FOR SELECT
  TO "anon", "authenticated"
  USING (( SELECT private.is_active_tenant(tenant_public_profiles.tenant_id) AS is_active_tenant));

CREATE POLICY "tenant_shipping_services_read" ON "public"."tenant_shipping_services"
  FOR SELECT
  TO "authenticated"
  USING ((EXISTS ( SELECT 1
   FROM public.tenant_memberships m
  WHERE ((m.tenant_id = tenant_shipping_services.tenant_id) AND (m.user_id = auth.uid()) AND (m.status = 'active'::text)))));

CREATE POLICY "tenant_site_state_manage_update" ON "public"."tenant_site_state"
  FOR UPDATE
  TO "authenticated"
  USING (private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text))
  WITH CHECK (private.can_tenant(tenant_id, 'website.manage'::text, 'website.editor'::text));

CREATE POLICY "tenant_site_state_member_select" ON "public"."tenant_site_state"
  FOR SELECT
  TO "authenticated"
  USING ((private.is_tenant_member(tenant_id) AND private.has_tenant_feature(tenant_id, 'website.editor'::text)));

CREATE POLICY "subscriptions_delete_admins" ON "public"."tenant_subscriptions"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "subscriptions_insert_admins" ON "public"."tenant_subscriptions"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "subscriptions_select_admins" ON "public"."tenant_subscriptions"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "subscriptions_update_admins" ON "public"."tenant_subscriptions"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id))
  WITH CHECK (private.is_tenant_admin(tenant_id));

CREATE POLICY "tenants_select_members" ON "public"."tenants"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(id));

CREATE POLICY "tenants_update_admins" ON "public"."tenants"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_admin(id))
  WITH CHECK (private.is_tenant_admin(id));

CREATE POLICY "trade_in_subscription_delete" ON "public"."trade_in_transactions"
  AS RESTRICTIVE
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.trade_in'::text)));

CREATE POLICY "trade_in_subscription_insert" ON "public"."trade_in_transactions"
  AS RESTRICTIVE
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.trade_in'::text)));

CREATE POLICY "trade_in_subscription_select" ON "public"."trade_in_transactions"
  AS RESTRICTIVE
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.view'::text) AND private.has_tenant_feature(tenant_id, 'module.trade_in'::text)));

CREATE POLICY "trade_in_subscription_update" ON "public"."trade_in_transactions"
  AS RESTRICTIVE
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.trade_in'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'buying.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.trade_in'::text)));

CREATE POLICY "trade_in_transactions_delete_admins" ON "public"."trade_in_transactions"
  FOR DELETE
  TO "authenticated"
  USING (private.is_tenant_admin(tenant_id));

CREATE POLICY "trade_in_transactions_insert_members" ON "public"."trade_in_transactions"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.is_tenant_member(tenant_id) AND ((created_by IS NULL) OR (created_by = auth.uid()))));

CREATE POLICY "trade_in_transactions_select_members" ON "public"."trade_in_transactions"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id));

CREATE POLICY "trade_in_transactions_update_members" ON "public"."trade_in_transactions"
  FOR UPDATE
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id))
  WITH CHECK (private.is_tenant_member(tenant_id));

CREATE POLICY "trading_value_components_valuation_delete" ON "public"."trading_value_components"
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)));

CREATE POLICY "trading_value_components_valuation_insert" ON "public"."trading_value_components"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)));

CREATE POLICY "trading_value_components_valuation_select" ON "public"."trading_value_components"
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.view'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)));

CREATE POLICY "trading_value_components_valuation_update" ON "public"."trading_value_components"
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)));

CREATE POLICY "trading_values_valuation_delete" ON "public"."trading_values"
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)));

CREATE POLICY "trading_values_valuation_insert" ON "public"."trading_values"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text) AND (status =
    'draft'::text)));

CREATE POLICY "trading_values_valuation_select" ON "public"."trading_values"
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.view'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)));

CREATE POLICY "trading_values_valuation_update" ON "public"."trading_values"
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)))
  WITH
    CHECK
    ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text) AND (status =
    'draft'::text)));

CREATE POLICY "valuation_rules_valuation_delete" ON "public"."valuation_rules"
  FOR DELETE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)));

CREATE POLICY "valuation_rules_valuation_insert" ON "public"."valuation_rules"
  FOR INSERT
  TO "authenticated"
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)));

CREATE POLICY "valuation_rules_valuation_select" ON "public"."valuation_rules"
  FOR SELECT
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.view'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)));

CREATE POLICY "valuation_rules_valuation_update" ON "public"."valuation_rules"
  FOR UPDATE
  TO "authenticated"
  USING ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)))
  WITH CHECK ((private.has_tenant_permission(tenant_id, auth.uid(), 'valuation.manage'::text) AND private.has_tenant_feature(tenant_id, 'module.valuation'::text)));

CREATE POLICY "workflow_transitions_insert_members" ON "public"."workflow_transitions"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "workflow_transitions_select_members" ON "public"."workflow_transitions"
  FOR SELECT
  TO "authenticated"
  USING (private.is_tenant_member(tenant_id, auth.uid()));

CREATE POLICY "tradeflow_customer_shipping_files" ON "storage"."objects"
  FOR SELECT
  TO "authenticated"
  USING
    (((bucket_id = 'tradeflow-media'::text) AND (split_part(name, '/'::text, 2) = 'buying-items'::text) AND ((split_part(name, '/'::text, 4) ~~ 'shipping-label-%'::text) OR
    (split_part(name, '/'::text, 4) ~~ 'shipping-qr-%'::text)) AND
    private.customer_can_access_buying_item_shipping((split_part(name, '/'::text, 1))::uuid, (split_part(name, '/'::text, 3))::uuid, auth.uid())));

CREATE POLICY "tradeflow_media_buying_item_return_customer_select" ON "storage"."objects"
  FOR SELECT
  TO "authenticated"
  USING
    (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'buying-items'::text) AND ((storage.foldername(name))[4] ~~ 'return-label-%'::text) AND (EXISTS (
    SELECT 1
   FROM ((public.buying_items bi
     JOIN public.buying_requests br ON (((br.id = bi.buying_request_id) AND (br.tenant_id = bi.tenant_id))))
     JOIN public.customers c ON (((c.id = br.customer_id) AND (c.tenant_id = bi.tenant_id))))
  WHERE ((bi.tenant_id = ((storage.foldername(objects.name))[1])::uuid) AND (bi.id = ((storage.foldername(objects.name))[3])::uuid) AND (c.auth_user_id = auth.uid()))))));

CREATE POLICY "tradeflow_media_buying_item_return_subscriber_insert" ON "storage"."objects"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'buying-items'::text) AND ((storage.foldername(name))[4] ~~ 'return-label-%'::text) AND
    private.is_tenant_member(((storage.foldername(name))[1])::uuid, auth.uid())));

CREATE POLICY "tradeflow_media_buying_item_shipping_customer_select" ON "storage"."objects"
  FOR SELECT
  TO "authenticated"
  USING
    (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'buying-items'::text) AND
    private.customer_can_access_buying_item_shipping(((storage.foldername(name))[1])::uuid, ((storage.foldername(name))[3])::uuid, auth.uid())));

CREATE POLICY "tradeflow_media_buying_item_shipping_subscriber_insert" ON "storage"."objects"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'buying-items'::text) AND (((storage.foldername(name))[4] ~~ 'shipping-label-%'::text) OR
    ((storage.foldername(name))[4] ~~ 'shipping-qr-%'::text)) AND private.is_tenant_member(((storage.foldername(name))[1])::uuid, auth.uid())));

CREATE POLICY "tradeflow_media_customer_buying_subscriber_select" ON "storage"."objects"
  FOR SELECT
  TO "authenticated"
  USING
    (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'customer-buying'::text) AND private.is_tenant_member(((storage.foldername(name))[1])::uuid,
    auth.uid())));

CREATE POLICY "tradeflow_media_customer_return_label_customer_select" ON "storage"."objects"
  FOR SELECT
  TO "authenticated"
  USING (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'returns'::text) AND (EXISTS ( SELECT 1
   FROM (public.returns r
     JOIN public.customers c ON (((c.id = r.customer_id) AND (c.tenant_id = r.tenant_id))))
  WHERE ((r.tenant_id = ((storage.foldername(objects.name))[1])::uuid) AND (r.id = ((storage.foldername(objects.name))[3])::uuid) AND (c.auth_user_id = auth.uid()))))));

CREATE POLICY "tradeflow_media_customer_return_label_subscriber_insert" ON "storage"."objects"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'returns'::text) AND private.is_tenant_member(((storage.foldername(name))[1])::uuid, auth.uid())));

CREATE POLICY "tradeflow_media_customer_return_label_subscriber_select" ON "storage"."objects"
  FOR SELECT
  TO "authenticated"
  USING
    (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'returns'::text) AND private.is_tenant_member(((storage.foldername(name))[1])::uuid, auth.uid())));

CREATE POLICY "tradeflow_media_delete" ON "storage"."objects"
  FOR DELETE
  TO PUBLIC
  USING (((bucket_id = 'tradeflow-media'::text) AND private.has_tenant_permission((split_part(name, '/'::text, 1))::uuid, auth.uid(), 'inventory.manage'::text)));

CREATE POLICY "tradeflow_media_insert" ON "storage"."objects"
  FOR INSERT
  TO PUBLIC
  WITH CHECK (((bucket_id = 'tradeflow-media'::text) AND private.is_tenant_member((split_part(name, '/'::text, 1))::uuid)));

CREATE POLICY "tradeflow_media_retail_fulfilment_customer_select" ON "storage"."objects"
  FOR SELECT
  TO "authenticated"
  USING (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'fulfilments'::text) AND (EXISTS ( SELECT 1
   FROM ((public.fulfilments f
     JOIN public.retail_orders o ON (((o.tenant_id = f.tenant_id) AND (o.id = f.retail_order_id))))
     JOIN public.customers c ON (((c.tenant_id = o.tenant_id) AND (c.id = o.customer_id))))
  WHERE (((f.tenant_id)::text = (storage.foldername(objects.name))[1]) AND ((f.id)::text = (storage.foldername(objects.name))[3]) AND (c.auth_user_id = auth.uid()))))));

CREATE POLICY "tradeflow_media_select" ON "storage"."objects"
  FOR SELECT
  TO PUBLIC
  USING (((bucket_id = 'tradeflow-media'::text) AND private.is_tenant_member((split_part(name, '/'::text, 1))::uuid)));

CREATE POLICY "tradeflow_media_shipping_label_customer_select" ON "storage"."objects"
  FOR SELECT
  TO "authenticated"
  USING (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'acquisitions'::text) AND (EXISTS ( SELECT 1
   FROM (public.acquisitions a
     JOIN public.customers c ON (((c.id = a.customer_id) AND (c.tenant_id = a.tenant_id))))
  WHERE (((a.tenant_id)::text = (storage.foldername(objects.name))[1]) AND ((a.id)::text = (storage.foldername(objects.name))[3]) AND (c.auth_user_id = auth.uid()))))));

CREATE POLICY "tradeflow_media_shipping_label_subscriber_insert" ON "storage"."objects"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'acquisitions'::text) AND private.is_tenant_member(((storage.foldername(name))[1])::uuid,
    auth.uid())));

CREATE POLICY "tradeflow_media_shipping_label_subscriber_select" ON "storage"."objects"
  FOR SELECT
  TO "authenticated"
  USING
    (((bucket_id = 'tradeflow-media'::text) AND ((storage.foldername(name))[2] = 'acquisitions'::text) AND private.is_tenant_member(((storage.foldername(name))[1])::uuid,
    auth.uid())));

CREATE POLICY "tradeflow_media_update" ON "storage"."objects"
  FOR UPDATE
  TO PUBLIC
  USING (((bucket_id = 'tradeflow-media'::text) AND private.is_tenant_member((split_part(name, '/'::text, 1))::uuid)))
  WITH CHECK (((bucket_id = 'tradeflow-media'::text) AND private.is_tenant_member((split_part(name, '/'::text, 1))::uuid)));

CREATE POLICY "tradeflow_published_listing_media_public_select" ON "storage"."objects"
  FOR SELECT
  TO PUBLIC
  USING (((bucket_id = 'tradeflow-media'::text) AND public.is_published_tradeflow_media(bucket_id, name)));

CREATE POLICY "tradeflow_site_media_delete" ON "storage"."objects"
  FOR DELETE
  TO "authenticated"
  USING (((bucket_id = 'tradeflow-site-media'::text) AND private.can_tenant(((storage.foldername(name))[1])::uuid, 'website.manage'::text, 'website.editor'::text)));

CREATE POLICY "tradeflow_site_media_insert" ON "storage"."objects"
  FOR INSERT
  TO "authenticated"
  WITH
    CHECK
    (((bucket_id = 'tradeflow-site-media'::text) AND private.is_tenant_member(((storage.foldername(name))[1])::uuid) AND private.can_tenant(((storage.foldername(name))[1])::uuid,
    'website.manage'::text, 'website.editor'::text)));

CREATE POLICY "tradeflow_site_media_update" ON "storage"."objects"
  FOR UPDATE
  TO "authenticated"
  USING (((bucket_id = 'tradeflow-site-media'::text) AND private.can_tenant(((storage.foldername(name))[1])::uuid, 'website.manage'::text, 'website.editor'::text)))
  WITH CHECK (((bucket_id = 'tradeflow-site-media'::text) AND private.can_tenant(((storage.foldername(name))[1])::uuid, 'website.manage'::text, 'website.editor'::text)));

COMMENT ON COLUMN "public"."acquisition_fulfilments"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."acquisition_items"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."acquisitions"."shipping_method" IS 'Shipping route for the acquisition: automated courier integration or subscriber override/manual shipping.';

COMMENT ON COLUMN "public"."acquisitions"."shipping_provider" IS 'Aggregator used for operational shipping/tracking; customer/subscriber shipping costs remain outside TradeFlow.';

COMMENT ON COLUMN "public"."acquisitions"."shipping_qr_storage_path" IS 'Optional private tradeflow-media path for a subscriber-supplied QR code image.';

COMMENT ON COLUMN "public"."acquisitions"."shipping_qr_url" IS 'Optional customer-facing QR code URL supplied by the subscriber shipping service.';

COMMENT ON COLUMN "public"."acquisitions"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."buying_requests"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."category_fields"."branch_id" IS 'Branch that owns this dynamic product property. Existing properties are assigned to their category default branch.';

COMMENT ON COLUMN "public"."category_fields"."enabled_for_buying" IS 'Whether this property is included in the Buying path for the branch.';

COMMENT ON COLUMN "public"."category_fields"."enabled_for_selling" IS 'Whether this property is included in the Selling path for the branch.';

COMMENT ON COLUMN "public"."customers"."auth_user_id" IS 'Optional Supabase Auth identity for customer self-service. Tenant-scoped; uniqueness enforced per tenant.';

COMMENT ON COLUMN "public"."fulfilments"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."inventory_assets"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."listings"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."offers"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."payment_records"."idempotency_key" IS 'Tenant-scoped key used to prevent duplicate payment creation/reprocessing.';

COMMENT ON COLUMN "public"."retail_orders"."amount_due" IS 'Authoritative amount due; browser clients cannot update.';

COMMENT ON COLUMN "public"."retail_orders"."customer_id" IS 'Optional CRM customer link; guest checkout can use captured customer_name/email instead.';

COMMENT ON COLUMN "public"."retail_orders"."discount_total" IS 'Authoritative pricing value; browser clients cannot update.';

COMMENT ON COLUMN "public"."retail_orders"."payment_status" IS 'Authoritative payment state; browser clients cannot update.';

COMMENT ON COLUMN "public"."retail_orders"."shipping_total" IS 'Authoritative pricing value; browser clients cannot update.';

COMMENT ON COLUMN "public"."retail_orders"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."retail_orders"."subtotal" IS 'Authoritative pricing value; browser clients cannot update.';

COMMENT ON COLUMN "public"."retail_orders"."tax_total" IS 'Authoritative pricing value; browser clients cannot update.';

COMMENT ON COLUMN "public"."retail_orders"."total" IS 'Authoritative pricing value; browser clients cannot update.';

COMMENT ON COLUMN "public"."retail_orders"."trade_in_credit_total" IS 'Authoritative applied trade-in credit; browser clients cannot update.';

COMMENT ON COLUMN "public"."returns"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."site_revisions"."content" IS 'Versioned website configuration snapshot. Includes site identity, homepage, navigation, theme, page configuration and the published category/configuration manifest. Operational transaction data is not stored here.';

COMMENT ON COLUMN "public"."site_revisions"."status" IS 'Publishing lifecycle controlled by the publish service. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."tenant_domains"."acquisition_source" IS 'How the domain entered TradeFlow: connected externally, purchased through TradeFlow, or transferred in.';

COMMENT ON COLUMN "public"."tenant_domains"."provider_metadata" IS 'Non-secret provider state needed for domain lifecycle reconciliation.';

COMMENT ON COLUMN "public"."tenant_domains"."registrar_domain_id" IS 'Provider-side domain identifier for purchased/transferred domains.';

COMMENT ON COLUMN "public"."tenant_domains"."registrar_provider" IS 'Provider-neutral registrar identifier; secrets are stored outside the database.';

COMMENT ON COLUMN "public"."tenant_email_settings"."sender_verification_status" IS 'Verification state for the subscriber sender address; actual provider credentials are never stored in this table.';

COMMENT ON COLUMN "public"."tenant_subscriptions"."billing_provider" IS 'Provider-neutral SaaS billing provider, e.g. stripe.';

COMMENT ON COLUMN "public"."tenant_subscriptions"."provider_customer_id" IS 'Provider-side TradeFlow subscriber customer identity.';

COMMENT ON COLUMN "public"."tenant_subscriptions"."provider_subscription_id" IS 'Provider-side TradeFlow SaaS subscription identity.';

COMMENT ON COLUMN "public"."trade_in_transactions"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."trading_values"."amount" IS 'Underlying Trading Value/reference value before transaction-specific cash or trade-in pricing.';

COMMENT ON COLUMN "public"."trading_values"."approved_by_name" IS 'Snapshot of approving staff display name for audit readability; approved_by remains the authoritative user reference.';

COMMENT ON COLUMN "public"."trading_values"."cash_price" IS 'Cash purchase price offered for an outright sale to the business.';

COMMENT ON COLUMN "public"."trading_values"."effective_from" IS 'Timestamp from which this valuation is effective.';

COMMENT ON COLUMN "public"."trading_values"."effective_to" IS 'Timestamp after which this valuation is no longer effective.';

COMMENT ON COLUMN "public"."trading_values"."status" IS 'Workflow-controlled. Direct authenticated UPDATE is intentionally denied.';

COMMENT ON COLUMN "public"."trading_values"."trade_in_price" IS 'Trade-in credit/value offered when the item is exchanged toward another purchase.';

COMMENT ON EXTENSION "pg_cron" IS 'Job scheduler for PostgreSQL';

COMMENT ON EXTENSION "pg_net" IS 'Async HTTP';

COMMENT ON FUNCTION "private"."can_tenant"(uuid, text, text) IS 'Combined authorization gate: active tenant permission plus optional active subscription feature.';

COMMENT ON FUNCTION "private"."create_tenant_with_owner"(text, text) IS 'Atomically creates a TradeFlow tenant and makes the authenticated caller its owner.';

COMMENT ON FUNCTION "private"."has_platform_owner_access"(uuid) IS 'Boolean platform-owner guard bound to the current authenticated identity.';

COMMENT ON FUNCTION "private"."is_platform_owner"(uuid) IS 'Returns true only for an explicitly provisioned active platform membership. Never grants platform ownership through tenant roles.';

COMMENT ON FUNCTION "private"."is_tenant_admin"(uuid, uuid) IS 'Security helper for tenant administration checks; intentionally not exposed to anonymous clients.';

COMMENT ON FUNCTION "private"."is_tenant_member"(uuid, uuid) IS 'Security helper for tenant membership checks; intentionally not exposed to anonymous clients.';

COMMENT ON FUNCTION "private"."queue_customer_notification"(uuid, text, text, uuid, text, text, jsonb) IS 'Server-side notification dispatcher. Checks tenant email master switch and event checkbox, resolves tenant/system template, records the event and queues one idempotent customer email. Not callable from browser clients.';

COMMENT ON FUNCTION "private"."require_platform_owner"(uuid) IS 'Authorisation guard for TradeFlow platform administration. Tenant owner/admin status is never sufficient.';

COMMENT ON FUNCTION "public"."admin_complete_test_registration"(text) IS 'TEMPORARY TEST-LAB ONLY. Creates one Admin membership for confirmed auth users in marked TradeFlow test tenants. Must be removed before production onboarding.';

COMMENT ON FUNCTION "public"."customer_accept_offer"(uuid, uuid, text) IS 'Customer-only offer acceptance boundary. Resolves customer from auth.uid(), validates tenant ownership and published/non-expired status, then atomically creates the acquisition and acquisition item.';

COMMENT ON FUNCTION "public"."customer_complete_test_registration"(text, text, text) IS 'Controlled TradeFlow test-lab onboarding only. Allows one authenticated test account to become a customer of one test tenant marked settings.test_lab=true. Remove before production onboarding.';

COMMENT ON FUNCTION "public"."customer_get_acquisitions"(uuid) IS 'Customer-only acquisition read model. Excludes internal notes/metadata.';

COMMENT ON FUNCTION "public"."customer_get_addresses"(uuid) IS 'Customer-only safe address read model. SECURITY DEFINER; explicit search_path; auth_user_id ownership required.';

COMMENT ON FUNCTION "public"."customer_get_buying_items"(uuid) IS 'Customer-only buying item read model. Excludes internal metadata.';

COMMENT ON FUNCTION "public"."customer_get_buying_requests"(uuid) IS 'Customer-only buying request read model. Excludes staff-only fields.';

COMMENT ON FUNCTION "public"."customer_get_fulfilments"(uuid) IS 'Customer-only outbound fulfilment read model. Excludes shipping address JSON and internal metadata.';

COMMENT ON FUNCTION "public"."customer_get_offers"(uuid) IS 'Customer-only offer read model. Excludes creator/internal audit fields.';

COMMENT ON FUNCTION "public"."customer_get_order_items"(uuid) IS 'Customer-only retail order item read model.';

COMMENT ON FUNCTION "public"."customer_get_order_trade_ins"(uuid) IS 'Customer-only trade-in/order bridge read model; validates same customer on both sides.';

COMMENT ON FUNCTION "public"."customer_get_orders"(uuid) IS 'Customer-only retail order read model. Excludes raw billing/shipping address JSON and internal metadata.';

COMMENT ON FUNCTION "public"."customer_get_profile"(uuid) IS 'Customer-only safe profile read model. SECURITY DEFINER; explicit search_path; auth_user_id ownership required.';

COMMENT ON FUNCTION "public"."customer_get_trade_ins"(uuid) IS 'Customer-only trade-in read model. Excludes staff notes/metadata.';

COMMENT ON FUNCTION "public"."customer_get_trading_values"(uuid) IS 'Customer-only Trading Value read model. Excludes components/source notes.';

COMMENT ON FUNCTION "public"."customer_refuse_offer"(uuid, uuid, text) IS 'Customer-only offer refusal boundary. Resolves customer from auth.uid(), validates tenant ownership and published status, then records refusal atomically.';

COMMENT ON FUNCTION "public"."customer_submit_buying_request"(uuid, text, jsonb) IS 'Authenticated customer submission boundary. Resolves customer from auth.uid(), validates tenant/category/field ownership, required buying fields and typed values, and creates the request atomically.';

COMMENT ON FUNCTION "public"."publish_site_revision"(uuid, uuid) IS 'Authoritative tenant website publication transaction. Draft changes are saved privately; only this function promotes a draft to the public published revision.';

COMMENT ON FUNCTION "public"."set_updated_at"() IS 'Internal trigger helper; not callable by client roles.';

COMMENT ON FUNCTION "public"."transition_workflow_entity"(uuid, text, uuid, text, text, text, jsonb) IS 'Authoritative tenant workflow transition boundary. Requires active tenant membership and the mapped domain manage permission; validates legal status transitions and records append-only workflow history.';

COMMENT ON TABLE "public"."acquisition_items" IS 'Tenant-scoped purchased item lines linking accepted offers/buying items to the acquisition lifecycle.';

COMMENT ON TABLE "public"."acquisitions" IS 'Tenant-scoped purchase/acquisition header. Acceptance is distinct from physical receipt.';

COMMENT ON TABLE "public"."buying_item_field_values" IS 'Typed dynamic field values for buying items; category fields remain the configuration authority.';

COMMENT ON TABLE "public"."buying_item_media" IS 'Tenant-scoped association between buying items and media assets.';

COMMENT ON TABLE "public"."buying_items" IS 'Tenant-scoped individual item within a buying request; category determines its dynamic fields.';

COMMENT ON TABLE "public"."buying_requests" IS 'Tenant-scoped buying request header; customer submits one request containing one or more buying items.';

COMMENT ON TABLE "public"."catalogue_master_branches" IS 'Standalone TradeFlow master catalogue branches. Initial seed copied from the separate GearCashOut catalogue; no runtime dependency.';

COMMENT ON TABLE "public"."catalogue_master_categories" IS 'Standalone TradeFlow master catalogue. Initial seed copied from the separate GearCashOut catalogue; no runtime dependency or foreign key to GearCashOut.';

COMMENT ON TABLE "public"."catalogue_master_manufacturers" IS 'Standalone TradeFlow master catalogue manufacturers. Initial seed copied from the separate GearCashOut catalogue; no runtime dependency.';

COMMENT ON TABLE "public"."catalogue_master_product_identifiers" IS 'Standalone TradeFlow master product identifiers copied as catalogue metadata only.';

COMMENT ON TABLE "public"."catalogue_master_products" IS 'Standalone TradeFlow master product catalogue. Product metadata only; GearCashOut market evidence/pricing is deliberately not copied or used as subscriber valuation evidence.';

COMMENT ON TABLE "public"."categories" IS 'Tenant-defined product/service categories used by TradeFlow buying and selling flows.';

COMMENT ON TABLE "public"."category_branches" IS 'Tenant category branches used to structure and independently enable buying/selling paths.';

COMMENT ON TABLE "public"."category_field_options" IS 'Selectable options for category fields such as select and multiselect fields.';

COMMENT ON TABLE "public"."category_fields" IS 'Tenant-defined dynamic fields for a category; these replace hard-coded GearCashOut product attributes.';

COMMENT ON TABLE "public"."customer_addresses" IS 'Tenant-scoped customer addresses with composite tenant/customer integrity.';

COMMENT ON TABLE "public"."customers" IS 'Tenant-scoped customer account/CRM identity for TradeFlow.';

COMMENT ON TABLE "public"."domain_tld_catalog" IS 'TradeFlow domain TLD catalogue and pricing foundation. Availability is provider-driven at search time; registrar credentials are never stored here.';

COMMENT ON TABLE "public"."email_templates" IS 'System and tenant-specific customer email templates. System templates use tenant_id NULL; tenant templates override them.';

COMMENT ON TABLE "public"."ledger_entries" IS 'Financial ledger is append-only from the browser. Entries are created by authoritative payment/order/acquisition services and cannot be edited or deleted by authenticated clients.';

COMMENT ON TABLE "public"."listing_events" IS 'Tenant-scoped listing lifecycle and price-change audit trail.';

COMMENT ON TABLE "public"."listings" IS 'Tenant-scoped public/private listing representation of a physical inventory asset.';

COMMENT ON TABLE "public"."media_assets" IS 'Tenant-scoped metadata for uploaded media; storage objects are addressed by bucket/path and are not exposed by this table alone.';

COMMENT ON TABLE "public"."notification_events" IS 'Delivery and provider event history for outbound notifications.';

COMMENT ON TABLE "public"."notification_queue" IS 'Authoritative outbound notification queue. Provider delivery is handled server-side.';

COMMENT ON TABLE "public"."offer_events" IS 'Immutable-style audit trail of offer lifecycle events.';

COMMENT ON TABLE "public"."offers" IS 'Tenant-scoped customer offers linked to an auditable Trading Value; offer lifecycle is separate from valuation lifecycle.';

COMMENT ON TABLE "public"."payment_provider_connections" IS 'Tenant payment-provider connections for customer payments and/or payouts. Never store card data, CVV, bank credentials, or provider secret keys here.';

COMMENT ON TABLE "public"."payment_provider_customers" IS 'Maps TradeFlow customers to provider-side customer identities without storing payment credentials.';

COMMENT ON TABLE "public"."payment_records" IS 'Payment records are authoritative provider/accounting records. Browser clients cannot edit or delete them.';

COMMENT ON TABLE "public"."payment_webhook_events" IS 'Provider webhook receipts are append-only audit records and cannot be edited or deleted by authenticated clients.';

COMMENT ON TABLE "public"."permissions" IS 'TradeFlow platform permission catalogue; separate from subscription features.';

COMMENT ON TABLE "public"."plan_features" IS 'Feature entitlements for each TradeFlow plan. Feature codes are capability gates, not UI-only labels.';

COMMENT ON TABLE "public"."plans" IS 'TradeFlow SaaS capability tiers. Pricing/provider identifiers are configured separately from capability definitions.';

COMMENT ON TABLE "public"."platform_memberships" IS 'TradeFlow platform-level operator boundary. Separate from tenant memberships; membership must be explicitly provisioned by trusted platform administration.';

COMMENT ON TABLE "public"."published_site_index" IS 'Controlled anonymous storefront read model. Anonymous access is intentionally limited to published public-site data; operational tenant tables are not anonymous API objects.';

COMMENT ON TABLE "public"."retail_order_items" IS 'Tenant-scoped retail order lines linking a sale to its listing and physical inventory asset.';

COMMENT ON TABLE "public"."retail_order_trade_ins" IS 'Canonical bridge between a retail order and one or more trade-in transactions. Trade-in transactions do not store a duplicate retail_order_id relationship.';

COMMENT ON TABLE "public"."retail_orders" IS 'Tenant-scoped customer sales order header. Payment and fulfilment are separate lifecycle concerns.';

COMMENT ON TABLE "public"."return_events" IS 'Immutable-style return lifecycle event history; workflow authority should create events transactionally.';

COMMENT ON TABLE "public"."return_resolutions" IS 'Recorded operational resolution and disposition for a return.';

COMMENT ON TABLE "public"."returns" IS 'Unified tenant-scoped return record supporting customer retail returns and acquisition-side returns without conflating the two workflows.';

COMMENT ON TABLE "public"."role_permissions" IS 'Maps TradeFlow roles to permissions.';

COMMENT ON TABLE "public"."roles" IS 'TradeFlow platform role catalogue.';

COMMENT ON TABLE "public"."sales_channels" IS 'Tenant-scoped selling destinations such as the TradeFlow storefront or external/manual channels.';

COMMENT ON TABLE "public"."shipping_provider_connections" IS 'Tenant-owned shipping aggregator connections. TradeFlow does not own or pay shipping accounts.';

COMMENT ON TABLE "public"."site_revisions" IS 'Immutable publication history plus one editable draft per tenant. Draft saves are private; only the published revision feeds the public site.';

COMMENT ON TABLE "public"."tenant_catalogue_state" IS 'Tracks the independent TradeFlow master-catalogue seed copied into a tenant. No runtime connection to GearCashOut.';

COMMENT ON TABLE "public"."tenant_domain_orders" IS 'Tenant-scoped domain registration, renewal and transfer order ledger. Payment and registrar references are provider-neutral.';

COMMENT ON TABLE "public"."tenant_domains" IS 'Tenant public-site hostnames. Domain ownership/activation is separate from website content publication.';

COMMENT ON TABLE "public"."tenant_email_notification_settings" IS 'Subscriber-controlled event switches for automatic customer emails. Each row belongs to the tenant email settings identified by the same tenant_id; no shared primary-key dependency is required.';

COMMENT ON TABLE "public"."tenant_email_settings" IS 'Simple subscriber email configuration. TradeFlow sends on behalf of the subscriber through its email provider; no SMTP credentials are stored here.';

COMMENT ON TABLE "public"."tenant_memberships" IS 'Maps authenticated users to TradeFlow tenants and establishes owner/admin/staff access.';

COMMENT ON TABLE "public"."tenant_site_state" IS 'Authoritative pointer to the tenant website draft and currently published revision.';

COMMENT ON TABLE "public"."tenant_subscriptions" IS 'Tenant billing/subscription state; restricted to tenant owners and administrators.';

COMMENT ON TABLE "public"."tenants" IS 'TradeFlow SaaS tenant/business security boundary.';

COMMENT ON TABLE "public"."trade_in_transactions" IS 'Trade-in transaction bridge. Supports standalone trade-in valuation and trade-in initiated during a retail purchase.';

COMMENT ON TABLE "public"."workflow_transitions" IS 'Append-only audit history for authoritative workflow transitions. Business status changes are performed through the controlled workflow transition service/RPC; direct browser status updates are blocked by column privileges.';

REVOKE ALL ON FUNCTION "private"."bootstrap_tenant_site"() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."bootstrap_tenant_site"() TO "postgres";

REVOKE ALL ON FUNCTION "private"."can_tenant"(uuid, text, text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."can_tenant"(uuid, text, text) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."create_tenant_with_owner"(text, text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."create_tenant_with_owner"(text, text) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."current_tenant_plan"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."current_tenant_plan"(uuid) TO "postgres";

REVOKE ALL ON FUNCTION "private"."customer_can_access_buying_item_shipping"(uuid, uuid, uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."customer_can_access_buying_item_shipping"(uuid, uuid, uuid) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."customer_id_for_current_user"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."customer_id_for_current_user"(uuid) TO "postgres";

REVOKE ALL ON FUNCTION "private"."customer_id_for_user"(uuid, uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."customer_id_for_user"(uuid, uuid) TO "postgres";

REVOKE ALL ON FUNCTION "private"."guard_site_revision_lifecycle"() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."guard_site_revision_lifecycle"() TO "postgres";

REVOKE ALL ON FUNCTION "private"."has_platform_owner_access"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."has_platform_owner_access"(uuid) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."has_tenant_feature"(uuid, text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."has_tenant_feature"(uuid, text) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."has_tenant_permission"(uuid, uuid, text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."has_tenant_permission"(uuid, uuid, text) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."has_tenant_role"(uuid, uuid, text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."has_tenant_role"(uuid, uuid, text) TO "postgres";

REVOKE ALL ON FUNCTION "private"."is_active_tenant"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."is_active_tenant"(uuid) TO "anon", "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."is_platform_owner"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."is_platform_owner"(uuid) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."is_tenant_admin"(uuid, uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."is_tenant_admin"(uuid, uuid) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."is_tenant_member"(uuid, uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."is_tenant_member"(uuid, uuid) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."platform_admin_create_tenant"(text, text, uuid, text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."platform_admin_create_tenant"(text, text, uuid, text) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."platform_admin_find_user"(text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."platform_admin_find_user"(text) TO "authenticated", "postgres";

GRANT EXECUTE ON FUNCTION "private"."platform_admin_list_subscriber_accounts"() TO "postgres";

REVOKE ALL ON FUNCTION "private"."platform_admin_list_tenants"() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."platform_admin_list_tenants"() TO "authenticated", "postgres";

GRANT EXECUTE ON FUNCTION "private"."platform_admin_manage_subscription"(uuid, text, text) TO "postgres";

REVOKE ALL ON FUNCTION "private"."provision_platform_owner"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."provision_platform_owner"(uuid) TO "postgres";

GRANT EXECUTE ON FUNCTION "private"."queue_buying_request_received_notification"() TO "postgres";

REVOKE ALL ON FUNCTION "private"."queue_customer_notification"(uuid, text, text, uuid, text, text, jsonb) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."queue_customer_notification"(uuid, text, text, uuid, text, text, jsonb) TO "postgres";

REVOKE ALL ON FUNCTION "private"."require_platform_owner"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."require_platform_owner"(uuid) TO "authenticated", "postgres";

REVOKE ALL ON FUNCTION "private"."require_tenant_feature"(uuid, text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."require_tenant_feature"(uuid, text) TO "postgres";

GRANT EXECUTE ON FUNCTION "private"."touch_fulfilment_updated_at"() TO "postgres";

REVOKE ALL ON FUNCTION "private"."touch_site_publication_updated_at"() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "private"."touch_site_publication_updated_at"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."activate_master_catalogue_products"(uuid, uuid[], boolean, boolean) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION "public"."add_master_buying_products_bulk"(uuid, uuid[], text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION
    "public"."add_master_buying_products_filtered"(uuid, uuid, uuid, uuid, text, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."admin_complete_test_registration"(text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION
    "public"."apply_buying_catalogue_bulk"(uuid, uuid[], text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, boolean, uuid, uuid, uuid,
    text)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."calculate_buying_item_valuation"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."claim_notification_queue_batch"(integer) TO "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION "public"."configure_master_catalogue_buying_product"(uuid, uuid, text, numeric, numeric, numeric, numeric, numeric, numeric)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION
    "public"."configure_master_catalogue_buying_product_pricing"(uuid, uuid, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric,
    numeric, text, text, text, text, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION "public"."configure_master_catalogue_buying_products_bulk"(uuid, uuid[], text, numeric, numeric, numeric, numeric, numeric)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION
    "public"."configure_master_catalogue_buying_products_bulk"(uuid, uuid[], text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION "public"."configure_master_catalogue_buying_products_filtered"(uuid, uuid, uuid, uuid, text, text, numeric, numeric, numeric, numeric, numeric)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION
    "public"."configure_master_catalogue_buying_products_filtered"(uuid, uuid, uuid, uuid, text, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric,
    numeric, numeric)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_accept_offer"(uuid, uuid, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_accept_offer_choice"(uuid, uuid, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_apply_retail_credit"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_cancel_retail_order"(uuid, uuid, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_complete_test_registration"(text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_create_order_payment"(uuid, uuid, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_create_retail_order"(uuid, uuid, jsonb, jsonb, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_create_retail_order_from_basket"(uuid, jsonb, jsonb, jsonb, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_delete_address"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_acquisition_shipping"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_acquisitions"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_addresses"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_bank_details"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_buying_categories"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_buying_category_fields"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_buying_items"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_buying_requests"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_completed_sales"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_credit_account"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_fulfilments"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_offer_choices"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_offers"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_offers_v2"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_order_details"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_order_items"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_order_trade_ins"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_orders"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_pre_acquisition_shipping"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_profile"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_retail_fulfilment_shipping"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_retail_order_for_checkout"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_returns"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_selling_status"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_selling_valuations"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_store_listings"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_trade_ins"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_get_trading_values"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_mark_acquisition_posted"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_mark_buying_item_posted"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_pay_retail_order_with_credit"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_refuse_offer"(uuid, uuid, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_register_for_tenant"(uuid, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_request_return"(uuid, uuid, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_save_bank_details"(uuid, text, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_set_default_address"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_submit_buying_request"(uuid, text, jsonb) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_test_registration_status"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."customer_update_profile"(uuid, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION "public"."customer_upsert_address"(uuid, uuid, text, text, text, text, text, text, text, text, text, boolean)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."ensure_category_default_branch"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."ensure_retail_order_fulfilment"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_acquisition_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_asset_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_buying_item_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_buying_request_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_customer_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_ledger_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_listing_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_offer_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_order_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_payment_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_return_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."generate_trade_in_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."get_buying_catalogue_status_counts"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."get_inventory_product_catalogue"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."get_master_buying_catalogue_facets"(uuid, uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."get_master_buying_catalogue_page"(uuid, uuid, uuid, uuid, text, integer, integer) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION "public"."get_master_buying_catalogue_page_filtered"(uuid, uuid, uuid, uuid, text, integer, integer, boolean)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."get_master_catalogue"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."get_master_catalogue_for_selection"(uuid) TO "authenticated", "postgres", "service_role";

REVOKE ALL ON FUNCTION "public"."get_public_buying_catalogue"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "public"."get_public_buying_catalogue"(uuid) TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ON FUNCTION "public"."get_published_site_preview"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "public"."get_published_site_preview"(uuid) TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ON FUNCTION "public"."get_published_sites"() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "public"."get_published_sites"() TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ON FUNCTION "public"."get_published_store_listing_media"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "public"."get_published_store_listing_media"(uuid) TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ON FUNCTION "public"."get_published_store_listings"(uuid) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "public"."get_published_store_listings"(uuid) TO "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."get_tenant_buying_catalogue_page"(uuid, uuid, uuid, uuid, text, integer, integer) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_acquisition_creation_boundary"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_acquisition_fulfilment_status_entry"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_acquisition_item_status_entry"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_acquisition_status_entry"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_fulfilment_status_entry"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_inventory_asset_status_entry"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_inventory_creation_boundary"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_ledger_entry_status_entry"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_listing_status_entry"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_payment_record_status_entry"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_retail_order_status_entry"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."guard_return_status_entry"() TO "authenticated", "postgres", "service_role";

REVOKE ALL ON FUNCTION "public"."is_published_tradeflow_media"(text, text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "public"."is_published_tradeflow_media"(text, text) TO "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."mark_notification_failed"(uuid, text) TO "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."mark_notification_sent"(uuid, text, text) TO "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."media_assets_set_updated_at"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."notification_processor_auth_secret"() TO "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."platform_admin_create_tenant"(text, text, uuid, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."platform_admin_find_user"(text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."platform_admin_list_subscriber_accounts"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."platform_admin_list_tenants"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."platform_admin_manage_subscription"(uuid, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."platform_owner_get_email"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."platform_owner_get_plans"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."platform_owner_save_email"(text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."platform_owner_update_plan"(uuid, text, text, boolean, numeric, numeric, text, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."process_external_payment_event"(text, text, text, uuid, uuid, text, text, numeric, text, jsonb) TO "postgres", "service_role";

REVOKE ALL ON FUNCTION "public"."public_get_available_plans"() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION "public"."public_get_available_plans"() TO "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."publish_site_revision"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."queue_customer_manual_valuation_notification"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."record_retail_order_payment"(uuid, uuid, numeric, text, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."seed_tenant_master_catalogue"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."set_buying_catalogue_website_visibility"(uuid, uuid, boolean) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."set_listing_media_retention_after_sale"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."set_media_retention_after_sale"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."set_trading_value_approved_timestamp"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."set_updated_at"() TO "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."shipping_provider_credentials_for_service"(uuid) TO "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."shipping_provider_secret_for_service"(uuid) TO "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."staff_complete_test_registration"(text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_complete_buying_item_followup"(uuid, uuid, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_complete_buying_item_inspection"(uuid, uuid, text, boolean, text, text, jsonb) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_complete_purchase"(uuid, uuid, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION
    "public"."subscriber_complete_retail_fulfilment_shipping"(uuid, uuid, text, text, text, text, text, text, text, text, text, text, text, text, numeric, numeric, numeric,
    numeric, text)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_connect_shipping_provider"(uuid, text, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_create_business"(text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_create_manual_buying_valuation"(uuid, uuid, numeric, numeric, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_credit_trade_in"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_decide_customer_return"(uuid, uuid, text, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_business_workflow"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_business_workflow_counts"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_buying_item_customer_details"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_buying_item_payment_details"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_customer_addresses"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_customer_bank_details"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_customer_bank_details_for_customer"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_email_status"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_fulfilment_orders"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_fulfilments"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_my_memberships"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_order_details"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_orders"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_retail_fulfilment_shipping"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_returns"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_shipping_service_settings"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_get_sold_retail_items"(uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_mark_buying_item_offer_ready"(uuid, uuid, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_mark_buying_item_received"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION "public"."subscriber_publish_buying_item_return_shipping"(uuid, uuid, text, text, text, text, text, text, text, text, text, text, text, text)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION "public"."subscriber_publish_buying_item_shipping_handoff"(uuid, uuid, text, text, text, text, text, text, text, text, text, text, uuid, text)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_publish_final_offer"(uuid, uuid, numeric, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION "public"."subscriber_publish_shipping_handoff"(uuid, uuid, text, text, text, text, text, text, text, text, text, text, uuid, text)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_refuse_after_inspection"(uuid, uuid, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_refuse_buying_item_valuation"(uuid, uuid, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_request_customer_bank_details"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_save_business_email"(uuid, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE
  ON FUNCTION
    "public"."subscriber_save_retail_fulfilment_shipping"(uuid, uuid, text, text, text, text, text, text, text, text, text, text, text, text, numeric, numeric, numeric, numeric,
    text)
  TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_save_shipping_provider_connection"(uuid, text, text, jsonb, jsonb) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_save_shipping_services"(uuid, jsonb) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_start_buying_item_inspection"(uuid, uuid) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."subscriber_transition_retail_fulfilment"(uuid, uuid, text, text, text) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."sync_category_branch_reference"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."sync_retail_order_payment_status"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."test_lab_current_customer"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."test_lab_current_customer_v2"() TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."touch_tenant_buying_products_updated_at"() TO "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."touch_tenant_public_profile_updated_at"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."transition_workflow_entity"(uuid, text, uuid, text, text, text, jsonb) TO "authenticated", "postgres", "service_role";

GRANT EXECUTE ON FUNCTION "public"."validate_published_offer_valuation"() TO PUBLIC, "anon", "authenticated", "postgres", "service_role";

GRANT USAGE ON SCHEMA "private" TO "authenticated";

GRANT CREATE, USAGE ON SCHEMA "private" TO "postgres";

REVOKE ALL ("acquisition_id") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("acquisition_id") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("acquisition_item_id") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("acquisition_item_id") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("carrier") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("carrier") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("delivered_at") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("delivered_at") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("direction") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("direction") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("dispatched_at") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("dispatched_at") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("fulfilment_reference") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("fulfilment_reference") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("label_url") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("label_url") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("metadata") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("metadata") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("notes") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("notes") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("recipient_email") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("recipient_email") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("recipient_name") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("recipient_name") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("returned_at") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("returned_at") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("service") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("service") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("shipping_address") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("shipping_address") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("tracking_number") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("tracking_number") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("tracking_url") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("tracking_url") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

REVOKE ALL ON TABLE "public"."acquisition_fulfilments" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."acquisition_fulfilments" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."acquisition_fulfilments" TO "postgres", "service_role";

REVOKE ALL ("acquisition_id") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("acquisition_id") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("agreed_amount") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("agreed_amount") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("buying_item_id") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("buying_item_id") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("completed_at") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("completed_at") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("currency") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("currency") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("final_amount") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("final_amount") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("finalised_at") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("finalised_at") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("metadata") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("metadata") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("notes") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("notes") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("offer_id") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("offer_id") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("paid_at") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("paid_at") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("received_at") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("received_at") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."acquisition_items" TO "authenticated";

REVOKE ALL ON TABLE "public"."acquisition_items" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."acquisition_items" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."acquisition_items" TO "postgres", "service_role";

REVOKE ALL ("accepted_at") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("accepted_at") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("acquisition_reference") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("acquisition_reference") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("agreed_total") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("agreed_total") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("cancelled_at") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("cancelled_at") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("completed_at") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("completed_at") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("currency") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("currency") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("customer_id") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("customer_id") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("finalised_at") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("finalised_at") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("metadata") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("metadata") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("notes") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("notes") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("paid_at") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("paid_at") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("payment_total") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("payment_total") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("received_at") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("received_at") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("source_offer_id") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("source_offer_id") ON TABLE "public"."acquisitions" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."acquisitions" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."acquisitions" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."acquisitions" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."buying_item_field_values" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."buying_item_inspections" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."buying_item_media" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."buying_item_return_shipping" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."buying_item_shipping" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."buying_items" TO "authenticated", "postgres", "service_role";

REVOKE ALL ("closed_at") ON TABLE "public"."buying_requests" FROM "authenticated";

GRANT UPDATE ("closed_at") ON TABLE "public"."buying_requests" TO "authenticated";

REVOKE ALL ("customer_id") ON TABLE "public"."buying_requests" FROM "authenticated";

GRANT UPDATE ("customer_id") ON TABLE "public"."buying_requests" TO "authenticated";

REVOKE ALL ("notes") ON TABLE "public"."buying_requests" FROM "authenticated";

GRANT UPDATE ("notes") ON TABLE "public"."buying_requests" TO "authenticated";

REVOKE ALL ("request_reference") ON TABLE "public"."buying_requests" FROM "authenticated";

GRANT UPDATE ("request_reference") ON TABLE "public"."buying_requests" TO "authenticated";

REVOKE ALL ("source") ON TABLE "public"."buying_requests" FROM "authenticated";

GRANT UPDATE ("source") ON TABLE "public"."buying_requests" TO "authenticated";

REVOKE ALL ("submitted_at") ON TABLE "public"."buying_requests" FROM "authenticated";

GRANT UPDATE ("submitted_at") ON TABLE "public"."buying_requests" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."buying_requests" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."buying_requests" TO "authenticated";

REVOKE ALL ON TABLE "public"."buying_requests" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."buying_requests" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."buying_requests" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."catalogue_master_branches" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."catalogue_master_categories" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."catalogue_master_manufacturers" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."catalogue_master_product_identifiers" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."catalogue_master_products" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."categories" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."category_branches" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."category_field_options" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."category_fields" TO "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."customer_addresses" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."customer_addresses" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."customer_addresses" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."customer_bank_details" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."customer_credit_accounts" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."customer_credit_holds" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."customers" TO "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."domain_tld_catalog" FROM "anon";

GRANT SELECT ON TABLE "public"."domain_tld_catalog" TO "anon";

REVOKE ALL ON TABLE "public"."domain_tld_catalog" FROM "authenticated";

GRANT SELECT ON TABLE "public"."domain_tld_catalog" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."domain_tld_catalog" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."email_templates" TO "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."fulfilment_events" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."fulfilment_events" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."fulfilment_events" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."fulfilment_parcels" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."fulfilment_parcels" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."fulfilment_parcels" TO "postgres", "service_role";

REVOKE ALL ("carrier") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("carrier") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("delivered_at") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("delivered_at") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("dispatched_at") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("dispatched_at") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("fulfilment_reference") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("fulfilment_reference") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("label_url") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("label_url") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("metadata") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("metadata") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("notes") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("notes") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("recipient_email") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("recipient_email") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("recipient_name") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("recipient_name") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("retail_order_id") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("retail_order_id") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("returned_at") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("returned_at") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("service") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("service") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("shipping_address") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("shipping_address") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("tracking_number") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("tracking_number") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("tracking_url") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("tracking_url") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."fulfilments" TO "authenticated";

REVOKE ALL ON TABLE "public"."fulfilments" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."fulfilments" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."fulfilments" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."inventory_asset_media" TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ("acquisition_item_id") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("acquisition_item_id") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("asset_reference") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("asset_reference") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("buying_item_id") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("buying_item_id") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("category_id") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("category_id") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("condition_grade") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("condition_grade") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("currency") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("currency") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("current_value") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("current_value") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("customer_condition") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("customer_condition") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("description") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("description") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("dynamic_values") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("dynamic_values") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("location") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("location") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("metadata") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("metadata") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("notes") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("notes") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("purchase_price") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("purchase_price") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("quantity") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("quantity") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("ready_for_sale_at") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("ready_for_sale_at") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("received_at") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("received_at") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("serial_number") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("serial_number") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("sold_at") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("sold_at") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("title") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("title") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."inventory_assets" TO "authenticated";

REVOKE ALL ON TABLE "public"."inventory_assets" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."inventory_assets" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."inventory_assets" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."inventory_costs" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."inventory_inspections" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."inventory_movements" TO "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."ledger_entries" FROM "authenticated";

GRANT INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."ledger_entries" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ledger_entries" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."listing_events" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."listing_media" TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ("asking_price") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("asking_price") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("asset_id") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("asset_id") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("category_id") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("category_id") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("channel_id") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("channel_id") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("currency") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("currency") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("delisted_at") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("delisted_at") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("description") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("description") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("listing_data") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("listing_data") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("listing_reference") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("listing_reference") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("published_at") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("published_at") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("quantity") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("quantity") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("reserved_at") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("reserved_at") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("sold_at") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("sold_at") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("title") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("title") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."listings" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."listings" TO "authenticated";

REVOKE ALL ON TABLE "public"."listings" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."listings" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."listings" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."media_assets" TO "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."notification_event_log" FROM "authenticated";

GRANT INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."notification_event_log" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."notification_event_log" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."notification_events" FROM "authenticated";

GRANT SELECT ON TABLE "public"."notification_events" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."notification_events" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."notification_queue" FROM "authenticated";

GRANT SELECT ON TABLE "public"."notification_queue" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."notification_queue" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."notification_templates" TO "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."offer_events" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."offer_events" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."offer_events" TO "postgres", "service_role";

REVOKE ALL ("amount") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("amount") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ("buying_item_id") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("buying_item_id") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ("currency") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("currency") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ("expires_at") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("expires_at") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ("offer_reference") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("offer_reference") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ("offer_type") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("offer_type") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ("published_at") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("published_at") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ("responded_at") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("responded_at") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ("response_notes") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("response_notes") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ("trading_value_id") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("trading_value_id") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."offers" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."offers" TO "authenticated";

REVOKE ALL ON TABLE "public"."offers" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."offers" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."offers" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."payment_provider_connections" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."payment_provider_customers" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."payment_provider_events" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."payment_records" FROM "authenticated";

GRANT INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."payment_records" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."payment_records" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."payment_webhook_events" FROM "authenticated";

GRANT SELECT ON TABLE "public"."payment_webhook_events" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."payment_webhook_events" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."permissions" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."plan_features" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."plans" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."platform_email_settings" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."platform_memberships" TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."published_site_index" FROM "anon";

GRANT SELECT ON TABLE "public"."published_site_index" TO "anon";

REVOKE ALL ON TABLE "public"."published_site_index" FROM "authenticated";

GRANT SELECT ON TABLE "public"."published_site_index" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."published_site_index" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."retail_order_items" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."retail_order_items" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."retail_order_items" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."retail_order_trade_ins" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."retail_order_trade_ins" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."retail_order_trade_ins" TO "postgres", "service_role";

REVOKE ALL ("billing_address") ON TABLE "public"."retail_orders" FROM "authenticated";

GRANT UPDATE ("billing_address") ON TABLE "public"."retail_orders" TO "authenticated";

REVOKE ALL ("customer_email") ON TABLE "public"."retail_orders" FROM "authenticated";

GRANT UPDATE ("customer_email") ON TABLE "public"."retail_orders" TO "authenticated";

REVOKE ALL ("customer_id") ON TABLE "public"."retail_orders" FROM "authenticated";

GRANT UPDATE ("customer_id") ON TABLE "public"."retail_orders" TO "authenticated";

REVOKE ALL ("customer_name") ON TABLE "public"."retail_orders" FROM "authenticated";

GRANT UPDATE ("customer_name") ON TABLE "public"."retail_orders" TO "authenticated";

REVOKE ALL ("metadata") ON TABLE "public"."retail_orders" FROM "authenticated";

GRANT UPDATE ("metadata") ON TABLE "public"."retail_orders" TO "authenticated";

REVOKE ALL ("notes") ON TABLE "public"."retail_orders" FROM "authenticated";

GRANT UPDATE ("notes") ON TABLE "public"."retail_orders" TO "authenticated";

REVOKE ALL ("pricing_version") ON TABLE "public"."retail_orders" FROM "authenticated";

GRANT UPDATE ("pricing_version") ON TABLE "public"."retail_orders" TO "authenticated";

REVOKE ALL ("shipping_address") ON TABLE "public"."retail_orders" FROM "authenticated";

GRANT UPDATE ("shipping_address") ON TABLE "public"."retail_orders" TO "authenticated";

REVOKE ALL ON TABLE "public"."retail_orders" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."retail_orders" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."retail_orders" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."return_events" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."return_events" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."return_events" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."return_resolutions" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."return_resolutions" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."return_resolutions" TO "postgres", "service_role";

REVOKE ALL ("acquisition_id") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("acquisition_id") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("acquisition_item_id") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("acquisition_item_id") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("authorised_at") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("authorised_at") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("closed_at") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("closed_at") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("currency") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("currency") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("customer_id") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("customer_id") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("customer_notes") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("customer_notes") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("inspected_at") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("inspected_at") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("inventory_asset_id") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("inventory_asset_id") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("metadata") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("metadata") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("order_id") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("order_id") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("order_item_id") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("order_item_id") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("reason_code") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("reason_code") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("reason") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("reason") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("received_at") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("received_at") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("refund_amount") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("refund_amount") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("requested_at") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("requested_at") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("resolved_at") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("resolved_at") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("return_reference") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("return_reference") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("return_type") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("return_type") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("staff_notes") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("staff_notes") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."returns" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."returns" TO "authenticated";

REVOKE ALL ON TABLE "public"."returns" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."returns" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."returns" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."role_permissions" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."roles" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."sales_channels" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."shipping_provider_catalog" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."shipping_provider_connections" TO "anon";

REVOKE ALL ON TABLE "public"."shipping_provider_connections" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."shipping_provider_connections" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."shipping_provider_connections" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."shipping_quote_sessions" TO "anon";

REVOKE ALL ON TABLE "public"."shipping_quote_sessions" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."shipping_quote_sessions" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."shipping_quote_sessions" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."shipping_service_catalog" TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ("content") ON TABLE "public"."site_revisions" FROM "authenticated";

GRANT UPDATE ("content") ON TABLE "public"."site_revisions" TO "authenticated";

REVOKE ALL ("published_at") ON TABLE "public"."site_revisions" FROM "authenticated";

GRANT UPDATE ("published_at") ON TABLE "public"."site_revisions" TO "authenticated";

REVOKE ALL ("published_by") ON TABLE "public"."site_revisions" FROM "authenticated";

GRANT UPDATE ("published_by") ON TABLE "public"."site_revisions" TO "authenticated";

REVOKE ALL ("revision_number") ON TABLE "public"."site_revisions" FROM "authenticated";

GRANT UPDATE ("revision_number") ON TABLE "public"."site_revisions" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."site_revisions" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."site_revisions" TO "authenticated";

REVOKE ALL ON TABLE "public"."site_revisions" FROM "authenticated";

GRANT INSERT, SELECT ON TABLE "public"."site_revisions" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."site_revisions" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE
  ON TABLE "public"."tenant_buying_condition_rules"
  TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_buying_manufacturers" TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."tenant_buying_products" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."tenant_buying_products" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_buying_products" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."tenant_buying_research" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."tenant_buying_research" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_buying_research" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_catalogue_selections" TO "anon", "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_catalogue_state" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."tenant_domain_orders" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."tenant_domain_orders" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_domain_orders" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."tenant_domains" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."tenant_domains" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_domains" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_email_notification_settings" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_email_settings" TO "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."tenant_memberships" FROM "authenticated";

GRANT MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."tenant_memberships" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_memberships" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_payment_methods" TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."tenant_public_profiles" FROM "anon";

GRANT SELECT ON TABLE "public"."tenant_public_profiles" TO "anon";

REVOKE ALL ON TABLE "public"."tenant_public_profiles" FROM "authenticated";

GRANT INSERT, SELECT, UPDATE ON TABLE "public"."tenant_public_profiles" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_public_profiles" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_shipping_services" TO "anon", "authenticated", "postgres", "service_role";

REVOKE ALL ON TABLE "public"."tenant_site_state" FROM "authenticated";

GRANT SELECT, UPDATE ON TABLE "public"."tenant_site_state" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_site_state" TO "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenant_subscriptions" TO "authenticated", "postgres", "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tenants" TO "authenticated", "postgres", "service_role";

REVOKE ALL ("accepted_at") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("accepted_at") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("acquisition_id") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("acquisition_id") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("acquisition_item_id") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("acquisition_item_id") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("buying_item_id") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("buying_item_id") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("buying_request_id") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("buying_request_id") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("cancelled_at") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("cancelled_at") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("cash_price") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("cash_price") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("completed_at") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("completed_at") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("credit_amount") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("credit_amount") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("credited_at") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("credited_at") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("currency") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("currency") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("customer_id") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("customer_id") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("customer_notes") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("customer_notes") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("metadata") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("metadata") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("offer_id") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("offer_id") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("received_at") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("received_at") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("requested_at") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("requested_at") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("staff_notes") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("staff_notes") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("trade_in_price") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("trade_in_price") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("trade_in_reference") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("trade_in_reference") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("trading_value") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("trading_value") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("valuation_method") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("valuation_method") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ("valued_at") ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT UPDATE ("valued_at") ON TABLE "public"."trade_in_transactions" TO "authenticated";

REVOKE ALL ON TABLE "public"."trade_in_transactions" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE ON TABLE "public"."trade_in_transactions" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."trade_in_transactions" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."trading_value_components" FROM "authenticated";

GRANT INSERT, UPDATE ON TABLE "public"."trading_value_components" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."trading_value_components" TO "postgres", "service_role";

REVOKE ALL ("amount") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("amount") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("approved_at") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("approved_at") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("approved_by_name") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("approved_by_name") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("approved_by") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("approved_by") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("buying_item_id") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("buying_item_id") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("calculated_at") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("calculated_at") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("cash_price") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("cash_price") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("confidence") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("confidence") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("currency") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("currency") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("effective_from") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("effective_from") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("effective_to") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("effective_to") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("metadata") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("metadata") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("method") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("method") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("notes") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("notes") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("superseded_at") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("superseded_at") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("trade_in_price") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("trade_in_price") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ("updated_at") ON TABLE "public"."trading_values" FROM "authenticated";

GRANT UPDATE ("updated_at") ON TABLE "public"."trading_values" TO "authenticated";

REVOKE ALL ON TABLE "public"."trading_values" FROM "authenticated";

GRANT INSERT, SELECT ON TABLE "public"."trading_values" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."trading_values" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."valuation_rules" FROM "authenticated";

GRANT INSERT, SELECT, UPDATE ON TABLE "public"."valuation_rules" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."valuation_rules" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."workflow_transitions" FROM "authenticated";

GRANT INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE ON TABLE "public"."workflow_transitions" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."workflow_transitions" TO "postgres", "service_role";

REVOKE ALL ON TABLE "public"."published_site_preview" FROM "anon";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."published_site_preview" TO "anon";

REVOKE ALL ON TABLE "public"."published_site_preview" FROM "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."published_site_preview" TO "authenticated";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."published_site_preview" TO "postgres", "service_role";

SELECT cron.schedule_in_database('tradeflow-notification-queue', '* * * * *', '
 select net.http_post(
  url:=(select decrypted_secret from vault.decrypted_secrets where name=''tradeflow_project_url'')||''/functions/v1/process-notification-queue'',
  headers:=jsonb_build_object(''Content-Type'',''application/json'',''x-tradeflow-cron-secret'',(select decrypted_secret from vault.decrypted_secrets
    where name=''tradeflow_notification_processor_secret'')),
  body:=jsonb_build_object(''run_at'',now()),timeout_milliseconds:=10000
 ) as request_id;
', 'postgres', NULL, true);

