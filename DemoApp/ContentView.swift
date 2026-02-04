import SwiftUI
import A2UIRuntime

struct ContentView: View {
    let engine: A2UIEngine

    @State private var input: String = "Broken pallet in aisle 4, leaking, urgent"
    @State private var context = TaskContext(userRole: "warehouse_worker", locationHint: "Aisle 4")
    @State private var intent: TaskIntent?
    @State private var execution: ExecutionResult?
    @State private var errorText: String?
    @State private var showPayload = false
    @State private var isGenerating = false
    @State private var toastText: String?
    @State private var toastTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    promptCard
                    if let intent { inferredCard(intent) }
                    if let intent { generatedMiniAppCard(intent) }
                    if let execution { executionCard(execution) }
                    if let errorText { errorBanner(errorText) }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .overlay(alignment: .top) {
                    if let toastText {
                        ToastView(text: toastText)
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(999)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.9), value: toastText)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("A2UI Mini-Apps")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Use Example Prompt") {
                            input = "Broken pallet in aisle 4, leaking, urgent"
                            context = TaskContext(userRole: "warehouse_worker", locationHint: "Aisle 4")
                        }
                        Button("Clear Results") {
                            intent = nil
                            execution = nil
                            errorText = nil
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showPayload) {
                payloadSheet
            }
        }
    }

    // MARK: - Cards

    private var headerCard: some View {
        Card {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.tint)

                VStack(alignment: .leading, spacing: 6) {
                    Text("On-demand native mini-apps")
                        .font(.headline)
                    Text("Type a real-world report. The agent generates a task-specific UI. You confirm. A deterministic executor outputs an enterprise-ready record.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var promptCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("1) Describe what happened")
                        .font(.headline)
                    Spacer()
                    Pill("Warehouse", systemImage: "shippingbox")
                }

                TextField("e.g. Broken pallet in aisle 4, leaking, urgent", text: $input, axis: .vertical)
                    .lineLimit(2...6)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 10) {
                    Button {
                        generate()
                    } label: {
                        HStack(spacing: 8) {
                            if isGenerating { ProgressView().controlSize(.small) }
                            Text(isGenerating ? "Generating…" : "Generate Mini-App")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isGenerating || input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button {
                        input = ""
                        intent = nil
                        execution = nil
                        errorText = nil
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Clear")
                }

                Divider().opacity(0.6)

                HStack(spacing: 12) {
                    smallMeta("Role", value: context.userRole, icon: "person.fill")
                    smallMeta("Location hint", value: context.locationHint ?? "—", icon: "mappin.and.ellipse")
                }
            }
        }
    }

    private func inferredCard(_ intent: TaskIntent) -> some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("2) Agent inference")
                        .font(.headline)
                    Spacer()
                    confidencePill(intent.confidence)
                }

                HStack(spacing: 10) {
                    Image(systemName: "bolt.circle.fill")
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Task detected")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(intent.taskType)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }

                if !intent.extracted.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Signals extracted")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 140), spacing: 8)],
                            alignment: .leading,
                            spacing: 8
                        ) {
                            ForEach(intent.extracted.sorted(by: { $0.key < $1.key }), id: \.key) { k, v in
                                Tag("\(k): \(v)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
        }
    }

    private func generatedMiniAppCard(_ intent: TaskIntent) -> some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("3) Generated mini-app")
                        .font(.headline)
                    Spacer()
                    Pill("Native SwiftUI", systemImage: "swift")
                }

                Text("A task-specific UI schema was generated for this report. Open it and submit to produce a validated record.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                NavigationLink {
                    DynamicRendererView(schema: intent.uiSchema) { values in
                        execute(values: values)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(intent.uiSchema.title)
                                .font(.headline)
                            Text("Tap to open the generated form")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func executionCard(_ execution: ExecutionResult) -> some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("4) Deterministic execution")
                        .font(.headline)
                    Spacer()
                    statusPill(execution.ok)
                }

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: execution.ok ? "checkmark.seal.fill" : "xmark.seal.fill")
                        .foregroundStyle(execution.ok ? .green : .red)
                        .font(.system(size: 22, weight: .semibold))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(execution.ok ? "Record created" : "Failed")
                            .font(.headline)
                        Text("Reference: \(execution.referenceId)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                if !execution.warnings.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Warnings")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        ForEach(execution.warnings, id: \.self) { w in
                            Text("• \(w)")
                                .font(.subheadline)
                        }
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        showPayload = true
                    } label: {
                        Label("View payload", systemImage: "doc.text.magnifyingglass")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        copy(execution.payloadPreview)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Copy payload")
                }
            }
        }
    }

    private func errorBanner(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Something went wrong")
                    .font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.orange.opacity(0.35), lineWidth: 1)
        )
    }

    private var payloadSheet: some View {
        NavigationStack {
            ScrollView {
                Text(execution?.payloadPreview ?? "")
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(16)
            }
            .navigationTitle("Payload Preview")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Copy") { copy(execution?.payloadPreview ?? "") }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { showPayload = false }
                }
            }
        }
    }

    // MARK: - Actions

    private func generate() {
        isGenerating = true
        defer { isGenerating = false }

        do {
            errorText = nil
            execution = nil
            intent = try engine.inferTask(input: input, context: context)
        } catch {
            errorText = error.localizedDescription
        }
    }

    private func execute(values: [String: FieldValue]) {
        guard let intent else { return }
        do {
            errorText = nil
            execution = try engine.execute(taskType: intent.taskType, schema: intent.uiSchema, values: values, context: context)
            if execution?.ok == true {
                showToast("Incident submitted")
            }

        } catch {
            errorText = error.localizedDescription
        }
    }

    private func copy(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
    }

    // MARK: - UI helpers

    private func confidencePill(_ confidence: Double) -> some View {
        let pct = Int((confidence * 100).rounded())
        return Pill("\(pct)%", systemImage: "gauge.with.dots.needle.67percent")
    }

    private func statusPill(_ ok: Bool) -> some View {
        Pill(ok ? "Success" : "Failed", systemImage: ok ? "checkmark.circle" : "xmark.circle")
    }

    private func smallMeta(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private struct ToastView: View {
        let text: String
        var body: some View {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
    }
    
    private func showToast(_ text: String) {
        toastTask?.cancel()
        toastText = text
        toastTask = Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s
            await MainActor.run { toastText = nil }
        }
    }

}

// MARK: - Small UI primitives (kept local for demo polish)

private struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 6)
    }
}

private struct Pill: View {
    let text: String
    let systemImage: String
    init(_ text: String, systemImage: String) {
        self.text = text
        self.systemImage = systemImage
    }
    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color(.secondarySystemGroupedBackground))
            )
            .foregroundStyle(.secondary)
    }
}

private struct Tag: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color(.secondarySystemGroupedBackground))
            )
    }
}
