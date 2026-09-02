-- ============================================================================
-- FULL SUPPLY CHAIN PROCESS QUERY
-- Traces complete order lifecycle from receiving to billing & payment
-- ============================================================================

-- ============================================================================
-- STEP 1: ORDER ARRIVAL & RECEIVING
-- Tables: ASN_HDR, ASN_DTL, BAR_CODE, CONTAINER
-- ============================================================================

SELECT 
  -- ASN Header
  ah.asn_hdr_id,
  ah.asn_id,
  ah.store_no,
  ah.box_count,
  ah.create_date AS asn_create_date,
  
  -- ASN Details
  ad.asn_dtl_id,
  ad.drug_xref_id,
  ad.lot_no,
  ad.exp_date,
  ad.item_qty,
  
  -- Barcode Info
  bc.bar_code_id,
  bc.code AS barcode_code,
  bc.format_cd,
  
  -- Container Info
  cn.cntr_id,
  cn.tote_type,
  cn.weight,
  
  -- Company & Client
  c.company_id,
  c.company_name,
  cl.client_cd,
  cl.client_name,
  cl.gpo_cd
  
FROM asn_hdr ah
LEFT JOIN asn_dtl ad ON ah.asn_hdr_id = ad.asn_hdr_id
LEFT JOIN bar_code bc ON ah.asn_hdr_id = bc.asn_hdr_id
LEFT JOIN container cn ON ah.asn_hdr_id = cn.asn_hdr_id
LEFT JOIN client cl ON ah.store_no = cl.client_cd
LEFT JOIN company c ON cl.company_id = c.company_id
WHERE 1=1
  -- AND ah.create_date >= TRUNC(SYSDATE) - 7  -- Last 7 days
ORDER BY ah.create_date DESC;

-- ============================================================================
-- STEP 2: QUALITY CONTROL & AUDIT
-- Tables: AUDIT_ITEM, BAD_*, DAMAGE_CODE, AGE_*
-- ============================================================================

SELECT 
  -- Audit
  ai.rds_id,
  ai.audit_id,
  ai.status AS audit_status,
  ai.invoice_no,
  ai.prod_name,
  
  -- Quality Issues
  CASE 
    WHEN bd.record_id IS NOT NULL THEN 'BAD_DEA'
    WHEN bb.record_id IS NOT NULL THEN 'BAD_BARCODE'
    WHEN bi.record_id IS NOT NULL THEN 'BAD_ITAG'
    WHEN aa.scan_dt IS NOT NULL THEN 'AGE_ISSUE'
    ELSE 'PASS'
  END AS qc_status,
  
  -- Damage Info
  dc.damage_code_id,
  dc.damage_code,
  dc.damage_desc,
  
  -- Aging
  aa.scan_dt,
  aa.out_box_no,
  aa.status AS aging_status,
  
  -- Related Info
  ad.drug_xref_id,
  ad.lot_no,
  ad.exp_date,
  ah.asn_hdr_id,
  ah.asn_id
  
FROM audit_item ai
LEFT JOIN asn_dtl ad ON ai.rds_id = ad.asn_dtl_id
LEFT JOIN asn_hdr ah ON ad.asn_hdr_id = ah.asn_hdr_id
LEFT JOIN bad_dea bd ON ai.rds_id = bd.rds_id
LEFT JOIN bad_barcode bb ON ai.rds_id = bb.rds_id
LEFT JOIN bad_itag bi ON ai.rds_id = bi.rds_id
LEFT JOIN aging_audit aa ON ai.rds_id = aa.rds_id
LEFT JOIN damage_code dc ON ai.damage_code_id = dc.damage_code_id
WHERE ai.status IN ('PASS', 'FAIL', 'HOLD', 'REWORK')
ORDER BY ai.audit_date DESC;

-- ============================================================================
-- STEP 3: INVENTORY STORAGE & LOCATION ASSIGNMENT
-- Tables: CELLS, WAREHOUSE_MASTER, AREA, CONTAINER
-- ============================================================================

SELECT 
  -- Location Master
  c.area,
  c.cell_no,
  c.cell_id,
  c.manuf_cd,
  c.status AS cell_status,
  c.returnable,
  
  -- Area (Zone)
  a.area,
  a.area_desc,
  a.no_levels,
  a.level_inc,
  a.bin_size,
  
  -- Warehouse
  wm.whse_id,
  wm.whse_name,
  wm.dc_id,
  
  -- Container in Location
  cn.cntr_id,
  cn.tote_type,
  cn.weight,
  cn.create_date
  
