@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Consumption View'
@Search.searchable: true
define view entity ZC_Customer
  as projection on ZI_Customer
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['LastName']
  key CustomerID,

      CustomerUUID,

      @Search.defaultSearchElement: true
      @Semantics.name.givenName: true
      FirstName,

      @Search.defaultSearchElement: true
      @Semantics.name.familyName: true
      @Semantics.text: true
      LastName,
      CustomerName,
      CustomerType,

      @Semantics.name.prefix: true
      Title,

      @Semantics.address.street: true
      Street,

      @Semantics.address.zipCode: true
      PostalCode,

      @Search.defaultSearchElement: true
      @Semantics.address.city: true
      City,

      @Semantics.address.country: true
      CountryCode,

      @Semantics.telephone.type: [#HOME]
      PhoneNumber,

      @Semantics.eMail.address: true
      EMailAddress,
      EMail,

      @Semantics.amount.currencyCode: 'CreditLimitCurrency'
      CreditLimit,
      CreditLimitCurrency,
      CurrencyCode,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      ChangedBy,
      ChangedAt
}
