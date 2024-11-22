CLASS LHC_SALESFORECAST DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR SalesForecast
        RESULT result,
      updateValues FOR DETERMINE ON SAVE
            IMPORTING keys FOR SalesForecast~updateValues.
ENDCLASS.

CLASS LHC_SALESFORECAST IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD updateValues.
    DATA productname TYPE char72.
    DATA uom TYPE char05.
    DATA forecastmonthval TYPE datum.
    DATA dateval TYPE char03.

    READ ENTITIES OF ZR_SalesForecastTP IN LOCAL MODE
      ENTITY SalesForecast
      FIELDS ( Productcode Plant Forecastdate Forecastmonth )
      WITH CORRESPONDING #( keys )
      RESULT DATA(entrylines).

    LOOP AT entrylines INTO DATA(entryline).
      productname = ''.
      uom = ''.
      forecastmonthval = '00000000'.
      dateval = entryline-Forecastmonth+6(2).
      IF dateval NE '01'.
*        APPEND VALUE #( %tky = entryline-%tky ) TO failed-.
        APPEND VALUE #( %tky = entryline-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Day must be 01 of month.' )
                      ) TO reported-salesforecast.
        RETURN.
      ENDIF.

*      IF entryline-Productcode NE '' AND entryline-Plant NE ''.

        SELECT from ZR_ProductPlant_VH
          FIELDS Product, ProductDescription, UnitOfMeasure_E, ProductAlias
          WHERE ( Product = @entryline-Productcode OR ProductAlias = @entryline-Productcode )
            and Plant = @entryline-Plant
          INTO TABLE @DATA(ltproduct).

        IF ltproduct IS INITIAL.
          APPEND VALUE #( %tky = entryline-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Product is not maintained at Plant.' )
                      ) TO reported-salesforecast.
          RETURN.

        ENDIF.

        LOOP AT ltproduct INTO DATA(waproduct).
          productname = waproduct-ProductDescription.
          uom = waproduct-UnitOfMeasure_E.
        ENDLOOP.

*      ENDIF.


      MODIFY ENTITIES OF ZR_SalesForecastTP IN LOCAL MODE
        ENTITY SalesForecast
        UPDATE
        FIELDS ( Productdesc Quantityunit ) WITH VALUE #( ( %tky = entryline-%tky
                                                          Productdesc = productname
                                                          Quantityunit = uom ) ).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
