@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Carrier Interface View'
@Search.searchable: true
define view entity ZI_Carrier
  as select from zflight_carrier as Carrier
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['Name']
  key carrier_id      as CarrierID,

      @Search.defaultSearchElement: true
      @Semantics.text: true
      name            as Name,

      currency_code   as CurrencyCode,
      created_by      as CreatedBy,
      created_at      as CreatedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt
}
