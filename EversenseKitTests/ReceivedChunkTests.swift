@testable import EversenseKit
import Foundation
import Testing

struct ReceivedChunkTests {
    @Test(arguments: [true, false])
    func ignoresEmptyUpdates(isE3: Bool) {
        var buffer = Data()
        #expect(!PeripheralManager.appendReceivedChunk(Data(), to: &buffer, isE3: isE3))
        #expect(buffer.isEmpty)
    }

    @Test(arguments: [1, 2])
    func rejectsTruncatedInitial365Header(length: Int) {
        var buffer = Data()
        #expect(!PeripheralManager.appendReceivedChunk(Data(repeating: 0, count: length), to: &buffer, isE3: false))
        #expect(buffer.isEmpty)
    }

    @Test func rejectsTruncatedContinuationAndClearsBuffer() {
        var buffer = Data([0x0b])
        #expect(!PeripheralManager.appendReceivedChunk(Data([0]), to: &buffer, isE3: false))
        #expect(buffer.isEmpty)
    }

    @Test func rejectsHeaderWithoutPayload() {
        var buffer = Data()
        #expect(!PeripheralManager.appendReceivedChunk(Data([0, 0, 0]), to: &buffer, isE3: false))
        #expect(buffer.isEmpty)
    }

    @Test(arguments: [true, false])
    func emptyUpdatePreservesPendingBuffer(isE3: Bool) {
        var buffer = Data([0x0b])
        #expect(!PeripheralManager.appendReceivedChunk(Data(), to: &buffer, isE3: isE3))
        #expect(buffer == Data([0x0b]))
    }

    @Test func preservesE3Bytes() {
        var buffer = Data()
        let packet = Data([0x88, 1, 2, 3])
        #expect(PeripheralManager.appendReceivedChunk(packet, to: &buffer, isE3: true))
        #expect(buffer == packet)
    }

    @Test func preservesSingle365Chunk() {
        var buffer = Data()
        #expect(PeripheralManager.appendReceivedChunk(Data([0, 0, 0, 0x0b, 0x12]), to: &buffer, isE3: false))
        #expect(buffer == Data([0x0b, 0x12]))
    }

    @Test func preservesMultiple365Chunks() {
        var buffer = Data()
        #expect(!PeripheralManager.appendReceivedChunk(Data([0, 1, 0, 0x0b, 0x12]), to: &buffer, isE3: false))
        #expect(buffer == Data([0x0b, 0x12]))
        #expect(PeripheralManager.appendReceivedChunk(Data([1, 1, 0x34]), to: &buffer, isE3: false))
        #expect(buffer == Data([0x0b, 0x12, 0x34]))
    }

    @Test func headerOnlyFinalChunkPreservesPendingPayload() {
        var buffer = Data([0x0b, 0x12])
        #expect(PeripheralManager.appendReceivedChunk(Data([1, 1]), to: &buffer, isE3: false))
        #expect(buffer == Data([0x0b, 0x12]))
    }
}
