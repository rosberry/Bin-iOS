//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class DictionaryEncoder {

    public enum Error: Swift.Error {
        case wrongType
    }

    public let encoder: JSONEncoder

    public init(encoder: JSONEncoder = .init()) {
        self.encoder = encoder
    }

    /// Encodes passed value using JSONSerialization.
    /// - Parameter value: The value for encoding
    public func encode<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try encoder.encode(value)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let dictionary = jsonObject as? [String: Any] else {
            throw Error.wrongType
        }
        return dictionary
    }
}
