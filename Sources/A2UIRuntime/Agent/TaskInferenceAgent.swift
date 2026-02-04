import Foundation

public struct TaskContext: Codable, Sendable {
    public var userRole: String
    public var locationHint: String?
    public var locale: String

    public init(userRole: String, locationHint: String? = nil, locale: String = "en_US") {
        self.userRole = userRole
        self.locationHint = locationHint
        self.locale = locale
    }
}

public struct TaskIntent: Codable, Sendable {
    public var taskType: String
    public var confidence: Double
    public var extracted: [String: String]   // light entity extraction for POC
    public var uiSchema: UISchema

    public init(taskType: String, confidence: Double, extracted: [String : String], uiSchema: UISchema) {
        self.taskType = taskType
        self.confidence = confidence
        self.extracted = extracted
        self.uiSchema = uiSchema
    }
}

public protocol TaskInferenceAgent: Sendable {
    func infer(from input: String, context: TaskContext) throws -> TaskIntent
}
