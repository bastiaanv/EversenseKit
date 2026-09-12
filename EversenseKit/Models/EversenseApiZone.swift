public enum EversenseApiZone: UInt8 {
    case US = 1
    case OutsideUS = 2

    var label: String {
        switch self {
        case .US: return String(localized: "US", comment: "us label apizone")
        case .OutsideUS: return String(localized: "Outside US", comment: "us label apizone")
        }
    }

    var careUrl: String {
        switch self {
        case .US:
            return "https://usapialpha.eversensedms.com/"
        case .OutsideUS:
            return "https://ousalphaapiservices.eversensedms.com/"
        }
    }

    var diagnosticUrl: String {
        switch self {
        case .US:
            return "https://usmobileappmsprod.eversensedms.com/api/v1.0/DiagnosticLog/"
        case .OutsideUS:
            return "https://ousmobileappmsprod.eversensedms.com/api/v1.0/DiagnosticLog/"
        }
    }

    var tokenUrl: String {
        switch self {
        case .US:
            return "https://usiamapi.eversensedms.com/connect/token"
        case .OutsideUS:
            return "https://ousiamapialpha.eversensedms.com/connect/token"
        }
    }

    var registerUrl: String {
        switch self {
        case .US:
            return "https://us.eversensedms.com/Account/Register"
        case .OutsideUS:
            return "https://global.eversensedms.com/registration"
        }
    }

    var forgotPasswordUrl: String {
        switch self {
        case .US:
            return "https://us.eversensedms.com/Account/ForgotPassword"
        case .OutsideUS:
            return "https://global.eversensedms.com/forgotpassword"
        }
    }

    var keyVaultUrl: String {
        switch self {
        case .US:
            return "https://deviceauthorization.eversensedms.com/api/vault"
        case .OutsideUS:
            return "https://ousdeviceauthorization.eversensedms.com/api/vault"
        }
    }

    static var all: [EversenseApiZone] {
        [.US, .OutsideUS]
    }
}
