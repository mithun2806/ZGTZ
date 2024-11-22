@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forPRPlanning'
define root view entity ZR_PRPlanningTP
  as select from ZPRPLANNING as PRPlanning
{
  key BUKRS as Bukrs,
  key PLANT as Plant,
  key PLANNINGMONTH as Planningmonth,
  key PRODUCTCODE as Productcode,
  PRODUCTDESC as Productdesc,
  QUANTITYUNIT as Quantityunit,
  PLANNINGDATE as Planningdate,
  MINIMUMQTY as Minimumqty,
  SALESTRENDQTY as Salestrendqty,
  FORECASTQTY as Forecastqty,
  SALESORDERQTY as Salesorderqty,
  SUGGESTEDQTY as Suggestedqty,
  OVERRIDEQTY as Overrideqty,
  REMARKS as Remarks,
  CLOSED as Closed,
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
