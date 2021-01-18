//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

public protocol Appendable {
    var bigEndian: Self { get }
}

public protocol Extractable {
    init(bigEndian: Self)
    static var stride: Int { get }
}

extension FixedWidthInteger {
    public static var stride: Int {
        return bitWidth / 8
    }
}

extension UInt8: Extractable, Appendable {}

extension Int8: Extractable, Appendable {}

extension UInt16: Extractable, Appendable {}

extension Int16: Extractable, Appendable {}

extension UInt32: Extractable, Appendable {}

extension Int32: Extractable, Appendable {}

extension UInt64: Extractable, Appendable {}

extension Int64: Extractable, Appendable {}

extension Data {

    public mutating func append<T: Appendable>(_ element: T) {
        var value = element.bigEndian
        append(UnsafeBufferPointer(start: &value, count: 1))
    }

    public mutating func append<T: Appendable>(_ elements: [T]) {
        let values = elements.map { (element: T) -> T in
            return element.bigEndian
        }
        values.withUnsafeBufferPointer { (values: UnsafeBufferPointer<T>) -> Void in
            self.append(values)
        }
    }

    public mutating func extract() -> UInt8? {
        return popFirst()
    }

    public mutating func extract(count: Int) -> Data? {
        defer {
            removeFirst(count)
        }

        return subdata(in: indices.lowerBound..<(indices.lowerBound + count))
    }

    public mutating func extract<T: Extractable>(usingHostByteOrder: Bool = false) -> T? {
        let bigEndian: T? = extract(count: T.stride)?.withUnsafeBytes { (pointer) -> T in
            return pointer.pointee
        }
        guard let value = bigEndian else {
            return nil
        }

        return usingHostByteOrder ? value: T(bigEndian: value)
    }
}
