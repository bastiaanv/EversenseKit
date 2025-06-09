enum KeyVaultApi {
    static let baseUrl = "https://deviceauthorization.eversensedms.com/api/vault"
    static let transmitterNo = "000000"
    static let clientNo = 2
    static let clientType = 128

    static let logger = EversenseLogger(category: "KeyVaultApi")

    static func getFleetSecret(accessToken: String) async -> SecureKeyResponse? {
        guard let url = URL(string: "\(baseUrl)/GetTxFleetSecret?transmitterNo=\(transmitterNo)&clientNo=\(clientNo)") else {
            logger.error("Could not create URL...")
            return nil
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                logger
                    .error(
                        "Got invalid response from KeyVault: \((response as? HTTPURLResponse)?.statusCode ?? -1) \(String(data: data, encoding: .utf8) ?? "No data")"
                    )
                return nil
            }

            return try! JSONDecoder().decode(SecureKeyResponse.self, from: data)
        } catch {
            logger.error("Failed to do request: \(error.localizedDescription)")
            return nil
        }
    }

    static func getFleetSecretV2(
        accessToken: String,
        serialNumber: String,
        nonce: String,
        flags: Bool,
        uniqueId: String
    ) async -> SecureKeyResponse? {
        guard let url =
            URL(
                string: "\(baseUrl)/GetTxCertificate?txSerialNumber=\(serialNumber)&clientNo=\(clientNo)&nonce=\(nonce)&tx_flags=\(flags)&client_type=\(clientType)&kp_client_unique_id=\(uniqueId)"
            )
        else {
            logger.error("Could not create URL...")
            return nil
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = ["Authorization": "Bearer \(accessToken)"]

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                logger
                    .error(
                        "Got invalid response from KeyVault: \((response as? HTTPURLResponse)?.statusCode ?? -1) \(String(data: data, encoding: .utf8) ?? "No data")"
                    )
                return nil
            }

            return try! JSONDecoder().decode(SecureKeyResponse.self, from: data)
        } catch {
            logger.error("Failed to do request: \(error.localizedDescription)")
            return nil
        }
    }
}
