@EndUserText.label : 'Flight RAP Travel'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zflight_travel {
  key client      : abap.clnt not null;
  key travel_id   : abap.numc(8) not null;
  agency_id       : abap.numc(6);
  customer_id     : abap.numc(6);
  begin_date      : abap.dats;
  end_date        : abap.dats;
  booking_fee     : abap.curr(15,2);
  total_price     : abap.curr(15,2);
  currency_code   : abap.cuky;
  description     : abap.char(1024);
  overall_status  : abap.char(1);
  created_by      : abap.char(12);
  created_at      : abap.utclong;
  last_changed_by : abap.char(12);
  last_changed_at : abap.utclong;
}
