# SRC.md — Sistema de Onboarding OrionHealth

> **Versión:** 1.0.0  
> **Fecha:** 2026-04-15  
> **Estado:** Implementado  
> **Autor:** SWAL Agent System

---

## 1. Concepto & Visión

Sistema de onboarding que guía al usuario a través de la configuración inicial de su perfil de salud en OrionHealth. Diseñado para ser:

- **Intuitivo:** Flujo lineal de 7 pasos sin opciones confusas
- **Seguro:** Validación de datos en cada paso
- **Personalizado:** Recopila información relevante para el AI médico
- **Privacy-first:** Consentimiento explícito antes de cualquier sincronización

El usuario debe sentir que OrionHealth "entiende" su situación de salud desde el primer uso.

---

## 2. Design Language

### Aesthetic Direction
Medical-tech moderno con colores que transmiten confianza y profesionalismo médico. Inspirado en apps de salud como Apple Health y Google Fit.

### Color Palette
```
Primary:        #00897B (Teal 600) — Confianza médica
Secondary:      #26A69A (Teal 400) — Acentos positivos
Accent:         #00BFA5 (Teal A700) — CTAs
Background:     #FAFAFA (Grey 50) — Fondo limpio
Surface:        #FFFFFF — Cards
Error:          #E53935 (Red 600) — Validación
Success:        #43A047 (Green 600) — Confirmación
Text Primary:   #212121 (Grey 900)
Text Secondary: #757575 (Grey 600)
```

### Typography
```
Headlines:  Roboto Bold, 24-32sp
Body:       Roboto Regular, 16sp
Captions:   Roboto Light, 14sp
Buttons:    Roboto Medium, 14sp (uppercase)
```

### Spatial System
- Padding base: 16dp
- Card elevation: 2dp
- Border radius: 12dp
- Touch targets: mínimo 48dp

### Motion Philosophy
- Transiciones suaves entre páginas (300ms ease-in-out)
- Indicador de progreso animado
- Feedback táctil en selections
- Sin animaciones excesivas (profesionalismo médico)

---

## 3. Layout & Structure

### Flujo de 7 Páginas

```
┌─────────────────────────────────────────────────────┐
│  ONBOARDING FLOW                                    │
├─────────────────────────────────────────────────────┤
│                                                      │
│  [1] Welcome        → Idioma + Bienvenida          │
│       ↓                                          │
│  [2] Basic Info     → Nombre, Edad, Sexo          │
│       ↓                                          │
│  [3] Conditions     → Condiciones médicas          │
│       ↓                                          │
│  [4] Family History → Antecedentes familiares      │
│       ↓                                          │
│  [5] Medications    → Medicamentos actuales        │
│       ↓                                          │
│  [6] Privacy        → Consentimiento + Wallet     │
│       ↓                                          │
│  [7] Complete       → AI Introduction + Ready      │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### Responsive Strategy
- Mobile-first (360dp+)
- Tablet:Centrado con max-width 600dp
- Desktop: Modal dialog con max-width 480dp

---

## 4. Features & Interactions

### Page 1: Welcome
- Logo + tagline
- Language selector (20 idiomas)
- Botón "Comenzar"
- Link "Omitir" (para usuarios avanzados)

### Page 2: Basic Info
- TextField: Nombre completo (requerido)
- Dropdown: Fecha de nacimiento
- SegmentedButton: Sexo (M/F/O)
- Touch spin: Peso (kg)
- Touch spin: Altura (cm)

### Page 3: Conditions
- Chip grid: Condiciones predefinidas
  - Diabetes Tipo 1, Tipo 2
  - Hipertensión
  - Asma
  - Enfermedad cardíaca
  - Artritis
  - Tiroides
  - Depresión/Ansiedad
  - Cancer (con subcategorías)
  - Otras (text input)
- Búsqueda inteligente

### Page 4: Family History
- Similar a Conditions
- Mapeo automático a riesgo cardiovascular

### Page 5: Medications
- Text input con autocomplete
- Drug class suggestions (usando RxNorm)
- Pill Reminder setup opcional

### Page 6: Privacy & Wallet
- Resumen de datos a almacenar
- Checkbox: Términos y condiciones
- Checkbox: Consentimiento de datos
- PIN setup (4-6 dígitos)
- Biometric enrollment
- Google Sign-In (opcional)

### Page 7: Complete
- Celebración visual (checkmark animado)
- Resumen del perfil creado
- AI Assistant introduction
- "Comenzar" → Home

---

## 5. Component Inventory

### OnboardingPage (base)
- States: active, completed, disabled
- Page indicator dots
- Navigation buttons (Back/Next)

### ProfileForm
- Validation: real-time + on-submit
- Error states: red border + message
- Loading: circular progress

### ConditionChip
- States: unselected, selected, disabled
- Tap: toggle selection
- Long press: info tooltip

### PrivacyConsent
- Checkbox with link to full text
- Grayed until scrolled

### ProgressIndicator
- Horizontal stepper
- Animated transitions

---

## 6. Technical Approach

### Architecture
- **State Management:** flutter_bloc (OnboardingCubit)
- **Navigation:** Navigator 2.0 con GoRouter
- **Storage:** SharedPreferences (flags) + Isar (encrypted profile)
- **Validation:** Form validation con validators

### Key Dependencies
```yaml
flutter_bloc: ^8.1.0
go_router: ^14.0.0
shared_preferences: ^2.2.0
isar: ^3.1.0
medical_standards: ^1.0.0
```

### Data Model
```dart
class UserProfile {
  String id;
  String name;
  DateTime? birthDate;
  String sex; // M, F, O
  double? weightKg;
  double? heightCm;
  List<String> conditions;
  List<String> familyHistory;
  List<String> medications;
  bool privacyConsent;
  DateTime createdAt;
  int onboardingStep;
}
```

### Selective Sync Trigger
Post-onboarding, `SelectiveSyncService.syncRelevantContext()` descarga solo los estándares médicos relevantes al perfil usando `ProfileAnalyzer`.

---

## 7. Testing

### E2E Tests
`integration_test/onboarding_e2e_test.dart`
- Test flujo completo happy path
- Test navegación forward/back
- Test validación campos requeridos
- Test selección múltiple de condiciones

### Unit Tests
- OnboardingCubit state transitions
- ProfileAnalyzer correct category selection
- Form validators

---

## 8. Metrics

### Success Criteria
- Tasa de completación: >80%
- Tiempo promedio: <5 minutos
- Error rate: <5%
- Onboarding abandon rate: <20%

### Tracking Events
- `onboarding_started`
- `onboarding_page_viewed` (por página)
- `onboarding_page_completed` (por página)
- `onboarding_abandoned` (con step)
- `onboarding_completed`

---

## 9. Roadmap

| Fase | Feature | Status |
|------|---------|--------|
| 1 | 7-page basic flow | ✅ |
| 2 | Selective sync integration | 🔄 |
| 3 | Voice input for conditions | 📋 |
| 4 | QR code data import | 📋 |
| 5 | Insurance card scan | 📋 |
| 6 | Family account linking | 📋 |

---

## 10. Decisions

| Decisión | Alternativas | Justificación |
|----------|--------------|--------------|
| Linear flow | Ramified paths | Simplicidad > flexibilidad |
| PIN requerido | Optional | Security-first |
| 20 idiomas | <10 idiomas | Alcance global desde día 1 |
| No skip | Skip allowed | Data quality |
