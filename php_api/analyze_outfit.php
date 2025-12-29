<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// 1. Handle Preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$API_KEY = "AIzaSyDo7W3JyGRcON3UcyFduiHR-ayS8rCOlCk";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Check if image exists
    if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
        echo json_encode(["success" => false, "error" => "No valid image uploaded"]);
        exit();
    }

    $tmpPath = $_FILES['image']['tmp_name'];
    $mimeType = mime_content_type($tmpPath);
    $imageData = base64_encode(file_get_contents($tmpPath));

    // 2. Prepare Gemini Request
    // 2. Prepare Gemini Request
    $prompt = "You are a professional stylist. Analyze this clothing item image.
    
    1. First, IDENTIFY the item type (Top, Bottom, Shoes, or Outerwear).
    2. Then, suggest exactly 3 items to complete the outfit based on this logic:
       - If it is a TOP (T-Shirt, Shirt, Hoodie) -> Suggest: [Pants/Jeans, Shoes, Jacket/Layer].
       - If it is a BOTTOM (Pants, Jeans, Skirt) -> Suggest: [Top/Shirt, Shoes, Accessory/Jacket].
       - If it is SHOES -> Suggest: [Pants/Jeans, Top/Shirt, Jacket/Accessory].
       - If it is OUTERWEAR (Jacket, Coat) -> Suggest: [Inner Top, Pants/Jeans, Shoes].

    Return ONLY valid JSON with this structure (no markdown):
    {
        \"success\": true,
        \"description\": \"One sentence description of the upload.\",
        \"ai_analysis\": {
            \"detected_type\": \"Top/Bottom/Shoes/Outerwear\",
            \"color_palette\": \"Dominant color name\",
            \"style_vibe\": \"e.g. Casual, Formal, Streetwear\",
            \"occasion\": \"Best occasion to wear this\"
        },
        \"suggested_combinations\": [
            {\"type\": \"e.g. Jeans\", \"color\": \"e.g. Black\", \"reason\": \"Why it works\"},
            {\"type\": \"e.g. Sneakers\", \"color\": \"e.g. White\", \"reason\": \"Why it works\"},
            {\"type\": \"e.g. Jacket\", \"color\": \"e.g. Denim\", \"reason\": \"Why it works\"}
        ]
    }";

    $payload = [
        "contents" => [
            [
                "parts" => [
                    ["text" => $prompt],
                    [
                        "inline_data" => [
                            "mime_type" => $mimeType,
                            "data" => $imageData
                        ]
                    ]
                ]
            ]
        ]
    ];

    // 3. Call Gemini API
    $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=" . $API_KEY;

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ["Content-Type: application/json"]);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

    $result = curl_exec($ch);

    if (curl_errno($ch)) {
        echo json_encode(["success" => false, "error" => "Curl error: " . curl_error($ch)]);
        exit();
    }
    curl_close($ch);

    // 4. Parse Response
    $response = json_decode($result, true);

    if (isset($response['candidates'][0]['content']['parts'][0]['text'])) {
        $rawText = $response['candidates'][0]['content']['parts'][0]['text'];

        // Clean Markdown if present
        $rawText = str_replace("```json", "", $rawText);
        $rawText = str_replace("```", "", $rawText);
        $rawText = trim($rawText);

        // Return Gemini's JSON
        echo $rawText;
    } else {
        // Fallback for API errors/safety blocks
        echo json_encode([
            "success" => false,
            "error" => "Gemini API Error",
            "raw_response" => $response
        ]);
    }
    exit();
}

http_response_code(405);
echo json_encode(["error" => "Method not allowed"]);
?>