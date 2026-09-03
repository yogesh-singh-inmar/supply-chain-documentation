-- ============================================================================
-- SUPPLY CHAIN PROCESS - STEP BY STEP QUERIES FOR INFORMIX
-- One independent query per step - NO COMPLEX JOINS
-- Using ACTUAL Informix database column names
-- ============================================================================

-- ============================================================================
-- STEP 1: ORDER ARRIVES → ASN_HDR (Scan Barcode)
-- ============================================================================
-- What happens: Supplier ships goods, we receive Advanced Ship Notice (ASN)

SELECT 
  asn_hdr_id,               -- Header ID in system
  gpo_cd,                   -- Customer GPO code
  store_no,                 -- Customer store number
  client_box_count,         -- How many boxes in this shipment
  client_ship_date,         -- When supplier shipped
  received,                 -- When we received it
  inbound_bar_code,         -- Inbound barcode
  order_id,                 -- Related order ID
  client_type,              -- Customer type
  client_program            -- Customer program
FROM asn_hdr
ORDER BY received DESC
LIMIT 100;

-- ============================================================================
-- STEP 1 DETAIL: What's inside each ASN?
-- ============================================================================
-- Shows line items of what arrived

SELECT 
  asn_hdr_id,               -- Which ASN header
  asn_dtl_id,               -- Line item ID
  drug_xref_id,             -- Product reference ID
  lot_no,                   -- Batch/lot number
  exp_date,                 -- Expiration date
  item_qty,                 -- Quantity ordered
  item_count,               -- Actual item count
  client_item_desc,         -- Item description from customer
  full_case_ind             -- Full case indicator
FROM asn_dtl
ORDER BY asn_hdr_id DESC
LIMIT 100;

-- ============================================================================
-- STEP 1 BARCODE: Physical barcode information
-- ============================================================================
-- The actual barcode scanned for this shipment

SELECT 
  bar_code_key,             -- Unique barcode ID
  bar_code,                 -- The actual barcode number
  format_cd_key,            -- Format type (UPC, EAN, etc)
  tag_gen_id,               -- Tag generation ID
  gpo_ref,                  -- Customer reference
  store_no,                 -- Store number
  box_no                    -- Box number
FROM bar_code
LIMIT 100;

-- ============================================================================
-- STEP 2: ITEMS CHECKED → AUDIT_ITEM (QC Pass/Fail)
-- ============================================================================
-- Quality Control inspects each received item
-- Pass: Item is good, Fail: Item has issues

SELECT 
  rds_id,                   -- Receive detail slip ID
  prod_name,                -- Product name
  status,                   -- PASS, FAIL, HOLD, REWORK
  invoice_no,               -- Invoice being checked
  out_222,                  -- Form 222 reference
  labeler_cd,               -- Labeler code
  out_box_no                -- Output box number
FROM audit_item
LIMIT 100;

-- ============================================================================
-- STEP 2A: BAD DEA RECORDS
-- ============================================================================
-- Invalid DEA numbers found

SELECT 
  rds_id,                   -- Item ID
  dea_no,                   -- DEA number (invalid)
  dea_name,                 -- DEA name
  addr_1,                   -- Address line 1
  city,                     -- City
  state,                    -- State
  zip                       -- ZIP code
FROM bad_dea
LIMIT 100;

-- ============================================================================
-- STEP 2B: BAD BARCODES
-- ============================================================================
-- Barcode scan errors

SELECT 
  rds_id,                   -- Item ID
  old_barcode,              -- Original barcode
  new_barcode               -- Corrected barcode
FROM bad_barcode
LIMIT 100;

-- ============================================================================
-- STEP 2C: BAD ITAGS (Multiple types)
-- ============================================================================
-- Item tag errors

SELECT 
  rds_id,                   -- Item ID
  rtn_no                    -- Return number
FROM bad_itag
LIMIT 100;

-- ============================================================================
-- STEP 2D: AGING ITEMS
-- ============================================================================
-- Items that are expired or approaching expiration

