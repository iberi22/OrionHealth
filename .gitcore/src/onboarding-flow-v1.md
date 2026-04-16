# Onboarding Flow v1

The OrionHealth onboarding process is designed to be concise yet comprehensive, ensuring all essential health data is captured while maintaining user privacy.

## 🚶 Step-by-Step Guide

### 1. Welcome Screen
- Explains the "Privacy-First" mission.
- Informs the user that all data remains on-device.

### 2. Basic Profile
- Captures name, age, height, and weight.
- Generates a unique "Digital Health Identity".

### 3. Vital Signs
- Records baseline Blood Pressure and Heart Rate.
- Explains why these metrics are important for AI analysis.

### 4. Allergies
- Prompts for known allergies and their severity.
- Critical for future medication safety checks.

### 5. Completion
- Summarizes the profile.
- Redirects to the Main Navigation shell.

## 🛠️ Implementation Details
- Managed by `OnboardingMainPage` in `lib/features/onboarding/`. (Note: Directory to be formalized).
- Uses a `PageView` for smooth transitions.
- Persists data to the `UserProfile` Isar collection.
