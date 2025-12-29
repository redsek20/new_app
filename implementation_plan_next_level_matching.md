# Implementation Plan: "Next Level" AI Matching & Data Fixes

## Objective
Upgrade the matching engine to be intelligent, dynamic, and error-free. The goal is to ensure:
1.  **No Dead Links**: Fix all 404 Image URLs.
2.  **No Repetition**: Matches must vary and explore the full 100-item wardrobe.
3.  **Logical Outfits**: **Top** matches with **Bottoms + Shoes**, NEVER another Top (unless it's a layer like a Jacket). **Jeans** match with **Tops + Shoes**, NEVER matching Jeans.

## 1. Data Repair (`PcWardrobeData`)
Several Unsplash links are dead (404). We will replace them with verified, stable IDs.
-   Fix `w1` (Crimson Blouse) -> 404.
-   Fix `w2` (Floral Dress) -> 404.
-   Fix `m2` (Grey Hoodie) -> Verify.
-   Review all IDs to ensure they are valid.

## 2. Smart Logic 2.0: The "Outfit Builder" Engine
Refactor `_getSmartMatches` in `UploadStyleScreen` to enforce strict Category rules.

### New Rules:
1.  **Category Exclusion**:
    *   If Upload = **Bottoms (Jeans, Pants)** -> REMOVE all **Bottoms** from candidates.
    *   If Upload = **Tops (Tee, Shirt)** -> REMOVE all **T-Shirts/Base Layers**. (Jackets are okay).
    *   If Upload = **Footwear** -> REMOVE all **Footwear**.
2.  **The "Full Look" Formula**:
    *   The result list must try to include at least:
        *   1 Top (if Bottom uploaded) OR 1 Bottom (if Top uploaded).
        *   1 Shoe.
        *   1 Accessory or Upper Layer (Jacket).
3.  **Gemini Parsing**:
    *   Extract the `category` ("Jeans", "Tee") from the Gemini Analysis JSON.
    *   Use this to trigger the Exclusion Rules.

## 3. Randomization & Exploration
To solve "images generated still the same every time":
-   If matches have similar scores, **Shuffle** them.
-   Don't just take the top 3 hardcoded best mathematical matches every time. Add a randomized "Spice" factor to the score so different items appear occasionally.

## 4. Execution Steps
1.  **Update Data**: Fix `lib/core/data/pc_wardrobe_data.dart` (Replace dead links).
2.  **Update Logic**: Rewrite `_getSmartMatches` to accept `inputCategory` and apply exclusion/variety logic.
3.  **Verify**: Test with "Jeans" upload -> Confirm no Jeans in results.