SELECT 
  rds_id,                   -- Item ID
  age_date,                 -- Aging date
  scan_datetime,            -- When scanned
  out_box_no                -- Output box
FROM aging_audit
LIMIT 100;

-- ============================================================================
-- STEP 3: ITEMS STORED → CELLS (Bin Location)
-- ============================================================================
-- Once QC passes, items are placed in warehouse storage locations (bins)

SELECT 
  area,                     -- Warehouse zone/area
  cell_no,                  -- Specific cell/bin number
  status,                   -- EMPTY, PARTIAL, FULL, ACTIVE
  manuf_cd,                 -- Manufacturer code
  item_cnt,                 -- Number of items in cell
  returnable,               -- Can be returned? Y/N
  whslr_dea,                -- Wholesaler DEA
  prev_status               -- Previous status
FROM cells
WHERE status IN ('ACTIVE', 'PARTIAL', 'FULL')
LIMIT 100;

-- ============================================================================
-- STEP 3B: WAREHOUSE & AREA DETAILS
-- ============================================================================
-- Warehouse area information

SELECT 
  area,                     -- Area code
  area_desc,                -- Area description
  no_levels,                -- Number of levels
  start_level_no,           -- Starting level
  level_incr,               -- Level increment
  cells_level,              -- Cells per level
  bin_size,                 -- Bin size
  area_type,                -- Type of area
  status                    -- Status
FROM area
LIMIT 100;

-- ============================================================================
-- STEP 4: PICK ORDER → DEL_LOC_ASG (Assign Location to Pick)
-- ============================================================================
-- When order comes in, we assign which locations to pick from

SELECT 
  loc_id,                   -- Which storage location (cell)
  cntr_id,                  -- Container ID
  out_box_no,               -- Output box number
  tote_id,                  -- Tote ID
  user_id,                  -- User who made assignment
  date_deleted              -- When deleted (if applicable)
FROM del_loc_asg
LIMIT 100;

-- ============================================================================
-- STEP 4B: WHAT PRODUCTS ARE BEING PICKED?
-- ============================================================================
-- Detailed product information

SELECT 
  drug_no,                  -- Product/drug number
  prod_name,                -- Product name
  labeler_cd,               -- Labeler code
  dosage_form,              -- Dosage form (tablet, liquid, injection, etc)
  pack_size,                -- Pack size
  mt_strn,                  -- Metric strength
  strn_u_m,                 -- Strength unit of measure
  dea_class,                -- DEA classification
  brand_name,               -- Brand name
  manuf_name                -- Manufacturer name
FROM del_drug_new
LIMIT 100;

-- ============================================================================
-- STEP 4C: SCHEDULE II CONTROLLED ITEMS
-- ============================================================================
-- Special handling for Schedule II drugs

SELECT 
  rds_id,                   -- Item ID
  age_date,                 -- Age date
  tote_id                   -- Tote identifier
FROM c2_itags
LIMIT 100;

-- ============================================================================
-- STEP 5: GROUP DELIVERY → AREA, CHAIN_PCT (Sort by Zone)
-- ============================================================================
-- After picking, items sorted by delivery zone for efficient loading

SELECT 
  area,                     -- Warehouse zone code
  area_desc,                -- Zone description
  no_levels,                -- Storage levels in zone
  level_incr,               -- Level increment value
  bin_size,                 -- Size of each bin
  area_type,                -- Type (storage, picking, staging)
  status                    -- Active status
FROM area
LIMIT 100;

-- ============================================================================
-- STEP 5B: DISTRIBUTION BY CHAIN/ROUTE
-- ============================================================================
-- How items distributed by store chain

SELECT 
  gpo_cd,                   -- Customer GPO code
  chain_id,                 -- Chain identifier
  ret_pct,                  -- Returnable percentage
  nonret_pct,               -- Non-returnable percentage
  age_pct,                  -- Aging percentage
  user_id,                  -- User who set this
  maint_date                -- When last maintained
