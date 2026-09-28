import Foundation

/// Pure framing / matching helpers that live outside `PeripheralManager` so they
/// can be unit-tested without a `CBPeripheral`.
enum PacketFraming {
    static func appendReceivedChunk(_ data: Data, to buffer: inout Data, isE3: Bool) -> Bool {
        guard !data.isEmpty else {
            return false
        }

        if isE3 {
            buffer.append(data)
        } else {
            let headerLength = buffer.isEmpty ? 3 : 2
            guard data.count >= headerLength else {
                buffer = Data()
                return false
            }
            buffer.append(data.subdata(in: headerLength ..< data.count))
        }

        guard !buffer.isEmpty else {
            return false
        }
        return isE3 || data[0] == data[1]
    }

    static func matchesNotification(_ data: Data, pushId: Eversense365.PushIds) -> Bool {
        data.count >= 2 && data[0] == Eversense365.PacketIds.NotificationId.rawValue && data[1] == pushId.rawValue
    }
}
