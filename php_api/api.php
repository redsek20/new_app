<?php
header("Content-Type: application/json");
$host = "localhost";
$user = "root";
$pass = "";
$db = "outfit_matcher";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$action = $_GET['action'] ?? '';

switch ($action) {
    case 'save_user':
        $data = json_decode(file_get_contents("php://input"), true);
        $email = $data['email']; // Required
        $name = $data['name'] ?? '';
        $password = $data['password'] ?? '';
        $last_login = $data['last_login'] ?? date('Y-m-d H:i:s');
        $auth_token = $data['auth_token'] ?? '';

        $stmt = $conn->prepare("INSERT INTO users (email, name, password, last_login, auth_token) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE name=?, password=?, last_login=?, auth_token=?");
        // 5 params for insert + 4 params for update = 9 params
        $stmt->bind_param(
            "sssssssss",
            $email,
            $name,
            $password,
            $last_login,
            $auth_token, // Insert
            $name,
            $password,
            $last_login,
            $auth_token  // Update
        );

        if ($stmt->execute()) {
            echo json_encode(["success" => true]);
        } else {
            echo json_encode(["success" => false, "error" => $stmt->error]);
        }
        break;

    case 'login':
        $data = json_decode(file_get_contents("php://input"), true);
        $email = $data['email'];
        $password = $data['password'];

        $stmt = $conn->prepare("SELECT name, email, password FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $user = $result->fetch_assoc();
            // In a real app we would use password_verify($password, $user['password'])
            // But since we stored it plain text for this demo:
            if ($user['password'] === $password) {
                echo json_encode(["success" => true, "user" => $user]);
            } else {
                echo json_encode(["success" => false, "error" => "Invalid password"]);
            }
        } else {
            echo json_encode(["success" => false, "error" => "User not found"]);
        }
        break;

    case 'get_products':
        $target = $_GET['target'] ?? '';

        if ($target && $target !== 'All') {
            $stmt = $conn->prepare("SELECT * FROM products WHERE target = ?");
            $stmt->bind_param("s", $target);
        } else {
            $stmt = $conn->prepare("SELECT * FROM products");
        }

        $stmt->execute();
        $result = $stmt->get_result();

        $products = [];
        while ($row = $result->fetch_assoc()) {
            // Convert numbers
            $row['id'] = (string) $row['id'];
            $row['price'] = (double) $row['price'];
            $row['rating'] = (double) $row['rating'];
            $row['stock'] = (int) $row['stock'];
            $row['isFeatured'] = (bool) $row['isFeatured'];
            $row['isNew'] = (bool) $row['isNew'];
            $row['sizes'] = explode(',', $row['sizes']); // Convert CSV string to array

            $products[] = $row;
        }
        echo json_encode(["success" => true, "products" => $products]);
        break;

    case 'add_favorite':
        $data = json_decode(file_get_contents("php://input"), true);
        $stmt = $conn->prepare("INSERT INTO favorites (title, imageUrl, category, tags) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $data['title'], $data['imageUrl'], $data['category'], $data['tags']);
        echo json_encode(["success" => $stmt->execute()]);
        break;

    case 'create_order':
        $data = json_decode(file_get_contents("php://input"), true);
        $order = $data['order'];
        $items = $data['items'];

        $conn->begin_transaction();
        try {
            // UPDATED: Added card_holder, card_number, and expiry_date to the SQL query
            $stmt = $conn->prepare("INSERT INTO orders (user_email, total_amount, shipping_address, payment_method, card_holder, card_number, expiry_date, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");

            // UPDATED: Added the 3 new string parameters to bind_param ("sdssssss")
            $stmt->bind_param(
                "sdssssss",
                $order['user_email'],
                $order['total_amount'],
                $order['shipping_address'],
                $order['payment_method'],
                $order['card_holder'],
                $order['card_number'],
                $order['expiry_date'],
                $order['status']
            );

            $stmt->execute();
            $orderId = $conn->insert_id;

            $stmtItem = $conn->prepare("INSERT INTO order_items (order_id, outfit_title, price, quantity) VALUES (?, ?, ?, ?)");
            foreach ($items as $item) {
                $stmtItem->bind_param("isdi", $orderId, $item['outfit_title'], $item['price'], $item['quantity']);
                $stmtItem->execute();
            }

            $conn->commit();
            echo json_encode(["success" => true, "order_id" => $orderId]);
        } catch (Exception $e) {
            $conn->rollback();
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    default:
        echo json_encode(["error" => "Invalid action"]);
        break;
}

$conn->close();
?>