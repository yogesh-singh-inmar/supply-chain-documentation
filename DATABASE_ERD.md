# 📊 Supply Chain Database - Entity Relationship Diagram (ERD)

## 🎯 Overview

This document maps all 680+ database tables into a complete **Entity Relationship Diagram** organized by supply chain processes.

---

## 🏗️ ERD - COMPLETE STRUCTURE

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SUPPLY CHAIN DATABASE ARCHITECTURE                       │
└─────────────────────────────────────────────────────────────────────────────┘

                                    ┌──────────────┐
                                    │   COMPANY    │
                                    │   & CLIENTS  │
                                    └──────┬───────┘
                                           │
                        ┌──────────────────┼──────────────────┐
                        │                  │                  │
                   ┌────▼────┐      ┌──────▼──────┐    ┌──────▼──────┐
                   │ COMPANY  │      │   CLIENT    │    │ DEA_MASTER  │
                   └────┬────┘      └──────┬──────┘    └──────┬──────┘
                        │                  │                  │
                ┌───────┴──────┬───────────┴────┬─────────────┼──────────┐
                │              │                │             │          │
           ┌────▼───┐   ┌──────▼──────┐   ┌────▼────┐   ┌────▼────┐   ┌▼──────┐
           │ DC_    │   │ CLIENT_     │   │ PRODUCT │   │WAREHOUSE│   │ AREA  │
           │ WHSE   │   │CUSTOM       │   │ MASTER  │   │ MASTER  │   │       │
           └───┬────┘   └─────────────┘   └────┬────┘   └────┬────┘   └───┬──┘
               │                               │             │            │
               │                          ┌────▼────┐        │      ┌─────▼────┐
               │                          │  DRUG_  │        │      │  CELLS   │
               │                          │  MASTER │        │      │          │
               │                          └────┬────┘        │      └──────────┘
               │                               │             │
        ┌──────▼──────────────────────────────┴─────────────┴──┐
        │                                                       │
        │            📥 RECEIVING PROCESS FLOW                 │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐   ┌──────────┐  │
        │  │ ASN_HDR      │   │ ASN_DTL      │   │ BAR_CODE │  │
        │  │ (Inbound)    │───│ (Line Items) │   │ (Scan)   │  │
        │  └──────────────┘   └──────────────┘   └──────────┘  │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐   ┌──────────┐  │
        │  │ CONTAINER    │   │ CONTAINER_   │   │ CELLS    │  │
        │  │ (Tote/Box)   │───│ WEIGHT       │   │ (Loca)   │  │
        │  └──────────────┘   └──────────────┘   └──────────┘  │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐                │
        │  │ BAR_CODE_    │   │ AUDIT_ITEM   │                │
        │  │ REASON       │   │ (QC Issues)  │                │
        │  └──────────────┘   └──────────────┘                │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │        🔍 PROCESSING & IDENTIFICATION FLOW           │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐   ┌──────────┐  │
        │  │ CLIENT_ITEM  │   │ DAMAGE_CODE  │   │ BAD_     │  │
        │  │ (Xref)       │   │ (Quality)    │   │ IITAG*   │  │
        │  └──────────────┘   └──────────────┘   └──────────┘  │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐                │
        │  │ BAD_DEA*     │   │ AGE_*        │                │
        │  │ (Invalid)    │   │ (Expiry)     │                │
        │  └──────────────┘   └──────────────┘                │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │      🏭 MANUFACTURING RA RETRIEVAL FLOW              │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐   ┌──────────┐  │
        │  │ CELLS        │   │ DEL_LOC_ASG  │   │ DEL_DRUG│  │
        │  │ (Locations)  │───│ (Assignment) │   │ (Pick)  │  │
        │  └──────────────┘   └──────────────┘   └──────────┘  │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐                │
        │  │ C2_ITAGS     │   │ BULK_AGING   │                │
        │  │ (Schedule II)│   │ (Batch Pick) │                │
        │  └──────────────┘   └──────────────┘                │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │           🔀 SORTING & ROUTE PLANNING                │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐   ┌──────────┐  │
        │  │ AREA         │   │ CELLS        │   │ BILLING_ │  │
        │  │ (Zones)      │   │ (Sort Area)  │   │ WS_HDR   │  │
        │  └──────────────┘   └──────────────┘   └──────────┘  │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐                │
        │  │ CLIENT_RSNCOD│   │ CHAIN_PCT    │                │
        │  │ (Reason)     │   │ (Distribution)               │
        │  └──────────────┘   └──────────────┘                │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │              🚚 SHIPPING & DELIVERY                  │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐   ┌──────────┐  │
        │  │ BILLING_WS_  │   │ BILLING_WS_  │   │ BILLING_ │  │
        │  │ HDR          │───│ DETAIL       │   │ WS_ERROR │  │
        │  │ (Order)      │   │ (Items)      │   │ (Issues) │  │
        │  └──────────────┘   └──────────────┘   └──────────┘  │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐                │
        │  │ C2P_OPEN_BOX │   │ BILLING_EXP* │                │
        │  │ (Tracking)   │   │ (Export)     │                │
        │  └──────────────┘   └──────────────┘                │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │          💰 BILLING & RETURN MANAGEMENT              │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐   ┌──────────┐  │
        │  │ AR_ORIG*     │   │ AR_CORRECT*  │   │ RECALL_  │  │
        │  │ (Original)   │───│ (Amended)    │   │ RETURN   │  │
        │  └──────────────┘   └──────────────┘   └──────────┘  │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐                │
        │  │ CHECK_INFO   │   │ CHECK_EDI    │                │
        │  │ (Payout)     │───│ (Batch)      │                │
        │  └──────────────┘   └──────────────┘                │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐                │
        │  │ DEL_MFG_     │   │ BLOCK        │                │
        │  │ POLICY       │   │ (Hold Items) │                │
        │  └──────────────┘   └──────────────┘                │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │         💵 COST & PRICING MANAGEMENT                 │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐   ┌──────────┐  │
        │  │ COST_TYPE    │   │ COST_NEW     │   │ COST_    │  │
        │  │ (Masters)    │───│ (Current)    │   │ PARENT   │  │
        │  └──────────────┘   └──────────────┘   └──────────┘  │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐                │
        │  │ CLIENT_COST  │   │ CLIENT_COST_ │                │
        │  │ (Assign)     │   │ PCT (Rule)   │                │
        │  └──────────────┘   └──────────────┘                │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐                │
        │  │ COST_DISC_PCT│   │ COST_ACQ_AWP │                │
        │  │ (Discount)   │   │ (Pricing)    │                │
        │  └──────────────┘   └──────────────┘                │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       │
        │       🔗 CONFIGURATION & CROSS-REFERENCE              │
        │                                                       │
        └──────┬───────────────────────────────────────────────┘
               │
        ┌──────▼──────────────────────────────────────────────┐
        │                                                       ��
        │  ┌──────────────┐   ┌──────────────┐   ┌──────────┐  │
        │  │ CLIENT_FIRST │   │ CLIENT_RSN   │   │ ARCOS_   │  │
        │  │ _DATA        │   │ _CD          │   │ 222_XREF │  │
        │  └──────────────┘   └──────────────┘   └──────────┘  │
        │                                                       │
        │  ┌──────────────┐   ┌──────────────┐                │
        │  │ CVS_KEY_REC  │   │ BUS_UNIT_*   │                │
        │  │ (Special)    │   │ (Hierarchy)  │                │
        │  └──────────────┘   └──────────────┘                │
        │                                                       │
        └──────────────────────────────────────────────────────┘

    * Multiple versions: _ORIG (original), _NEW (current), _LATE (amendments)
