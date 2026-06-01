CLASS zcl_flight_rules DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF travel_status,
        new       TYPE c LENGTH 1 VALUE 'N',
        planned   TYPE c LENGTH 1 VALUE 'P',
        booked    TYPE c LENGTH 1 VALUE 'B',
        cancelled TYPE c LENGTH 1 VALUE 'X',
      END OF travel_status,
      BEGIN OF booking_status,
        new       TYPE c LENGTH 1 VALUE 'N',
        booked    TYPE c LENGTH 1 VALUE 'B',
        cancelled TYPE c LENGTH 1 VALUE 'X',
      END OF booking_status.

    CLASS-METHODS is_travel_status_valid
      IMPORTING status        TYPE c
      RETURNING VALUE(result) TYPE abap_bool.

    CLASS-METHODS is_booking_status_valid
      IMPORTING status        TYPE c
      RETURNING VALUE(result) TYPE abap_bool.

    CLASS-METHODS are_dates_valid
      IMPORTING begin_date    TYPE d
                end_date      TYPE d
      RETURNING VALUE(result) TYPE abap_bool.

    CLASS-METHODS is_amount_valid
      IMPORTING amount        TYPE p
      RETURNING VALUE(result) TYPE abap_bool.
ENDCLASS.

CLASS zcl_flight_rules IMPLEMENTATION.
  METHOD is_travel_status_valid.
    result = xsdbool( status = travel_status-new
                   OR status = travel_status-planned
                   OR status = travel_status-booked
                   OR status = travel_status-cancelled ).
  ENDMETHOD.

  METHOD is_booking_status_valid.
    result = xsdbool( status = booking_status-new
                   OR status = booking_status-booked
                   OR status = booking_status-cancelled ).
  ENDMETHOD.

  METHOD are_dates_valid.
    result = xsdbool( begin_date IS NOT INITIAL
                  AND end_date   IS NOT INITIAL
                  AND end_date   >= begin_date ).
  ENDMETHOD.

  METHOD is_amount_valid.
    result = xsdbool( amount >= 0 ).
  ENDMETHOD.
ENDCLASS.
