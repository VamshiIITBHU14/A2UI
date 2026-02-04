## License

A2UI is licensed under the Apache License, Version 2.0.

https://github.com/user-attachments/assets/1650891b-1ec3-4bc9-a7b3-b69bb9d57b3b

# A2UI Field Mini-Apps (iOS)  
**Agent-to-UI for the Enterprise Edge**

> _What if enterprise software stopped forcing humans to learn UIs —  
and instead generated the right UI at the moment work happens?_

---

## TL;DR

**A2UI Field Mini-Apps** is an iOS-first proof of concept for **Agent-to-UI (A2UI)** — a new interaction model where:

- A user describes what happened (text or voice)
- An agent infers the task
- A **task-specific native UI is generated on demand**
- The user confirms or edits
- A **clean, validated enterprise record** is produced

No prebuilt forms.  
No legacy UI exposure.  
No brittle automation.

This repo proves the hardest part: **dynamic, native UI generation that enterprises can trust.**

---

## The Problem

Large enterprises still run on systems like **SAP, Oracle, Salesforce**, etc.

These systems are:
- Desktop-first
- Menu-heavy
- Painful on mobile
- Hostile to field workers

As a result:
- Data entry is delayed
- Records are incomplete or wrong
- Compliance relies on memory, not systems
- Frontline teams avoid software whenever possible

> The real issue isn’t data capture —  
> **it’s forcing humans to navigate software instead of describing reality.**

---

## The Insight

Most enterprise work already looks like this:

1. Something happens in the real world  
2. A human understands what matters  
3. The software still forces them through irrelevant UI  

**A2UI flips the model.**

Instead of:
> “Find the right screen and fill the form”

We do:
> “Describe what happened — we’ll generate the right UI”

UI becomes a **temporary artifact**, not a permanent product surface.

---

## What This Demo Shows (End-to-End)

### Scenario: Warehouse Incident Reporting

A worker types (or speaks):

> **“Broken pallet in aisle 4, leaking, urgent”**

That’s the only instruction.

### What happens next:

#### 1️⃣ Task Inference  
An agent:
- Infers the task type (`warehouse_incident`)
- Extracts signals (location, hazard, urgency)
- Decides **what information is required**

#### 2️⃣ A2UI Generation  
A **native SwiftUI form** is generated at runtime containing only:
- Photo (required)
- Severity
- Location (pre-filled)
- Timestamp
- Hazard toggle
- Notes

This UI **did not exist before the prompt** and will not exist afterward.

#### 3️⃣ Human-in-the-loop Confirmation  
- Defaults are pre-seeded
- Required fields are validated
- The user can correct the agent

AI never submits data directly.

#### 4️⃣ Deterministic Execution  
- A validated payload is produced
- Written as a clean JSON record
- Enterprise-ready (SAP / Oracle / middleware shape)

---

## Why This Is Not a Form Builder

| Traditional Forms | A2UI |
|------------------|------|
| Designed upfront | Generated at runtime |
| Generic | Task-specific |
| Menu-driven | Intent-driven |
| Static | Context-aware |
| UI-first | Reality-first |

This is **UI as a by-product of intent**, not a product artifact.

---

## Why Enterprises Can Trust This

The architecture enforces a hard boundary:

### ❌ AI does NOT:
- Execute side effects
- Write to systems
- Skip validation
- Persist records

### ✅ AI ONLY:
- Infers intent
- Proposes UI schemas

### ✅ Deterministic code:
- Renders UI
- Validates required fields
- Executes submissions
- Produces records

> **If the agent is wrong, the human corrects it before anything irreversible happens.**

This is the safety model enterprises require.

---

## Why Mobile Is the Wedge

- Work happens at the edge (field, floor, bedside)
- Mobile is where friction is highest
- Legacy UIs do not translate to small screens

iOS provides:
- Strong native controls
- Offline capability
- Secure sandboxing
- Enterprise deployment paths

This repo is iOS-first by design.

---

## Why Now

This idea only became possible **recently**.

### 1️⃣ LLMs now understand intent, not just text  
Modern agents can reliably infer:
- Task type
- Required data
- Defaults and constraints

Five years ago, inference quality made this impossible.  
Today, it’s good enough — and improving fast.

---

### 2️⃣ Enterprises are drowning in UI debt  
Most large companies:
- Cannot rewrite legacy systems
- Cannot make them mobile-friendly
- Cannot train frontline workers on dozens of tools

They are actively looking for **edge-layer solutions** that avoid rewrites.

---

### 3️⃣ Mobile is now the primary work surface  
Construction, logistics, healthcare, inspections, sales —  
the moment of work happens away from desks.

The UI mismatch is now a business risk, not a UX complaint.

---

