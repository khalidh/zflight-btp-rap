@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Interface View'
define view entity ZI_Booking
  as select from zflight_booking as Booking
  association to parent ZI_Travel as _Travel
    on $projection.TravelID = _Travel.TravelID
  composition [0..*] of ZI_BookingSupplement as _BookingSupplement
  association [1..1] to ZI_Customer as _Customer
    on $projection.CustomerID = _Customer.CustomerID
  association [1..1] to ZI_Carrier as _Carrier
    on $projection.CarrierID = _Carrier.CarrierID
  association [1..1] to ZI_Connection as _Connection
    on  $projection.CarrierID    = _Connection.CarrierID
    and $projection.ConnectionID = _Connection.ConnectionID
  association [1..1] to ZI_Flight as _Flight
    on  $projection.CarrierID    = _Flight.CarrierID
    and $projection.ConnectionID = _Flight.ConnectionID
    and $projection.FlightDate   = _Flight.FlightDate
  association [0..1] to ZI_BookingStatusVH as _BookingStatus
    on $projection.BookingStatus = _BookingStatus.BookingStatus
{
  key travel_id      as TravelID,
  key booking_id     as BookingID,

      booking_date   as BookingDate,
      customer_id    as CustomerID,
      carrier_id     as CarrierID,
      connection_id  as ConnectionID,
      flight_date    as FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price   as FlightPrice,

      currency_code  as CurrencyCode,
      booking_status as BookingStatus,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,

      _Travel,
      _BookingSupplement,
      _Customer,
      _Carrier,
      _Connection,
      _Flight,
      _BookingStatus
}
