import Foundation

public struct ValidatedPayload: Codable, Sendable {
    public var taskType: String
    public var fields: [String: FieldValue]
    public var metadata: [String: String]
}

public protocol TaskExecutor: Sendable {
    func execute(taskType: String, payload: ValidatedPayload, context: TaskContext) throws -> ExecutionResult
}
