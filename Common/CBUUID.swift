import CoreBluetooth

extension CBUUID {
    static let serviceUUID = CBUUID(string: "c3230001-9308-47ae-ac12-3d030892a211")
    static let requestCharacteristicUUID = CBUUID(string: "6eb0f021-a7ba-7e7d-66c9-6d813f01d273")
    static let requestCharacteristicSecureUUID = CBUUID(string: "6eb0f025-bd60-7aaa-25a7-0029573f4f23")
    static let requestCharacteristicSecureV2UUID = CBUUID(string: "c3230002-9308-47ae-ac12-3d030892a211")
    static let responseCharacteristicUUID = CBUUID(string: "6eb0f024-bd60-7aaa-25a7-0029573f4f23")
    static let responseCharacteristicSecureUUID = CBUUID(string: "6eb0f027-a7ba-7e7d-66c9-6d813f01d273")
    static let responseCharacteristicSecureV2UUID = CBUUID(string: "c3230003-9308-47ae-ac12-3d030892a211")
}
