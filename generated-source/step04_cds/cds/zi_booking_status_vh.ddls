@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Status Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_BookingStatusVH
  as select from zflight_book_stat as BookingStatus
{
      @ObjectModel.text.element: ['StatusText']
  key booking_status as BookingStatus,

      @Semantics.text: true
      status_text    as StatusText
}
