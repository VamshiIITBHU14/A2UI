import Foundation

/// Deterministic executor: writes payload to Documents directory as JSON.
/// In enterprise, this becomes SAP/Oracle middleware connector (paid).
public final class LocalJSONTaskExecutor: TaskExecutor {
    public init() {}

    public func execute(taskType: String, payload: ValidatedPayload, context: TaskContext) throws -> ExecutionResult {
        let reference = "INC-\(Int(Date().timeIntervalSince1970))"

        let envelope: [String: AnyCodable] = [
            "referenceId": .init(reference),
            "taskType": .init(taskType),
            "timestamp": .init(ISO8601DateFormatter().string(from: Date())),
            "userRole": .init(context.userRole),
            "fields": .init(payload.fields.mapValues { $0.toAnyCodable() }),
            "metadata": .init(payload.metadata)
        ]

        let data = try JSONEncoder.pretty.encode(envelope)
        let filename = "a2ui-\(reference).json"

        let url = try Self.documentsDirectory().appendingPathComponent(filename)
        try data.write(to: url, options: [.atomic])

        return ExecutionResult(
            ok: true,
            referenceId: reference,
            warnings: [],
            payloadPreview: String(data: data, encoding: .utf8) ?? ""
        )
    }

    private static func documentsDirectory() throws -> URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "LocalJSONTaskExecutor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing documents directory"])
        }
        return url
    }
}
