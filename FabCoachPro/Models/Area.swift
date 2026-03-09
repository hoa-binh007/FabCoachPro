import Foundation

enum Area: String, CaseIterable, Hashable, Identifiable, Codable {
    
    case pruefungsfach1
    case pruefungsfach2
    case pruefungsfach3
    case pruefungsfach4

    // MARK: - Identifiable
    var id: String { title }

    // MARK: - Anzeige für UI
    var title: String {
        switch self {
        case .pruefungsfach1:
            return "1 Retten, Erstversorgung & Schwimmen"
        case .pruefungsfach2:
            return "2 Badebetrieb"
        case .pruefungsfach3:
            return "3 Bädertechnik"
        case .pruefungsfach4:
            return "4 Wirtschafts- & Sozialkunde"
        }
    }

    // MARK: - JSON Decoder (robust)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let first = rawValue.first else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Leerer Area-Wert im JSON"
            )
        }

        switch first {
        case "1":
            self = .pruefungsfach1
        case "2":
            self = .pruefungsfach2
        case "3":
            self = .pruefungsfach3
        case "4":
            self = .pruefungsfach4
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unbekannter Area-Wert: \(rawValue)"
            )
        }
    }

    // MARK: - JSON Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(title)
    }
}
