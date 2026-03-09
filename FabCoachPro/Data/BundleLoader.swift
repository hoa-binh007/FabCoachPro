import Foundation

enum BundleLoaderError: Error, LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name): return "Datei nicht gefunden im Bundle: \(name)"
        case .decodingFailed(let msg): return "JSON Decode fehlgeschlagen: \(msg)"
        }
    }
}

final class BundleLoader {
    static func loadJSON<T: Decodable>(_ type: T.Type, filename: String) throws -> T {
        // 1) erst "questions.json"
        let name = (filename as NSString).deletingPathExtension
        let ext  = (filename as NSString).pathExtension

        let url =
            (!ext.isEmpty ? Bundle.main.url(forResource: name, withExtension: ext) : nil)
            ?? Bundle.main.url(forResource: filename, withExtension: nil)   // z.B. "questions" ohne Extension
            ?? Bundle.main.url(forResource: name, withExtension: nil)

        guard let fileURL = url else {
            throw BundleLoaderError.fileNotFound(filename)
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw BundleLoaderError.decodingFailed(error.localizedDescription)
        }
    }
}