FROM cells c
LEFT JOIN area a ON c.area = a.area
LEFT JOIN warehouse_master wm ON a.whse_id = wm.whse_id
LEFT JOIN container cn ON c.cell_no = cn.cell_location
WHERE c.status IN ('ACTIVE', 'FULL', 'PARTIAL')
ORDER BY c.area, c.cell_no;

-- ============================================================================
-- STEP 4: PICKING OPERATIONS & MANUFACTURING RA RETRIEVAL
-- Tables: DEL_LOC_ASG, DEL_DRUG_NEW, C2_ITAGS, BLUE_ITAGS
-- ============================================================================

SELECT 
  -- Location Assignment
  dla.del_loc_asg_id,
  dla.loc_id,
  dla.cntr_id,
  dla.cnt AS pick_count,
  dla.box_no,
  dla.create_date AS pick_date,
  
  -- Drug/Item to Pick
  ddn.drug_no,
  ddn.prod_name,
  ddn.strength,
  ddn.dosage_form,
  ddn.pack_size,
  
  -- Controlled Substances (Schedule II)
  c2.tote_id,
  c2.age_date,
  c2.rds_id,
  
  -- Aging Items
  bi.tote_id AS blue_tote_id,
  bi.age_date AS blue_age_date,
  
  -- Location Details
  c.cell_id,
  c.area,
  c.cell_no,
  a.area_desc
  
FROM del_loc_asg dla
LEFT JOIN del_drug_new ddn ON dla.drug_no = ddn.drug_no
LEFT JOIN c2_itags c2 ON dla.del_loc_asg_id = c2.del_loc_asg_id
LEFT JOIN blue_itags bi ON dla.del_loc_asg_id = bi.del_loc_asg_id
LEFT JOIN cells c ON dla.loc_id = c.cell_id
LEFT JOIN area a ON c.area = a.area
WHERE dla.create_date >= TRUNC(SYSDATE) - 30
ORDER BY dla.create_date DESC;

-- ============================================================================
-- STEP 5: SORTING & ROUTE PLANNING
-- Tables: AREA, CELLS, CHAIN_PCT, CLIENT_RSNCOD, CLIENT_SUB_CLIENT
-- ============================================================================

SELECT 
  -- Sorting Area
  a.area,
  a.area_desc,
  a.no_levels,
  
  -- Sorting Location
  c.cell_no,
  c.status,
  COUNT(*) AS items_in_cell,
  
  -- Distribution Chain
  cp.chain_cd,
  cp.chain_name,
  cp.ret_pct,
  cp.nonret_pct,
  cp.age_pct,
  
  -- Client Reason Code (Return mapping)
  cr.rsn_cd,
  cr.rsn_desc,
  
  -- Sub-client (Hierarchy)
  csc.sub_client,
  csc.ret_pct AS subclient_ret_pct,
  csc.nonret_pct AS subclient_nonret_pct
  
FROM area a
LEFT JOIN cells c ON a.area = c.area
LEFT JOIN chain_pct cp ON a.area = cp.area
LEFT JOIN client_rsn_cd cr ON cp.chain_cd = cr.chain_cd
LEFT JOIN client_sub_client csc ON cr.rsn_cd = csc.gpocd
WHERE a.no_levels > 0
GROUP BY a.area, a.area_desc, a.no_levels, c.cell_no, c.status, 
         cp.chain_cd, cp.chain_name, cp.ret_pct, cp.nonret_pct, cp.age_pct,
         cr.rsn_cd, cr.rsn_desc, csc.sub_client, csc.ret_pct, csc.nonret_pct
ORDER BY a.area, c.cell_no;

-- ============================================================================
-- STEP 6: SHIPPING PREPARATION & TRUCK LOADING
-- Tables: BILLING_WS_HDR, BILLING_WS_DETAIL, C2P_OPEN_BOX
-- ============================================================================

SELECT 
  -- Warehouse Services (Order Header)
  bwh.order_header_id,
  bwh.order_id,
  bwh.customer_id,
  bwh.invoice_no,
  bwh.order_date,
  bwh.ship_date,
  bwh.status AS order_status,
  
  -- Order Details (Items)
  bwd.order_detail_id,
  bwd.item_id,
  bwd.amount,
  bwd.rate,
  bwd.qty,
  bwd.unit_price,
  
  -- Box Tracking
  cob.event_name,
  cob.box_trk,
  cob.event_date,
  cob.jwt_token,
  
  -- Error Tracking
  bwe.error_code,
  bwe.error_text,
  bwe.record_status,
  
  -- Related
  cl.client_name,
  cl.gpo_cd
  
