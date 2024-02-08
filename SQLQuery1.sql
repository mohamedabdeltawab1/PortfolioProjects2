/*

Cleaning Data in SQL Queries

*/


Select *
From [Portfolio Project]..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate , convert(date,SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

alter table NashvilleHousing 
add SaleDateConverted date ;


update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

--____________________________________________________________________________________________________

-- If it doesn't Update properly




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
From [Portfolio Project].. NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress , isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing a
join [Portfolio Project]..NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing a
join [Portfolio Project]..NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select *
from [Portfolio Project]..NashvilleHousing


select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as address
from [Portfolio Project]..NashvilleHousing


alter table [Portfolio Project]..NashvilleHousing 
add PropertySplitAddress  nvarchar(255) ;


update [Portfolio Project]..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)


alter table [Portfolio Project]..NashvilleHousing 
add PropertySplitCity nvarchar(255) ;


update [Portfolio Project]..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))




select PARSENAME(REPLACE( OwnerAddress,',','.'),1),
PARSENAME(REPLACE( OwnerAddress,',','.'),2),
PARSENAME(REPLACE( OwnerAddress,',','.'),3)
from [Portfolio Project]..NashvilleHousing


alter table [Portfolio Project]..NashvilleHousing 
add OwnerSplitAddress nvarchar(255) ;


update [Portfolio Project]..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE( OwnerAddress,',','.'),3)


alter table [Portfolio Project]..NashvilleHousing 
add OwnerSplitCity nvarchar(255) ;


update [Portfolio Project]..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE( OwnerAddress,',','.'),2)


alter table [Portfolio Project]..NashvilleHousing 
add OwnerySplitState nvarchar(255) ;


update [Portfolio Project]..NashvilleHousing
set OwnerySplitState = PARSENAME(REPLACE( OwnerAddress,',','.'),1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant
from [Portfolio Project]..NashvilleHousing
where SoldAsVacant = 'N' or SoldAsVacant ='Y'

select distinct(SoldAsVacant),count(SoldAsVacant)
from [Portfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2




select SoldAsVacant ,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from [Portfolio Project]..NashvilleHousing

update [Portfolio Project]..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

select *
from [Portfolio Project]..NashvilleHousing



with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 order by UniqueID
				 ) row_num 

from [Portfolio Project]..NashvilleHousing
)
delete
from RowNumCTE
--where row_num > 1 
where row_num > 1
--order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select * 
from [Portfolio Project]..NashvilleHousing


alter table [Portfolio Project]..NashvilleHousing
drop column PropertyAddress , SaleDate , OwnerAddress, TaxDistrict





-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO