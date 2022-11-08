/* 
DATA CLEANING PROJECT
*/

---------------------------------------------------------------------

--Getting rid of the time from the Sales Date

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted=CONVERT(Date,SaleDate) -- Method to convert date/time to just date format.

---------------------------------------------------------------------

--Populate Property Address (Replacing NULL values with actual address)
/* After analyzing the data, we found out that same parcel Id's have same Property Addresses.
 Therefore using the ParcelId, we will replace the nulls with the proper address. */

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
 Join PortfolioProject..NashvilleHousing b --applying self join
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
 
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
 Join PortfolioProject..NashvilleHousing b 
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Property Address into indivisual coloumns (Address, City, State)

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1) as PropertyAddressStreet , 
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress)) as PropertyAddressCity
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertyAddressStreet Nvarchar(255);

Update NashvilleHousing
Set PropertyAddressStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) - 1)

Alter Table NashvilleHousing
Add PropertyAddressCity Nvarchar(255);

Update NashvilleHousing
Set PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1, LEN(PropertyAddress))

--Breaking out Owner Address into indivisual coloumns (Address, City, State)

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3), PARSENAME(Replace(OwnerAddress,',','.'),2), PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerAddressStreet Nvarchar(255);
Update NashvilleHousing
Set OwnerAddressStreet = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerAddressCity Nvarchar(255);
Update NashvilleHousing
Set OwnerAddressCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerAddressState Nvarchar(255);
Update NashvilleHousing
Set OwnerAddressState = PARSENAME(Replace(OwnerAddress,',','.'),1)

--Changing Y and N to Yes and No in "Sold as Vacant" coloumn

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						End

--Removing the Duplicates

WITH RowNumCTE AS (    --Using CTE to remove the duplicates with the help of Row_Number function)
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) as row_num
From PortfolioProject..NashvilleHousing
)

Delete
From RowNumCTE
Where row_num > 1

--Deleting the Unused Coloumns

Alter Table NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, SaleDate, TaxDistrict

Select *
From PortfolioProject..NashvilleHousing