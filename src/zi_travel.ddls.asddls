@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Interface View'
define root view entity ZI_Travel
  as select from zflight_travel as Travel
  composition [0..*] of ZI_Booking as _Booking
  association [0..1] to ZI_FlightCustomer as _Customer
    on $projection.CustomerID = _Customer.CustomerID
  association [0..1] to ZI_TravelStatusVH as _TravelStatus
    on $projection.OverallStatus = _TravelStatus.TravelStatus
{
  key travel_id       as TravelID,

      agency_id       as AgencyID,
      customer_id     as CustomerID,
      begin_date      as BeginDate,
      end_date        as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee     as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price     as TotalPrice,

      currency_code   as CurrencyCode,
      description     as Description,
      overall_status  as OverallStatus,

      @Semantics.user.createdBy: true
      created_by      as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by as LastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,

      _Booking,
      _Customer,
      _TravelStatus
}
