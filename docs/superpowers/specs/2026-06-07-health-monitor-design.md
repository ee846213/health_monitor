# Health Monitor App Design

Date: 2026-06-07
Status: Draft for review

## 1. Product Summary

Health Monitor is a mobile health assistant focused on passive sensing. The product uses built-in phone sensors and low-friction device signals to infer daily movement, posture-related phone habits, digital lifestyle patterns, and environmental context without requiring extra hardware or heavy manual logging.

The first release is designed to validate one core hypothesis:

Users will keep a health assistant installed and enabled if it can produce useful, credible, low-interruption health insights from passive phone data alone.

The product is aimed at two initial audiences:

- Urban desk workers who want help with sedentary behavior, low activity, and neck or shoulder strain but do not want to log data manually.
- Mildly health-anxious users who want lightweight awareness of daily patterns and healthier routines without buying wearables.

## 2. Product Goals

The MVP should achieve the following:

- Passively detect a small, stable set of high-value daily behaviors.
- Translate raw sensing into simple, explainable health insights.
- Generate lightweight, actionable suggestions rather than medical conclusions.
- Create enough daily value that users return to view summaries and keep permissions enabled.

The MVP will not try to:

- Provide medical diagnosis.
- Infer mental health conditions or emotional state.
- Depend on external hardware such as watches or rings.
- Build a social, community, or habit-gamification system.
- Rely on large cloud models for core product logic.

## 3. MVP Scope

The MVP follows a unified minimum-capability approach across both iPhone and Android. Product outputs should remain consistent across platforms even if the underlying data access differs.

### Included in MVP

- Passive activity detection for walking, running, static periods, and sedentary behavior.
- Screen and digital lifestyle analysis for phone checking frequency, usage periods, and app-category preferences.
- Posture-related phone use risk detection, including prolonged head-down phone use, prolonged holding sessions, and probable lying-down phone use.
- Risk behavior detection for probable phone use while moving.
- Low-frequency context analysis for commute distance and outdoor activity time.
- Environmental noise level analysis without storing raw audio.
- Daily summaries, low-interruption reminders, and explainable rule-based suggestions.

### Explicitly Excluded from MVP

- Sleep-stage detection.
- Stress or recovery scoring.
- Heart-rate, blood oxygen, or other biometric sensing.
- Detailed social-activity inference from microphone data.
- Uploading raw audio, raw sensor streams, or replayable fine-grained movement traces.
- Medical claims about cervical spine, lumbar spine, anxiety, or sleep disorders.

## 4. Core Product Loop

The product loop is:

Passive sensing -> state recognition -> daily metric aggregation -> rule evaluation -> summary and reminders

The product experience should feel low effort and low pressure. The app should not overwhelm users with dashboards or highly technical sensor interpretations. It should convert sensing into a small set of understandable outputs and suggestions.

## 5. Core User Outputs

The first release should revolve around three user-facing outputs:

### 5.1 Today Overview

The home screen answers: how am I doing today?

It should include:

- A one-line daily status summary.
- Three core metrics: step count, sedentary duration, and screen usage duration.
- Secondary insight cards such as outdoor activity time, commute distance, noise overview, risky phone-while-moving events, and posture-risk summary.
- One or two recommended actions only.

### 5.2 Daily Health Brief

The daily brief should summarize the previous day with:

- Date and overall summary.
- Step count, sedentary duration, and screen usage duration.
- Activity pattern summary across the day.
- Digital lifestyle summary.
- Posture habit summary.
- Environment and mobility summary.
- One high-priority suggestion for tomorrow.

### 5.3 Reminder History

This screen exists to build trust by showing:

- What reminders fired.
- Why each reminder was triggered.
- Whether the user acted on or dismissed it.
- Simple reminder intensity and quiet-hours controls.

## 6. Sensing and Inference Scope

### 6.1 Movement and Posture-Related Sensing

