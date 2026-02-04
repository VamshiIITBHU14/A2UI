import Foundation

public struct AnyCodable: Codable, Sendable, Equatable {
    public let value: Any

    public init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) { value = s; return }
        if let b = try? container.decode(Bool.self) { value = b; return }
        if let n = try? container.decode(Double.self) { value = n; return }
        if let m = try? container.decode([String: String].self) { value = m; return }
        if let d = try? container.decode([String: AnyCodable].self) { value = d; return }
        if let a = try? container.decode([AnyCodable].self) { value = a; return }
        value = ""
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let s as String: try container.encode(s)
        case let b as Bool: try container.encode(b)
        case let n as Double: try container.encode(n)
        case let i as Int: try container.encode(Double(i))
        case let m as [String: String]: try container.encode(m)
        case let d as [String: AnyCodable]: try container.encode(d)
        case let a as [AnyCodable]: try container.encode(a)
        default:
            try container.encode(String(describing: value))
        }
    }

    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        String(describing: lhs.value) == String(describing: rhs.value)
    }
}