```

---

## 📋 DETAILED TABLE GROUPS & RELATIONSHIPS

### **GROUP 1: MASTER DATA & CONFIGURATION**

```
                        MASTER DATA CORE
                              │
        ┌─────────────────┬───┴────┬─────────────────┐
        │                 │        │                 │
    ┌───▼────┐      ┌─────▼──┐  ┌─▼────────┐  ┌─────▼──┐
    │COMPANY  │      │ CLIENT │  │ DRUG     │  │  DEA   │
    │         │      │        │  │ MASTER   │  │        │
    │ ✓ ID    │      │ ✓ ID   │  │ ✓ ID     │  │ ✓ ID   │
    │ ✓ NAME  │      │ ✓ ADDR │  │ ✓ NDC    │  │ ✓ NAME │
    │ ✓ DEA   │      │ ✓ TYPE │  │ ✓ NAME   │  │ ✓ ADDR │
    └────┬────┘      └────────┘  └──────────┘  └───┬────┘
         │                                          │
         │          RELATES TO ALL OPERATIONS      │
         └──────────────────┬─────────────────────┘
                            │
                    ┌───────┴────────┐
                    │                │
              ┌─────▼─────┐    ┌─────▼──────┐
              │ WAREHOUSE │    │ LOCATION   │
              │           │    │ MASTER     │
              │ ✓ ID      │    │ ✓ AREA     │
              │ ✓ NAME    │    │ ✓ CELLS    │
              │ ✓ DEA     │    │ ✓ BIN_SIZE │
              └───────────┘    └────────────┘
