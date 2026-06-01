@EndUserText.label : 'Flight RAP Carrier'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zflight_carrier {
  key client      : abap.clnt not null;
  key carrier_id  : abap.char(3) not null;
  name            : abap.char(80);
  currency_code   : abap.cuky;
  created_by      : abap.char(12);
  created_at      : abap.utclong;
  last_changed_by : abap.char(12);
  last_changed_at : abap.utclong;
}
