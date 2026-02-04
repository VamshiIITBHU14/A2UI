import Foundation

/// POC agent: rule-based task inference + schema generation.
/// Replace with LLM later without changing renderer/executor boundaries.
public final class RuleBasedIncidentAgent: TaskInferenceAgent {
    public init() {}

    public func infer(from input: String, context: TaskContext) throws -> TaskIntent {
        let lower = input.lowercased()

        // Simple entity extraction
        var extracted: [String: String] = [:]
        if let aisle = Self.extractAisle(from: lower) { extracted["aisle"] = aisle }
        if lower.contains("leak") || lower.contains("leaking") { extracted["hazard"] = "leak" }
        if lower.contains("urgent") || lower.contains("critical") { extracted["urgency"] = "high" }

        let schema = UISchema(
            id: "warehouse_incident_v1",
            title: "Report Warehouse Incident",
            subtitle: "Generated for this report only (A2UI).",
            taskType: "warehouse_incident",
            components: [
                .section(title: "Evidence", components: [
                    .imageField(id: "photo", label: "Photo (required)", required: true),
                ]),
                .section(title: "Details", components: [
                    .enumField(
                        id: "severity",
                        label: "Severity",
                        required: true,
                        options: [
                            .init(value: "low", label: "Low"),
                            .init(value: "medium", label: "Medium"),
                            .init(value: "high", label: "High")
                        ],
                        defaultValue: extracted["urgency"] == "high" ? "high" : "medium"
                    ),
                    .textField(
                        id: "location",
                        label: "Location",
                        required: true,
                        placeholder: "e.g. Aisle 4, Bay 2",
                        defaultValue: context.locationHint ?? (extracted["aisle"].map { "Aisle \($0)" } ?? nil)
                    ),
                    .dateField(
                        id: "occurredAt",
                        label: "Occurred At",
                        required: true,
                        defaultNow: true
                    ),
                    .toggleField(
                        id: "hazardous",
                        label: "Hazardous (leak / sharp / chemical)",
                        required: true,
                        defaultValue: (extracted["hazard"] != nil)
                    ),
                    .textField(
                        id: "notes",
                        label: "Notes",
                        required: false,
                        placeholder: "Optional details…",
                        defaultValue: input
                    )
                ]),
                .button(
                    id: "submit",
                    label: "Submit Incident",
                    action: .submit
                )
            ],
            metadata: [
                "generated_by": "RuleBasedIncidentAgent",
                "user_role": context.userRole
            ]
        )

        return TaskIntent(
            taskType: "warehouse_incident",
            confidence: 0.92,
            extracted: extracted,
            uiSchema: schema
        )
    }

    private static func extractAisle(from input: String) -> String? {
        // naive: find "aisle 4" patterns
        let tokens = input.split(separator: " ")
        for i in 0..<max(0, tokens.count - 1) {
            if tokens[i] == "aisle" {
                return String(tokens[i+1]).trimmingCharacters(in: .punctuationCharacters)
            }
        }
        return nil
    }
}