```

**Key Tables:**
- `company` → Company basic info
- `client` → Customer details (670+ columns!)
- `client_assoc` → Client relationships
- `dea_new` / `dea_prev` → DEA regulatory data
- `dc_whse` → Distribution center mapping
- `area` → Warehouse areas/zones
- `cells` → Storage locations
- `code_desc` → Code lookup tables

---

### **GROUP 2: RECEIVING & INBOUND FLOW**

```
                    INBOUND PROCESSING
                              │
                    ┌─────────┴──────────┐
                    │                    │
        ┌───────────▼──────────┐   ┌─────▼────────────┐
        │  ADVANCED SHIPPING   │   │  BARCODE/SCAN    │
        │  NOTIFICATION        │   │  PROCESS         │
        └──────────┬───────────┘   └─────┬────────────┘
                   │                     │
            ┌──────▼──────┐      ┌───────▼────────┐
            │ ASN_HDR      │      │ BAR_CODE       │
            │              │      │                │
            │ ✓ ASN_ID     │      │ ✓ CODE         │
            │ ✓ STORE_NO   │      │ ✓ FORMAT_CD    │
            │ ✓ BOX_COUNT  │      │ ✓ TAG_GEN_ID   │
            └──────┬───────┘      └────────────────┘
                   │
            ┌──────▼──────┐      ┌──────────────────┐
            │ ASN_DTL      │      │ BAR_CODE_REASON  │
            │              │      │                  │
            │ ✓ DRUG_XREF  │      │ ✓ REASON_CD      │
            │ ✓ LOT_NO     │      │ ✓ CREATE_DATE    │
            │ ✓ EXP_DATE   │      │ ✓ USER_ID        │
            │ ✓ ITEM_QTY   │      └──────────────────┘
            └──────────────┘
```

**Key Tables:**
- `asn_hdr` / `asn_dtl` → Advance Ship Notice (Header/Detail)
- `bar_code` → Physical barcode records
- `bar_code_reason` → Why barcode was generated
- `container` → Physical totes/boxes
- `container_weight` → Weight tracking

---

### **GROUP 3: RECEIVING QUALITY CONTROL**

```
                   RECEIVING QC ISSUES
                              │
        ┌─────────────────┬───┴────┬─────────────────┐
        │                 │        │                 │
    ┌───▼────────┐   ┌────▼───┐ ┌─▼──────┐  ┌──────▼──┐
    │ AUDIT_ITEM  │   │BAD_*   │ │AGE_*   │  │DAMAGE_  │
    │ (QC Check)  │   │(Invalid)│ │(Expiry)│  │CODE     │
    │             │   │        │ │        │  │         │
    │✓ RDS_ID     │   │✓ Field │ │✓ Field │  │✓ Field  │
    │✓ PROD_NAME  │   │Data    │ │Data    │  │Lookups  │
    │✓ STATUS     │   │Issues  │ │Issues  │  │         │
    │✓ INVOICE_NO │   │        │ │        │  │         │
    └─────────────┘   └────────┘ └────────┘  └─────────┘
         │                 │         │           │
         └─────────────────┼─────────┼───────────┘
                           │         │
                     REJECT/REWORK/HOLD
                           │
        ┌──────────────────┴──────────────────┐
        │                                      │
    ┌───▼────────┐                   ┌────────▼──┐
    │ BAD_ITAG*  │                   │AGING_AUDIT│
    │ (10 types) │                   │           │
    │            │                   │ ✓ SCAN_DT │
    │ Specific   │                   │ ✓ OUT_BOX │
    │ data issues│                   │ ✓ STATUS  │
    └────────────┘                   └───────────┘
