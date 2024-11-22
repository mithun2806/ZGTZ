@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Plant Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_ProductPlant_VH as
  select from I_ProductPlantBasic as pb
  join I_ProductDescription as pd on pb.Product = pd.Product and pd.LanguageISOCode = 'EN'
  join I_UnitOfMeasure as uom on pb.BaseUnit = uom.UnitOfMeasure
{
  key pb.Product,
  pd.ProductDescription,
  uom.UnitOfMeasure_E,
  pb.Plant,
  ltrim(pb.Product,'0') as ProductAlias
  
}