FROM chain_pct
LIMIT 100;

-- ============================================================================
-- STEP 5C: CLIENT PERCENTAGES (Alternative to chain)
-- ============================================================================
-- Distribution percentages by customer

SELECT 
  gpo_cd,                   -- Customer GPO code
  client_sub_client,        -- Sub-client code
  ret_pct,                  -- Returnable %
  nonret_pct,               -- Non-returnable %
  age_pct,                  -- Aging %
  recall_pct,               -- Recall %
  disc_flag,                -- Discount flag
  age_ret_flag              -- Age return flag
FROM client_pct
LIMIT 100;

-- ============================================================================
-- STEP 6: LOAD TRUCK → BILLING_WS_HDR (Assign Order)
-- ============================================================================
-- Organize shipments and prepare for delivery

SELECT 
  order_header_id,          -- Warehouse Services Order ID
  order_number,             -- Order number
  customer_number,          -- Customer/DEA number
  customer_name,            -- Customer name
  invoice_number,           -- Invoice number
  invoice_amount,           -- Invoice total amount
  invoice_date,             -- Invoice date
  dea_no,                   -- DEA number
  processing_end_date,      -- When order was processed
  order_type,               -- Type of order
  recall_flag               -- Recall flag
FROM billing_ws_hdr
LIMIT 100;

-- ============================================================================
-- STEP 6B: SHIPMENT LINE ITEMS
-- ============================================================================
-- Detailed items in each shipment

SELECT 
  order_header_id,          -- Which order
  ws_dtl_id,                -- Detail line ID
  item_code,                -- Item code
  item_desc,                -- Item description
  units,                    -- Quantity shipped
  rate,                     -- Rate per unit
  amount,                   -- Total amount for line
  sort_seq,                 -- Sort sequence
  record_status             -- Status
FROM billing_ws_detail
LIMIT 100;

-- ============================================================================
-- STEP 6C: SHIPPING ERRORS (if any)
-- ============================================================================
-- Any errors during shipping preparation

SELECT 
  order_header_id,          -- Which order had error
  error_code,               -- Error code
  error_text,               -- Error description
  creation_date,            -- When error occurred
  created_by                -- Who logged the error
FROM billing_ws_error
LIMIT 100;

-- ============================================================================
-- STEP 7: DELIVER → Shipment Tracking
-- ============================================================================
-- Track shipment status and delivery

SELECT 
  order_header_id,          -- Shipment ID
  order_number,             -- Order number
  customer_name,            -- Recipient name
  city,                     -- Delivery city
  state,                    -- Delivery state
  zip,                      -- Delivery ZIP
  invoice_date,             -- Invoice date
  processing_end_date,      -- Processing/ship date
  invoice_amount,           -- Amount shipped
  dea_no                    -- DEA number
FROM billing_ws_hdr
LIMIT 100;

-- ============================================================================
-- STEP 7B: BOX TRACKING EVENTS
-- ============================================================================
-- Delivery events: Out for delivery, Delivered, etc

SELECT 
  c2p_id,                   -- Event ID
  station_id,               -- Station/location
  rma_no,                   -- RMA number
  bar_code,                 -- Tracking barcode
  date,                     -- Event date
  event_name,               -- Event type (SHIPPED, DELIVERED, etc)
  sent_status,              -- Delivery status
  jwt_token,                -- JWT token for tracking
  box_trk_no                -- Box tracking number
FROM c2p_open_box
LIMIT 100;

-- ============================================================================
-- STEP 8: BILL → BILLING_EXP_HDR (Export to Accounting)
-- ============================================================================
-- Create billing export for accounting system

SELECT 
  billing_exp_hdr_id,       -- Export header ID
  gpo_cd,                   -- Customer GPO code
  billing_export_date,      -- When exported
  billing_period_year,      -- Year
  billing_period_cycle,     -- Cycle/period
  billing_period_start_date,-- Period start date
  billing_period_end_date,  -- Period end date
  billing_report_type,      -- Type of report
  period_date_key           -- Date key
