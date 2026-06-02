@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Booking Supplement Interface View'
define view entity ZI_Flight_Book_Suppl
  as select from zflight_bksuppl as BookingSupplement
  association to parent ZI_Flight_Booking as _Booking
    on  $projection.TravelID  = _Booking.TravelID
    and $projection.BookingID = _Booking.BookingID
  association [1..1] to ZI_Flight_Travel as _Travel
    on $projection.TravelID = _Travel.TravelID
  association [0..1] to ZI_Supplement as _Supplement
    on $projection.SupplementID = _Supplement.SupplementID
{
  key travel_id             as TravelID,
  key booking_id            as BookingID,
  key booking_supplement_id as BookingSupplementID,

      supplement_id         as SupplementID,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,

      currency_code         as CurrencyCode,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Booking,
      _Travel,
      _Supplement
}
