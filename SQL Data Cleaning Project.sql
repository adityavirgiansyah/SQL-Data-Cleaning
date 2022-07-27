/*
Data Cleaning In SQL Queries
*/

SELECT 
	*
FROM 
	nashville.dbo.NashvilleHousing

-- Standarized Date Format

SELECT 
	SaleDate,
	CONVERT(date, SaleDate)
FROM 
	nashville.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


-- Populate Property Address

SELECT 
	a.ParcelID, 
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	nashville.dbo.NashvilleHousing a
JOIN
	nashville.dbo.NashvilleHousing b
		ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
	nashville.dbo.NashvilleHousing a
JOIN
	nashville.dbo.NashvilleHousing b
		ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking Out Address Into Individual Columns (Address, City, State)

SELECT 
	PropertyAddress
FROM 
	nashville.dbo.NashvilleHousing

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM 
	nashville.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM 
	nashville.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-- Change Y and N to Yes and No in SoldAsVacant Column

SELECT 
	DISTINCT(SoldAsVacant), 
	COUNT(SoldAsVacant)
FROM 
	nashville.dbo.NashvilleHousing
GROUP BY
	SoldAsVacant
ORDER BY
	2
	
SELECT 
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM
	nashville.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM
	nashville.dbo.NashvilleHousing
)
SELECT
	*
FROM 
	RowNumCTE
WHERE
	row_num > 1
ORDER BY
	PropertyAddress

-- Delete Unused Columns


SELECT 
	*
FROM 
	nashville.dbo.NashvilleHousing

ALTER TABLE nashville.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE nashville.dbo.NashvilleHousing
DROP COLUMN SaleDate