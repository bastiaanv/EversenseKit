import HealthKit
import LoopAlgorithm
import LoopKitUI
import SwiftUI

struct CalibrationGroup: Identifiable {
    let id = UUID()
    let date: String
    var items: [CalibrationHistoryItem]
}

struct CalibrationHistoryItem: Identifiable {
    let id = UUID()
    let time: String
    let glucose: String
    let flag: CalibrationFlag
}

class CalibrationHistoryViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var history: [CalibrationGroup] = []

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    private let glucosePreference: DisplayGlucosePreference
    private let logger = EversenseLogger(category: "CalibrationHistoryViewModel")
    private let cgmManager: EversenseCGMManager?
    init(cgmManager: EversenseCGMManager?, glucosePreference: DisplayGlucosePreference) {
        self.cgmManager = cgmManager
        self.glucosePreference = glucosePreference
    }

    func start() {
        guard let cgmManager = cgmManager else {
            logger.error("No CGMManager...")
            return
        }

        Task {
            await MainActor.run {
                isLoading = true
                history = []
            }

            do {
                if cgmManager.state.is365 {
                    logger.info("[365] sending GetLogRangePacket...")

                    let packet = Eversense365.GetLogRangePacket(
                        communicationVersion: cgmManager.state.communicationProtocol,
                        logType: .Calibrations
                    )
                    let rangeResponse: Eversense365.GetLogRangeResponse = try cgmManager.bluetoothManager.write(packet)

                    logger.info("[365] Got range - from: \(rangeResponse.rangeFrom), to: \(rangeResponse.rangeTo)")
                    let range = RangeCalculator.calculateRange(rangeFrom: rangeResponse.rangeFrom, rangeTo: rangeResponse.rangeTo)

                    guard range.from <= range.to else {
                        logger.warning("[365] No pages to fetch...")
                        await MainActor.run {
                            isLoading = false
                            history = []
                        }
                        return
                    }

                    logger.info("[365] Fetching range - from: \(range.from), to: \(range.to)")
                    let packet2 = Eversense365.GetCalibrationLogPacket(from: range.from, to: range.to)
                    let historyResponse: Eversense365.GetCalibrationLogResponse = try cgmManager.bluetoothManager.write(
                        packet2,
                        timeout: .seconds(15)
                    )

                    var tempHistory: [CalibrationGroup] = []
                    for item in historyResponse.calibrationHistory {
                        let quantity = LoopQuantity(unit: .milligramsPerDeciliter, doubleValue: Double(item.glucoseInMgDl))
                        let historyItem = CalibrationHistoryItem(
                            time: timeFormatter.string(from: item.datetime),
                            glucose: glucosePreference.format(quantity),
                            flag: item.flag
                        )

                        let date = dateFormatter.string(from: item.datetime)
                        if let index = tempHistory.firstIndex(where: { $0.date == date }) {
                            tempHistory[index].items.append(historyItem)
                        } else {
                            tempHistory.append(CalibrationGroup(
                                date: date,
                                items: [historyItem]
                            ))
                        }
                    }

                    await MainActor.run { [tempHistory] in
                        isLoading = false
                        history = tempHistory
                    }
                } else {
                    logger.info("[E3] sending GetLogRangePacket...")
                    let rangeResponse: EversenseE3.GetLogRangeResponse = try cgmManager.bluetoothManager
                        .write(EversenseE3.GetLogRangePacket(type: .calibration))

                    logger.info("[E3] Got range - from: \(rangeResponse.rangeFrom), to: \(rangeResponse.rangeTo)")
                    let range = RangeCalculator.calculateRange(rangeFrom: rangeResponse.rangeFrom, rangeTo: rangeResponse.rangeTo)

                    guard range.from <= range.to else {
                        logger.warning("[E3] No pages to fetch...")
                        await MainActor.run {
                            isLoading = false
                            history = []
                        }
                        return
                    }

                    logger.info("[E3] Fetching range - from: \(range.from), to: \(range.to)")
                    var tempHistory: [CalibrationGroup] = []
                    for index in range.from ... range.to {
                        let item: EversenseE3.GetCalibrationLogResponse = try cgmManager.bluetoothManager
                            .write(EversenseE3.GetCalibrationLogPacket(index: UInt16(index)))

                        let quantity = LoopQuantity(unit: .milligramsPerDeciliter, doubleValue: Double(item.glucoseInMgDl))
                        let historyItem = CalibrationHistoryItem(
                            time: timeFormatter.string(from: item.datetime),
                            glucose: glucosePreference.format(quantity),
                            flag: item.flag
                        )

                        let date = dateFormatter.string(from: item.datetime)
                        if let index = tempHistory.firstIndex(where: { $0.date == date }) {
                            tempHistory[index].items.append(historyItem)
                        } else {
                            tempHistory.append(CalibrationGroup(
                                date: date,
                                items: [historyItem]
                            ))
                        }
                    }

                    await MainActor.run { [tempHistory] in
                        isLoading = false
                        history = tempHistory
                    }
                }
            } catch {
                logger.error("Failed to fetch calibration history: \(error)")
            }
        }
    }
}