FROM billing_ws_hdr bwh
LEFT JOIN billing_ws_detail bwd ON bwh.order_header_id = bwd.order_header_id
LEFT JOIN c2p_open_box cob ON bwh.order_header_id = cob.order_header_id
LEFT JOIN billing_ws_error bwe ON bwh.order_header_id = bwe.order_header_id
LEFT JOIN client cl ON bwh.customer_id = cl.client_cd
WHERE bwh.order_date >= TRUNC(SYSDATE) - 30
ORDER BY bwh.order_date DESC, bwh.order_id;

-- ============================================================================
-- STEP 7: DELIVERY & SHIPPING CONFIRMATION
-- Tables: BILLING_WS_HDR, BILLING_WS_DETAIL, C2P_OPEN_BOX
-- ============================================================================

SELECT 
  -- Delivery Info
  bwh.order_header_id,
  bwh.order_id,
  bwh.ship_date,
  bwh.delivered_date,
  bwh.status AS delivery_status,
  
  -- Shipped Items
  bwd.item_id,
  bwd.qty AS qty_shipped,
  bwd.amount AS amount_shipped,
  
  -- Delivery Tracking
  cob.box_trk,
  cob.event_name,
  cob.event_date,
  
  -- Recipient
  cl.client_name,
  cl.client_addr,
  cl.client_city,
  cl.client_state,
  
  -- Order Total
  SUM(bwd.amount) OVER (PARTITION BY bwh.order_header_id) AS order_total
  
FROM billing_ws_hdr bwh
LEFT JOIN billing_ws_detail bwd ON bwh.order_header_id = bwd.order_header_id
LEFT JOIN c2p_open_box cob ON bwh.order_header_id = cob.order_header_id
LEFT JOIN client cl ON bwh.customer_id = cl.client_cd
WHERE bwh.delivered_date >= TRUNC(SYSDATE) - 60
ORDER BY bwh.delivered_date DESC;

-- ============================================================================
-- STEP 8: BILLING & EXPORT TO ACCOUNTING
-- Tables: BILLING_EXP_HDR, BILLING_EXP_DTL, BILLING_WS_HDR
-- ============================================================================

SELECT 
  -- Export Header
  beh.export_hdr_id,
  beh.export_date,
  beh.year,
  beh.period,
  beh.report_type,
  beh.export_status,
  
  -- Export Details
  bed.export_dtl_id,
  bed.rds_id,
  bed.type AS line_type,
  bed.batch_id,
  bed.amount,
  
  -- Related Order
  bwh.order_header_id,
  bwh.order_id,
  bwh.invoice_no,
  bwh.order_date,
  
  -- Client
  cl.client_name,
  cl.gpo_cd,
  
  -- Accounting
  ac.acct_code,
  ac.acct_name,
  ac.client_master_id
  
FROM billing_exp_hdr beh
LEFT JOIN billing_exp_dtl bed ON beh.export_hdr_id = bed.export_hdr_id
LEFT JOIN billing_ws_hdr bwh ON bed.rds_id = bwh.order_header_id
LEFT JOIN client cl ON bwh.customer_id = cl.client_cd
LEFT JOIN accounting_codes ac ON cl.client_cd = ac.client_master_id
WHERE beh.export_date >= TRUNC(SYSDATE) - 90
ORDER BY beh.export_date DESC, beh.export_hdr_id;

-- ============================================================================
-- STEP 9: RETURN AUTHORIZATION & CORRECTIONS
-- Tables: AR_ORIG, AR_CORRECT, AR_CORRECTION, CHECK_INFO
-- ============================================================================

SELECT 
  -- Original Record
  ao.report_no AS ar_report_no,
  ao.trans_id,
  ao.entry_no,
  ao.dea_no,
  ao.trans_code,
  ao.qty AS original_qty,
  ao.lot_no,
  ao.strength,
  ao.create_date AS ar_original_date,
  
  -- Correction
  ac.corr_no,
  ac.correction_id,
  ac.correction_text,
  ac.maint_date AS correction_date,
  acor.correction_detail_code,
  acor.correction_amount,
  
  -- Payment/Check
  ci.check_no,
  ci.check_amt,
  ci.check_date,
  ci.check_status,
  ci.clr_date,
  ci.bank_account,
  
  -- Related Info
  dd.drug_no,
  dd.prod_name,
  cl.client_name,
  cl.gpo_cd
  
FROM ar_orig ao
LEFT JOIN ar_correct ac ON ao.report_no = ac.report_no 
                        AND ao.trans_id = ac.trans_id