```

**Key Tables:**
- `audit_item` → QC audit trail
- `bad_dea`, `bad_dea1`, `bad_dea2` → Invalid DEA records
- `bad_hin_data` → Bad Healthcare ID Numbers
- `bad_barcode` → Barcode scan errors
- `bad_itag1-12` → Multiple item tag error types
- `bad_walgrr` → Walgreens specific issues
- `aging_audit` → Aging/expiry tracking
- `damage_code` → Damage classification

---

### **GROUP 4: PROCESSING & IDENTIFICATION**

```
                    ITEM IDENTIFICATION
                              │
            ┌─────────────────┴──────────────┐
            │                                │
      ┌─────▼──────┐                ┌───────▼───────┐
      │ CLIENT_ITEM │                │ DEL_DRUG_NEW  │
      │ (Cross-ref) │                │ (Product Info)│
      │             │                │               │
      │ ✓ DRUG_NO   │                │ ✓ DRUG_NO     │
      │ ✓ LABELER   │                │ ✓ PROD_NAME   │
      │ ✓ ITEM_NO   │                │ ✓ STRENGTH    │
      │ ✓ DIRECT    │                │ ✓ DOSAGE_FORM │
      │ ✓ WHSLR_DEA │                │ ✓ PACK_SIZE   │
      └─────────────┘                └───────────────┘
            │
      ┌─────▼──────────┐
      │ CLIENT_FIRST   │
      │ _DATA          │
      │                │
      │ ✓ NDC_UPC      │
      │ ✓ BRAND_NAME   │
      │ ✓ MT_STRN      │
      │ ✓ DOSAGE_FORM  │
      │ ✓ PACK_QTY     │
      │ ✓ AWP/ACQ      │
      │ ✓ GENERIC_FLAG │
      └────────────────┘
```

**Key Tables:**
- `client_item` → Product assignment to customer
- `client_first_data` → Extended product master data
- `del_drug_new` → Deleted/discontinued drugs
- `dea_ndc` → DEA-to-NDC mapping
- `block` / `block_lite` → Blocked items (hold/prevent)
- `allow_upd_gpo` → Allowance rules

---

### **GROUP 5: MANUFACTURING RA RETRIEVAL (PICKING)**

```
                      PICKING OPERATIONS
                              │
        ┌─────────────────┬───┴────┬─────────────────┐
        │                 │        │                 │
    ┌───▼────────┐   ┌────▼───┐ ┌─▼──────┐  ┌──────▼──┐
    │  CELLS     │   │DEL_LOC │ │DEL_DRUG│  │BLUE_    │
    │            │   │_ASG    │ │        │  │ITAGS    │
    │✓ CELL_NO   │   │        │ │(Pick)  │  │(Aged)   │
    │✓ STATUS    │   │✓ LOC   │ │        │  │         │
    │✓ MANUF_CD  │   │✓ CNT   │ │✓ ITEM  │  │✓ AGE_DT │
    │✓ RETURNABLE│   │✓ BOX   │ │ID      │  │✓ TOTE   │
    └─────────────┘   └────────┘ └────────┘  └─────────┘
         │                 │         │
         └─────────────────┼─────────┘
                           │
                    ┌──────▼──────┐
                    │ C2_ITAGS    │
                    │(Schedule II)│
                    │             │
                    │✓ TOTE_ID    │
                    │✓ AGE_DATE   │
                    │✓ RDS_ID     │
                    └─────────────┘
