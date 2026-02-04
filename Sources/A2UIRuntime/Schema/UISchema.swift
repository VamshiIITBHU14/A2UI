import Foundation

public struct UISchema: Codable, Sendable, Equatable {
    public var id: String
    public var title: String
    public var subtitle: String?
    public var taskType: String
    public var components: [UIComponent]
    public var metadata: [String: String]

    public init(id: String, title: String, subtitle: String?, taskType: String, components: [UIComponent], metadata: [String : String] = [:]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.taskType = taskType
        self.components = components
        self.metadata = metadata
    }
}
