# Software Requirements Specification (SRS) - OrionHealth

## 1. Introduction
OrionHealth is a privacy-first, local-first personal health assistant.

## 2. Functional Requirements

### REQ-F-012: Local AI Agent (local_agent)
The system shall provide an on-device AI agent to assist users with health-related queries and data analysis without requiring an internet connection.

#### 2.1. Model Architecture
- **Models:** Support for Gemma 2B and Phi-3 Mini.
- **Runtime:** Inference powered by ONNX Runtime for cross-platform compatibility and efficiency.
- **Inference Strategy:** 100% on-device execution.

#### 2.2. Privacy and Security
- **Data Locality:** All processing occurs locally on the user's device.
- **Zero Cloud Leakage:** No health data, prompts, or model outputs are sent to external servers or cloud providers.
- **Encryption:** Model weights and local memory stores are protected using device-level encryption.

#### 2.3. Capabilities
- **Symptom Analysis:** Preliminary analysis of user-reported symptoms based on local medical standards (ICD-10, SNOMED).
- **Health Suggestions:** Grounded suggestions for next steps, such as consulting specific specialists or monitoring vitals.
- **Voice Processing:** Integration with local ASR (Speech-to-Text) and TTS (Text-to-Speech) for hands-free interaction.
- **Medical Grounding:** RAG (Retrieval-Augmented Generation) using local medical standards and the user's health history.

#### 2.4. Constraints and Restrictions
- **Hardware Requirements:** Requires a minimum of 4GB RAM for Gemma 2B and 8GB RAM for E4B variants for optimal performance.
- **Storage:** Approximately 1.2GB to 2.5GB of local storage required for model weights.
- **Battery Impact:** High computational load during inference may impact battery life on mobile devices.
- **No Diagnosis:** The agent is an educational tool and shall never provide a formal medical diagnosis.
