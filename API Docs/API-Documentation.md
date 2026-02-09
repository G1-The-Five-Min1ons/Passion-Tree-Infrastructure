# Passion Tree — API Documentation

> Base URL (Backend): `http://localhost:5000`
> Base URL (AI Service): `http://localhost:8000`

### Services

| Service | Port | Description |
| ------- | ---- | ----------- |
| **Go Backend** | `5000` | REST API หลัก (Authentication, Learning Path, Tree, etc.) |
| **AI Service (Python/FastAPI)** | `8000` | AI-powered features (Search Embedding, Sentiment Analysis, etc.) |

---

## สารบัญ (Table of Contents)

- [1. Backend & Service (Health Check)](#1-backend--service-health-check)
- [2. Authentication](#2-authentication)
- [3. Generator](#3-generator)
- [4. Learning Path](#4-learning-path)
- [5. Node](#5-node)
- [6. Reflection](#6-reflection)
- [7. Search](#7-search)
- [8. Tree](#8-tree)
- [9. Album](#9-album)

---

## 1. Backend & Service (Health Check)

### 1.1 GO Health Check

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/health`
- **Method:** `GET`
- **Description:** ตรวจสอบสถานะของ Backend Service (Go)

---

### 1.2 AI Service — Embed Text (Health Check)

- **Service:** AI Service (`port 8000`)
- **URL:** `/api/v1/search/embed`
- **Method:** `POST`
- **Description:** ตรวจสอบสถานะของ AI Service โดยทดสอบ embedding ข้อความ

**Request Body:**

```json
{
  "text": "Learn Python programming"
}
```

---

## 2. Authentication

### 2.1 Register

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/auth/register`
- **Method:** `POST`
- **Description:** สมัครสมาชิกผู้ใช้ใหม่

**Request Body:**

```json
{
  "username": "falros4",
  "password": "123456",
  "email": "thirapatth@gmail.com",
  "role": "student",
  "first_name": "Thiraphat",
  "last_name": "Panthong"
}
```

---

### 2.2 Re-send Verification Mail

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/auth/resend-verification`
- **Method:** `POST`
- **Description:** ส่งอีเมลยืนยันตัวตนอีกครั้ง

**Request Body:**

```json
{
  "email": "thirapatth@gmail.com"
}
```

---

### 2.3 Verify Email Code

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/auth/verify-email`
- **Method:** `POST`
- **Description:** ยืนยันอีเมลด้วยรหัส OTP

**Request Body:**

```json
{
  "code": "428900"
}
```

---

### 2.4 Login

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/auth/login`
- **Method:** `POST`
- **Description:** เข้าสู่ระบบด้วย email/username และรหัสผ่าน

**Request Body:**

```json
{
  "identifier": "test@example.com",
  "password": "testpass"
}
```

---

### 2.5 Forgot Password

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/auth/forgot-password`
- **Method:** `POST`
- **Description:** ขอรีเซ็ตรหัสผ่าน (ระบบจะส่ง OTP ไปยังอีเมล)

**Request Body:**

```json
{
  "email": "thirapatth@gmail.com"
}
```

---

### 2.6 Reset Password

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/auth/reset-password`
- **Method:** `POST`
- **Description:** ตั้งรหัสผ่านใหม่โดยใช้ OTP ที่ได้รับจากอีเมล

**Request Body:**

```json
{
  "email": "thirapatth@gmail.com",
  "code": "207077",
  "new_password": "123456"
}
```

---

### 2.7 Retrieve Profile

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/auth/profile`
- **Method:** `GET`
- **Description:** ดึงข้อมูลโปรไฟล์ของผู้ใช้ที่เข้าสู่ระบบ

**Headers:**

| Header          | Value              |
| --------------- | ------------------ |
| `Authorization` | `Bearer <token>`   |

---

### 2.8 Update Profile

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/auth/profile`
- **Method:** `PUT`
- **Description:** อัปเดตข้อมูลโปรไฟล์ผู้ใช้ (avatar, bio, location)

**Headers:**

| Header          | Value              |
| --------------- | ------------------ |
| `Authorization` | `Bearer <token>`   |
| `Content-Type`  | `application/json` |

**Request Body:**

```json
{
  "avatar_url": "https://example.com/my-photo.png",
  "bio": "Hello World, I love Coding!",
  "location": "Bangkok, Thailand"
}
```

---

### 2.9 Update User

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/auth/user`
- **Method:** `PUT`
- **Description:** อัปเดตข้อมูลพื้นฐานของผู้ใช้ (ชื่อ-นามสกุล)

**Headers:**

| Header          | Value              |
| --------------- | ------------------ |
| `Authorization` | `Bearer <token>`   |
| `Content-Type`  | `application/json` |

**Request Body:**

```json
{
  "first_name": "John",
  "last_name": "Doe"
}
```

---

### 2.10 Delete User

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/auth/user`
- **Method:** `DELETE`
- **Description:** ลบบัญชีผู้ใช้ (ต้องยืนยันด้วยรหัสผ่าน)

**Headers:**

| Header          | Value              |
| --------------- | ------------------ |
| `Authorization` | `Bearer <token>`   |
| `Content-Type`  | `application/json` |

**Request Body:**

```json
{
  "password": "testpass"
}
```

---

## 3. Generator

### 3.1 Generate Learning Path with AI

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/generate`
- **Method:** `POST`
- **Description:** สร้าง Learning Path อัตโนมัติจาก AI โดยระบุหัวข้อที่ต้องการเรียนรู้

**Request Body:**

```json
{
  "topic": "เรียนรู้พื้นฐานความปลอดภัยทางไซเบอร์ (Cybersecurity) ..."
}
```

---

## 4. Learning Path

### 4.1 Get All Learning Paths

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths`
- **Method:** `GET`
- **Description:** ดึงรายการ Learning Path ทั้งหมดของผู้ใช้

---

### 4.2 Get Learning Path Detail

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/:path_id`
- **Method:** `GET`
- **Description:** ดึงรายละเอียดของ Learning Path ตาม ID

**Path Parameters:**

| Parameter | Type   | Description            |
| --------- | ------ | ---------------------- |
| `path_id` | string | UUID ของ Learning Path |

---

### 4.3 Create Learning Path

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths`
- **Method:** `POST`
- **Description:** สร้าง Learning Path ใหม่

**Request Body:**

```json
{
  "title": "Mastering Microservices with Go",
  "objective": "เพื่อให้ผู้เรียนเข้าใจการออกแบบระบบ Microservices",
  "description": "เจาะลึกการใช้ Go, gRPC, และ Docker ในการทำระบบขนาดใหญ่",
  "cover_img_url": "https://storage.passiontree.com/covers/microservices-go.png",
  "publish_status": "draft",
  "creator_ID": "c88ef5c2-1176-48d7-8bce-dd4768669769"
}
```

---

### 4.4 Edit Learning Path

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/:path_id`
- **Method:** `PUT`
- **Description:** แก้ไขข้อมูล Learning Path

**Path Parameters:**

| Parameter | Type   | Description            |
| --------- | ------ | ---------------------- |
| `path_id` | string | UUID ของ Learning Path |

**Request Body:**

```json
{
  "publish_status": "published"
}
```

---

### 4.5 Delete Learning Path

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/:path_id`
- **Method:** `DELETE`
- **Description:** ลบ Learning Path ตาม ID

**Path Parameters:**

| Parameter | Type   | Description            |
| --------- | ------ | ---------------------- |
| `path_id` | string | UUID ของ Learning Path |

---

## 5. Node

### 5.1 Get All Node Questions

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/nodes/:node_id/questions`
- **Method:** `GET`
- **Description:** ดึงคำถามทั้งหมดภายใน Node

**Path Parameters:**

| Parameter | Type   | Description    |
| --------- | ------ | -------------- |
| `node_id` | string | UUID ของ Node  |

---

### 5.2 Create Node in Learning Path

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/:path_id/nodes`
- **Method:** `POST`
- **Description:** สร้าง Node ใหม่ภายใน Learning Path

**Path Parameters:**

| Parameter | Type   | Description            |
| --------- | ------ | ---------------------- |
| `path_id` | string | UUID ของ Learning Path |

**Request Body:**

```json
{
  "title": "Hello",
  "description": "Hello Test 123",
  "path_id": "e384bd20-5d3b-1247-b374-061175543c0c",
  "sequence": "1"
}
```

---

### 5.3 Add Material to Node

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/nodes/:node_id/materials`
- **Method:** `POST`
- **Description:** เพิ่ม Material (เอกสารประกอบ) ให้กับ Node

**Path Parameters:**

| Parameter | Type   | Description   |
| --------- | ------ | ------------- |
| `node_id` | string | UUID ของ Node |

---

### 5.4 Create Question in Node

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/nodes/:node_id/questions`
- **Method:** `POST`
- **Description:** สร้างคำถามใหม่ภายใน Node

**Path Parameters:**

| Parameter | Type   | Description   |
| --------- | ------ | ------------- |
| `node_id` | string | UUID ของ Node |

---

### 5.5 Create Choice for Question

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/questions/:question_id/choices`
- **Method:** `POST`
- **Description:** สร้างตัวเลือก (Choice) สำหรับคำถาม

**Path Parameters:**

| Parameter     | Type   | Description       |
| ------------- | ------ | ----------------- |
| `question_id` | string | UUID ของ Question |

---

### 5.6 Edit Node

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/nodes/:node_id`
- **Method:** `PUT`
- **Description:** แก้ไขข้อมูล Node

**Path Parameters:**

| Parameter | Type   | Description   |
| --------- | ------ | ------------- |
| `node_id` | string | UUID ของ Node |

---

### 5.7 Delete Node

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/nodes/:node_id`
- **Method:** `DELETE`
- **Description:** ลบ Node ออกจาก Learning Path

**Path Parameters:**

| Parameter | Type   | Description   |
| --------- | ------ | ------------- |
| `node_id` | string | UUID ของ Node |

---

### 5.8 Delete Material

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/nodes/materials/:material_id`
- **Method:** `DELETE`
- **Description:** ลบ Material ออกจาก Node

**Path Parameters:**

| Parameter     | Type   | Description       |
| ------------- | ------ | ----------------- |
| `material_id` | string | UUID ของ Material |

---

### 5.9 Delete Question

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/questions/:question_id`
- **Method:** `DELETE`
- **Description:** ลบคำถามออกจาก Node

**Path Parameters:**

| Parameter     | Type   | Description       |
| ------------- | ------ | ----------------- |
| `question_id` | string | UUID ของ Question |

---

### 5.10 Delete Choice

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/questions/choices/:choice_id`
- **Method:** `DELETE`
- **Description:** ลบตัวเลือก (Choice) ออกจากคำถาม

**Path Parameters:**

| Parameter   | Type   | Description     |
| ----------- | ------ | --------------- |
| `choice_id` | string | UUID ของ Choice |

---

### 5.11 Reorder Nodes

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/:path_id/nodes/reorder`
- **Method:** `PUT`
- **Description:** จัดเรียงลำดับ Node ใหม่ภายใน Learning Path

**Path Parameters:**

| Parameter | Type   | Description            |
| --------- | ------ | ---------------------- |
| `path_id` | string | UUID ของ Learning Path |

**Request Body:**

```json
{
  "node_ids": [
    "<node_id_1>",
    "<node_id_2>",
    "<node_id_3>"
  ]
}
```

---

### 5.12 Get Node by ID

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/nodes/:node_id`
- **Method:** `GET`
- **Description:** ดึงข้อมูล Node ตาม ID

**Path Parameters:**

| Parameter | Type   | Description   |
| --------- | ------ | ------------- |
| `node_id` | string | UUID ของ Node |

---

## 6. Reflection

### 6.1 Get All Reflections

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/reflections`
- **Method:** `GET`
- **Description:** ดึง Reflection ทั้งหมดของผู้ใช้

---

### 6.2 Get Reflection by ID

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/reflections/:reflection_id`
- **Method:** `GET`
- **Description:** ดึง Reflection ตาม ID

**Path Parameters:**

| Parameter       | Type   | Description        |
| --------------- | ------ | ------------------ |
| `reflection_id` | string | UUID ของ Reflection|

---

### 6.3 Sentiment Analysis (AI Service)

- **Service:** AI Service (`port 8000`)
- **URL:** `/api/v1/sentiment/analyze`
- **Method:** `POST`
- **Description:** วิเคราะห์ความรู้สึก (Sentiment) จากข้อความที่ผู้ใช้เขียนเกี่ยวกับการเรียนรู้

**Request Body:**

```json
{
  "what_learned": "Learn about function in Python and how to use it i have a little bit problem with functioncalling",
  "feelings_after_learning": "I feel very fun and confident after learning about function in Python"
}
```

---

### 6.4 Create Reflection

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/reflections`
- **Method:** `POST`
- **Description:** สร้าง Reflection ใหม่สำหรับบันทึกการเรียนรู้

**Request Body:**

```json
{
  "learned": "today i learn python and how to use the library",
  "feel_score": "8",
  "reflect": "this is so fun and i want to make my knowledge epandation",
  "progress_score": "7",
  "challenge_score": "3",
  "mood": "Fun",
  "tree_node_id": "bbbb2222-cc33-dd44-ee55-ffffffffffff"
}
```

---

## 7. Search

### 7.1 Debug Collection Info (AI Service)

- **Service:** AI Service (`port 8000`)
- **URL:** `/api/v1/search/debug/collection/learning_paths`
- **Method:** `GET`
- **Description:** ดึงข้อมูล Collection ของ Qdrant Vector Database สำหรับ Debug

---

### 7.2 Search Init

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/search/init`
- **Method:** `POST`
- **Description:** เริ่มต้น (Initialize) ระบบ Search

---

### 7.3 Search (No Filter)

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/search`
- **Method:** `POST`
- **Description:** ค้นหา Learning Path โดยไม่มีตัวกรอง

---

### 7.4 Search (With Filter)

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/search`
- **Method:** `POST`
- **Description:** ค้นหา Learning Path พร้อมตัวกรอง

**Request Body:**

```json
{}
```

> หมายเหตุ: สามารถเพิ่ม filter ต่าง ๆ ลงใน body ได้

---

### 7.5 Search Learning Path with Filters (GO)

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/search`
- **Method:** `POST`
- **Description:** ค้นหา Learning Path ผ่าน Go Backend พร้อม filter

**Request Body:**

```json
{
  "query": "machine learning",
  "filters": {
    "status": "published",
    "category": "AI"
  }
}
```

---

### 7.6 Search Learning Path (GO)

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/search`
- **Method:** `POST`
- **Description:** ค้นหา Learning Path ผ่าน Go Backend

---

### 7.7 Sync Single Learning Path

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/learningpaths/sync/:path_id`
- **Method:** `POST`
- **Description:** Sync ข้อมูล Learning Path เดียวเข้า Vector Database

**Path Parameters:**

| Parameter | Type   | Description            |
| --------- | ------ | ---------------------- |
| `path_id` | string | UUID ของ Learning Path |

---

### 7.8 Delete from Qdrant (AI Service)

- **Service:** AI Service (`port 8000`)
- **URL:** `/api/v1/search/sync/:id`
- **Method:** `DELETE`
- **Description:** ลบข้อมูลออกจาก Qdrant Vector Database

**Path Parameters:**

| Parameter | Type   | Description                  |
| --------- | ------ | ---------------------------- |
| `id`      | string | ID ของข้อมูลใน Qdrant       |

---

## 8. Tree

### 8.1 Create Tree

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/trees`
- **Method:** `POST`
- **Description:** สร้าง Tree ใหม่สำหรับติดตามความก้าวหน้าของ Learning Path

**Request Body:**

```json
{
  "title": "My Learning Tree",
  "difficulties": "Easy",
  "path_id": "e384bd20-5d3b-1247-b374-061175543c0c",
  "album_id": "6b97779d-05b4-9a41-a664-3303605a1282"
}
```

---

### 8.2 Update Tree

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/trees/:tree_id`
- **Method:** `PUT`
- **Description:** อัปเดตข้อมูล Tree

**Path Parameters:**

| Parameter | Type   | Description   |
| --------- | ------ | ------------- |
| `tree_id` | string | UUID ของ Tree |

**Request Body:**

```json
{
  "title": "Updated Tree Title",
  "status": "active",
  "is_pause": false
}
```

---

### 8.3 Get Tree

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/trees/:tree_id`
- **Method:** `GET`
- **Description:** ดึงข้อมูล Tree ตาม ID

**Path Parameters:**

| Parameter | Type   | Description   |
| --------- | ------ | ------------- |
| `tree_id` | string | UUID ของ Tree |

---

### 8.4 Get Trees by Album

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/trees`
- **Method:** `GET`
- **Description:** ดึง Tree ทั้งหมดภายใน Album

**Query Parameters:**

| Parameter  | Type   | Description    |
| ---------- | ------ | -------------- |
| `album_id` | string | UUID ของ Album |

---

### 8.5 Pause Tree

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/trees/:tree_id/pause`
- **Method:** `PATCH`
- **Description:** หยุด/เริ่มต้น Tree ชั่วคราว (Pause/Resume)

**Path Parameters:**

| Parameter | Type   | Description   |
| --------- | ------ | ------------- |
| `tree_id` | string | UUID ของ Tree |

**Request Body:**

```json
{
  "title": "Updated Tree Title",
  "status": "active",
  "is_pause": false
}
```

---

### 8.6 Create Tree Node

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/tree-nodes`
- **Method:** `POST`
- **Description:** สร้าง Tree Node ใหม่ (เชื่อมโยง Node จาก Learning Path กับ Tree)

**Request Body:**

```json
{
  "node_title": "Node Tree Title",
  "node_id": "bc0fd57e-e300-468d-9393-016c40c871e1",
  "tree_id": "b68492ba-e292-4f46-a51c-05c352e24708"
}
```

---

### 8.7 Get Tree Nodes by Tree ID

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/tree-nodes`
- **Method:** `GET`
- **Description:** ดึง Tree Node ทั้งหมดตาม Tree ID

**Query Parameters:**

| Parameter | Type   | Description   |
| --------- | ------ | ------------- |
| `tree_id` | string | UUID ของ Tree |

---

### 8.8 Get Tree Node by Tree Node ID

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/tree-nodes/:tree_node_id`
- **Method:** `GET`
- **Description:** ดึงข้อมูล Tree Node ตาม Tree Node ID

**Path Parameters:**

| Parameter      | Type   | Description        |
| -------------- | ------ | ------------------ |
| `tree_node_id` | string | UUID ของ Tree Node |

---

### 8.9 Update Tree Node

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/tree-nodes/:tree_node_id`
- **Method:** `PUT`
- **Description:** อัปเดตข้อมูล Tree Node

**Path Parameters:**

| Parameter      | Type   | Description        |
| -------------- | ------ | ------------------ |
| `tree_node_id` | string | UUID ของ Tree Node |

**Request Body:**

```json
{
  "node_title": "Updated Node Title",
  "node_score": null,
  "child_node": null
}
```

---

### 8.10 Delete Tree Node

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/tree-nodes/:tree_node_id`
- **Method:** `DELETE`
- **Description:** ลบ Tree Node

**Path Parameters:**

| Parameter      | Type   | Description        |
| -------------- | ------ | ------------------ |
| `tree_node_id` | string | UUID ของ Tree Node |

---

## 9. Album

### 9.1 Create Album

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/albums`
- **Method:** `POST`
- **Description:** สร้าง Album ใหม่สำหรับจัดกลุ่ม Tree

**Request Body:**

```json
{
  "user_id": "c2f58ec8-7611-d748-8bce-dd4768669769",
  "album_name": "Hello",
  "cover_image_url": ""
}
```

---

### 9.2 Get Albums

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/albums`
- **Method:** `GET`
- **Description:** ดึง Album ทั้งหมดของผู้ใช้

**Query Parameters:**

| Parameter | Type   | Description      |
| --------- | ------ | ---------------- |
| `user_id` | string | UUID ของ User    |

---

### 9.3 Delete Album

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/albums/:album_id`
- **Method:** `DELETE`
- **Description:** ลบ Album

**Path Parameters:**

| Parameter  | Type   | Description    |
| ---------- | ------ | -------------- |
| `album_id` | string | UUID ของ Album |

---

### 9.4 Update Album

- **Service:** Go Backend (`port 5000`)
- **URL:** `/api/v1/albums/:album_id`
- **Method:** `PUT`
- **Description:** อัปเดตข้อมูล Album

**Path Parameters:**

| Parameter  | Type   | Description    |
| ---------- | ------ | -------------- |
| `album_id` | string | UUID ของ Album |

**Request Body:**

```json
{
  "album_name": "Hello456",
  "cover_image_url": ""
}
```

---

> **หมายเหตุ:**
> - API ที่ต้องการ Authentication จะต้องส่ง Header `Authorization: Bearer <token>` มาด้วย
> - ค่า UUID ทั้งหมดเป็นตัวอย่าง ให้เปลี่ยนเป็นค่าจริงตอนใช้งาน
> - Base URL อาจเปลี่ยนแปลงได้ตาม Environment (development / production)