Use accelerometer and gyroscope signals to infer:

- Walking
- Running
- Static periods
- Sedentary periods
- Motion plus active-screen combinations that indicate probable phone use while moving
- Device-angle patterns that indicate prolonged head-down use
- Extended holding sessions with limited posture variation
- Probable lying-down or reclined phone-use sessions

This layer should be framed as posture-risk and usage-pattern detection, not full-body posture diagnosis.

### 6.2 Location and Environment Sensing

Use low-frequency GPS and available context signals to infer:

- Commute distance
- Outdoor activity duration
- Daily movement radius

Use microphone analysis only for non-content environmental noise estimation:

- Quiet environment
- Moderate noise
- Sustained noisy environment

No raw audio should be stored or uploaded. No speech recognition or content interpretation should occur in the MVP.

### 6.3 Digital Lifestyle Sensing

Use phone interaction signals to infer:

- Phone check frequency
- Concentrated late-night usage
- High fragmentation during work or daytime blocks
- App-category preference patterns such as social, video, reading, tools, and productivity

The MVP should prioritize category-level habits over exposing highly detailed app-by-app surveillance views.

## 7. Core Metrics

The primary metrics in the MVP are:

- Step count
- Sedentary duration
- Screen usage duration

The secondary metrics are:

- Outdoor activity duration
- Commute distance
- Noise environment overview
- Phone check frequency
- Late-night usage duration
- Mobile-use risk event count
- Prolonged head-down usage duration
- Long uninterrupted phone-use sessions

These metrics should be expressed in user-friendly terms and not in raw sensor units.

## 8. Functional Modules

### 8.1 Passive Collection Layer

Collect the minimum required device signals from:

- Accelerometer
- Gyroscope
- Screen state and usage signals
- GPS
- Barometer where available
- Microphone for non-content noise level analysis

Collection should be low-frequency and scene-aware wherever possible to protect battery life.

### 8.2 State Recognition Layer

Convert raw device signals into interpretable states such as:

- Walking
- Running
- Static
- Sedentary
- Probable phone use while moving
- Outdoor period
- Commute period
- Quiet environment
- Noisy environment
- Head-down usage pattern
- Lying-down usage pattern
- Long continuous phone-use session

### 8.3 Daily Aggregation Layer

Aggregate state slices into daily metrics, time windows, patterns, and event counts.

### 8.4 Rule Engine

Use explainable rules to generate reminders and recommendations.

### 8.5 Presentation Layer

Render the home view, daily brief, reminder history, permission education, and settings.

## 9. Rule Engine Design

The MVP should use a deterministic rule engine rather than opaque scoring models.

### 9.1 Activity Rules

- If uninterrupted sedentary time exceeds a threshold, trigger a movement reminder.
- If total daily steps remain below a target by late afternoon or evening, trigger a light activity suggestion.

### 9.2 Risk Behavior Rules

- If the user appears to be moving while actively viewing the screen, trigger a safety reminder.

### 9.3 Environment Rules

- If nighttime environmental noise remains elevated for a sustained period, surface a sleep-environment suggestion.
- If outdoor activity is very low, suggest a short outdoor break.

### 9.4 Digital Lifestyle Rules

- If phone checking frequency is unusually high, suggest reducing fragmented checking.
- If late-night screen usage exceeds a threshold, suggest a lower-stimulation wind-down period.
- If certain daily blocks show heavy repeated phone activation, surface a routine-awareness suggestion.

### 9.5 Posture-Risk Rules

- If head-down phone use remains prolonged, suggest lifting the device and relaxing neck and shoulders.
- If a continuous phone-use session becomes too long, suggest an eye and posture break.
- If lying-down phone use is prolonged at night, suggest ending screen use earlier.

All triggered outputs should remain explainable in plain language.

## 10. Experience Principles

The front-end language should remain everyday and supportive, not clinical or sensor-centric.

The product should say:

