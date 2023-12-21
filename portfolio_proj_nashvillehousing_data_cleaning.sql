use portfolio_proj;
select * from nashvillehousing;

-- standardize date format
update nashvillehousing
set saledate=STR_TO_DATE(saledate, '%M %e, %Y');                           

-- populate property address data
select * from nashvillehousing where propertyaddress is null;               -- properptyaddress null check

select  a.parcelId,a.propertyaddress,b.parcelId,b.propertyaddress,ifnull(a.propertyaddress,b.propertyaddress) as replacedpropertyaddress
from nashvillehousing a
join nashvillehousing b                                                     -- isnull can be used also
on a.parcelId=b.parcelId
and a.ï»¿UniqueID<>b.ï»¿UniqueID                                            -- self join to replace null values with same parcelId address
where a.propertyaddress is null;

UPDATE nashvillehousing a
JOIN nashvillehousing b
ON a.parcelId = b.parcelId                                                 -- update replaced address
AND a.`ï»¿UniqueID` <> b.`ï»¿UniqueID`
SET a.propertyaddress = IFNULL(a.propertyaddress, b.propertyaddress)
WHERE a.propertyaddress IS NULL;

-- breaking out address into individual columns
select propertyaddress from nashvillehousing;
select substr(propertyaddress,1,locate(',',propertyaddress)-1) as address                                         -- instead of locate charindex can also be used
,substr(propertyaddress,locate(',',propertyaddress)+1,length(propertyaddress)) as address from nashvillehousing ;

alter table nashvillehousing
add propertysplitaddress nvarchar(255);
update nashvillehousing
set propertysplitaddress=substr(propertyaddress,1,locate(',',propertyaddress)-1);

alter table nashvillehousing
add propertysplitcity nvarchar(255);
update nashvillehousing
set propertysplitcity=substr(propertyaddress,locate(',',propertyaddress)+1,length(propertyaddress));

select propertysplitaddress,propertysplitcity from nashvillehousing;

select substring(owneraddress,1,locate(',',owneraddress)-1) as first_part from nashvillehousing;
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1) AS middle_part
FROM nashvillehousing;
SELECT SUBSTRING_INDEX(owneraddress, ',', -1) AS last_part
FROM nashvillehousing;

alter table nashvillehousing
add ownersplitaddress nvarchar(255),
add ownersplitcity nvarchar(255),
add ownersplitstate nvarchar(255);

update nashvillehousing
set ownersplitaddress=substring(owneraddress,1,locate(',',owneraddress)-1);
update nashvillehousing
set ownersplitcity=substring_index(substring_index(owneraddress,',',2),',',-1);
update nashvillehousing
set ownersplitstate=SUBSTRING_INDEX(owneraddress, ',', -1);

-- change Y and N to yes and no in 'sold as vacant' field using case stmts
select soldasvacant,
case when soldasvacant ='Y' then 'Yes'
	 when soldasvacant ='N' then 'No'
     else soldasvacant
end
from nashvillehousing;

update nashvillehousing
set soldasvacant = case when soldasvacant ='Y' then 'Yes'
	 when soldasvacant ='N' then 'No'
     else soldasvacant
end;

select distinct(soldasvacant) from nashvillehousing;

-- remove duplicates
with cte as(
select *,row_number()
over (partition by
				parcelId,
                PropertyAddress,
                SaleDate,
                SalePrice,
                LegalReference
                order by parcelId ) as rownumber
from nashvillehousing
)

delete from cte where rownumber>1;

-- delete unused column
ALTER TABLE nashvillehousing
DROP COLUMN ownersaddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress,
DROP COLUMN saledate;










