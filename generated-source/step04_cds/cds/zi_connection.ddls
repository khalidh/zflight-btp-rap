@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection Interface View'
@Search.searchable: true
define view entity ZI_Connection
  as select from zflight_conn as Connection
  association [1..1] to ZI_Carrier as _Carrier
    on $projection.CarrierID = _Carrier.CarrierID
  association [0..1] to ZI_Airport as _DepartureAirport
    on $projection.DepartureAirportID = _DepartureAirport.AirportID
  association [0..1] to ZI_Airport as _ArrivalAirport
    on $projection.ArrivalAirportID = _ArrivalAirport.AirportID
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.association: '_Carrier'
  key carrier_id       as CarrierID,

      @Search.defaultSearchElement: true
  key connection_id    as ConnectionID,

      airport_from_id  as DepartureAirportID,
      airport_to_id    as ArrivalAirportID,
      departure_time   as DepartureTime,
      arrival_time     as ArrivalTime,

      @Semantics.quantity.unitOfMeasure: 'DistanceUnit'
      distance         as Distance,
      distance_unit    as DistanceUnit,

      _Carrier,
      _DepartureAirport,
      _ArrivalAirport
}
