import Foundation

public enum SchemaValidationError: LocalizedError {
    case missingRequiredField(String)
    case invalid(String)

    public var errorDescription: String? {
        switch self {
        case .missingRequiredField(let id): return "Missing required field: \(id)"
        case .invalid(let msg): return msg
        }
    }
}

public enum SchemaValidator {
    public static func validate(schema: UISchema, values: [String: FieldValue]) throws -> ValidatedPayload {
        var requiredIds: [String] = []
        collectRequiredFields(from: schema.components, into: &requiredIds)

        for id in requiredIds {
            guard let v = values[id] else { throw SchemaValidationError.missingRequiredField(id) }
            // minimal value checks
            if case .string(let s) = v, s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw SchemaValidationError.missingRequiredField(id)
            }
            if case .imageData(let d) = v, d.isEmpty {
                throw SchemaValidationError.missingRequiredField(id)
            }
        }

        return ValidatedPayload(taskType: schema.taskType, fields: values, metadata: schema.metadata)
    }

    private static func collectRequiredFields(from components: [UIComponent], into requiredIds: inout [String]) {
        for c in components {
            switch c {
            case .section(_, let sub):
                collectRequiredFields(from: sub, into: &requiredIds)
            case .textField(let id, _, let required, _, _):
                if required { requiredIds.append(id) }
            case .toggleField(let id, _, let required, _):
                if required { requiredIds.append(id) }
            case .sliderField(let id, _, let required, _, _, _, _):
                if required { requiredIds.append(id) }
            case .dateField(let id, _, let required, _):
                if required { requiredIds.append(id) }
            case .enumField(let id, _, let required, _, _):
                if required { requiredIds.append(id) }
            case .imageField(let id, _, let required):
                if required { requiredIds.append(id) }
            case .button:
                break
            }
        }
    }
}
