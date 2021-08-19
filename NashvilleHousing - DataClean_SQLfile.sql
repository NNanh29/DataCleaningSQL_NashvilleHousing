-- Select all from table
SELECT * 
FROM [Portfolio Project].[dbo].[NashvilleHousing];

-- Standardize Date Format: Drop time in SaleDate column

ALTER TABLE NashvilleHousing
ADD DateConverted Date;

UPDATE NashvilleHousing
SET DateConverted = CAST(SaleDate AS Date);

SELECT DateConverted
FROM [Portfolio Project].[dbo].[NashvilleHousing];

-- Populate Property Address data: Fill Null value with value from same Parcel ID

SELECT *
FROM [Portfolio Project].[dbo].[NashvilleHousing]
WHERE PropertyAddress is NULL
ORDER BY ParcelID


UPDATE a 
SET PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].[dbo].[NashvilleHousing] a
JOIN [Portfolio Project].[dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


SELECT *
FROM [Portfolio Project].[dbo].[NashvilleHousing]
WHERE PropertyAddress is NULL


-- Breaking out Property Address Columns to Address and City

ALTER TABLE NashvilleHousing
ADD NewProperyAddress text,
 PropertyCity text;

 UPDATE NashvilleHousing
 SET NewProperyAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

 UPDATE NashvilleHousing
 SET PropertyCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

 -- Breaking out Owner Address into Individual Columns (Address, City, State)

ALTER TABLE NashvilleHousing
ADD NewOwnerAddress nvarchar(255),
OwnerCity nvarchar(255),
OwnerState nvarchar(255)

UPDATE NashvilleHousing
SET NewOwnerAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHousing
SET OwnerCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing
SET OwnerState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant)
FROM [Portfolio Project].[dbo].[NashvilleHousing]

UPDATE NashvilleHousing
SET SoldAsVacant=(CASE WHEN SoldAsVacant='N' THEN 'No'
            WHEN SoldAsVacant='Y' THEN 'Yes'
			ELSE SoldAsVacant
			END)


-- Remove Duplicates
SELECT *
FROM [Portfolio Project].[dbo].[NashvilleHousing]

WITH Duplicate AS(
SELECT * ,
ROW_NUMBER() OVER (PARTITION BY ParcelID, SaleDate, SalePrice ORDER BY UniqueID) as DuplicateValue
FROM [Portfolio Project].[dbo].[NashvilleHousing])

DELETE FROM  Duplicate
WHERE DuplicateValue >1

WITH Duplicate AS(
SELECT * ,
ROW_NUMBER() OVER (PARTITION BY ParcelID, SaleDate, SalePrice ORDER BY UniqueID) as DuplicateValue
FROM [Portfolio Project].[dbo].[NashvilleHousing])

SELECT * 
FROM Duplicate
WHERE DuplicateValue >1

-- Delete Unused Columns
ALTER NashvilleHousing
DROP COLUMN PropertyAdress, 
            OwnerAddress