FROM billing_exp_hdr
LIMIT 100;

-- ============================================================================
-- STEP 8B: BILLING EXPORT DETAILS
-- ============================================================================
-- Line items being exported

SELECT 
  billing_exp_dtl_id,       -- Detail ID
  billing_exp_hdr_id,       -- Which export header
  rds_id,                   -- RDS reference
  billing_report_type,      -- Report type
  edi_batch_id              -- EDI batch
FROM billing_exp_dtl
LIMIT 100;

-- ============================================================================
-- STEP 8C: ACCOUNTING CODES
-- ============================================================================
-- Chart of accounts for billing

SELECT 
  acct_code_key,            -- Account code ID
  acct_code,                -- Accounting code
  acct_name,                -- Account name
  client_master_id,         -- Customer reference
  create_user,              -- Created by
  create_datetime           -- Created date
FROM accounting_codes
LIMIT 100;

-- ============================================================================
-- STEP 9: RETURN AUTHORIZATION → AR_ORIG (Return Records)
-- ============================================================================
-- Original return authorization records

SELECT 
  entry_no,                 -- Entry number
  report_no,                -- Report number
  trans_id,                 -- Transaction ID
  dea_no,                   -- DEA number
  trans_code,               -- Transaction code (type of transaction)
  quantity,                 -- Quantity returned
  uom,                      -- Unit of measure
  lot_no,                   -- Lot number
  strength,                 -- Strength
  trans_date,               -- Transaction date
  drug_no,                  -- Drug number
  rds_id,                   -- RDS ID
  form_222,                 -- Form 222 reference
  reported,                 -- Reported indicator
  report_date               -- Report date
FROM ar_orig
LIMIT 100;

-- ============================================================================
-- STEP 9B: CORRECTIONS TO RETURNS
-- ============================================================================
-- Amended/corrected return records

SELECT 
  report_no,                -- Report number
  trans_id,                 -- Transaction ID
  corr_no,                  -- Correction number
  correction_id,            -- Correction ID
  maint_type,               -- Type of correction
  user_id,                  -- User who corrected
  maint_date,               -- When corrected
  rds_id,                   -- RDS ID
  orig_report_no,           -- Original report
  resubmit_date             -- Resubmission date
FROM ar_correct
LIMIT 100;

-- ============================================================================
-- STEP 9C: CORRECTION DETAILS
-- ============================================================================
-- Detailed correction information

SELECT 
  correction_id,            -- Correction ID
  entry_no,                 -- Entry number
  dea_no,                   -- DEA number
  trans_code,               -- Transaction code
  quantity,                 -- Corrected quantity
  lot_no,                   -- Lot number
  strength,                 -- Strength
  drug_no,                  -- Drug number
  trans_date,               -- Transaction date
  report_no                 -- Report number
FROM ar_correction
LIMIT 100;

-- ============================================================================
-- STEP 10: PAYMENT → CHECK_INFO (Payment Record)
-- ============================================================================
-- Payment processing and checks issued

SELECT 
  check_id,                 -- Payment ID
  gpo_cd,                   -- Customer GPO code
  check_no,                 -- Check number
  check_amt,                -- Check amount ($)
  check_date,               -- Check date
  check_status,             -- Status (PENDING, CLEARED, VOIDED)
  check_clr_date,           -- When cleared/processed
  job_number,               -- Job number
  deleted                   -- If deleted
FROM check_info
LIMIT 100;

-- ============================================================================
-- STEP 10B: EDI BATCH FOR PAYMENTS
-- ============================================================================
-- Electronic payment batches

SELECT 
  check_id,                 -- Check ID
  edi_batch_id              -- EDI batch ID for this check
FROM check_edi_batch
LIMIT 100;

-- ============================================================================
-- STEP 10C: CHECK WRITING PARAMETERS
-- ============================================================================
-- Configuration for check processing

