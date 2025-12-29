# Implementation Plan: Smart AI Color Matching Logic

## Objective
Upgrade the simple "Bold vs Neutral" logic to a sophisticated **Color Theory Algorithm** that suggests aesthetically pleasing outfits based on Harmony, Contrast, and Style Rules.

## 1. Data Enhancement
We need to accurately understand the colors in the simulated "PC Wardrobe".
- **Action**: Create a `Map<String, Color>` helper to convert the text colors (e.g., 'Red', 'Beige') in the `_pcWardrobe` list to actual `Color` objects for mathematical comparison.

## 2. The "Smart Matcher" Algorithm
We will implement a scoring system (`compatibilityScore`) for each item in the wardrobe against the uploaded image's dominant color.

### Core Rules (The Brain):
1.  **Neutral Supremacy**:
    -   If the input is **Neutral** (Black, White, Grey), it matches with **ANYTHING**.
    -   *Bonus*: Match Black with Bold/Neon (High Contrast). Match White with Pastel/Denim.
2.  **Complementary Contrast**:
    -   If the input is **Cool** (Blue, Green), suggest **Warm Earth Tones** (Beige, Brown, Orange).
    -   If the input is **Warm** (Red, Yellow), suggest **Cool Solids** (Navy, Black, Grey).
3.  **Monochromatic Class**:
    -   Suggest items of the *same* hue but different brightness (e.g., Navy Hoodie with Light Blue Jeans).

### Context Awareness (Using the Chips):
-   **"Sand" Chip Selected**: Force recommendation of Earth Tones (Beige, Brown, Olive, Cream) regardless of input.
-   **"Alot" Chip Selected**: Prioritize High Contrast (Complementary colors).

## 3. Implementation Steps

### Step 1: Parsing
-   Modify `_analyzeAndMatch`.
-   Extract `HSVColor` from the uploaded image.

### Step 2: Scoring Function
Create a helper function `double matches(Color input, Color candidate)`:
-   **Exact Match**: Score +0 (Avoid "Red on Red" unless monochromatic rule active).
-   **Neutral Match**: Score +50 (Safe bet).
-   **Complementary**: Score +80 (High fashion).
-   **Clash**: Score -20 (e.g., Pink on Red, unless specific style).

### Step 3: Filtering & Sorting
-   Iterate through `_pcWardrobe`.
-   Calculate score for each item.
-   Return the top 3 items with Score > 30.

## 4. Immediate Code Changes
-   Update `UploadStyleScreen` to include a `getColorFromName` helper.
-   Rewrite `_analyzeAndMatch` to use this new scoring logic.