- You have been sitting for a while this afternoon.
- You checked your phone frequently tonight.
- Your nighttime environment was noisier than usual.
- Your head-down phone use was high today.

The product should avoid saying:

- Accelerometer variance indicates abnormal posture.
- Audio threshold exceeded environmental baseline.
- Cervical risk score is elevated.

The app should feel like a transparent assistant, not a surveillance or diagnostic tool.

## 11. Privacy and Trust Strategy

The MVP must treat privacy as a product feature.

### 11.1 Principles

- Local-first processing for raw sensor interpretation wherever feasible.
- Minimum necessary data collection.
- No raw-audio storage.
- No replayable raw sensor history uploaded by default.
- Clear explanation of why each permission is requested.
- Graceful degradation when users deny optional permissions.

### 11.2 Permission Strategy

Permissions should be requested progressively, not all at once.

Recommended sequence:

- Onboarding requests core activity and notification permissions first.
- Location permission is requested only when mobility or outdoor insights are introduced.
- Microphone permission is requested only when environment-noise insight is introduced.
- Screen-usage or equivalent digital-lifestyle permissions are requested only when digital habit insights are introduced.

Each permission prompt should explain:

- What feature it enables
- What data is or is not stored
- What the user loses if they decline

## 12. Cross-Platform Strategy

The MVP should use a unified product definition with platform adapters.

### 12.1 Unified Product Layer

Both platforms should present the same top-level metrics, summary structure, and reminder categories.

### 12.2 Platform Adaptation Layer

Android and iPhone may use different APIs, sampling models, and permission flows. Those differences should be normalized into a shared state model before they reach the product layer.

The user should not feel that the app is fundamentally different on each platform.

## 13. Technical Architecture Direction

The recommended structure is:

### 13.1 Shared Client Experience Layer

Shared UI, navigation, summary rendering, rule presentation, settings, and product logic where feasible.

### 13.2 Native Sensing Adapter Layer

Platform-specific code that:

- Reads device signals
- Handles permissions
- Applies platform-specific background collection strategies
- Normalizes data into common event and state models

### 13.3 On-Device Processing Layer

Performs:

- Sensor preprocessing
- State recognition
- Daily aggregation
- Rule evaluation

This layer should remain on device for the MVP wherever possible.

### 13.4 Lightweight Backend

The backend should be limited to:

- Authentication if needed
- User preferences and settings sync
- Daily brief backup and retrieval
- Future experimentation hooks

The backend should not be required for core daily inference in the MVP.

## 14. Success Criteria for MVP

The MVP is successful if it can demonstrate:

- Users understand the value of passive health sensing without extra hardware.
- Users keep core permissions enabled after onboarding.
- Users read daily summaries repeatedly.
- Users find reminders helpful rather than intrusive.
- Users perceive the insights as understandable and credible.

## 15. Risks and Mitigations

### 15.1 Privacy Concern

Risk:
Users may fear the product is over-collecting, especially with microphone and location.

Mitigation:
Use local-first processing, progressive permission prompts, plain-language explanations, and explicit statements that raw audio is not stored.

### 15.2 Battery Drain

Risk:
Passive sensing may create unacceptable battery cost.

Mitigation:
Use minimum viable sampling, scene-based activation, and conservative background collection.

### 15.3 Overclaiming

Risk:
Users may interpret behavior suggestions as medical judgment.

Mitigation:
Frame outputs as habits, patterns, and risk tendencies, not diagnosis.

### 15.4 Cross-Platform Inconsistency

Risk:
Different platform limits may create divergent experiences.

Mitigation:
Keep the MVP capability set intentionally small and normalize platform outputs into the same product vocabulary.

## 16. Recommended Next Step

The next phase should convert this design into an implementation plan covering:

- Product milestones
- Feature breakdown
- Data model design
- Cross-platform architecture choices
- Permission and onboarding flow
- Measurement and QA strategy
