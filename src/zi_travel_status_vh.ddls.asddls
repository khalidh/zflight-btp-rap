@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Status Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_TravelStatusVH
  as select from zflight_trvl_stat as TravelStatus
{
      @ObjectModel.text.element: ['StatusText']
  key travel_status as TravelStatus,

      @Semantics.text: true
      status_text   as StatusText
}
