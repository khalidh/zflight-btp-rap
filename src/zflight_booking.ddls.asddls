@EndUserText.label : 'Flight RAP Booking'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zflight_booking {
  key client      : abap.clnt not null;
  key travel_id   : abap.numc(8) not null;
  key booking_id  : abap.numc(4) not null;
  booking_date    : abap.dats;
  customer_id     : abap.numc(6);
  carrier_id      : abap.char(3);
  connection_id   : abap.numc(4);
  flight_date     : abap.dats;
  flight_price    : abap.curr(15,2);
  currency_code   : abap.cuky;
  booking_status  : abap.char(1);
  last_changed_at : abap.utclong;
}
