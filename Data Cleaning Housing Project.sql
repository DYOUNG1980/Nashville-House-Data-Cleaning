/*

Cleaning data in SQL Queries


*/

-- Select all the data from Excel file

Select *
From Portfolio_Project.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDate, Convert (date, SaleDate)
From Portfolio_Project.dbo.NashvilleHousing

Update Portfolio_Project..NashvilleHousing
SET SaleDate = Convert (date, SaleDate)

Select Cast(SaleDate as Date) as Date
From Portfolio_Project..NashvilleHousing

-- Populate Property Address
Select *
From Portfolio_Project..NashvilleHousing
Where PropertyAddress is Null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
Join Portfolio_Project.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
Join Portfolio_Project.dbo.NashvilleHousing b
	On a.ParcelID = b.ParcelID
Where a.PropertyAddress is null
	And a.[UniqueID ] <> b.[UniqueID ]

	-- Breaking out Address into Individual Columns
Select PropertyAddress
From Portfolio_Project..NashvilleHousing
-- Where PropertyAddress is null
--Order By ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From Portfolio_Project..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Portfolio_Project..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Portfolio_Project..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From Portfolio_Project..NashvilleHousing

Select OwnerAddress
From Portfolio_Project..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From Portfolio_Project..NashvilleHousing

Alter Table Portfolio_Project..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio_Project..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table Portfolio_Project..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Portfolio_Project..NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table Portfolio_Project..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Portfolio_Project..NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes or No in Sold as Vacant column

Select Distinct(SoldAsVacant)
From Portfolio_Project..NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project..NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From Portfolio_Project..NashvilleHousing

Update Portfolio_Project..NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project..NashvilleHousing
Group By SoldAsVacant
Order by 2

-- Remove Duplicates
With RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				 UniqueID
				 ) row_num
From Portfolio_Project..NashvilleHousing
--Order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1

Select * 
From Portfolio_Project..NashvilleHousing

-- Delete Unused Columns

Select * 
From Portfolio_Project..NashvilleHousing

Alter Table Portfolio_Project..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress