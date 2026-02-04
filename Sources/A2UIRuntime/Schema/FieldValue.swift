import Foundation

public enum FieldValue: Codable, Sendable, Equatable {
    case string(String)
    case bool(Bool)
    case number(Double)
    case date(Date)
    case imageData(Data) // POC only. Enterprise: upload + reference.

    public func toAnyCodable() -> AnyCodable {
        switch self {
        case .string(let s): return .init(s)
        case .bool(let b): return .init(b)
        case .number(let n): return .init(n)
        case .date(let d): return .init(ISO8601DateFormatter().string(from: d))
        case .imageData(let data): return .init(data.base64EncodedString())
        }
    }
}
