--Data cleaning
select * 
from Portfolio.dbo.Nashville

--Data format normalization

select SaleDate 
from Portfolio.dbo.Nashville

select convert(Date, SaleDate)
from Portfolio.dbo.Nashville

alter table Portfolio.dbo.Nashville
add Datesold date;

update Portfolio.dbo.Nashville
set Datesold = convert(date,SaleDate)

select Datesold 
from Portfolio.dbo.Nashville

--Querying Property address data which is null

select ParcelID,PropertyAddress
from Portfolio.dbo.Nashville
where PropertyAddress is null
order by ParcelID;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, 
isnull(a.PropertyAddress,b.PropertyAddress) 
from Portfolio.dbo.Nashville a
join Portfolio.dbo.Nashville b
on a.ParcelID =b.ParcelID
where a.PropertyAddress is null and b.PropertyAddress is not null;

--lets try doing the above update to our existing table

update a
set  PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Portfolio.dbo.Nashville a
join Portfolio.dbo.Nashville b
on a.ParcelID =b.ParcelID
where a.PropertyAddress is null and b.PropertyAddress is not null;

--Segregating property address

select PropertyAddress, substring(PropertyAddress,1,4)
from Portfolio.dbo.Nashville

select PropertyAddress, substring(PropertyAddress,1,4), 
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) +1) as a
from Portfolio.dbo.Nashville

--updating our table

alter table Portfolio.dbo.Nashville
add propaddress nvarchar(100)


update Portfolio.dbo.Nashville
set propaddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) 

--adding "-1" above to eradicate the ',' 

alter table Portfolio.dbo.Nashville
add propcity char(50)

update Portfolio.dbo.Nashville
set propcity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress) +1
,len(PropertyAddress))

--adding "+1" as we need characters which comes after the ',' character.

select * 
from Portfolio.dbo.Nashville

--Viewing owner address which is null

select a.PropertyAddress,b.OwnerAddress
ISNULL(b.OwnerAddress,a.PropertyAddress) as owner_add
from Portfolio.dbo.Nashville a
join Portfolio.dbo.Nashville b
on a.ParcelID = b.ParcelID
where b.OwnerAddress is null and a.PropertyAddress

alter table Portfolio.dbo.Nashville
add owner_add nvarchar(100)

update a
set owner_add = ISNULL(b.OwnerAddress,a.PropertyAddress)
from Portfolio.dbo.Nashville a
join Portfolio.dbo.Nashville b
on a.ParcelID = b.ParcelID
where b.OwnerAddress is null and a.PropertyAddress is not null

--segregating city from owneraddress


select OwnerAddress, PARSENAME(replace(OwnerAddress,',','.'), 1) as OwnerCity
from 
Portfolio.dbo.Nashville

alter table Portfolio.dbo.Nashville
add ownercity char(20)

update Portfolio.dbo.Nashville
set ownercity = PARSENAME(replace(OwnerAddress,',','.'), 1)

--'Sold as vacant' has same values but disapled in mutiple terms

select distinct(SoldAsVacant),count(SoldAsVacant) as c
from Portfolio.dbo.Nashville
group by SoldAsVacant

select SoldAsVacant,
   case
   when SoldAsVacant = 'Y' then 'Yes'
   when SoldAsVacant = 'N' then 'No'
   else SoldAsVacant
   end
   from Portfolio.dbo.Nashville

update Portfolio.dbo.Nashville
set SoldAsVacant = case
   when SoldAsVacant = 'Y' then 'Yes'
   when SoldAsVacant = 'N' then 'No'
   else SoldAsVacant
   end
   
--Deleting unused columns

Alter table Portfolio.dbo.Nashville
drop column OwnerAddress, TaxDistrict,PropertyAddress,SaleDate

select * 
from Portfolio.dbo.Nashville