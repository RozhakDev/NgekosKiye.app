# NgekostKiye.app

## Deskripsi Proyek

NgekostKiye.app merupakan aplikasi mobile marketplace kost berbasis Flutter yang dirancang untuk membantu tenant mencari, melihat detail, dan melakukan pemesanan kamar kost secara online. Aplikasi ini terintegrasi dengan backend Django REST API untuk mendukung autentikasi, pengelolaan data kost, transaksi booking, serta upload bukti pembayaran.

Proyek ini dikembangkan dengan pendekatan Clean Architecture dan fokus pada pengalaman pengguna yang minimalis, modern, serta responsif pada perangkat Android dan iOS.

## Fitur Utama

* Autentikasi pengguna menggunakan JWT dan OTP Verification.
* Pencarian dan katalog kost berbasis lokasi.
* Detail kost lengkap dengan fasilitas dan galeri gambar.
* Booking kamar secara online.
* Upload bukti pembayaran.
* Riwayat transaksi tenant.
* Integrasi maps dan geolocation.
* Push notification menggunakan Firebase Cloud Messaging.

## Teknologi yang Digunakan

### Mobile

* Flutter
* Dart
* Riverpod
* Dio
* Go Router
* Flutter Secure Storage
* Google Maps Flutter
* Firebase Messaging

### Backend

* Django REST Framework
* JWT Authentication
* MySQL / SQLite

## Struktur Proyek

```bash
lib/
├── core/
├── features/
│   ├── auth/
│   ├── kost/
│   ├── booking/
│   └── profile/
└── main.dart
```

## Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/RozhakDev/NgekosKiye.app.git
cd NgekosKiye.app
```

### 2. Install Dependency

```bash
flutter pub get
```

### 3. Jalankan Aplikasi

```bash
flutter run
```

## Konfigurasi Environment

Buat file `.env` atau konfigurasi endpoint API pada project Flutter sesuai kebutuhan.

Contoh:

```env
BASE_URL=https://your-api-domain.com/api/v1
```

## Arsitektur Aplikasi

Aplikasi menggunakan pendekatan Feature-First Clean Architecture agar struktur kode tetap modular, scalable, dan mudah untuk maintenance.

Layer utama:

* Presentation Layer
* Domain Layer
* Data Layer

## API Endpoint Utama

### Autentikasi

* `POST /users/auth/register/`
* `POST /users/auth/login/`
* `POST /users/auth/verify-otp/`

### Kost dan Kamar

* `GET /kosts/`
* `GET /kosts/{id}/`
* `GET /rooms/`

### Booking

* `POST /bookings/`
* `POST /bookings/{id}/upload_payment/`

## Target Platform

* Android
* iOS

## Tujuan Pengembangan

NgekostKiye.app dikembangkan sebagai implementasi proyek mobile application pada mata kuliah Aplikasi Berbasis Platform dengan fokus pada integrasi REST API, networking, authentication, maps, dan fitur transaksi mobile.

## Lisensi

Project ini menggunakan lisensi MIT. Seluruh kode dan pengembangan dapat digunakan untuk kebutuhan pembelajaran dan pengembangan lanjutan.