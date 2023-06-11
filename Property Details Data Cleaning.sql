-------------------------------------------------------------------------------------------------------
						--Data Cleaning--
-------------------------------------------------------------------------------------------------------
select * 
from ProjectPortfolio..NashvilleHousing

--Date Format Conversion

select SaleDate, CONVERT(date, SaleDate)
from ProjectPortfolio..NashvilleHousing

update ProjectPortfolio..NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update ProjectPortfolio..NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select SaleDateConverted from ProjectPortfolio..NashvilleHousing

--Filling up Null Property Address

select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from ProjectPortfolio..NashvilleHousing a
join ProjectPortfolio..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] = b.[UniqueID ]
where a.PropertyAddress is null
order by a.ParcelID

update	a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from ProjectPortfolio..NashvilleHousing a
join ProjectPortfolio..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking of Property Address into Indiviudal Columns as Address and State

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress ) -1) as Address,
substring(propertyAddress, CHARINDEX(',', PropertyAddress ) +1, LEN(PropertyAddress)) Address
from ProjectPortfolio..NashvilleHousing


alter table ProjectPortfolio..NashvilleHousing
add PropertySplitAddress nvarchar (255);

update ProjectPortfolio..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress ) -1)

alter table ProjectPortfolio..NashvilleHousing
add PropertySplitCity nvarchar (255);

update ProjectPortfolio..NashvilleHousing
set PropertySplitCity = substring(propertyAddress, CHARINDEX(',', PropertyAddress ) +1, LEN(PropertyAddress))

select propertysplitaddress, propertysplitcity
from ProjectPortfolio..NashvilleHousing

select OwnerAddress
from ProjectPortfolio..NashvilleHousing

--Breaking of Owner Address into Individual Columns As Address, City and State

select 
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)

from ProjectPortfolio..NashvilleHousing

alter table ProjectPortfolio..NashvilleHousing
add OwnerSplitAddress nvarchar (255);

update ProjectPortfolio..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)

-----
alter table ProjectPortfolio..NashvilleHousing
add OwnerSplitCity nvarchar (255);

update ProjectPortfolio..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)

-----
alter table ProjectPortfolio..NashvilleHousing
add OwnerSplitState nvarchar (255);

update ProjectPortfolio..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)

select SoldAsVacant, COUNT(SoldAsVacant)
from ProjectPortfolio..NashvilleHousing
group by SoldAsVacant
order by 2

--Organizing SoldAsVacant 

select SoldAsVacant, COUNT(SoldAsVacant),
case 
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
else SoldAsVacant
end
from ProjectPortfolio..NashvilleHousing
group by SoldAsVacant

update ProjectPortfolio..NashvilleHousing
set SoldAsVacant= case 
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
else SoldAsVacant
end

--Removing Duplicates

with RowNumCTE as(
select *, ROW_NUMBER()
over( 
partition by ParcelID, PropertyAddress,	SalePrice, SaleDate, LegalReference
			order by UniqueID
			)
			 row_num
from ProjectPortfolio..NashvilleHousing
)

select *
from RowNumCTE
where row_num>1
order by PropertyAddress

--Removing Unnecessary Columns

select *
from ProjectPortfolio..NashvilleHousing

alter table ProjectPortfolio..NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict

alter table ProjectPortfolio..NashvilleHousing
drop column SaleDate
