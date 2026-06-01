CLASS zcl_flight_pricing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF booking_amount,
        amount        TYPE p LENGTH 15 DECIMALS 2,
        currency_code TYPE c LENGTH 5,
      END OF booking_amount,
      booking_amounts TYPE STANDARD TABLE OF booking_amount WITH EMPTY KEY.

    CLASS-METHODS calculate_total
      IMPORTING booking_fee   TYPE p
                currency_code TYPE c
                bookings      TYPE booking_amounts OPTIONAL
                supplements   TYPE booking_amounts OPTIONAL
      RETURNING VALUE(total)  TYPE p LENGTH 15 DECIMALS 2.

    CLASS-METHODS calculate_flight_price
      IMPORTING occupied_seats TYPE i
                maximum_seats  TYPE i
                distance       TYPE p
      RETURNING VALUE(price)   TYPE p LENGTH 15 DECIMALS 2.
ENDCLASS.

CLASS zcl_flight_pricing IMPLEMENTATION.
  METHOD calculate_total.
    total = booking_fee.

    LOOP AT bookings INTO DATA(booking).
      IF booking-currency_code = currency_code.
        total += booking-amount.
      ENDIF.
    ENDLOOP.

    LOOP AT supplements INTO DATA(supplement).
      IF supplement-currency_code = currency_code.
        total += supplement-amount.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculate_flight_price.
    IF maximum_seats <= 0 OR distance <= 0.
      price = 0.
      RETURN.
    ENDIF.

    DATA(occupied_percent) = occupied_seats * 100 / maximum_seats.
    DATA(percent_of_max_price) = ( 3 * occupied_percent * occupied_percent / 400 ) + 25.
    price = distance * percent_of_max_price / 100.
  ENDMETHOD.
ENDCLASS.
