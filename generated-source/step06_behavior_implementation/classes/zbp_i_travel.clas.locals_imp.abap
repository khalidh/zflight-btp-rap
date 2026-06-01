CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS validateagency FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateagency.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.
    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedates.
    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatestatus.
    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecurrencycode.
    METHODS validatebookingfee FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatebookingfee.

    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calculatetotalprice.
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.

    METHODS setstatusbooked FOR MODIFY
      IMPORTING keys FOR ACTION travel~setstatusbooked RESULT result.
    METHODS setstatuscancelled FOR MODIFY
      IMPORTING keys FOR ACTION travel~setstatuscancelled RESULT result.
    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~copytravel.
ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.
  METHOD validateagency.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        FIELDS ( AgencyID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-AgencyID IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(
          %tky = travel-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Agency is required.' )
          %element-AgencyID = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatecustomer.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        FIELDS ( CustomerID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    DATA customer_ids TYPE SORTED TABLE OF zflight_customer-customer_id WITH UNIQUE KEY table_line.
    customer_ids = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING table_line = CustomerID ).
    DELETE customer_ids WHERE table_line IS INITIAL.

    IF customer_ids IS NOT INITIAL.
      SELECT customer_id
        FROM zflight_customer
        FOR ALL ENTRIES IN @customer_ids
        WHERE customer_id = @customer_ids-table_line
        INTO TABLE @DATA(customers_db).
    ENDIF.

    LOOP AT travels INTO DATA(travel).
      IF travel-CustomerID IS INITIAL
         OR NOT line_exists( customers_db[ customer_id = travel-CustomerID ] ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(
          %tky = travel-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Customer does not exist.' )
          %element-CustomerID = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedates.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        FIELDS ( BeginDate EndDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF zcl_flight_rules=>are_dates_valid(
           begin_date = travel-BeginDate
           end_date   = travel-EndDate ) = abap_false.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(
          %tky = travel-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Travel dates are invalid.' )
          %element-BeginDate = if_abap_behv=>mk-on
          %element-EndDate   = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatestatus.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        FIELDS ( OverallStatus )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF zcl_flight_rules=>is_travel_status_valid( travel-OverallStatus ) = abap_false.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(
          %tky = travel-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Travel status is invalid.' )
          %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatecurrencycode.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        FIELDS ( CurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-CurrencyCode IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(
          %tky = travel-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Currency is required.' )
          %element-CurrencyCode = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatebookingfee.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        FIELDS ( BookingFee )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-BookingFee < 0.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(
          %tky = travel-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Booking fee must not be negative.' )
          %element-BookingFee = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculatetotalprice.
    recalctotalprice( keys = CORRESPONDING #( keys ) ).
  ENDMETHOD.

  METHOD recalctotalprice.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        FIELDS ( TravelID BookingFee CurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel BY \_Booking
        FIELDS ( TravelID FlightPrice CurrencyCode )
        WITH CORRESPONDING #( travels )
      RESULT DATA(bookings).

    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY booking BY \_BookingSupplement
        FIELDS ( TravelID Price CurrencyCode )
        WITH CORRESPONDING #( bookings )
      RESULT DATA(supplements).

    DATA updates TYPE TABLE FOR UPDATE zi_travel.

    LOOP AT travels INTO DATA(travel).
      DATA booking_amounts TYPE zcl_flight_pricing=>booking_amounts.
      DATA supplement_amounts TYPE zcl_flight_pricing=>booking_amounts.

      LOOP AT bookings INTO DATA(booking) WHERE TravelID = travel-TravelID.
        APPEND VALUE #(
          amount        = booking-FlightPrice
          currency_code = booking-CurrencyCode ) TO booking_amounts.
      ENDLOOP.

      LOOP AT supplements INTO DATA(supplement) WHERE TravelID = travel-TravelID.
        APPEND VALUE #(
          amount        = supplement-Price
          currency_code = supplement-CurrencyCode ) TO supplement_amounts.
      ENDLOOP.

      APPEND VALUE #(
        %tky       = travel-%tky
        TotalPrice = zcl_flight_pricing=>calculate_total(
                       booking_fee   = travel-BookingFee
                       currency_code = travel-CurrencyCode
                       bookings      = booking_amounts
                       supplements   = supplement_amounts ) ) TO updates.
    ENDLOOP.

    IF updates IS NOT INITIAL.
      MODIFY ENTITIES OF zi_travel IN LOCAL MODE
        ENTITY travel
          UPDATE FIELDS ( TotalPrice )
          WITH updates
        REPORTED DATA(update_reported).
      reported = CORRESPONDING #( DEEP update_reported ).
    ENDIF.
  ENDMETHOD.

  METHOD setstatusbooked.
    MODIFY ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys
          ( %tky = key-%tky OverallStatus = zcl_flight_rules=>travel_status-booked ) )
      REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky %param = travel ) ).
  ENDMETHOD.

  METHOD setstatuscancelled.
    MODIFY ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR key IN keys
          ( %tky = key-%tky OverallStatus = zcl_flight_rules=>travel_status-cancelled ) )
      REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky %param = travel ) ).
  ENDMETHOD.

  METHOD copytravel.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    DATA create_travels TYPE TABLE FOR CREATE zi_travel.

    LOOP AT keys INTO DATA(key).
      READ TABLE travels ASSIGNING FIELD-SYMBOL(<travel>) WITH KEY %tky = key-%tky.
      IF sy-subrc = 0.
        APPEND VALUE #(
          %cid          = key-%cid
          AgencyID      = <travel>-AgencyID
          CustomerID    = <travel>-CustomerID
          BeginDate     = cl_abap_context_info=>get_system_date( )
          EndDate       = cl_abap_context_info=>get_system_date( ) + 30
          BookingFee    = <travel>-BookingFee
          CurrencyCode  = <travel>-CurrencyCode
          Description   = <travel>-Description
          OverallStatus = zcl_flight_rules=>travel_status-new ) TO create_travels.
      ENDIF.
    ENDLOOP.

    IF create_travels IS NOT INITIAL.
      MODIFY ENTITIES OF zi_travel IN LOCAL MODE
        ENTITY travel
          CREATE FIELDS ( AgencyID CustomerID BeginDate EndDate BookingFee CurrencyCode Description OverallStatus )
          WITH create_travels
        MAPPED mapped
        FAILED failed
        REPORTED reported.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
