CLASS ZCL_GET_DATE_HTTP_000 DEFINITION
  PUBLIC
  CREATE PUBLIC.

PUBLIC SECTION.
  INTERFACES IF_HTTP_SERVICE_EXTENSION.
  METHODS: get_html RETURNING VALUE(ui_html) TYPE string
           RAISING cx_abap_context_info_error.

PROTECTED SECTION.

PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_GET_DATE_HTTP_000 IMPLEMENTATION.


  METHOD get_html.
    DATA(user_formatted_name) = cl_abap_context_info=>get_user_formatted_name( ).
    DATA(system_date) = cl_abap_context_info=>get_system_date( ).
    DATA: formatted_date TYPE string.


    DATA:lv_year   TYPE c LENGTH 4.
    DATA:lv_month TYPE c LENGTH 2.
    DATA:lv_day   TYPE c LENGTH 2.

    lv_year = system_date+0(4).
    lv_month = system_date+4(2).
    lv_day = system_date+6(2).


    formatted_date = |{ lv_year }/{ lv_month }/{ lv_day }|.

    ui_html =  |<html> \n| &&
               |<body> \n| &&
               |<title>General Information</title> \n| &&
               |<p style="color:DodgerBlue;"> Hello there, { user_formatted_name } </p> \n| &&
               |<p> Today, the date is: { formatted_date } </p> \n| &&
               |</body> \n| &&
               |</html> |.
  ENDMETHOD.


  METHOD IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.
    TRY.
      response->set_text( get_html( ) ).
    CATCH cx_web_message_error cx_abap_context_info_error.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
