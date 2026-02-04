import Foundation

public struct ExecutionResult: Codable, Sendable {
    public var ok: Bool
    public var referenceId: String
    public var warnings: [String]
    public var payloadPreview: String

    public init(ok: Bool, referenceId: String, warnings: [String] = [], payloadPreview: String) {
        self.ok = ok
        self.referenceId = referenceId
        self.warnings = warnings
        self.payloadPreview = payloadPreview
    }
}

public final class A2UIEngine: @unchecked Sendable {
    private let agent: TaskInferenceAgent
    private let executor: TaskExecutor

    public init(agent: TaskInferenceAgent, executor: TaskExecutor) {
        self.agent = agent
        self.executor = executor
    }

    public func inferTask(input: String, context: TaskContext) throws -> TaskIntent {
        try agent.infer(from: input, context: context)
    }

    public func execute(taskType: String, schema: UISchema, values: [String: FieldValue], context: TaskContext) throws -> ExecutionResult {
        let validated = try SchemaValidator.validate(schema: schema, values: values)
        return try executor.execute(taskType: taskType, payload: validated, context: context)
    }
}
