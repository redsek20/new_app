# Implementation Plan: Gender-Specific & Product-Only Wardrobe

## Objective
Refine the `UploadStyleScreen` to enforce gender-specific results and switch the visual style to "Product-Only" (flat lay/ghost mannequin) images, avoiding models.

## 1. UI Updates (Gender Selection)
We need a clear way for the user to select their gender preference which persists for the matching session.
-   **Action**: Add a `Gender Selector` Segmented Button or Toggle in the Header (replacing the old "Alot/Sand" location or near the "Upload" title).
-   **State**: Add `String _selectedGender = 'Men';` (default).
-   **UI Component**: A sleek styled switcher: `[ Men | Women ]`.

## 2. Recommendation Engine (Strict Filtering)
-   **Filter Logic**: Update `_getSmartMatches` to strictly filter candidates:
    ```dart
    final candidates = _pcWardrobe.where((item) => item.demographic == _selectedGender).toList();
    ```
-   **Safety**: Ensure there are enough items for each gender in the simulated wardrobe to provide good matches.

## 3. Data Overhaul: "Product Only" Images
We will completely rebuild `_pcWardrobe` with a clear "Men" vs "Women" split, using URLs that feature *only the clothes* (flat lays), not people.

### Proposed Data Set (Simulated):

**MEN'S WARDROBE (Flat Lay/Product Focus)**
1.  **Black Tee**: Simple black t-shirt on hanger/flat.
2.  **Blue Jeans**: Folded or flat denim.
3.  **Grey Hoodie**: Standard product shot.
4.  **Beige Chinos**: Product shot.
5.  **White Sneakers**: Product shot (shoe only).
6.  **Olive Jacket**: Bomber/Field jacket on hanger.

**WOMEN'S WARDROBE (Flat Lay/Product Focus)**
1.  **Red Blouse**: Chic top product shot.
2.  **Black Skirt/Pants**: Product shot.
3.  **Floral Dress**: Product shot.
4.  **Beige Trench**: Coat on hanger.
5.  **Denim Shorts**: Product shot.
6.  **White Heels/Boots**: Shoe product shot.

## 4. Execution Steps
1.  **Modify State**: Add `_selectedGender` variable.
2.  **Modify UI**: Insert the Gender Toggle in the `Stack` header.
3.  **Rebuild Data**: Replace `_pcWardrobe` with the new 12-item list (6 Men, 6 Women) using vetted "Product Only" URLs.
4.  **Update Logic**: Apply the `where` filter before scoring.
