@EndUserText.label : 'Flight RAP Connection'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zflight_conn {
  key client       : abap.clnt not null;
  key carrier_id   : abap.char(3) not null;
  key connection_id: abap.numc(4) not null;
  airport_from_id  : abap.char(3);
  airport_to_id    : abap.char(3);
  departure_time   : abap.tims;
  arrival_time     : abap.tims;
  distance         : abap.dec(9,2);
  distance_unit    : abap.unit(3);
}
