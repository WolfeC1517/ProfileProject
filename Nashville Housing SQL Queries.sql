/*

Cleaning Data in SQL Queries

*/


--------------------------------------------------------------------------------------------------------------------------

-- Display Top 100 rows


SELECT TOP (100) *
FROM PortfolioProject..nashville_housing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT 
	SaleDate,
	CONVERT(date,saleDate)
FROM PortfolioProject..nashville_housing

UPDATE PortfolioProject..nashville_housing
SET SaleDate = CONVERT(date,saleDate)

-- If it doesn't Update properly
-- We must change the DATATYPE

ALTER TABLE nashville_housing
ALTER COLUMN SaleDate date;



--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject..nashville_housing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..nashville_housing a
JOIN PortfolioProject..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..nashville_housing a
JOIN PortfolioProject..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) AS city
FROM PortfolioProject..nashville_housing



ALTER TABLE nashville_housing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
FROM PortfolioProject..nashville_housing

ALTER TABLE nashville_housing
ADD PropertySplitCity NVARCHAR(255)

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))
FROM PortfolioProject..nashville_housing



SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProject..nashville_housing




SELECT
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..nashville_housing


ALTER TABLE nashville_housing
ADD OwnerSplitAddress NVARCHAR(255)

ALTER TABLE nashville_housing
ADD OwnerSplitCity NVARCHAR(255)

ALTER TABLE nashville_housing
ADD OwnerSplitState NVARCHAR(255)

UPDATE nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM PortfolioProject..nashville_housing

UPDATE nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
FROM PortfolioProject..nashville_housing

UPDATE nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..nashville_housing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM PortfolioProject..nashville_housing
GROUP BY SoldAsVacant


SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..nashville_housing


UPDATE PortfolioProject..nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- It is not standard practice to delete raw data but this code does work and could be used for views or temp tables.

WITH row_num_cte AS (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY
			ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference,
			OwnerName,
			Acreage
		ORDER BY
			UniqueID
			) row_num
FROM PortfolioProject..nashville_housing

)
DELETE
FROM row_num_cte
WHERE row_num > 1


--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
-- Again not for use with raw data but for use with views or temp tables.


SELECT *
FROM PortfolioProject..nashville_housing


ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

