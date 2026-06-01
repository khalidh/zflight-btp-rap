CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS validatebookingdate FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatebookingdate.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatecustomer.
    METHODS validateflight FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validateflight.
    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatestatus.
    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR booking~validatecurrencycode.

    METHODS determineflightprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~determineflightprice.
    METHODS requesttraveltotalrecalc FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~requesttraveltotalrecalc.
ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.
  METHOD validatebookingdate.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY booking
        FIELDS ( BookingDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings INTO DATA(booking).
      IF booking-BookingDate IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #(
          %tky = booking-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Booking date is required.' )
          %element-BookingDate = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatecustomer.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY booking
        FIELDS ( CustomerID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    DATA customer_ids TYPE SORTED TABLE OF zflight_customer-customer_id WITH UNIQUE KEY table_line.
    customer_ids = CORRESPONDING #( bookings DISCARDING DUPLICATES MAPPING table_line = CustomerID ).
    DELETE customer_ids WHERE table_line IS INITIAL.

    IF customer_ids IS NOT INITIAL.
      SELECT customer_id
        FROM zflight_customer
        FOR ALL ENTRIES IN @customer_ids
        WHERE customer_id = @customer_ids-table_line
        INTO TABLE @DATA(customers_db).
    ENDIF.

    LOOP AT bookings INTO DATA(booking).
      IF booking-CustomerID IS INITIAL
         OR NOT line_exists( customers_db[ customer_id = booking-CustomerID ] ).
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #(
          %tky = booking-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Booking customer does not exist.' )
          %element-CustomerID = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateflight.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY booking
        FIELDS ( CarrierID ConnectionID FlightDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings INTO DATA(booking).
      SELECT SINGLE carrier_id
        FROM zflight_flight
        WHERE carrier_id    = @booking-CarrierID
          AND connection_id = @booking-ConnectionID
          AND flight_date   = @booking-FlightDate
        INTO @DATA(flight_id).

      IF booking-CarrierID IS INITIAL
         OR booking-ConnectionID IS INITIAL
         OR booking-FlightDate IS INITIAL
         OR flight_id IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #(
          %tky = booking-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Flight does not exist.' )
          %element-CarrierID    = if_abap_behv=>mk-on
          %element-ConnectionID = if_abap_behv=>mk-on
          %element-FlightDate   = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
      CLEAR flight_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatestatus.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY booking
        FIELDS ( BookingStatus )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings INTO DATA(booking).
      IF zcl_flight_rules=>is_booking_status_valid( booking-BookingStatus ) = abap_false.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #(
          %tky = booking-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Booking status is invalid.' )
          %element-BookingStatus = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatecurrencycode.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY booking
        FIELDS ( CurrencyCode )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    LOOP AT bookings INTO DATA(booking).
      IF booking-CurrencyCode IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-booking.
        APPEND VALUE #(
          %tky = booking-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Booking currency is required.' )
          %element-CurrencyCode = if_abap_behv=>mk-on ) TO reported-booking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD determineflightprice.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY booking
        FIELDS ( CarrierID ConnectionID FlightDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    DATA updates TYPE TABLE FOR UPDATE zi_travel\\booking.

    LOOP AT bookings INTO DATA(booking).
      SELECT SINGLE price, currency_code
        FROM zflight_flight
        WHERE carrier_id    = @booking-CarrierID
          AND connection_id = @booking-ConnectionID
          AND flight_date   = @booking-FlightDate
        INTO @DATA(flight).

      IF sy-subrc = 0.
        APPEND VALUE #(
          %tky         = booking-%tky
          FlightPrice  = flight-price
          CurrencyCode = flight-currency_code ) TO updates.
      ENDIF.
    ENDLOOP.

    IF updates IS NOT INITIAL.
      MODIFY ENTITIES OF zi_travel IN LOCAL MODE
        ENTITY booking
          UPDATE FIELDS ( FlightPrice CurrencyCode )
          WITH updates
        REPORTED DATA(update_reported).
      reported = CORRESPONDING #( DEEP update_reported ).
    ENDIF.
  ENDMETHOD.

  METHOD requesttraveltotalrecalc.
    READ ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY booking
        FIELDS ( TravelID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).

    MODIFY ENTITIES OF zi_travel IN LOCAL MODE
      ENTITY travel
        EXECUTE ReCalcTotalPrice
        FROM VALUE #( FOR booking IN bookings ( TravelID = booking-TravelID ) )
      REPORTED DATA(action_reported).

    reported = CORRESPONDING #( DEEP action_reported ).
  ENDMETHOD.
ENDCLASS.
