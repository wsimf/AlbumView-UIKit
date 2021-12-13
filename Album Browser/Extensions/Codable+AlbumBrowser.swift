//
//  Codable+AlbumBrowser.swift
//  Album Browser
//
//  Created by Sudara Fernando on 13/12/21.
//

import Foundation

extension Data {

	func decoded<T: Decodable>(using decoder: AnyDecoder = JSONDecoder()) throws -> T {
		return try decoder.decode(T.self, from: self)
	}
}

extension Encodable {

	func encoded(using encoder: AnyEncoder = JSONEncoder()) throws -> Data {
		return try encoder.encode(self)
	}
}

protocol AnyDecoder {
	func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

protocol AnyEncoder {
	func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONDecoder: AnyDecoder { }
extension JSONEncoder: AnyEncoder { }

extension PropertyListDecoder: AnyDecoder { }
extension PropertyListEncoder: AnyEncoder { }
