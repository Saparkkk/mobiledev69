# 🏠 House Builder - แอปพลิเคชันจัดการแบบบ้านและการนัดหมาย

แอปพลิเคชันสำหรับลูกค้าที่ต้องการสร้างบ้าน เพื่อใช้ในการค้นหาและดูรายละเอียดแบบบ้านต่างๆ พร้อมระบบจัดการคิวการนัดหมายกับผู้รับเหมาโดยตรง แก้ปัญหาความยุ่งยากในการติดต่อและจัดเก็บข้อมูลการนัดหมาย ลดความผิดพลาดในการสื่อสารระหว่างผู้สร้างและผู้รับเหมา

## ✨ Features

- ล็อกอินและล็อกเอาต์ผ่านระบบ OIDC (django-oidc-provider)
- แสดงรายการแบบบ้าน ค้นหา และกรองข้อมูลแบบเรียลไทม์
- ระบบนัดหมาย (CRUD): สร้าง (Create), ดูรายการ (Read), แก้ไข (Update) และลบการนัดหมาย (Delete)
- **🌟 Extra Feature:** 
- Real-time filtering & sorting: ระบบค้นหาและกรองข้อมูลแบบบ้านที่แสดงผลทันทีแบบเรียลไทม์

## 🛠 Tech Stack

- **Frontend:** Flutter
- **Backend:** Django
- **Authentication:** django-oidc-provider
- **Package Manager (Python):** uv

## 📦 Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Python 3.10+](https://www.python.org/downloads/)
- [uv](https://docs.astral.sh/uv/)
- [Git](https://git-scm.com/downloads)
- Google Chrome

## 🚀 How to Run

### Terminal 1 - Backend (OIDC Server & API)

```bash
cd backend
uv sync
uv run manage.py migrate
uv run manage.py runserver
```

### Terminal 2 - Flutter Web App

เปิด Terminal ใหม่ที่โฟลเดอร์ root ของโปรเจกต์ Flutter

```bash
flutter pub get
flutter run -d chrome --web-port 50000
```

## 🔐 Demo Account

- **Username:** `student01`
- **Password:** `test1234`

## 📸 Screenshots

**1. หน้าจอหลักและระบบค้นหาแบบบ้าน**
![หน้าจอรายการแบบบ้าน](path/to/image_4fc79d.png)

**2. ระบบจัดการการนัดหมาย (CRUD - สร้าง, อ่าน, แก้ไข, ลบ)**
![หน้าจอการนัดหมายของฉัน](path/to/image_4fc818.png)

## 🎥 Demo Video

[YouTube link - unlisted](https://youtube.com/your-video-link)