## License

A2UI is licensed under the Apache License, Version 2.0.

https://github.com/user-attachments/assets/1650891b-1ec3-4bc9-a7b3-b69bb9d57b3b


# A2UI: Agent-to-UI Runtime for Mobile  
**Human-in-the-loop execution for enterprise AI**

> _What if enterprise software stopped forcing humans to learn UIs —  
and instead generated the right UI at the moment work happens?_

> **A2UI is a runtime for generating native mobile interfaces at runtime from AI agents - with humans in the loop and deterministic execution.**

AI agents are great at reasoning.  
They are terrible at responsibility.

Most AI-in-enterprise demos collapse the moment someone asks:

> *“What happens when this writes to production?”*

A2UI takes a different approach.

Instead of letting agents mutate data directly, **agents generate task-specific native UIs**, humans confirm intent, and systems execute deterministically.

No chatbots.  
No RPA.  
No AI writing directly to SAP, Oracle, or Salesforce.

---

## Why A2UI Exists

Modern enterprises still run on systems like **SAP, Oracle, Salesforce**, and custom internal platforms.

These systems are:
- Desktop-first  
- Menu-heavy  
- Painful on mobile  
- Hostile to frontline workers  

As a result:
- Data entry is delayed or skipped  
- Records are incomplete or inaccurate  
- Compliance relies on memory instead of systems  
- Field teams actively avoid official software  

> The real problem isn’t data capture —  
> **it’s forcing humans to navigate software instead of describing reality.**

---

## The Core Insight

Most enterprise work already looks like this:

1. Something happens in the real world  
2. A human understands what matters  
3. Software forces them through irrelevant UI  

**A2UI flips the model.**

Instead of:
> *“Find the right screen and fill the form”*

We do:
> *“Describe what happened — we’ll generate the right UI”*

The UI becomes a **temporary artifact**, not a permanent product surface.

---

## What This Repo Demonstrates

This repository is an **iOS-first proof of concept** for **Agent-to-UI (A2UI)**.

It proves the hardest part:

> **Dynamic, native UI generation that enterprises can trust.**

Specifically, this repo includes:
- A SwiftUI runtime for rendering agent-generated UIs  
- A schema-driven mini-app system (not forms)  
- Local validation and deterministic execution  
- A demo app showing the full end-to-end flow  

This is **infrastructure**, not a vertical SaaS product.

---

## 🎬 60-Second Demo

> Natural language → generated native UI → submit → validated enterprise record

⬇️ *(Demo video goes here)*

---

## End-to-End Example: Warehouse Incident Reporting

A worker types (or speaks):

> **“Broken pallet in aisle 4, leaking, urgent”**

That’s the only instruction.

### What happens next:

### 1️⃣ Task Inference  
An agent:
- Infers the task type (`warehouse_incident`)  
- Extracts signals (location, hazard, urgency)  
- Determines **what information is required**  

### 2️⃣ A2UI Generation  
A **native SwiftUI mini-app** is generated at runtime containing only:
- Photo (required)  
- Severity  
- Location (pre-filled)  
- Timestamp  
- Hazard toggle  
- Notes  

This UI **did not exist before the prompt** and will not exist afterward.

### 3️⃣ Human-in-the-Loop Confirmation  
- Defaults are pre-seeded  
- Required fields are validated  
- The human can correct the agent  

AI never submits data directly.

### 4️⃣ Deterministic Execution  
- A validated payload is produced  
- Written as a clean JSON record  
- Shaped for SAP / Oracle / middleware ingestion  

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

### ❌ AI does NOT
- Execute side effects  
- Write to systems  
- Skip validation  
- Persist records  

### ✅ AI ONLY
- Infers intent  
- Proposes UI schemas  

### ✅ Deterministic code
- Renders native UI  
- Validates required fields  
- Executes submissions  
- Produces records  

> **If the agent is wrong, the human corrects it before anything irreversible happens.**

---

## High-Level Architecture

```
Agent (LLM / Rules)
        ↓
   UI Schema
        ↓
 Native Mini-App (SwiftUI)
        ↓
 Human Confirmation
        ↓
 Deterministic Executor
        ↓
 Enterprise System
```

AI proposes.  
Humans confirm.  
Systems execute.

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

### 1️⃣ LLMs now understand intent, not just text  
### 2️⃣ Enterprises are drowning in UI debt  
### 3️⃣ Mobile is now the primary work surface  
### 4️⃣ Automation failed; augmentation is winning  
### 5️⃣ Open-source infrastructure is trusted again  

---

## One-Sentence Pitch

> **A2UI lets agents generate task-specific native mini-apps on demand, so frontline workers describe reality instead of navigating legacy software — while enterprises still get clean, validated records.**

---

## License

Apache License, Version 2.0

---

## Interested?

We’re early and actively talking to **design partners**.

👉 Open a GitHub Discussion  
👉 Or email: vamshi.iitbhu@gmail.com




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
