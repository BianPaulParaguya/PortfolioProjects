 /* 
 Cleaning Data in SQL Queries
 */

 Select *
 From PortfolioProject2.dbo.NashvilleHousing


 -- Standardize Date Format
 Select SaleDateConverted, CONVERT(Date,SaleDate) 
 From PortfolioProject2.dbo.NashvilleHousing

 Update NashvilleHousing
 SET SaleDate = Convert(Date,SaleDate)

 Alter Table NashvilleHousing
 Add SaleDateConverted Date;

 Update NashvilleHousing
 SET SaleDateConverted = Convert(Date,SaleDate)


-- Populate Property Address Data

Select *
From PortfolioProject2.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject2.dbo.NashvilleHousing a
Join PortfolioProject2.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET	PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject2.dbo.NashvilleHousing a
Join PortfolioProject2.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--breaking out ADdress into individual columns (adress,city,state)

Select PropertyAddress
From PortfolioProject2.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject2.dbo.NashvilleHousing

Alter Table PortfolioProject2.dbo.NashvilleHousing
Add PropertySplitAddress NVarchar(250);

Update PortfolioProject2.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
 
Alter Table PortfolioProject2.dbo.NashvilleHousing
Add PropertySplitCity NVarchar(250);

Update PortfolioProject2.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select * 
from PortfolioProject2.dbo.NashvilleHousing


Select OwnerAddress 
from PortfolioProject2.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 1)
from PortfolioProject2.dbo.NashvilleHousing

Alter Table PortfolioProject2.dbo.NashvilleHousing
Add OwnerSplitAddress NVarchar(250);

Update PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 3)

Alter Table PortfolioProject2.dbo.NashvilleHousing
Add OwnerSplitCity NVarchar(250);

Update PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 2)

Alter Table PortfolioProject2.dbo.NashvilleHousing
Add OwnerSplitState NVarchar(250);

Update PortfolioProject2.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 1)

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject2.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,	CASE When SoldAsVacant ='Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject2.dbo.NashvilleHousing

Update PortfolioProject2.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant ='Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates
WITH RowNumCTE AS(
Select *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY ParcelID
			 ) row_num

From PortfolioProject2.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num >1
Order By PropertyAddress


-- Delete Unusued Columns

Select * 
from PortfolioProject2.dbo.NashvilleHousing

ALTER Table PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN SaleDateConverted, PropertyAddress, OwnerAddress
