import Foundation

enum AppConfig {

    static var supabaseURL: URL {
        let raw = Bundle.main.object(
            forInfoDictionaryKey: "SUPABASE_URL"
        ) as? String ?? ""

        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let url = URL(string: value) else {
            fatalError("SUPABASE_URL invalid: '\(raw)'")
        }

        return url
    }

    static var supabaseAnonKey: String {
        let raw = Bundle.main.object(
            forInfoDictionaryKey: "SUPABASE_ANON_KEY"
        ) as? String ?? ""

        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !value.isEmpty else {
            fatalError("SUPABASE_ANON_KEY missing")
        }

        return value
    }

    static var apiBaseURL: URL {
        let raw = Bundle.main.object(
            forInfoDictionaryKey: "API_BASE_URL"
        ) as? String ?? ""

        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let url = URL(string: value) else {
            fatalError("API_BASE_URL invalid: '\(raw)'")
        }

        return url
    }
}
