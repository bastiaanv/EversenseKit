enum AuthenticationApi {
    private static let tokenUrl = "https://usiamapi.eversensedms.com/connect/token"
    private static let clientId = "eversenseMMAAndroid"
    private static let clientSecret = "6ksPx#]~wQ3U"

    private static let logger = EversenseLogger(category: "AuthenticationApi")

    static func login(username: String, password: String) async throws -> AuthResponse {
        guard let url = URL(string: tokenUrl) else {
            logger.error("Could not create URL...")
            throw NSError(domain: "Could not create URL...", code: -1)
        }

        do {
            let message = [
                "grant_type=password",
                "client_id=\(clientId)",
                "client_secret=\(clientSecret)",
                "username=\(username)",
                "password=\(password)"
            ].joined(separator: "&")

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = message.data(using: .utf8)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                let message =
                    "Got invalid response from Authentication: \((response as? HTTPURLResponse)?.statusCode ?? -1) \(String(data: data, encoding: .utf8) ?? "No data")"

                logger.error(message)
                throw NSError(domain: message, code: -1)
            }

            return try! JSONDecoder().decode(AuthResponse.self, from: data)
        } catch {
            logger.error("Failed to do request: \(error.localizedDescription)")
            throw error
        }
    }
}
