@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplement Interface View'
@Search.searchable: true
define view entity ZI_Supplement
  as select from zflight_supplement as Supplement
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['Description']
  key supplement_id as SupplementID,

      @Search.defaultSearchElement: true
      @Semantics.text: true
      description   as Description,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      price         as Price,

      currency_code as CurrencyCode
}
