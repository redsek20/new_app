# Implementation Plan: Real Gemini API Integration

## Objective
Replace the mock backend with a **Real Gemini 1.5 Flash** integration using the provided API Key. The backend will serve as a proxy, sending the user's image to Google and returning structured fashion advice.

## 1. Backend Update (`php_api/analyze_outfit.php`)
We will rewrite the PHP script to perform the following:
1.  **Receive Image**: Accept the multipart form upload from Flutter.
2.  **Encode**: Convert the temporary image file to Base64.
3.  **Call Gemini API**:
    *   **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`
    *   **Method**: POST
    *   **Payload**:
        ```json
        {
          "contents": [{
            "parts": [
              {"text": "Analyze this clothing item... [Strict JSON Prompt]"},
              {"inline_data": {"mime_type": "image/jpeg", "data": "BASE64_STRING"}}
            ]
          }]
        }
        ```
    *   **Key**: Use the provided `AIza...` key.
4.  **Parse & Clean**: Extract the JSON text from Gemini's response (removing any markdown backticks) and return clean JSON to the app.

## 2. Frontend Validation
The Flutter app is already architected to receive the JSON structure:
-   `ai_analysis` (Color, Vibe)
-   `suggested_combinations` (List of matches)

No major Flutter changes are needed if the PHP script maintains the *Contract* (the JSON structure).

## 3. Workflow
1.  **User** uploads image (e.g., Blue Shirt).
2.  **Flutter** sends to `localhost/analyze_outfit.php`.
3.  **PHP** sends Blue Shirt + "Give me advice" prompt to **Gemini**.
4.  **Gemini** sees image, thinks "Navy Tee, Casual". Returns "Wear with Beige Chinos".
5.  **PHP** forwards this to Flutter.
6.  **All** updates UI with "AI detected Casual Vibe. Suggesting Beige Chinos."
7.  **Smart Matcher** boosts "Beige Chinos" in the grid.

## 4. Execution
1.  Rewrite `php_api/analyze_outfit.php` with the real API Key and cURL logic.
