### 3.2 Functional Requirements



The following requirements are mapped to the feature catalog and follow the Clean Architecture hierarchy.



| ID | Feature | Layer | Description |

|---|---|---|---|

| **REQ-F-001** | **Auth & Biometrics** | Presentation | Secure user authentication including biometric (fingerprint/face) login and PIN setup. |

| **REQ-F-002** | **User Profile** | Presentation | Management of personal health profile, basic information, and preferences. |

| **REQ-F-003** | **Dashboard** | Presentation | Centralized overview of health status, upcoming appointments, and daily summaries. |

| **REQ-F-004** | **Health Records** | Domain | Comprehensive management of medical history, clinical documents, and FHIR resources. |

| **REQ-F-005** | **Vitals Monitor** | Presentation | Tracking and visualization of vital signs like heart rate, blood pressure, and oxygen levels. |

| **REQ-F-006** | **Medications** | Domain | Tracking of prescribed medications, dosages, and adherence schedules. |

| **REQ-F-007** | **Appointments** | Application | Scheduling and management of medical appointments and follow-ups. |

| **REQ-F-008** | **Reports & Analytics** | Presentation | Visual representation of health trends and generated health reports. |

| **REQ-F-009** | **Medical Standards** | Domain | Integration and mapping of medical terminologies (ICD-10, LOINC, RxNorm, SNOMED). |

| **REQ-F-010** | **Doctor Verification** | Application | System for verifying medical credentials and professional status of healthcare providers. |

| **REQ-F-011** | **Voice Chat** | Presentation | On-device AI-powered voice assistant for hands-free interaction. |

| **REQ-F-012** | **Local Agent** | Infrastructure | Personalized local AI agent that learns from user data while maintaining privacy. |

| **REQ-F-013** | **Network Sync** | Infrastructure | Infrastructure for peer-to-peer data synchronization across devices. |

| **REQ-F-014** | **Allergies** | Domain | Management and tracking of known allergies and adverse reactions. |

| **REQ-F-015** | **Calendar Import** | Presentation | Integration with external calendar providers (Gmail, Outlook) to import medical appointments. |

| **REQ-F-016** | **Health Sharing** | Application | Secure sharing of health data with trusted individuals or providers via P2P. |

| **REQ-F-017** | **Governance** | Application | Mechanisms for network participation, decision-making, and policy updates. |

| **REQ-F-018** | **Incentives & Rewards** | Presentation | Gamification and reward system for healthy habits and network contributions. |

| **REQ-F-019** | **Meditation** | Presentation | Guided offline meditation and breathing exercises for mental well-being. |

| **REQ-F-020** | **Settings** | Presentation | Application configuration, privacy controls, and theme management. |

| **REQ-F-021** | **Sync Service** | Infrastructure | Background service orchestrating data consistency across multiple platforms. |

| **REQ-F-022** | **Emergency Data** | Domain | Critical health information accessible in case of emergency (Medical ID). |

| **REQ-F-023** | **Scraping Config** | Application | Configuration and adapters for retrieving medical information from various research sources. |

| **REQ-F-024** | **Proposals** | Presentation | Interface for submitting and voting on network improvement proposals. |

| **REQ-F-025** | **Data Sources** | Infrastructure | Integration layer for diverse health data inputs (sensors, files, external APIs). |



