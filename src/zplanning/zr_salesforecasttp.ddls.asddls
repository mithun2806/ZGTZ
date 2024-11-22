@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forSalesForecast'
define root view entity ZR_SalesForecastTP
  as select from ZSALESFORECAST as SalesForecast
{
  key BUKRS as Bukrs,
  key PLANT as Plant,
  key FORECASTMONTH as Forecastmonth,
  key PRODUCTCODE as Productcode,
  PRODUCTDESC as Productdesc,
  QUANTITYUNIT as Quantityunit,
  FORECASTDATE as Forecastdate,
  FORECASTQTY as Forecastqty,
  @Semantics.user.createdBy: true
  CREATED_BY as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  CREATED_AT as CreatedAt,
  LAST_CHANGED_BY as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt
  
}
