//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

public final class DictionaryDecoder {

    public let decoder: JSONDecoder

    public init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }

    /// Decodes an object from passed dictionary.
    /// - Parameters:
    ///   - dictionary: The dictionary for decoding.
    public func decode<T: Decodable>(from dictionary: [String: Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return try decoder.decode(T.self, from: data)
    }
}
