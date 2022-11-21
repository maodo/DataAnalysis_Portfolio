/*

-- Data Cleaning on Nashville Housing Data --

*/

-- Cleaning queries

SELECT
	*
FROM
	"NashvilleHousing";

--## Standardize Date Format
SELECT
	"SaleDate", to_char("SaleDate"::DATE,'yyyy/mm/dd') /*In Postgres to format a date we use the to_char function but MySQL we use CONVERT */
FROM
	"NashvilleHousing";

--## Populate property address data

SELECT
	*
FROM
	"NashvilleHousing"
WHERE
	"PropertyAddress"=''
ORDER BY "ParcelID";
-- We see that we have some property addresses which are null. Now we'll fill the missing addresses with the same addresses based on ParcelID
UPDATE "NashvilleHousing"
SET "PropertyAddress" = NULL
WHERE "PropertyAddress"='';

-- Let's use CTE to get the filled addresses

WITH d AS (
	SELECT
		a. "UniqueID" as "UniqueID",
		COALESCE(a. "PropertyAddress",
			b. "PropertyAddress") AS "NewPropertyAddress"
	FROM
		"NashvilleHousing" a
		JOIN "NashvilleHousing" b ON a. "ParcelID" = b. "ParcelID"
			AND a. "UniqueID" <> b. "UniqueID"
	WHERE
		a. "PropertyAddress" IS NULL
)


UPDATE
	"NashvilleHousing" n
SET
	"PropertyAddress" = d."NewPropertyAddress"
FROM
	d
WHERE
	n."UniqueID" = d."UniqueID";

-- Let's check 
SELECT
	*
FROM
	"NashvilleHousing";

--## Breaking out Address into individual columns (Address, City, State)

SELECT "PropertyAddress" FROM "NashvilleHousing";

-- Let's add two columns for addresses
ALTER TABLE "NashvilleHousing"
	ADD "PropertySplitAddress" VARCHAR(255);

ALTER TABLE "NashvilleHousing"
	ADD "PropertySplitCity" VARCHAR(255);


SELECT
	SUBSTRING("PropertyAddress", 1, strpos("PropertyAddress", ',') - 1) "Address",
	SUBSTRING("PropertyAddress", strpos("PropertyAddress", ',') + 1) "City",
	"PropertyAddress"
FROM
	"NashvilleHousing";

UPDATE "NashvilleHousing"
SET "PropertySplitAddress" = SUBSTRING("PropertyAddress", 1, strpos("PropertyAddress", ',') - 1);

UPDATE "NashvilleHousing"
SET "PropertySplitCity" = SUBSTRING("PropertyAddress", strpos("PropertyAddress", ',') + 1);

SELECT "PropertyAddress", "PropertySplitAddress", "PropertySplitCity" FROM "NashvilleHousing";
-- For the owner address
SELECT
	"OwnerAddress"
FROM
	"NashvilleHousing";

SELECT
	split_part("OwnerAddress", ',', 3),
	split_part("OwnerAddress", ',', 2),
	split_part("OwnerAddress", ',', 1),
	"OwnerAddress"
FROM
	"NashvilleHousing";

-- Let's add the column

ALTER TABLE "NashvilleHousing"
	ADD "OwnerSplitAddress" VARCHAR(255);

ALTER TABLE "NashvilleHousing"
	ADD "OwnerSplitCity" VARCHAR(255);

ALTER TABLE "NashvilleHousing"
	ADD "OwnerSplitState" VARCHAR(255);

-- Let's populate our new columns
UPDATE
	"NashvilleHousing"
SET
	"OwnerSplitAddress" = split_part("OwnerAddress", ',', 1);

UPDATE
	"NashvilleHousing"
SET
	"OwnerSplitCity" = split_part("OwnerAddress", ',', 2);

UPDATE
	"NashvilleHousing"
SET
	"OwnerSplitState" = split_part("OwnerAddress", ',', 3);

SELECT * FROM "NashvilleHousing";

-- ## Change Y and N to Yes and No in 'SoldAsVacant' column
SELECT DISTINCT "SoldAsVacant" FROM "NashvilleHousing";

	"NashvilleHousing";
-- Updating
UPDATE
	"NashvilleHousing"
SET
	"SoldAsVacant" = CASE WHEN "SoldAsVacant" = 'Y' THEN
		'Yes'
	WHEN "SoldAsVacant" = 'N' THEN
		'No'
	ELSE
		"SoldAsVacant"
	END;

-- ## Remove duplicates
WITH RowNumCTE AS (
	SELECT
		"UniqueID"
	FROM (
		SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY "ParcelID",
				"PropertyAddress",
				"SalePrice",
				"SaleDate",
				"LegalReference" ORDER BY "UniqueID") row_num
		FROM
			"NashvilleHousing") sbq
	WHERE row_num > 1
)
DELETE FROM "NashvilleHousing" 
WHERE "UniqueID" IN(SELECT * FROM RowNumCTE);

-- ## Delete unused columns
ALTER TABLE "NashvilleHousing" DROP COLUMN "TaxDistrict";
ALTER TABLE "NashvilleHousing" DROP COLUMN "OwnerAddress";
ALTER TABLE "NashvilleHousing" DROP COLUMN "PropertyAddress";

SELECT * FROM "NashvilleHousing";
