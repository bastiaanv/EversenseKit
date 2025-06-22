//
//  EncodingOperations.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 22/06/2025.
//

enum EncodingOperations {
    public static func encode(data: Data, splitLength: Int = 20) -> Data {
        let chunkSize = splitLength - 2
        let totalChunks = (data.count / chunkSize) + 1
        var result = Data()
        var currentIndex = 0

        for chunkIndex in 1...totalChunks {
            // Header for the first chunk is [1, totalChunks, 1]
            // Header for others is [chunkIndex, totalChunks]
            let header: [UInt8] = chunkIndex == 1 ? [1, UInt8(truncatingIfNeeded: totalChunks), 1] : [UInt8(truncatingIfNeeded: chunkIndex), UInt8(truncatingIfNeeded: totalChunks)]
            result.append(Data(header))

            let endIndex = min(currentIndex + chunkSize, data.count)
            let chunk = data.subdata(in: currentIndex..<endIndex)
            result.append(chunk)

            currentIndex = endIndex
        }

        return result
    }
    
    public static func split(data: Data, chunkSize: Int = 20) -> [Data] {
        guard chunkSize > 0, !data.isEmpty else {
            return []
        }

        var result: [Data] = []
        var index = data.startIndex

        while index < data.endIndex {
            let endIndex = data.index(index, offsetBy: chunkSize, limitedBy: data.endIndex) ?? data.endIndex
            let chunk = data[index..<endIndex]
            result.append(Data(chunk))
            index = endIndex
        }

        return result
    }
}