SELECT 
  gpo_cd,                   -- Customer GPO code
  client_no,                -- Client number
  div_no,                   -- Division number
  check_to_dea,             -- Check to DEA indicator
  reject_same_batch,        -- Reject if same batch
  programid,                -- Program ID
  rollup                    -- Rollup indicator
FROM check_write_parms
LIMIT 100;

-- ============================================================================
-- ============================================================================
-- COMPLETE JOURNEY - ALL 10 STEPS COMBINED
-- ============================================================================
-- ============================================================================

SELECT 
  '01_RECEIVING' AS step_number,
  'ASN Received' AS step_name,
  asn_hdr_id AS record_id,
  received AS event_timestamp,
  'Order arrived from supplier' AS event_description,
  client_box_count || ' boxes' AS details
FROM asn_hdr

UNION ALL

SELECT 
  '02_QC_AUDIT',
  'Quality Control',
  rds_id,
  CURRENT YEAR TO SECOND,
  'Item checked - Status: ' || status,
  prod_name
FROM audit_item

UNION ALL

SELECT 
  '03_STORAGE',
  'Stored in Warehouse',
  cell_no,
  CURRENT YEAR TO SECOND,
  'Stored in area ' || area || ' cell ' || cell_no,
  'Status: ' || status
FROM cells

UNION ALL

SELECT 
  '04_PICKING',
  'Pick Assignment',
  loc_id,
  CURRENT YEAR TO SECOND,
  'Pick assigned from location',
  'Tote: ' || tote_id
FROM del_loc_asg

UNION ALL

SELECT 
  '05_SORTING',
  'Sorted by Chain/Route',
  chain_id,
  CURRENT YEAR TO SECOND,
  'Sorted for delivery route',
  'Chain: ' || chain_id || ' | Returnable: ' || ret_pct || '%'
FROM chain_pct

UNION ALL

SELECT 
  '06_TRUCK_LOADING',
  'Order Ready for Truck',
  order_header_id,
  invoice_date,
  'Shipment prepared',
  'Order: ' || order_number || ' | Amount: $' || invoice_amount
FROM billing_ws_hdr

UNION ALL

SELECT 
  '07_SHIPPED',
  'Shipment Departed',
  order_header_id,
  processing_end_date,
  'Shipment left warehouse',
  'Invoice: ' || invoice_number
FROM billing_ws_hdr

UNION ALL

SELECT 
  '08_BILLED',
  'Billing Export',
  billing_exp_hdr_id,
  billing_export_date,
  'Exported to accounting',
  'Period: ' || billing_period_cycle || '/' || billing_period_year
FROM billing_exp_hdr

UNION ALL

SELECT 
  '09_RETURN_AUTH',
  'Return Authorized',
  entry_no,
  trans_date,
  'Return/correction recorded',
  'DEA: ' || dea_no || ' | Qty: ' || quantity
FROM ar_orig

UNION ALL

SELECT 
  '10_PAYMENT',
  'Payment Received',
  check_id,
  check_date,
  'Payment processed - Status: ' || check_status,
  'Check: ' || check_no || ' | Amount: $' || check_amt
FROM check_info

ORDER BY event_timestamp DESC;

-- ============================================================================
-- QUICK REFERENCE: MAIN TABLES FOR EACH STEP
-- ============================================================================

SELECT 
  'STEP 1: RECEIVING' AS step,
  'asn_hdr' AS primary_table,
  'asn_hdr_id, gpo_cd, store_no, received, client_box_count' AS key_columns,
  'Order arrives from supplier' AS description

UNION ALL SELECT 'STEP 1: DETAILS', 'asn_dtl', 'asn_dtl_id, drug_xref_id, lot_no, exp_date, item_qty', 'Line items in ASN'
UNION ALL SELECT 'STEP 1: BARCODE', 'bar_code', 'bar_code_key, bar_code, format_cd_key, tag_gen_id', 'Physical barcodes'

