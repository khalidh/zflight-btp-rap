@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Interface View'
@Search.searchable: true
define view entity ZI_Flight
  as select from zflight_flight as Flight
  association [1..1] to ZI_Carrier as _Carrier
    on $projection.CarrierID = _Carrier.CarrierID
  association [1..1] to ZI_Connection as _Connection
    on  $projection.CarrierID    = _Connection.CarrierID
    and $projection.ConnectionID = _Connection.ConnectionID
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.association: '_Carrier'
  key carrier_id     as CarrierID,

      @Search.defaultSearchElement: true
  key connection_id  as ConnectionID,

      @Search.defaultSearchElement: true
  key flight_date    as FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      price          as Price,

      currency_code  as CurrencyCode,
      plane_type_id  as PlaneTypeID,
      seats_max      as MaximumSeats,
      seats_occupied as OccupiedSeats,

      _Carrier,
      _Connection
}
