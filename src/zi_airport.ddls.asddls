@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Airport Interface View'
@Search.searchable: true
define view entity ZI_Airport
  as select from zflight_airport as Airport
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['Name']
  key airport_id   as AirportID,

      @Search.defaultSearchElement: true
      @Semantics.text: true
      name         as Name,

      @Search.defaultSearchElement: true
      city         as City,

      country_code as CountryCode
}
