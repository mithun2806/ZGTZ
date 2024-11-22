@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forPRPlanning'
define root view entity ZI_PRPlanningTP
  provider contract TRANSACTIONAL_INTERFACE
  as projection on ZR_PRPlanningTP as PRPlanning
{
  key Bukrs,
  key Plant,
  key Planningmonth,
  key Productcode,
  Productdesc,
  Quantityunit,
  Planningdate,
  Minimumqty,
  Salestrendqty,
  Forecastqty,
  Salesorderqty,
  Suggestedqty,
  Overrideqty,
  Remarks,
  Closed,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
