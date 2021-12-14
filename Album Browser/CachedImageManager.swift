//
//  CachedImageManager.swift
//  Album Browser
//
//  Created by Sudara Fernando on 14/12/21.
//

import Foundation
import UIKit

class CachedImageManager {

	private let cache = NSCache<NSString, NSData>()

	enum CachedImageManagerError: Error {
		case invalidUrl
		case serverError(status: Int)
		case badImageData
	}
	
	func fetchImage(_ rawUrl: String) async throws -> UIImage {
		guard let url = URL(string: rawUrl) else {
			throw CachedImageManagerError.invalidUrl
		}

		if let data = self.cache.object(forKey: url.path as NSString), let image = UIImage(data: data as Data) {
			return image
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"

		let (data, response) = try await URLSession.shared.data(for: request)
		guard (response as? HTTPURLResponse)?.statusCode == 200 else {
			throw CachedImageManagerError.serverError(status: (response as? HTTPURLResponse)?.statusCode ?? 400)
		}

		self.cache.setObject(data as NSData, forKey: url.path as NSString, cost: data.count)

		guard let image = UIImage(data: data) else {
			throw CachedImageManagerError.badImageData
		}

		return image
	}
}
