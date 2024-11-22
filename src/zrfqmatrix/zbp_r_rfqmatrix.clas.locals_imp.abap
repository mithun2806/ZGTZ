CLASS lhc_RFQMatrix DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR RFQMatrix RESULT result.
    METHODS createRFQData FOR MODIFY
      IMPORTING keys FOR ACTION RFQMATRIX~createRFQData RESULT result.

    METHODS markSupply FOR MODIFY
      IMPORTING keys FOR ACTION RFQMATRIX~markSupply.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR RFQMATRIX RESULT result.

    METHODS deleteRFQ FOR MODIFY
      IMPORTING keys FOR ACTION RFQMATRIX~deleteRFQ RESULT result.

ENDCLASS.

CLASS lhc_RFQMatrix IMPLEMENTATION.


  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createRFQData.

    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_rfqmatrix' ##NO_TEXT.

    DATA rfqno TYPE char13 .
    DATA create_rfqmatrix TYPE STRUCTURE FOR CREATE ZR_RFQMatrix.
    DATA create_rfqtab TYPE TABLE FOR CREATE ZR_RFQMatrix.
    DATA insertTag TYPE int1.
    DATA supplytag TYPE int1.


    LOOP AT keys INTO DATA(ls_key).

      TRY.
        rfqno = ls_key-%param-RFQNo.

        if rfqno = ''.
          APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
          APPEND VALUE #( %cid = ls_key-%cid
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'RFQ No. cannot be blank.' )
                        ) TO reported-rfqmatrix.
          RETURN.
        ENDIF.

*        CATCH .
*          APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
*          APPEND VALUE #( %cid = ls_key-%cid
*                          %msg = new_message_with_text(
*                                   severity = if_abap_behv_message=>severity-error
*                                   text     = fill_node_object_exception->get_text( ) )
*                        ) TO reported-rfqmatrix.
*          RETURN.

      ENDTRY.

      SELECT FROM zrfqmatrix
        FIELDS requestforquotation
        WHERE zrfqmatrix~requestforquotation = @rfqno
            INTO TABLE @DATA(ltcheck).
      IF ltcheck is NOT INITIAL.
        APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
          APPEND VALUE #( %cid = ls_key-%cid
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'RFQ Data already generated.' )
                        ) TO reported-rfqmatrix.
          RETURN.
      ENDIF.



      insertTag = 0.

      SELECT FROM I_Requestforquotation_Api01 as rfq
        join I_RfqBidder_Api01 AS bidder on rfq~RequestForQuotation = bidder~RequestForQuotation
        join I_RfqItem_Api01 as lines on bidder~RequestForQuotation = lines~RequestForQuotation
        join I_RfqScheduleLine_Api01 as sch on bidder~RequestForQuotation = sch~RequestForQuotation and lines~RequestForQuotationItem = sch~RequestForQuotationItem
        join I_ProductDescription as pd on lines~Material = pd~Product and pd~LanguageISOCode = 'EN'
        LEFT JOIN i_supplier AS supplier ON supplier~supplier = bidder~Supplier
        FIELDS rfq~CompanyCode, rfq~RequestForQuotation, rfq~RFQPublishingDate, bidder~Supplier, lines~RequestForQuotationItem, lines~Material,
            sch~OrderQuantityUnit, sch~ScheduleLineOrderQuantity, sch~ScheduleLine, pd~ProductDescription, supplier~SupplierFullName
        WHERE rfq~RequestForQuotation = @rfqno
           INTO TABLE @DATA(ltlines).

      LOOP AT ltlines INTO DATA(walines).
        IF walines-RFQPublishingDate = '00000000'.
          APPEND VALUE #( %cid = ls_key-%cid ) TO failed-rfqmatrix.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = 'RFQ is not published.' )
                          ) TO reported-rfqmatrix.
            RETURN.
        ENDIF.

        supplytag = 0.
        SELECT FROM I_MPPurchasingSourceItem as sourcelist
        FIELDS sourcelist~Plant
        WHERE sourcelist~Material = @walines-Material AND sourcelist~Supplier = @walines-Supplier
          and sourcelist~ValidityStartDate <= @walines-RFQPublishingDate
          and ( sourcelist~ValidityEndDate = '00000000' OR sourcelist~ValidityEndDate >= @walines-RFQPublishingDate )
        INTO TABLE @DATA(ltsource).
        IF ltsource IS NOT INITIAL.
          supplytag = 1.
        ENDIF.

        SELECT single  FROM I_Businesspartner as bp
        LEFT JOIN I_BusinessPartnerTypeText as bptt on bp~BusinessPartnerType = bptt~BusinessPartnerType and bptt~Language = 'E'
        FIELDS bp~businesspartner, bp~BusinessPartnerType, bptt~BusinessPartnerTypeDesc
        WHERE bp~BusinessPartner = @walines-Supplier
            INTO @data(bp_type).

        SELECT SINGLE from I_BuPaIdentification as bpif
        FIELDS bpif~BPIdentificationType, bpif~Region
        WHERE bpif~BusinessPartner = @walines-Supplier
            INTO @DATA(bpif_Aadhar).

        SELECT SINGLE from I_Suppliercompany as sc
        FIELDS sc~SupplierCertificationDate, sc~SupplierHeadOffice
        WHERE sc~Supplier = @walines-Supplier
            INTO @DATA(sc_SCD).