LEFT JOIN ar_correction acor ON ac.correction_id = acor.correction_id
LEFT JOIN check_info ci ON ao.entry_no = ci.check_id
LEFT JOIN del_drug_new dd ON ao.drug_no = dd.drug_no
LEFT JOIN client cl ON ao.gpo_cd = cl.gpo_cd
WHERE ao.create_date >= TRUNC(SYSDATE) - 180
ORDER BY ao.create_date DESC;

-- ============================================================================
-- STEP 10: PAYMENT RECORD & EDI BATCH
-- Tables: CHECK_INFO, CHECK_EDI_BATCH, CHECK_WRITE_PARMS
-- ============================================================================

SELECT 
  -- Check Info
  ci.check_id,
  ci.check_no,
  ci.check_amt,
  ci.check_date,
  ci.check_status,
  ci.void_ind,
  ci.clr_date,
  ci.void_date,
  
  -- EDI Batch
  ceb.check_edi_batch_id,
  ceb.edi_batch_no,
  ceb.batch_date,
  ceb.batch_status,
  ceb.transmission_date,
  
  -- Parameters
  cwp.check_write_parm_id,
  cwp.bank_acct_no,
  cwp.routing_no,
  cwp.from_amount,
  cwp.to_amount,
  
  -- Client
  cl.client_name,
  cl.gpo_cd,
  
  -- Related Invoice
  ao.report_no,
  ao.trans_id,
  SUM(ao.qty) OVER (PARTITION BY ci.check_id) AS total_items_paid
  
FROM check_info ci
LEFT JOIN check_edi_batch ceb ON ci.check_id = ceb.check_id
LEFT JOIN check_write_parms cwp ON ci.bank_account = cwp.bank_acct_no
LEFT JOIN ar_orig ao ON ci.check_id = ao.check_ref
LEFT JOIN client cl ON ao.gpo_cd = cl.gpo_cd
WHERE ci.check_date >= TRUNC(SYSDATE) - 180
ORDER BY ci.check_date DESC;

-- ============================================================================
-- MASTER QUERY: COMPLETE ORDER LIFECYCLE (End-to-End)
-- ============================================================================

WITH order_journey AS (
  SELECT 
    -- STEP 1: RECEIVING
    ah.asn_id,
    ah.asn_hdr_id,
    ah.store_no,
    ah.create_date AS received_date,
    'RECEIVING' AS process_step,
    
    -- STEP 2: QC
    ai.audit_id,
    ai.status AS qc_status,
    ai.audit_date,
    
    -- STEP 3: STORAGE
    c.area,
    c.cell_no,
    
    -- STEP 4: PICKING
    dla.del_loc_asg_id,
    dla.create_date AS pick_date,
    
    -- STEP 5: SORTING
    a.area_desc,
    cp.chain_cd,
    
    -- STEP 6-7: SHIPPING
    bwh.order_header_id,
    bwh.order_id,
    bwh.ship_date,
    bwh.delivered_date,
    bwh.status AS delivery_status,
    
    -- STEP 8: BILLING
    beh.export_date,
    
    -- STEP 9-10: PAYMENT
    ci.check_no,
    ci.check_amt,
    ci.check_date,
    ci.clr_date,
    
    -- CLIENT & COMPANY
    cl.client_name,
    cl.gpo_cd,
    c_comp.company_name
  
  FROM asn_hdr ah
  LEFT JOIN asn_dtl ad ON ah.asn_hdr_id = ad.asn_hdr_id
  LEFT JOIN audit_item ai ON ad.asn_dtl_id = ai.rds_id
  LEFT JOIN cells c ON ah.asn_hdr_id = c.asn_hdr_id
  LEFT JOIN area a ON c.area = a.area
  LEFT JOIN del_loc_asg dla ON c.cell_id = dla.loc_id
  LEFT JOIN chain_pct cp ON a.area = cp.area
  LEFT JOIN billing_ws_hdr bwh ON ah.asn_hdr_id = bwh.asn_ref_id
  LEFT JOIN billing_exp_hdr beh ON bwh.order_header_id = beh.order_header_id
  LEFT JOIN ar_orig ao ON bwh.order_header_id = ao.order_ref_id
  LEFT JOIN check_info ci ON ao.check_ref = ci.check_id
  LEFT JOIN client cl ON ah.store_no = cl.client_cd
  LEFT JOIN company c_comp ON cl.company_id = c_comp.company_id
  
  WHERE ah.create_date >= TRUNC(SYSDATE) - 90
)

