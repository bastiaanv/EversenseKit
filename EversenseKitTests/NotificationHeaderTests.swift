@testable import EversenseKit
import Foundation
import Testing

struct NotificationHeaderTests {
    @Test(arguments: [
        Eversense365.PushIds.KeepAlive,
        .AlarmWithData
    ]) func rejectsTruncatedNotificationHeader(pushId: Eversense365.PushIds) {
        let data = Data([Eversense365.PacketIds.NotificationId.rawValue])
        #expect(!PacketFraming.matchesNotification(data, pushId: pushId))
    }

    @Test(arguments: [Eversense365.PushIds.KeepAlive, .AlarmWithData]) func preservesNotificationMatching(
        pushId: Eversense365
            .PushIds
    ) {
        let data = Data([Eversense365.PacketIds.NotificationId.rawValue, pushId.rawValue])
        #expect(PacketFraming.matchesNotification(data, pushId: pushId))
        #expect(!PacketFraming.matchesNotification(Data([0, pushId.rawValue]), pushId: pushId))
        let other: Eversense365.PushIds = pushId == .KeepAlive ? .AlarmWithData : .KeepAlive
        #expect(!PacketFraming.matchesNotification(data, pushId: other))
    }
}
