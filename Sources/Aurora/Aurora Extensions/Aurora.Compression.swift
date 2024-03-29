// Aurora framework for Swift
//
// The **Aurora.framework** contains a base for your project.
//
// It has a lot of extensions built-in to make development easier.
//
// - Version: 1.0
// - Copyright: [Wesley de Groot](https://wesleydegroot.nl) ([WDGWV](https://wdgwv.com))\
//  and [Contributors](https://github.com/AuroraFramework/Aurora.swift/graphs/contributors).
//
// Thanks for using!
//
// Licence: MIT

import Foundation
import Compression

public extension Aurora {
    /// Compresses the data using the zlib deflate algorithm.
    /// - Parameter data: data to be compressed
    /// - Returns: compressed data
    func compress(data: Data) -> Data? {
        return data.deflate()
    }

    /// Decompresses the data using the zlib deflate algorithm.
    /// - Parameter data: data to be decompressed
    /// - Returns: uncompressed data
    func decompress(data: Data) -> Data? {
        return data.inflate()
    }
}
