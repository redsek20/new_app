# Implementation Plan: Redesign Upload Style Screen

## Objective
Rebuild the `UploadStyleScreen` to exactly match the provided design reference while integrating functional image upload and AI matching.

## 1. Visual Design (UI)
We will implement a `Stack`-based layout to achieve the overlapping "Curved Header" effect.

### Components:
1.  **Curved Header**:
    *   **Background**: Deep Purple Gradient (`#2E2E3E` to `#4B39EF`).
    *   **Shape**: Custom Bezier Curve (concave/convex wave) at the bottom.
    *   **Content**: Back Button, Title ("Upload or Upload Outfit"), Filter Chips ("Alot", "Sand").
2.  **Circular Scanner (Avatar)**:
    *   **Position**: Centered, overlapping the boundary between the purple header and the white body.
    *   **Style**: Large radius, white border, shadow.
    *   **Interaction**: Tap to Upload (Image Picker).
    *   **Sub-element**: "Retry" pill button floating on the right edge.
3.  **Input Section**:
    *   **Row**: "Outfit Name" Input Field (Grey background) + Toggle Switch.
    *   **Style**: Rounded corners, "Beta" label text.
4.  **Action Button**:
    *   **Style**: Full-width, gradient purple, rounded pills.
    *   **Label**: "Analyze & Find Matches (AI)".
5.  **Results Section**:
    *   **Title**: "Your Auto-Generated Matches".
    *   **List**: Horizontal scroll or Grid of simulated matches.

## 2. Functionality (Logic)
We will combine the "Upload" capability with the "PC Wardrobe" data.

1.  **Image Source**:
    *   User taps Avatar -> Choose Camera or Gallery (`image_picker`).
    *   *Fallback*: If on Emulator without images, we provide a "Demo Mode" button hidden or explicit.
2.  **AI Matching Engine**:
    *   **Input**: The user's uploaded image (detected color/style).
    *   **Database**: The local `_pcWardrobe` list we created in the previous step (simulating the user's PC data).
    *   **Algorithm**: Strict "Bold <-> Neutral" matching logic.
3.  **State Management**:
    *   `_selectedImage`: Holds the uploaded file.
    *   `_isAnalyzing`: Triggers the loading animation (Spinner).
    *   `_matches`: Stores the suggested items.

## 3. Execution Steps
1.  **Create Clipper**: Define `HeaderCurveClipper` class.
2.  **Scaffold Layout**: Build the `Stack` with `Positioned` elements.
3.  **Widgets**: Build `_buildHeader()`, `_buildAvatar()`, `_buildInputForm()`, `_buildResults()`.
4.  **Logic**: Wire up `_pickImage()` and `_analyze()`.

 This plan ensures the specific visual aesthetic is met while delivering the requested functionality.
