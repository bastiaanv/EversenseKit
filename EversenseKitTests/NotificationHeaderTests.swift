@testable import EversenseKit
import Foundation
import Testing

struct NotificationHeaderTests {
    @Test(arguments: [Eversense365.PushIds.KeepAlive, .AlarmWithData])
    func rejectsTruncatedNotificationHeader(pushId: Eversense365.PushIds) {
        let data = Data([Eversense365.PacketIds.NotificationId.rawValue])
        #expect(!PeripheralManager.matchesNotification(data, pushId: pushId))
    }

    @Test(arguments: [Eversense365.PushIds.KeepAlive, .AlarmWithData])
    func preservesNotificationMatching(pushId: Eversense365.PushIds) {
        let data = Data([Eversense365.PacketIds.NotificationId.rawValue, pushId.rawValue])
        #expect(PeripheralManager.matchesNotification(data, pushId: pushId))
        #expect(!PeripheralManager.matchesNotification(Data([0, pushId.rawValue]), pushId: pushId))
        let other: Eversense365.PushIds = pushId == .KeepAlive ? .AlarmWithData : .KeepAlive
        #expect(!PeripheralManager.matchesNotification(data, pushId: other))
    }
}