*        SELECT SINGLE FROM yy1_BusinessPartnerSuplDex as bpsd
*        FIELDS bpsd~TitleSupplier, bpsd~Supplier
*        WHERE bpsd~Supplier = @walines-Supplier
*            INTO @data(bpsd_Sup).
*


        create_rfqmatrix = VALUE #( %cid      = ls_key-%cid
                                    Bukrs = walines-CompanyCode
                                    Requestforquotation = walines-RequestForQuotation
                                    Vendorcode = walines-Supplier
                                    Productcode = walines-Material
                                    Scheduleline = walines-ScheduleLine
                                    Supplierquotationitem = walines-RequestForQuotationItem
                                    Productdesc = walines-ProductDescription
                                    Vendorname = walines-SupplierFullName
                                    Producttradename = ''
                                    Remarks = ''
                                    Orderquantity = walines-ScheduleLineOrderQuantity
                                    Orderquantityunit = walines-OrderQuantityUnit
                                    Vendortype = ''
                                    Majoractivity = bp_type-BusinessPartnerTypeDesc
                                    Typeofenterprise = ''
                                    Udyamaadharno = bpif_aadhar-BPIdentificationType
                                    Udyamcertificatedate = sc_SCD-SupplierCertificationDate
                                    Udyamcertificatereceivingdate = ''
                                    Vendorspecialname = ''
                                    Supply = supplytag
                                    Processed = 0
                                            ).
      APPEND create_rfqmatrix TO create_rfqtab.

      MODIFY ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
            ENTITY rfqmatrix
            CREATE FIELDS ( bukrs requestforquotation vendorcode productcode scheduleline supplierquotationitem
                productdesc vendorname producttradename remarks orderquantity orderquantityunit vendortype
                majoractivity typeofenterprise udyamaadharno udyamcertificatedate udyamcertificatereceivingdate
                vendorspecialname supply processed )
                  WITH create_rfqtab
            MAPPED   mapped
            FAILED   failed
            REPORTED reported.

        CLEAR : create_rfqmatrix.
        CLEAR : create_rfqtab.
      ENDLOOP.

    APPEND VALUE #( %cid = ls_key-%cid
                    %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text = 'RFQ Data Generated.' )
                      ) to reported-rfqmatrix.


    ENDLOOP.



  ENDMETHOD.

  METHOD markSupply.
    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(rfqmatrix)
      FAILED failed.

    SORT rfqmatrix BY Supply DESCENDING.
    LOOP AT rfqmatrix ASSIGNING FIELD-SYMBOL(<lfs_rfqmatrix>).
      IF <lfs_rfqmatrix>-Supply = 0.
        <lfs_rfqmatrix>-Supply = 1.
      ELSE.
        <lfs_rfqmatrix>-Supply = 0.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      UPDATE FIELDS ( Supply ) WITH CORRESPONDING #( rfqmatrix ).


    APPEND VALUE #( %tky = <lfs_rfqmatrix>-%tky
                    %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text = 'Supply Marked.' )
                      ) to reported-rfqmatrix.


  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      FIELDS ( Requestforquotation Productcode Supplierquotationitem Vendorcode Scheduleline Supply ) with CORRESPONDING #( keys )
      RESULT DATA(rfqdata)
      FAILED failed.

    result = VALUE #(
      FOR rfqline IN rfqdata
      LET statusval = COND #( WHEN rfqline-Supply = 1
                              THEN if_abap_behv=>fc-o-disabled
                              ELSE if_abap_behv=>fc-o-enabled )

                              IN ( %tky = rfqline-%tky
                                   %action-deleteRFQ = statusval )

      ).

  ENDMETHOD.

  METHOD deleteRFQ.
    DATA: it_instance_d TYPE TABLE FOR DELETE ZR_RFQMatrix.


    READ ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
      ENTITY rfqmatrix
      FIELDS ( Bukrs Requestforquotation Productcode Supplierquotationitem Vendorcode Scheduleline Supply ) with CORRESPONDING #( keys )
      RESULT DATA(rfqdata)
      FAILED failed.

    LOOP AT rfqdata INTO DATA(rfqline).
      IF rfqline-Requestforquotation <> ''.
        SELECT FROM zrfqmatrix
          FIELDS requestforquotation, supply
          WHERE requestforquotation = @rfqline-Requestforquotation AND supply = 1
          INTO TABLE @DATA(ltrfqcheck).
        IF ltrfqcheck IS NOT INITIAL.
          APPEND VALUE #( %tky = rfqline-%tky ) to failed-rfqmatrix.

          APPEND VALUE #( %tky = keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text = 'Supply is marked, cannot delete.'
                        ) ) TO reported-rfqmatrix.
          RETURN.
        ENDIF.

        SELECT FROM zrfqmatrix
          FIELDS Bukrs, Requestforquotation, Productcode, Supplierquotationitem, Vendorcode, Scheduleline
          WHERE requestforquotation = @rfqline-Requestforquotation
          INTO TABLE @DATA(ltrfqdelete).
        LOOP AT ltrfqdelete INTO DATA(walines).
          it_instance_d = value #( ( Bukrs = walines-bukrs
                                    Requestforquotation = walines-Requestforquotation
                                    Productcode = walines-Productcode
                                    Supplierquotationitem = walines-Supplierquotationitem
                                    Vendorcode = walines-Vendorcode
                                    Scheduleline = walines-Scheduleline
                                    ) ).

          MODIFY ENTITIES OF ZR_RFQMatrix IN LOCAL MODE
            ENTITY rfqmatrix
            DELETE FROM it_instance_d
            FAILED failed
            REPORTED reported.
        ENDLOOP.

        APPEND VALUE #( %tky = rfqline-%tky
                    %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text = 'RFQ Data Deleted.' )
                      ) to reported-rfqmatrix.

*        COMMIT ENTITIES
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
