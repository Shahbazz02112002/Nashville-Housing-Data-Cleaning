SELECT * FROM PortfolioProject..NashvilleHousing;

--1)Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) FROM PortfolioProject..NashvilleHousing;

UPDATE PortfolioProject..NashvilleHousing SET SaleDate = CONVERT(Date, SaleDate);

-- Using TRY_CONVERT
UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = TRY_CONVERT(Date, SaleDate);

-- Using CAST
UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = CAST(SaleDate AS Date);

ALTER TABLE PortfolioProject..NashvilleHousing add saledate2 Date;

UPDATE PortfolioProject..NashvilleHousing SET saledate2 = CONVERT(Date, SaleDate);

SELECT saledate2, CONVERT(Date, SaleDate) FROM PortfolioProject..NashvilleHousing;

--2)Populate property address data

SELECT * FROM PortfolioProject..NashvilleHousing WHERE PropertyAddress is null;

SELECT * FROM PortfolioProject..NashvilleHousing ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ] WHERE a.PropertyAddress is NULL;

UPDATE a SET a.PropertyAddress = b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ] WHERE a.PropertyAddress is NULL;

--Or

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID];

--Breaking out address into  (address, city) 

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject..NashvilleHousing add PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE PortfolioProject..NashvilleHousing add PropertySplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT OwnerAddress FROM PortfolioProject..NashvilleHousing;

--Parsename works backwards and it works for .

--SELECT PARSENAME(OwnerAddress, 1)
--FROM PortfolioProject..NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject..NashvilleHousing add OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3);

ALTER TABLE PortfolioProject..NashvilleHousing add OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2);

ALTER TABLE PortfolioProject..NashvilleHousing add OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1);

--Change Y and N to no and yes using case statement

UPDATE PortfolioProject..NashvilleHousing SET SoldAsVacant  = CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
WHEN SoldAsVacant = 'N' Then 'No'
ELSE SoldAsVacant
END

SELECT DISTINCT(SoldAsVacant) FROM PortfolioProject..NashvilleHousing

--Remove Duplicates

WITH RowNumCTE as (
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate,
LegalReference ORDER BY UniqueID) row_num FROM PortfolioProject..NashvilleHousing)

DELETE FROM RowNumCTE WHERE row_num > 1 

--Delete unused columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
