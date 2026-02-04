import SwiftUI
import PhotosUI

public struct DynamicRendererView: View {
    public let schema: UISchema
    public let onSubmit: (_ values: [String: FieldValue]) -> Void

    @State private var values: [String: FieldValue]
    @State private var validationError: String?
    @Environment(\.dismiss) private var dismiss

    public init(schema: UISchema, onSubmit: @escaping (_ values: [String: FieldValue]) -> Void) {
        self.schema = schema
        self.onSubmit = onSubmit
        self._values = State(initialValue: Self.seedDefaults(from: schema))
    }

    public var body: some View {
        VStack(spacing: 0) {
            Form {
                if let subtitle = schema.subtitle {
                    Section {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    HStack(spacing: 8) {
                        Text("*").foregroundStyle(.red).font(.caption)
                        Text("Required fields are marked")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                ForEach(Array(schema.components.enumerated()), id: \.offset) { _, component in
                    render(component)
                }

                if let validationError {
                    Section {
                        Label(validationError, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }

                // Spacer so last content isn't hidden under sticky bar
                Section { EmptyView() }
                    .listRowBackground(Color.clear)
                    .frame(height: 70)
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(schema.title)
            .onAppear {
                // Ensure defaults exist even if schema changes while view lives
                let seeded = Self.seedDefaults(from: schema)
                for (k, v) in seeded where values[k] == nil {
                    values[k] = v
                }
            }

            stickySubmitBar
        }
    }

    private var stickySubmitBar: some View {
        VStack(spacing: 10) {
            Divider().opacity(0.5)

            Button {
                submit()
            } label: {
                HStack {
                    Spacer()
                    Text("Submit")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .background(.ultraThinMaterial)
    }

    private func submit() {
        do {
            _ = try SchemaValidator.validate(schema: schema, values: values)
            validationError = nil
            onSubmit(values)
            dismiss()
        } catch {
            validationError = error.localizedDescription
        }
    }

    // MARK: - Rendering (type-erased to avoid SwiftUI generic explosions)

    private func render(_ component: UIComponent) -> AnyView {
        switch component {

        case .section(let title, let components):
            return AnyView(
                Section {
                    ForEach(Array(components.enumerated()), id: \.offset) { _, c in
                        render(c)
                    }
                } header: {
                    Text(title.uppercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            )

        case .textField(let id, let label, let required, let placeholder, _):
            let binding = Binding<String>(
                get: { stringValue(id) ?? "" },
                set: { values[id] = .string($0) }
            )

            return AnyView(
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text(label)
                        requiredStar(required)
                    }
                    TextField(placeholder ?? "", text: binding)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.vertical, 4)
            )

        case .toggleField(let id, let label, let required, _):
            let binding = Binding<Bool>(
                get: { boolValue(id) ?? false },
                set: { values[id] = .bool($0) }
            )

            return AnyView(
                HStack(spacing: 4) {
                    Toggle(label, isOn: binding)
                    requiredStar(required)
                }
            )

        case .sliderField(let id, let label, let required, let min, let max, let step, _):
            return AnyView(
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text(label)
                        requiredStar(required)
                    }
                    SliderFieldView(
                        label: "",
                        min: min, max: max, step: step,
                        value: Binding<Double>(
                            get: { numberValue(id) ?? min },
                            set: { values[id] = .number($0) }
                        )
                    )
                }
                .padding(.vertical, 4)
            )

        case .dateField(let id, let label, let required, _):
            return AnyView(
                HStack(spacing: 4) {
                    DateFieldView(
                        label: label,
                        date: Binding<Date>(
                            get: { dateValue(id) ?? Date() },
                            set: { values[id] = .date($0) }
                        )
                    )
                    requiredStar(required)
                }
            )

        case .enumField(let id, let label, let required, let options, _):
            return AnyView(
                HStack(spacing: 4) {
                    EnumFieldView(
                        label: label,
                        options: options,
                        selection: Binding<String>(
                            get: { stringValue(id) ?? options.first?.value ?? "" },
                            set: { values[id] = .string($0) }
                        )
                    )
                    requiredStar(required)
                }
            )

        case .imageField(let id, let label, let required):
            return AnyView(
                ImageFieldView(
                    label: label,
                    required: required,
                    data: Binding<Data?>(
                        get: {
                            if case .imageData(let d) = values[id] { return d }
                            return nil
                        },
                        set: { newValue in
                            if let d = newValue { values[id] = .imageData(d) }
                            else { values.removeValue(forKey: id) }
                        }
                    )
                )
            )

        case .button:
            // We use sticky submit bar instead of rendering schema button row.
            return AnyView(EmptyView())
        }
    }

    private func requiredStar(_ required: Bool) -> AnyView {
        required
        ? AnyView(Text("*").foregroundStyle(.red))
        : AnyView(EmptyView())
    }

    // MARK: - Value helpers

    private func stringValue(_ id: String) -> String? {
        if case .string(let s) = values[id] { return s }
        return nil
    }

    private func boolValue(_ id: String) -> Bool? {
        if case .bool(let b) = values[id] { return b }
        return nil
    }

    private func numberValue(_ id: String) -> Double? {
        if case .number(let n) = values[id] { return n }
        return nil
    }

    private func dateValue(_ id: String) -> Date? {
        if case .date(let d) = values[id] { return d }
        return nil
    }

    // MARK: - Default seeding

    private static func seedDefaults(from schema: UISchema) -> [String: FieldValue] {
        var seeded: [String: FieldValue] = [:]

        func walk(_ components: [UIComponent]) {
            for c in components {
                switch c {
                case .section(_, let subs):
                    walk(subs)

                case .textField(let id, _, _, _, let defaultValue):
                    if let dv = defaultValue { seeded[id] = .string(dv) }

                case .toggleField(let id, _, _, let defaultValue):
                    seeded[id] = .bool(defaultValue)

                case .sliderField(let id, _, _, _, _, _, let defaultValue):
                    seeded[id] = .number(defaultValue)

                case .dateField(let id, _, _, let defaultNow):
                    if defaultNow { seeded[id] = .date(Date()) }

                case .enumField(let id, _, _, let options, let defaultValue):
                    let dv = defaultValue ?? options.first?.value
                    if let dv { seeded[id] = .string(dv) }

                case .imageField:
                    break

                case .button:
                    break
                }
            }
        }

        walk(schema.components)
        return seeded
    }
}
