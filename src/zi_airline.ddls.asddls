@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Airline Interface View'
@Search.searchable: true
define view entity ZI_Airline
  as select from zflight_carrier as Airline
  association [0..*] to ZI_Flight as _Flight
    on $projection.AirlineID = _Flight.CarrierID
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['Name']
  key carrier_id      as AirlineID,

      @Search.defaultSearchElement: true
      @Semantics.text: true
      name            as Name,

      currency_code   as CurrencyCode,
      created_by      as CreatedBy,
      created_at      as CreatedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt,

      _Flight
}