### 4️⃣ Automation failed; augmentation is winning  
RPA promised to remove humans.  
Reality proved humans are still required.

A2UI embraces the winning model:
> **Human decision-making, with friction removed**

---

### 5️⃣ Open-source infrastructure is trusted again  
Enterprises now adopt open primitives by default:
- Kubernetes
- Terraform
- Airflow
- Swift Packages

They want transparent systems — not black-box AI.

---

### Timing Summary

| Before | Now |
|------|-----|
| Weak intent inference | Strong task inference |
| Desktop-first work | Mobile-first work |
| UI rewrites required | UI bypass possible |
| Automation hype | Human-in-the-loop reality |
| Closed platforms | OSS infrastructure |

> **A2UI wasn’t viable before.  
Now it’s inevitable.**

---

## One-Sentence Pitch

> **A2UI lets agents generate task-specific native mini-apps on demand, so frontline workers describe reality instead of navigating legacy software — while enterprises still get clean, validated records.**

---

## Status

- ✅ Working iOS demo
- ✅ End-to-end flow
- ✅ Deterministic execution
- ✅ Enterprise-safe architecture

This repo exists to prove **this is possible today**.

---

## What’s Next

- Additional task agents (sales visits, inspections, compliance)
- Android runtime
- Enterprise connectors
- Production hardening

If you’re reading this and nodding —  
you already understand the opportunity.






## 🚀 Getting Started: Add A2UI to Your iOS App

A2UI is distributed as a **Swift Package** and can be embedded into any iOS app in minutes.  
This section shows how to add A2UI, render a generated UI, and verify that everything works end-to-end.

---

### 1️⃣ Add A2UI via Swift Package Manager

In **Xcode**:

1. Open your iOS app project  
2. Go to **File → Add Packages…**  
3. Enter the repository URL:

```
https://github.com/VamshiIITBHU14/A2UI
```

4. Select **Up to Next Major Version**  
5. Add the package to your **App target**

Once added, import the runtime:

```swift
import A2UIRuntime
```

---

### 2️⃣ Create the A2UI Engine

Initialize the engine once (for example, in your main view or app coordinator):

```swift
let engine = A2UIEngine()
```

This engine is responsible for:
- Inferring intent
- Generating UI schemas
- Executing tasks deterministically

---

### 3️⃣ Infer a Task from Natural Language

Call the agent with real-world input:

```swift
let intent = try engine.inferTask(
    input: "Broken pallet in aisle 4, leaking, urgent",
    context: TaskContext(
        userRole: "warehouse_worker",
        locationHint: "Aisle 4"
    )
)
```

This returns:
- A detected `taskType`
- Extracted signals (location, urgency, etc.)
- A **runtime-generated UI schema** (`UISchema`)

No UI is predefined.

---

### 4️⃣ Render the Generated Mini-App (Native UI)

Present the generated UI using SwiftUI:

```swift
NavigationLink {
    DynamicRendererView(schema: intent.uiSchema) { values in
        handleSubmit(values, intent)
    }
} label: {
    Text("Open Generated Mini-App")
}
```

The rendered UI is:
- 100% native SwiftUI
- Generated at runtime
- Task-specific (no generic forms)
- Human-in-the-loop by default

---

### 5️⃣ Execute the Task on Submit (Deterministic)

When the user taps **Submit**, execute the task:

```swift
let result = try engine.execute(
    taskType: intent.taskType,
    schema: intent.uiSchema,
    values: values,
    context: context
)
```

This step:
- Validates required fields
- Produces a structured payload
- Generates a reference ID
- Returns a deterministic execution result

⚠️ No AI is used at execution time.

---

### 6️⃣ What to Expect When Testing (Verification Checklist)

When running the demo app in Simulator or on device:

1. Enter a real-world description (e.g. incident, note, update)
2. Tap **Generate Mini-App**
3. Review the inferred task and extracted signals
4. Open the generated mini-app
5. Fill in required fields
6. Tap **Submit**
7. You are automatically returned to the Home screen
8. A success card appears showing:
   - Execution status
   - Reference ID
   - JSON payload preview

This confirms the full loop:

```
Intent → UI → Human → Validation → Record
```

---

### 7️⃣ Where Is the Data Stored?

In the demo app:
- The validated payload is written to the app’s **Documents directory**
- It is displayed back in the UI for inspection

In production:
- Replace the executor with:
  - SAP / Oracle APIs
  - Middleware services
  - Message queues
  - Offline sync pipelines

A2UI is backend-agnostic by design.

---

## 🧠 Important Design Notes

- This is **not** a form builder  
- This is **not** chat UI  
- This is **not** RPA  

A2UI generates **ephemeral, task-specific native interfaces** that exist only long enough to safely capture human-confirmed data.
