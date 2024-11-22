@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forSalesForecast'
define root view entity ZI_SalesForecastTP
  provider contract TRANSACTIONAL_INTERFACE
  as projection on ZR_SalesForecastTP as SalesForecast
{
  key Bukrs,
  key Plant,
  key Forecastmonth,
  key Productcode,
  Productdesc,
  Quantityunit,
  Forecastdate,
  Forecastqty,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