```

**Key Tables:**
- `cells` → Bin/location inventory
- `del_loc_asg` → Item location assignment
- `del_drug_new` → Drug to pick
- `c2_itags` → Schedule II controlled items
- `c2p_itags` → Category 2 items (aging)
- `blue_itags` → Aged items
- `bulk_aging_itag` → Batch aging operations
- `bad_itag*` → Picking errors

---

### **GROUP 6: SORTING & ROUTE OPTIMIZATION**

```
                  SORTING & ORGANIZATION
                              │
        ┌─────────────────┬───┴────┬─────────────────┐
        │                 │        │                 │
    ┌───▼────────┐   ┌────▼───┐ ┌─▼──────┐  ┌──────▼──┐
    │   AREA     │   │ CELLS  │ │CHAIN_  │  │CLIENT_  │
    │ (Zones)    │   │(Sort)  │ │PCT     │  │RSNCOD   │
    │            │   │        │ │(Chain) │  │(Mapping)│
    │✓ AREA_DESC │   │✓ ITEM  │ │        │  │         │
    │✓ NO_LEVELS │   │✓ STATUS│ │✓ RET%  │  │✓ MAP_CD │
    │✓ LEVEL_INC │   │✓ CELL  │ │✓ AGE%  │  │✓ DAMAGE_│
    │✓ BIN_SIZE  │   │        │ │        │  │ CD_ID   │
    └─────────────┘   └────────┘ └────────┘  └─────────┘
         │
    ┌────▼────────────────────────┐
    │ CLIENT_SUB_CLIENT            │
    │ (Distribution Hierarchy)     │
    │                              │
    │ ✓ GPOCD                      │
    │ ✓ SUB_CLIENT                 │
    │ ✓ RET_PCT / NONRET_PCT       │
    │ ✓ ASN_THRESHOLD              │
    └──────────────────────────────┘
```

**Key Tables:**
- `area` → Warehouse zones/areas
- `cells` → Sorting locations
- `chain_pct` → Chain store distribution %
- `client_rsn_cd` → Return reason mapping
- `client_pct` → Client distribution %
- `client_sub_client` → Sub-client hierarchy
- `client_rsncd_rtnable` → Returnable codes
- `asg_box_lane` → Lane assignments

---

### **GROUP 7: SHIPPING & DELIVERY**

```
                  SHIPPING OPERATIONS
                              │
        ┌─────────────────┬───┴────┬─────────────────┐
        │                 │        │                 │
    ┌───▼────────┐   ┌────▼───┐ ┌─▼──────────┐  ┌──────▼──┐
    │BILLING_WS  │   │BILLING │ │C2P_OPEN_BOX│  │CVS_TOTE │
    │_HDR        │   │_WS_DTL │ │(Tracking)  │  │         │
    │(Order)     │   │(Items) │ │            │  │✓ TOTE   │
    │            │   │        │ │✓ EVENT_NAME│  │_TYPE    │
    │✓ ORDER_ID  │   │✓ ITEM  │ │✓ DATE      │  │         │
    │✓ CUSTOMER  │   │✓ AMOUNT│ │✓ BOX_TRK   │  │         │
    │✓ INVOICE   │   │✓ RATE  │ │✓ JWT_TOKEN │  │         │
    │✓ DATEA     │   │        │ │            │  │         │
    └─────────────┘   └────────┘ └────────────┘  └─────────┘
         │
    ┌────▼────────────────────────┐
    │  BILLING_WS_ERROR            │
    │  (Delivery Issues)           │
    │                              │
    │  ✓ ERROR_CODE                │
    │  ✓ ERROR_TEXT                │
    │  ✓ RECORD_STATUS             │
    └──────────────────────────────┘
```

**Key Tables:**
- `billing_ws_hdr` → Order header (Warehouse Services)
- `billing_ws_detail` → Order line items
- `billing_ws_error` → Shipping errors
- `c2p_open_box` → Box open tracking/events
- `cvs_tote` → CVS tote management
- `cvs_key_recid` → CVS key record ID mapping

---

### **GROUP 8: BILLING & RETURNS MANAGEMENT**

```
                  BILLING & RETURNS FLOW
                              │
        ┌─────────────────┬───┴────┬─────────────────┐
        │                 │        │                 │
    ┌───▼────────┐   ┌────▼───┐ ┌─▼──────┐  ┌──────▼──┐
    │AR_ORIG*    │   │AR_CORR │ │AR_YR   │  │AR_YREND │
    │(Original)  │   │ECT*    │ │END*    │  │_CORRECT*│
    │            │   │(Amend) │ │(YrEnd) │  │         │
    │✓ ENTRY_NO  │   │        │ │        │  │✓ FIELD  │
    │✓ DEA_NO    │   │✓ CORR  │ │✓ ENTRY │  │ Same    │
    │✓ TRANS_CODE│   │_NO     │ │        │  │Pattern  │
    │✓ QTY       │   │✓ MAINT │ │        │  │         │
    │✓ LOT_NO    │   │_DATE   │ │        │  │         │
    │✓ STRENGTH  │   │        │ │        │  │         │
    └─────────────┘   └────────┘ └────────┘  └─────────┘
         │                 │         │           │
         └─────────────────┼─────────┼───────────┘
                           │
                    ┌──────▼──────┐
                    │ CHECK_INFO   │
                    │ (Payouts)    │
                    │              │
                    │✓ CHECK_NO    │
                    │✓ CHECK_AMT   │
                    │✓ CHECK_DATE  │
                    │✓ STATUS      │
                    │✓ CLR_DATE    │
                    └──────────────┘