SELECT 
  asn_id,
  order_id,
  client_name,
  gpo_cd,
  company_name,
  
  -- Timeline
  received_date,
  pick_date,
  ship_date,
  delivered_date,
  export_date,
  check_date,
  clr_date,
  
  -- Status Through Process
  qc_status,
  delivery_status,
  
  -- Location & Routing
  area_desc,
  chain_cd,
  
  -- Financial
  check_no,
  check_amt,
  DATEDIFF(DAY, received_date, clr_date) AS days_to_payment
  
FROM order_journey
WHERE asn_id IS NOT NULL
ORDER BY received_date DESC;

-- ============================================================================
-- COST & PRICING LOOKUP (Related to Order Process)
-- ============================================================================

SELECT 
  -- Product
  dd.drug_no,
  dd.prod_name,
  dd.strength,
  dd.dosage_form,
  
  -- Cost Hierarchy
  ct.cost_type_id,
  ct.cost_type,
  cn.cost,
  cn.run_date,
  
  -- Client Specific Cost
  cc.gpo_cd,
  cc.cost_type_id AS client_cost_type_id,
  cc.cost AS client_cost,
  cc.pack_qty,
  
  -- Discount
  ccp.brand_pct,
  ccp.generic_pct,
  ccp.recall_pct,
  
  -- AWP vs ACQ
  caa.acq_price,
  caa.awp_price,
  
  -- Related Client
  cl.client_name
  
FROM del_drug_new dd
LEFT JOIN cost_new cn ON dd.drug_no = cn.drug_no
LEFT JOIN cost_type ct ON cn.cost_type_id = ct.cost_type_id
LEFT JOIN client_cost cc ON ct.cost_type_id = cc.cost_type_id
LEFT JOIN client_cost_pct ccp ON cc.gpo_cd = ccp.gpo_cd 
                              AND cc.cost_type_id = ccp.cost_type_id
LEFT JOIN cost_acq_awp caa ON dd.drug_no = caa.drug_no
LEFT JOIN client cl ON cc.gpo_cd = cl.gpo_cd
WHERE cn.run_date >= TRUNC(SYSDATE) - 30
ORDER BY dd.drug_no, cl.client_name;

-- ============================================================================
-- AUDIT & COMPLIANCE VERIFICATION
-- ============================================================================

SELECT 
  -- Process Checkpoint
  'COMPLIANCE_CHECK' AS check_type,
  ah.asn_id,
  
  -- QC Verification
  COUNT(DISTINCT ai.audit_id) AS total_audits,
  SUM(CASE WHEN ai.status = 'PASS' THEN 1 ELSE 0 END) AS pass_count,
  SUM(CASE WHEN ai.status = 'FAIL' THEN 1 ELSE 0 END) AS fail_count,
  
  -- Bad Records
  COUNT(DISTINCT bd.record_id) AS bad_dea_count,
  COUNT(DISTINCT bb.record_id) AS bad_barcode_count,
  COUNT(DISTINCT bi.record_id) AS bad_itag_count,
  
  -- Delivery Success
  COUNT(DISTINCT bwh.order_header_id) AS total_orders,
  SUM(CASE WHEN bwh.status = 'DELIVERED' THEN 1 ELSE 0 END) AS delivered_count,
  
  -- Payment Verification
  COUNT(DISTINCT ci.check_id) AS total_checks,
  SUM(CASE WHEN ci.check_status = 'CLEARED' THEN ci.check_amt ELSE 0 END) AS cleared_amount,
  
  -- Timeline
  MIN(ah.create_date) AS earliest_receipt,
  MAX(ci.clr_date) AS latest_clearance
  
FROM asn_hdr ah
LEFT JOIN asn_dtl ad ON ah.asn_hdr_id = ad.asn_hdr_id
LEFT JOIN audit_item ai ON ad.asn_dtl_id = ai.rds_id
LEFT JOIN bad_dea bd ON ai.rds_id = bd.rds_id
LEFT JOIN bad_barcode bb ON ai.rds_id = bb.rds_id
LEFT JOIN bad_itag bi ON ai.rds_id = bi.rds_id
LEFT JOIN cells c ON ah.asn_hdr_id = c.asn_hdr_id
LEFT JOIN del_loc_asg dla ON c.cell_id = dla.loc_id
LEFT JOIN billing_ws_hdr bwh ON dla.del_loc_asg_id = bwh.del_loc_asg_ref_id
LEFT JOIN ar_orig ao ON bwh.order_header_id = ao.order_ref_id
LEFT JOIN check_info ci ON ao.check_ref = ci.check_id
WHERE ah.create_date >= TRUNC(SYSDATE) - 90
GROUP BY ah.asn_id
ORDER BY ah.asn_id;
