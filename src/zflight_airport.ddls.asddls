@EndUserText.label : 'Flight RAP Airport'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zflight_airport {
  key client     : abap.clnt not null;
  key airport_id : abap.char(3) not null;
  name           : abap.char(80);
  city           : abap.char(40);
  country_code   : abap.char(3);
}
