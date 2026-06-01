@EndUserText.label : 'Flight RAP Flight'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zflight_flight {
  key client       : abap.clnt not null;
  key carrier_id   : abap.char(3) not null;
  key connection_id: abap.numc(4) not null;
  key flight_date  : abap.dats not null;
  price            : abap.curr(15,2);
  currency_code    : abap.cuky;
  plane_type_id    : abap.char(10);
  seats_max        : abap.int4;
  seats_occupied   : abap.int4;
}
