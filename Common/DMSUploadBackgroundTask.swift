import UIKit

/// Runs an async operation while holding a UIKit background task assertion, giving the DMS
/// network requests time to finish after the CGM fetch callback has already returned.
enum DMSUploadBackgroundTask {
    static func run(_ operation: () async -> Void) async {
        let taskID = await MainActor.run {
            UIApplication.shared.beginBackgroundTask(withName: "EversenseDMSUpload")
        }

        await operation()

        await MainActor.run {
            if taskID != .invalid {
                UIApplication.shared.endBackgroundTask(taskID)
            }
        }
    }
}
