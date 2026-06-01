@EndUserText.label : 'Flight RAP Customer'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zflight_customer {
  key client      : abap.clnt not null;
  key customer_id : abap.numc(6) not null;
  first_name      : abap.char(40);
  last_name       : abap.char(40);
  title           : abap.char(10);
  street          : abap.char(60);
  postal_code     : abap.char(10);
  city            : abap.char(40);
  country_code    : abap.char(3);
  phone_number    : abap.char(30);
  email_address   : abap.char(255);
  created_by      : abap.char(12);
  created_at      : abap.utclong;
  last_changed_by : abap.char(12);
  last_changed_at : abap.utclong;
}