```

**Key Tables:**
- `ar_orig*` → Original records (multiple versions: ORIG, ORIG_LATE)
- `ar_correct*` → Corrected records (multiple versions: CORRECT, CORR_LATE)
- `ar_correction` → Correction detail
- `ar_yrend*` → Year-end records
- `check_info` → Check payment info
- `check_edi_batch` → EDI batch linking
- `check_write_parms` → Check writing parameters
- `arcos_222_xref` → Form 222 cross-reference

---

### **GROUP 9: MANUFACTURING POLICY & HOLDS**

```
              MANUFACTURING POLICY CONTROL
                              │
        ┌─────────────────┬───┴────┬─────────────────┐
        │                 │        │                 │
    ┌───▼────────┐   ┌────▼───┐ ┌─▼──────┐  ┌──────▼──┐
    │DEL_MFG_    │   │BLOCK   │ │BLOCK_  │  │BAD_ITAG │
    │POLICY      │   │(Hold)  │ │LITE    │  │(Errors) │
    │            │   │        │ │        │  │         │
    │✓ LABELER   │   │✓ DRUG  │ │✓ DRUG  │  │✓ Issues │
    │✓ GPO_CD    │   │_NO     │ │_NO     │  │Fields   │
    │✓ ALLOW_    │   │✓ USER  │ │✓ USER  │  │         │
    │ RTNS       │   │✓ MAINT │ │✓ MAINT │  │         │
    │✓ FULLS %   │   │_DATE   │ │_DATE   │  │         │
    │✓ DISC %    │   │        │ │        │  │         │
    │✓ AUTH_REQD │   │        │ │        │  │         │
    └─────────────┘   └────────┘ └────────┘  └─────────┘
```

**Key Tables:**
- `del_mfg_policy` → Manufacturer return policy
- `block` / `block_lite` → Blocking items
- `bad_itag*` → Item errors preventing processing
- `dea_bus_act` → DEA business activity codes

---

### **GROUP 10: COST & PRICING HIERARCHY**

```
                   COST HIERARCHY STRUCTURE
                              │
        ┌─────────────────┬───┴────┬─────────────────┐
        │                 │        │                 │
    ┌───▼────────┐   ┌────▼───┐ ┌─▼──────┐  ┌──────▼──┐
    │COST_TYPE   │   │COST_NEW│ │COST_   │  │COST_DISC│
    │ (Masters)  │   │(Current)│PARENT   │  │_PCT     │
    │            │   │        │ │(Hierarchy)         │
    │✓ COST_TYPE │   │✓ COST  │ │        │  │✓ BASE   │
    │✓ FILE_     │   │✓ DRUG  │ │✓ CHILD │  │_COST    │
    │ LAYOUT_ID  │   │✓ RUN   │ │✓ PARENT│  │✓ PCT    │
    │✓ SAVE_COST │   │_DATE   │ │        │  │         │
    │✓ RUN_COST  │   │        │ │        │  │         │
    └─────────────┘   └────────┘ └────────┘  └─────────┘
         │
    ┌────▼──────────────────────────┐
    │ CLIENT_COST / CLIENT_COST_TYPE │
    │                                │
    │ ✓ GPOCD                        │
    │ ✓ COST_TYPE_ID                 │
    │ ✓ COST                         │
    │ ✓ PACK_QTY / PACK_SIZE         │
    └────────────────────────────────┘
         │
    ┌────▼────────────────────────────┐
    │ CLIENT_COST_PCT                  │
    │ (Brand vs Generic Discount)      │
    │                                  │
    │ ✓ BRAND_PCT                      │
    │ ✓ GENERIC_PCT                    │
    │ ✓ RECALL_PCT                     │
    └──────────────────────────────────┘
