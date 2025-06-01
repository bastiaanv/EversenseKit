//
//  AuthenticationApi.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 01/06/2025.
//

class AuthenticationApi {
    static let tokenUrl = "https://usiamapi.eversensedms.com/connect/token"
    static let clientId = "eversenseMMAAndroid"
    static let clientSecret = "6ksPx#]~wQ3U"
    
    static let logger = EversenseLogger(category: "AuthenticationApi")
    
    static func login(username: String, password: String) async -> AuthResponse? {
        guard let url = URL(string: tokenUrl) else {
            logger.error("Could not create URL...")
            return nil
        }

        do {
            let accessToken = ""
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = Data("grant_type=password&client_id=\(clientId)&client_secret=\(clientSecret)&username=\(username)&password=\(password)".utf8)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                logger.error("Got invalid response from Authentication: \((response as? HTTPURLResponse)?.statusCode ?? -1) \(String(data: data, encoding: .utf8) ?? "No data")")
                return nil
            }
            
            return try! JSONDecoder().decode(AuthResponse.self, from: data)
        } catch {
            logger.error("Failed to do request: \(error.localizedDescription)")
            return nil
        }
    }
}
