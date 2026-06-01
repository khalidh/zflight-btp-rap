CLASS lhc_bookingsupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS validatesupplement FOR VALIDATE ON SAVE
      IMPORTING keys FOR bookingsupplement~validatesupplement.
    METHODS validateprice FOR VALIDATE ON SAVE
      IMPORTING keys FOR bookingsupplement~validateprice.
    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR bookingsupplement~validatecurrencycode.

    METHODS determinesupplementprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR bookingsupplement~determinesupplementprice.
    METHODS requesttraveltotalrecalc FOR DETERMINE ON MODIFY
      IMPORTING keys FOR bookingsupplement~requesttraveltotalrecalc.
ENDCLASS.

CLASS lhc_bookingsupplement IMPLEMENTATION.
  METHOD validatesupplement.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY bookingsupplement
        FIELDS ( SupplementID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(supplements).

    LOOP AT supplements INTO DATA(supplement).
      SELECT SINGLE supplement_id
        FROM zflight_supplement
        WHERE supplement_id = @supplement-SupplementID
        INTO @DATA(supplement_id).

      IF supplement-SupplementID IS INITIAL OR supplement_id IS INITIAL.
        APPEND VALUE #( %tky = supplement-%tky ) TO failed-bookingsupplement.
        APPEND VALUE #(
          %tky = supplement-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Supplement does not exist.' )
          %element-SupplementID = if_abap_behv=>mk-on ) TO reported-bookingsupplement.
      ENDIF.
      CLEAR supplement_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateprice.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY bookingsupplement
        FIELDS ( Price )
        WITH CORRESPONDING #( keys )
      RESULT DATA(supplements).

    LOOP AT supplements INTO DATA(supplement).
      IF supplement-Price < 0.
        APPEND VALUE #( %tky = supplement-%tky ) TO failed-bookingsupplement.
        APPEND VALUE #(
          %tky = supplement-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Supplement price must not be negative.' )
          %element-Price = if_abap_behv=>mk-on ) TO reported-bookingsupplement.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatecurrencycode.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY bookingsupplement
        FIELDS ( CurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(supplements).

    LOOP AT supplements INTO DATA(supplement).
      IF supplement-CurrencyCode IS INITIAL.
        APPEND VALUE #( %tky = supplement-%tky ) TO failed-bookingsupplement.
        APPEND VALUE #(
          %tky = supplement-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Supplement currency is required.' )
          %element-CurrencyCode = if_abap_behv=>mk-on ) TO reported-bookingsupplement.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD determinesupplementprice.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY bookingsupplement
        FIELDS ( SupplementID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(supplements).

    DATA updates TYPE TABLE FOR UPDATE zi_travel\\bookingsupplement.

    LOOP AT supplements INTO DATA(supplement).
      SELECT SINGLE price, currency_code
        FROM zflight_supplement
        WHERE supplement_id = @supplement-SupplementID
        INTO @DATA(master_supplement).

      IF sy-subrc = 0.
        APPEND VALUE #(
          %tky         = supplement-%tky
          Price        = master_supplement-price
          CurrencyCode = master_supplement-currency_code ) TO updates.
      ENDIF.
    ENDLOOP.

    IF updates IS NOT INITIAL.
      MODIFY ENTITIES OF zi_travel IN LOCAL MODE
        ENTITY bookingsupplement
          UPDATE FIELDS ( Price CurrencyCode )
          WITH updates
        REPORTED DATA(update_reported).
      reported = CORRESPONDING #( DEEP update_reported ).
    ENDIF.
  ENDMETHOD.

  METHOD requesttraveltotalrecalc.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY bookingsupplement
        FIELDS ( TravelID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(supplements).

    MODIFY ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        EXECUTE ReCalcTotalPrice
        FROM VALUE #( FOR supplement IN supplements ( TravelID = supplement-TravelID ) )
      REPORTED DATA(action_reported).

    reported = CORRESPONDING #( DEEP action_reported ).
  ENDMETHOD.
ENDCLASS.