```

**Key Tables:**
- `cost_type` / `cost_type_orig` → Cost type master
- `cost_new` / `cost_new_log` → Current & historical costs
- `cost_parent` / `cost_parent_orig` → Hierarchical relationship
- `cost_hierarchy` → Cost structure definition
- `client_cost` → Customer cost assignments
- `client_cost_type` → Customer cost type
- `client_cost_pct` → Brand/generic pricing
- `cost_disc_pct` → Discount percentages
- `cost_acq_awp` → Acquisition vs AWP pricing
- `client_bill_rate` → Storage rate calculation

---

### **GROUP 11: ACCOUNTING & FINANCIAL**

```
                 ACCOUNTING & BILLING EXPORT
                              │
        ┌─────────────────┬───┴────┬─────────────────┐
        │                 │        │                 │
    ┌───▼────────┐   ┌────▼───┐ ┌─▼──────┐  ┌──────▼──┐
    │BILLING_    │   │BILLING │ │BILLING │  │API_LOG  │
    │EXP_HDR     │   │_EXP_DTL│ │_WASTE* │  │(Track)  │
    │(Export)    │   │        │ │(Waste) │  │         │
    │            │   │        │ │        │  │✓ API_ID │
    │✓ EXPORT_DT │   │✓ RDS_ID│ │✓ DTL_  │  │✓ URL    │
    │✓ YEAR      │   │✓ TYPE  │ │ID      │  │✓ STATUS │
    │✓ PERIOD    │   │✓ BATCH │ │✓ WASTE │  │✓ TIME   │
    │✓ REPORT_TYP│   │_ID     │ │_TYPE   │  │         │
    └─────────────┘   └────────┘ └────────┘  └─────────┘
         │
    ┌────▼────────────────────────┐
    │ ACCOUNTING_CODES             │
    │ (Chart of Accounts)          │
    │                              │
    │ ✓ ACCT_CODE                  │
    │ ✓ ACCT_NAME                  │
    │ ✓ CLIENT_MASTER_ID           │
    └──────────────────────────────┘
```

**Key Tables:**
- `billing_exp_hdr` / `billing_exp_dtl` → Export header/detail
- `billing_waste_hdr` / `billing_waste_dtl` → Waste billing
- `billing_ws_hdr` / `billing_ws_detail` → Warehouse services billing
- `accounting_codes` → Chart of accounts
- `api_log` → API call tracking
- `api_config` → API configuration

---

### **GROUP 12: CONFIGURATION & MISCELLANEOUS**

```
              SYSTEM CONFIGURATION & TOOLS
                              │
        ┌─────────────────┬───┴────┬─────────────────┐
        │                 │        │                 │
    ┌───▼────────┐   ┌────▼───┐ ┌─▼──────┐  ┌──────▼──┐
    │CLIENT_      │   │CODE_   │ │CLIENT  │  │COVER_   │
    │ASSOC        │   │DESC    │ │_CUSTOM │  │LETTER   │
    │(Relation)   │   │(Codes) │ │        │  │(Docs)   │
    │             │   │        │ │        │  │         │
    │✓ REP_GPO    │   │✓ TABLE │ │✓ CUST  │  │✓ VERSION│
    │✓ REF_GPO    │   │_NAME   │ │_DC     │  │✓ SIGN   │
    │✓ TYPE       │   │✓ CODE  │ │✓ STORE │  │_NAME    │
    │             │   │✓ DESC  │ │_NO     │  │✓ FILE   │
    └─────────────┘   └────────┘ └────────┘  └─────────┘
         │
    ┌────▼──────────────────────────┐
    │ ANSWER & QUESTION              │
    │ (Survey/Config Data)           │
    │                                │
    │ ✓ QUESTION_ID                  │
    │ ✓ ANSWER_ID                    │
    │ ✓ ANSWER_TEXT / BOOL           │
    │ ✓ NEXT_ANSWER_ID (Tree)        │
    └────────────────────────────────┘
```

**Key Tables:**
- `client_assoc` → Client associations/relationships
- `code_desc` → Code description lookup
- `client_custom` → Customer customization
- `answer` / `question` → Configuration Q&A
- `cover_letter` → Correspondence template
- `client_log` → Audit log for client changes
- `client_line_no` → Line number assignments
- `client_web_except` → Web exceptions

---

## 🔄 KEY RELATIONSHIPS & JOIN PATTERNS

### **Primary Key Relationships:**

```sql
-- COMPANY-CLIENT-WAREHOUSE HIERARCHY
client (gpo_cd) → dc_whse (dc_id, whse_id)
client (gpo_cd) → company (company_id)

