---
description: Implement Smart Outfit Analysis using Gemini API
---

# Smart Outfit Analysis Plan

## 1. Objective
Replace the simulated "AI" in the `UploadAnalyzerScreen` with a real connection to the existing `analyze_outfit.php` backend, which uses Google's Gemini Vision API. This will allow users to upload a photo and get real style advice and outfit recommendations.

## 2. Components

### Backend (Existing)
- `php_api/analyze_outfit.php`: Already configured to take an image and return JSON from Gemini.
- **Action**: Verify it's accessible and returns the expected format.

### Frontend (`UploadAnalyzerScreen`)
- **Current State**: Uses `Future.delayed` to fake results.
- **Changes Needed**:
    1.  Import `http` and `dart:convert`.
    2.  Implement `_analyzeWithServer(File image)` method.
    3.  Send `MultipartRequest` to `http://10.0.2.2/php_api/analyze_outfit.php`.
    4.  Parse the complex JSON response.
    5.  Redesign `_buildAnalysisResults` to show:
        - The "One Sentence Description".
        - The "AI Analysis" tags (Style, Vibe, Occasion).
        - The `Style Score` (we can calculate this or ask AI for it).
        - The `Suggested Combinations` as a list of "Ghost" items the user should buy/wear.

## 3. Step-by-Step Implementation

1.  **Update `UploadAnalyzerScreen`**:
    - Add methods to upload image.
    - specialized UI for "Analysis" results (Cards for suggested items).
    - Error handling for server connection.

2.  **Refine PHP (Optional)**:
    - Ensure the JSON structure is strictly enforced (Gemini 2.0 is good at this, but safety checks help).

3.  **User Flow**:
    - User picks image -> Loading Spinner -> "AI is analyzing threads..." -> Results Screen.

## 4. Why this is "Smarter" than YOLO
- **YOLO**: Detects "Shirt". (Does not know if it's a *formal* shirt or a *grunge* shirt).
- **Gemini (VLM)**: Sees "Vintage 90s Flannel Shirt, Grunge Aesthetic". Can suggest "Ripped Jeans" and "Combat Boots" specifically. YOLO cannot do this easily without massive custom datasets.
