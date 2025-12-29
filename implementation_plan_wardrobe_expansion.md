# Implementation Plan: Massive Wardrobe Expansion (100+ Items)

## Objective
Expand the "Simulated PC Wardrobe" from 12 items to **100 diversified, high-quality items** (50 Men, 50 Women) to provide a rich, realistic AI matching experience.

## 1. Strategy: Curated Categories
We will generate lists for specific categories to ensuring Gemini has plenty of options to choose from.

### Men's Wardrobe (50 Items)
-   **Tops (20)**: Tees (Black, White, Navy, Grey, Graphic), Hoodies, Polos, Flannels, Denim Jackets, Bombers, Blazers.
-   **Bottoms (15)**: Jeans (Blue, Black, Grey), Chinos (Beige, Olive, Navy), Shorts, Sweatpants.
-   **Footwear (10)**: Sneakers (White, Jordan-style, Runners), Boots (Chelsea, Timberland-style), Loafers.
-   **Accessories (5)**: Caps, Watches, Bags.

### Women's Wardrobe (50 Items)
-   **Tops (20)**: Blouses (Silk, Cotton), Crops, Sweaters, Blazers, Leather Jackets, Coats (Trench, Puffer).
-   **Bottoms (15)**: Skirts (Mini, Midi), Jeans (Mom, Skinny, Wide Leg), Trousers, Leggings.
-   **Dresses (5)**: Summer, Formal, Maxi.
-   **Footwear (10)**: Heels, Boots, Sneakers, Sandals.

## 2. Implementation with `List.generate` & Unsplash
Hardcoding 100 items line-by-line allows for precision but is verbose. I will create a structured Helper Class or Method to populate this list efficiently using a mix of:
1.  **Specific Hero Items**: 20 hand-picked URLs for high quality ("Ghost Mannequin" style).
2.  **Procedural Generation**: 80 items using Unsplash Keywords (e.g., `source.unsplash.com/featured/?men,shirt`) to ensure variety without finding 100 unique IDs manually. *Note: Unsplash Source is deprecated, so I will likely use a list of 100 known-good IDs or a reliable placeholder service for the bulk.*

**Decision**: I will use a **Static List of ~50-60 verified Unsplash IDs** combined with color/category variations to simulate 100 distinctive items.

## 3. Execution
1.  Create a new file `lib/core/data/pc_wardrobe_data.dart` to hold this massive list (keeping the screen code clean).
2.  Import this list into `UploadStyleScreen`.
3.  Update the `OutfitItem` model if needed (it works fine now).
