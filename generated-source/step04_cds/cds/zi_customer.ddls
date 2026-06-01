@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Interface View'
@Search.searchable: true
define view entity ZI_Customer
  as select from zflight_customer as Customer
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['LastName']
  key customer_id     as CustomerID,

      customer_id     as CustomerUUID,

      @Search.defaultSearchElement: true
      @Semantics.name.givenName: true
      first_name      as FirstName,

      @Search.defaultSearchElement: true
      @Semantics.name.familyName: true
      @Semantics.text: true
      last_name       as LastName,

      @Semantics.name.prefix: true
      title           as Title,

      @Semantics.address.street: true
      street          as Street,

      @Semantics.address.zipCode: true
      postal_code     as PostalCode,

      @Search.defaultSearchElement: true
      @Semantics.address.city: true
      city            as City,

      @Semantics.address.country: true
      country_code    as CountryCode,

      @Semantics.telephone.type: [#HOME]
      phone_number    as PhoneNumber,

      @Semantics.eMail.address: true
      email_address   as EMailAddress,

      cast( 0 as abap.curr( 15, 2 ) ) as CreditLimit,

      created_by      as CreatedBy,
      created_at      as CreatedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt,
      last_changed_by as ChangedBy,
      last_changed_at as ChangedAt
}
