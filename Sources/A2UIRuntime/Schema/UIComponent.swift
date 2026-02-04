import Foundation

public enum UIAction: Codable, Sendable, Equatable {
    case submit
    case none
}

public struct EnumOption: Codable, Sendable, Equatable {
    public var value: String
    public var label: String
    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }
}

public enum UIComponent: Codable, Sendable, Equatable {
    case section(title: String, components: [UIComponent])
    case textField(id: String, label: String, required: Bool, placeholder: String?, defaultValue: String?)
    case toggleField(id: String, label: String, required: Bool, defaultValue: Bool)
    case sliderField(id: String, label: String, required: Bool, min: Double, max: Double, step: Double, defaultValue: Double)
    case dateField(id: String, label: String, required: Bool, defaultNow: Bool)
    case enumField(id: String, label: String, required: Bool, options: [EnumOption], defaultValue: String?)
    case imageField(id: String, label: String, required: Bool)
    case button(id: String, label: String, action: UIAction)

    private enum CodingKeys: String, CodingKey { case type, payload }
    private enum Kind: String, Codable { case section, textField, toggleField, sliderField, dateField, enumField, imageField, button }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .section(let title, let components):
            try container.encode(Kind.section, forKey: .type)
            try container.encode(SectionPayload(title: title, components: components), forKey: .payload)
        case .textField(let id, let label, let required, let placeholder, let defaultValue):
            try container.encode(Kind.textField, forKey: .type)
            try container.encode(TextPayload(id: id, label: label, required: required, placeholder: placeholder, defaultValue: defaultValue), forKey: .payload)
        case .toggleField(let id, let label, let required, let defaultValue):
            try container.encode(Kind.toggleField, forKey: .type)
            try container.encode(TogglePayload(id: id, label: label, required: required, defaultValue: defaultValue), forKey: .payload)
        case .sliderField(let id, let label, let required, let min, let max, let step, let defaultValue):
            try container.encode(Kind.sliderField, forKey: .type)
            try container.encode(SliderPayload(id: id, label: label, required: required, min: min, max: max, step: step, defaultValue: defaultValue), forKey: .payload)
        case .dateField(let id, let label, let required, let defaultNow):
            try container.encode(Kind.dateField, forKey: .type)
            try container.encode(DatePayload(id: id, label: label, required: required, defaultNow: defaultNow), forKey: .payload)
        case .enumField(let id, let label, let required, let options, let defaultValue):
            try container.encode(Kind.enumField, forKey: .type)
            try container.encode(EnumPayload(id: id, label: label, required: required, options: options, defaultValue: defaultValue), forKey: .payload)
        case .imageField(let id, let label, let required):
            try container.encode(Kind.imageField, forKey: .type)
            try container.encode(ImagePayload(id: id, label: label, required: required), forKey: .payload)
        case .button(let id, let label, let action):
            try container.encode(Kind.button, forKey: .type)
            try container.encode(ButtonPayload(id: id, label: label, action: action), forKey: .payload)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .section:
            let p = try container.decode(SectionPayload.self, forKey: .payload)
            self = .section(title: p.title, components: p.components)
        case .textField:
            let p = try container.decode(TextPayload.self, forKey: .payload)
            self = .textField(id: p.id, label: p.label, required: p.required, placeholder: p.placeholder, defaultValue: p.defaultValue)
        case .toggleField:
            let p = try container.decode(TogglePayload.self, forKey: .payload)
            self = .toggleField(id: p.id, label: p.label, required: p.required, defaultValue: p.defaultValue)
        case .sliderField:
            let p = try container.decode(SliderPayload.self, forKey: .payload)
            self = .sliderField(id: p.id, label: p.label, required: p.required, min: p.min, max: p.max, step: p.step, defaultValue: p.defaultValue)
        case .dateField:
            let p = try container.decode(DatePayload.self, forKey: .payload)
            self = .dateField(id: p.id, label: p.label, required: p.required, defaultNow: p.defaultNow)
        case .enumField:
            let p = try container.decode(EnumPayload.self, forKey: .payload)
            self = .enumField(id: p.id, label: p.label, required: p.required, options: p.options, defaultValue: p.defaultValue)
        case .imageField:
            let p = try container.decode(ImagePayload.self, forKey: .payload)
            self = .imageField(id: p.id, label: p.label, required: p.required)
        case .button:
            let p = try container.decode(ButtonPayload.self, forKey: .payload)
            self = .button(id: p.id, label: p.label, action: p.action)
        }
    }
}

// Payload structs
private struct SectionPayload: Codable, Equatable { let title: String; let components: [UIComponent] }
private struct TextPayload: Codable, Equatable { let id: String; let label: String; let required: Bool; let placeholder: String?; let defaultValue: String? }
private struct TogglePayload: Codable, Equatable { let id: String; let label: String; let required: Bool; let defaultValue: Bool }
private struct SliderPayload: Codable, Equatable { let id: String; let label: String; let required: Bool; let min: Double; let max: Double; let step: Double; let defaultValue: Double }
private struct DatePayload: Codable, Equatable { let id: String; let label: String; let required: Bool; let defaultNow: Bool }
private struct EnumPayload: Codable, Equatable { let id: String; let label: String; let required: Bool; let options: [EnumOption]; let defaultValue: String? }
private struct ImagePayload: Codable, Equatable { let id: String; let label: String; let required: Bool }
private struct ButtonPayload: Codable, Equatable { let id: String; let label: String; let action: UIAction }