UNION ALL SELECT 'STEP 2: QC CHECK', 'audit_item', 'rds_id, prod_name, status, invoice_no', 'Quality control audit'
UNION ALL SELECT 'STEP 2: BAD ITEMS', 'bad_dea, bad_barcode, bad_itag, aging_audit', 'rds_id + issue details', 'Items with issues'

UNION ALL SELECT 'STEP 3: STORAGE', 'cells', 'area, cell_no, status, item_cnt, returnable', 'Bin locations'
UNION ALL SELECT 'STEP 3: AREA INFO', 'area', 'area, area_desc, no_levels, bin_size', 'Warehouse zones'

UNION ALL SELECT 'STEP 4: PICK ASSIGN', 'del_loc_asg', 'loc_id, cntr_id, out_box_no, tote_id', 'Pick assignments'
UNION ALL SELECT 'STEP 4: PRODUCTS', 'del_drug_new', 'drug_no, prod_name, dosage_form, pack_size, dea_class', 'Product info'
UNION ALL SELECT 'STEP 4: CTRL ITEMS', 'c2_itags, blue_itags', 'rds_id, age_date, tote_id', 'Controlled substances'

UNION ALL SELECT 'STEP 5: SORT ZONE', 'area', 'area, area_desc, no_levels', 'Sorting areas'
UNION ALL SELECT 'STEP 5: CHAIN DIST', 'chain_pct', 'gpo_cd, chain_id, ret_pct, nonret_pct', 'Distribution %'
UNION ALL SELECT 'STEP 5: CLIENT PCT', 'client_pct', 'gpo_cd, client_sub_client, ret_pct, age_pct', 'Customer splits'

UNION ALL SELECT 'STEP 6: ORDER HDR', 'billing_ws_hdr', 'order_header_id, order_number, invoice_amount', 'Order header'
UNION ALL SELECT 'STEP 6: ORDER DTLS', 'billing_ws_detail', 'ws_dtl_id, item_code, units, rate, amount', 'Order details'
UNION ALL SELECT 'STEP 6: ERRORS', 'billing_ws_error', 'order_header_id, error_code, error_text', 'Shipping errors'

UNION ALL SELECT 'STEP 7: TRACKING', 'c2p_open_box', 'c2p_id, event_name, date, bar_code', 'Delivery events'
UNION ALL SELECT 'STEP 7: SHIPMENT', 'billing_ws_hdr', 'processing_end_date, customer_name, city, state', 'Shipment status'

UNION ALL SELECT 'STEP 8: EXPORT HDR', 'billing_exp_hdr', 'billing_exp_hdr_id, billing_export_date, gpo_cd', 'Billing export'
UNION ALL SELECT 'STEP 8: EXPORT DTL', 'billing_exp_dtl', 'billing_exp_dtl_id, rds_id, edi_batch_id', 'Export details'
UNION ALL SELECT 'STEP 8: ACCT CODES', 'accounting_codes', 'acct_code, acct_name, client_master_id', 'Chart of accounts'

UNION ALL SELECT 'STEP 9: AR_ORIG', 'ar_orig', 'entry_no, report_no, trans_id, dea_no, trans_date', 'Return auth original'
UNION ALL SELECT 'STEP 9: AR_CORRECT', 'ar_correct', 'corr_no, correction_id, maint_date, report_no', 'Return corrections'
UNION ALL SELECT 'STEP 9: AR_DETAIL', 'ar_correction', 'correction_id, entry_no, dea_no, quantity', 'Correction details'

UNION ALL SELECT 'STEP 10: PAYMENT', 'check_info', 'check_id, check_no, check_amt, check_date, check_status', 'Check/payment'
UNION ALL SELECT 'STEP 10: EDI', 'check_edi_batch', 'check_id, edi_batch_id', 'EDI payment batch'
UNION ALL SELECT 'STEP 10: PARAMS', 'check_write_parms', 'gpo_cd, client_no, check_to_dea', 'Check parameters';