-- RECEIVING TO INVENTORY
asn_hdr (asn_hdr_id) → asn_dtl (asn_hdr_id)
asn_dtl (drug_xref_id) → client_first_data (ndc_upc_hri)
asn_hdr (store_no) → client (client_cd)

-- PICKING & LOCATION
cells (area, cell_no) → area (area)
del_loc_asg (loc_id, cntr_id) → cells (area, cell_no)
del_loc_asg (out_box_no) → container (cntr_id)

-- RETURNS & CORRECTIONS
ar_orig (report_no, trans_id) → ar_correct (report_no, trans_id, corr_no)
ar_correct (correction_id) → ar_correction (correction_id)
ar_correction (drug_no) → del_drug_new (drug_no)

-- COSTING
cost_type (cost_type_id) → cost_new (cost_type_id, drug_no)
client (gpo_cd) → client_cost_type (gpo_cd, cost_type_id)
cost_parent (cost_type_id_child) → cost_type (cost_type_id)

-- BILLING & SHIPPING
billing_ws_hdr (order_header_id) → billing_ws_detail (order_header_id)
check_info (gpo_cd) → check_edi_batch (check_id)
```

---

## 📊 SUMMARY STATISTICS

| Category | Count | Examples |
|----------|-------|----------|
| **Master Data Tables** | ~30 | company, client, dea, area |
| **Receiving Tables** | ~50 | asn_*, bar_code*, audit_item, bad_* |
| **Processing Tables** | ~25 | client_item, client_first_data, damage_code |
| **Picking Tables** | ~20 | cells, del_loc_asg, c2_itags, blue_itags |
| **Sorting Tables** | ~15 | area, chain_pct, client_rsn_cd |
| **Billing Tables** | ~40 | billing_ws*, billing_exp*, billing_waste* |
| **Return/AR Tables** | ~15 | ar_orig*, ar_correct*, ar_yrend* |
| **Cost Tables** | ~20 | cost_type*, cost_new*, client_cost* |
| **Config Tables** | ~25 | code_desc, client_assoc, api_config |
| **Misc/Audit Tables** | ~50 | client_log, counter, cw*, cvs* |
| **TOTAL** | **~310** | (+ Many archive/history versions) |

---

## 🎯 PRACTICAL USAGE EXAMPLES

### **Example 1: Trace an Order from Receipt to Delivery**

```
1. Order arrives → ASN_HDR (scan barcode)
2. Items checked → AUDIT_ITEM (QC pass/fail)
3. Items stored → CELLS (bin location)
4. Pick order → DEL_LOC_ASG (assign location)
5. Group delivery → AREA, CELLS (sort by zone)
6. Load truck → BILLING_WS_HDR (assign order)
7. Deliver → BILLING_WS_DETAIL (items shipped)
8. Bill → BILLING_EXP_HDR (export to accounting)
9. Return check → CHECK_INFO (payment record)
```

### **Example 2: Find Return Authorization Issue**

```
1. Customer returns items → AR_ORIG
2. Check pricing → CLIENT_COST / COST_NEW
3. Verify damage → DAMAGE_CODE
4. Calculate refund → COST_DISC_PCT
5. Correction → AR_CORRECT
6. Pay → CHECK_INFO
7. Audit log → CLIENT_LOG
```

### **Example 3: Product Cost Analysis**

```
1. Get product → DRUG_MASTER (find NDC)
2. Get customer cost → CLIENT_COST (by gpo_cd + drug_no)
3. Check hierarchy → COST_PARENT (base cost)
4. Apply discount → COST_DISC_PCT
5. Final price → COST_NEW (current rate)
6. Audit change → COST_NEW_LOG
```

---

## 📝 LEGEND

- **✓** = Primary/Key column
- **→** = Foreign Key relationship
- **|** = Physical connection
- **┌┐└┘** = Table grouping
- **\*** = Multiple versions exist

---

**Last Updated:** 2024  
**Total Tables Documented:** 680+  
**Relationship Mappings:** 100+  
**Process Flows:** 8 Major + 12 Sub-categories
