# STYLX (Outfit Matcher) - Master Development Blueprint

This document outlines the architectural design, AI logic, and tech stack for the STYLX professional fashion application.

---

## Part 1: Database Schema

### 1. `users` Table / Collection
*Focuses on personal style profile and identity.*
- **user_id**: UUID (Primary Key)
- **email**: String (Unique)
- **display_name**: String
- **created_at**: Timestamp
- **preferences**: JSON object (e.g., `{"preferred_palette": "minimalist", "avoid_colors": ["neon"]}`)
- **body_type**: String (Optional: Athletic, Slim, Regular, etc. - for future AR fit)
- **style_persona**: Enum (Streetwear, Formal, Bohemian, Casual)

### 2. `clothing_items` Table / Collection
*The digital wardrobe. Every item is indexed with metadata.*
- **item_id**: UUID (Primary Key)
- **user_id**: UUID (Foreign Key)
- **image_url**: String (Storage Link)
- **category**: Enum (Top, Bottom, Outerwear, Shoes, Accessories, Dress)
- **subcategory**: String (e.g., Hoodie, Chinos, Chelsea Boot)
- **primary_color**: Hex Code (e.g., #2C3E50)
- **secondary_colors**: Array of Hex Codes
- **pattern**: Enum (Solid, Striped, Plaid, Floral, Graphic)
- **material**: String (Cotton, Leather, Wool, etc.)
- **formality_level**: Integer (1: Sleepwear -> 5: Black Tie)
- **weather_tag**: Enum (Summer, Winter, All-Season, Rain)
- **upload_date**: Timestamp

### 3. `outfits` Table / Collection
*Stores saved combinations.*
- **outfit_id**: UUID (Primary Key)
- **user_id**: UUID (Foreign Key)
- **name**: String (e.g., "Monday Morning Meeting")
- **occasion_tag**: Enum (Work, Date, Gym, Casual)
- **items**: Array of UUIDs (References `item_id` in `clothing_items`)
- **is_ai_generated**: Boolean
- **date_created**: Timestamp

---

## Part 2: AI Matching Logic & Flow

### 1. Auto-Tagging New Uploads (Computer Vision)
When a user uploads a photo, the system triggers a Cloud Vision analysis:
- **Object Localization**: Detects the bounding box to distinguish between "Shirt" and "Pants".
- **Label Detection**: Extracts descriptors (e.g., "denim", "blue", "v-neck").
- **Image Properties**: Determines the dominant color hex codes.
- **AI Logic**: Map Vision API labels to internal database enums (e.g., Label "Trousers" -> Category "Bottom").

### 2. Step-by-Step Recommendation Flow

#### **Step A: Input & Initial Filter**
- **User Inputs**: Occasion: "Work", Weather: "Cold", Palette: "Neutral".
- **Query**: `SELECT * FROM clothing_items WHERE weather_tag IN ('Winter', 'All-Season') AND formality_level >= 3`.

#### **Step B: Compatibility Rules & Scoring**
The engine generates potential combinations (Top + Bottom + Outerwear + Shoes) and scores them:
1. **Color Harmony Rule**: Uses the Color Wheel logic. Analogous colors (blue/green) or Monochromatic sets get +20 pts. Clashing colors get -50 pts.
2. **Formality Match Rule**: calculates variance. If Top is level 5 (Formal) and Bottom is level 2 (Sweatpants), the combination is rejected.
3. **Layering Logic**: Validates structure. `Top` -> `Outerwear` is valid. `Top` -> `Top` is invalid unless "Undershirt" tag exists.
4. **Weather Suitability**: If Weather is "Cold", the presence of an `Outerwear` item adds +30 pts.
5. **Occasion Boost**: Items tagged specifically for "Work" by the user get +15 pts.

#### **Step C: Ranking**
- Final Score = `(ColorScore * 0.4) + (FormalityScore * 0.3) + (OccasionScore * 0.3)`.
- Top 3 combinations with the highest scores are returned to the Flutter UI.

---

## Part 3: Tech Stack Recommendations (MVP)

### 1. Backend & Infrastructure
- **Backend Service**: **Firebase Cloud Functions (Node.js)**. Scalable, serverless, and integrates natively with Flutter.
- **Database**: **Cloud Firestore**. NoSQL allows for flexible tagging and rapid prototyping of clothing attributes.
- **Image Storage**: **Firebase Storage**. Handles large 4K fashion assets with built-in CDN.

### 2. Intelligence Layer
- **Image Tagging**: **Google Cloud Vision API**. High accuracy for clothing detection and color extraction.
- **Matching Engine**: **Custom TypeScript Logic** within Cloud Functions. For an MVP, a rule-based engine is more reliable and cheaper than a full neural network.

### 3. Implementation Path
1. **Phase 1**: Implement Firebase Auth and Local Wardrobe (Done).
2. **Phase 2**: Deploy Cloud Functions for Vision API integration.
3. **Phase 3**: Build the "AI Matcher" logic using the scoring rules defined above.
4. **Phase 4**: Add Social/Sharing features to the `outfits` collection.
