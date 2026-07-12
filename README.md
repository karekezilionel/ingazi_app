# Ingazi

> Connect. Grow. Impact.

Ingazi is a mobile application that connects ALU students seeking internship experience with student-led startups and early-stage ventures within the ALU ecosystem.

---

##  Features

###  Authentication & Onboarding
- Role-based registration (Student, Startup, Admin)
- Secure login with Firebase Auth
- Real-time user data sync with Firestore

###  Student Features
- **Browse** - View all available opportunities with search and filters
- **Apply** - Submit applications with cover letter
- **Track** - View application status (Pending, Reviewing, Accepted, Rejected)
- **Save** - Bookmark opportunities for later
- **Profile** - Edit personal information

###  Startup Features
- **Dashboard** - View stats: posts, active, applications
- **Post** - Create new internship opportunities
- **Manage** - Edit, delete, close/reopen posts
- **Review** - View applicants, accept or reject

###  Admin Features
- **Verify** - Approve or reject startup registrations
- **Manage** - Delete rejected startups

###  Real-time Updates
- Instant sync with Firebase Firestore
- Push notifications for application status changes

---

##  Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| State Management | Riverpod |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| Storage | Firebase Storage |

---

##  Installation

### Prerequisites
- Flutter SDK (^3.12.2)
- Firebase account
- Android Studio / VS Code

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/karekezilionel/ingazi_app.git

# 2. Navigate to project
cd ingazi_app

# 3. Get dependencies
flutter pub get

# 4. Configure Firebase
flutterfire configure

# 5. Run the app
flutter run

```


```text
lib/
├── core/
│   ├── constants/       # App constants
│   ├── themes/          # Theme configuration
│   ├── utils/           # Validators, helpers
│   └── widgets/         # Reusable widgets
├── data/
│   ├── models/          # Data models
│   ├── repositories/    # Firebase operations
│   └── services/        # Firebase services
├── providers/           # Riverpod state management
└── presentation/
    ├── screens/         # All UI screens
    └── widgets/         # Screen-specific widgets
```
```
    ### DEMO CREDENTIALS for the Admin
    
    Admin	admin@ingazi.com	Admin123!
    

    
