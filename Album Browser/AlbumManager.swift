//
//  AlbumManager.swift
//  Album Browser
//
//  Created by Sudara Fernando on 13/12/21.
//

import Foundation

class AlbumManager {

	private static let baseUrl = "https://jsonplaceholder.typicode.com"

	enum ApiEndpoint: String {
		case albums = "albums"
		case users = "users"
		case photos = "photos"
	}

	enum AlbumManagerError: Error {
		case invalidUrl
		case serverError(status: Int)
	}

	var albums: [Album] = []
	var users: [User] = []
	var albumPhotos: [AlbumPhoto] = []

	func refreshAlbumsIfNecessary(forceRefresh: Bool = false) async throws {
		guard forceRefresh || self.albums.isEmpty else { return }

		self.albums = try await self.getData(endpoint: .albums, forceRefresh: forceRefresh)
	}

	func refreshUsersIfNecessary(forceRefresh: Bool = false) async throws {
		guard forceRefresh || self.users.isEmpty else { return }

		self.users = try await self.getData(endpoint: .users, forceRefresh: forceRefresh)
	}

	func refreshAlbumPhotosIfNecessary(forceRefresh: Bool = false) async throws {
		guard forceRefresh || self.albumPhotos.isEmpty else { return }

		self.albumPhotos = try await self.getData(endpoint: .photos, forceRefresh: forceRefresh)
	}

	func getUser(for album: Album) -> User? {
		return self.users.first(where: { $0.id == album.userId })
	}

	func findAlbum(with id: Int) -> Album? {
		return self.albums.first(where: { $0.id == id })
	}

	func findAlbumPhoto(with id: Int) -> AlbumPhoto? {
		return self.albumPhotos.first(where: { $0.id == id })
	}
	
	func findAlbumPhotos(for album: Album) -> [AlbumPhoto] {
		return self.albumPhotos.filter({ $0.albumId == album.id })
	}

	private func getData<T>(endpoint: ApiEndpoint, forceRefresh: Bool = false) async throws -> T where T: Codable {
		if !forceRefresh && self.canServeFromCache(endpoint: endpoint), let cached: T = self.getCacheData(endpoint: endpoint) {
			return cached
		}

		let result: T = try await self.downloadData(endpoint: endpoint)
		self.setCacheData(endpoint: endpoint, data: result)

		return result
	}
}

/// Network extension
fileprivate extension AlbumManager {

	func downloadData<T>(endpoint: ApiEndpoint) async throws -> T where T: Decodable {
		let request = try self.getUrlRequest(endpoint: endpoint)
		let (data, response) = try await URLSession.shared.data(for: request)

		guard (response as? HTTPURLResponse)?.statusCode == 200 else {
			throw AlbumManagerError.serverError(status: (response as? HTTPURLResponse)?.statusCode ?? 400)
		}

		return try data.decoded()
	}

	private func getUrlRequest(endpoint: ApiEndpoint) throws -> URLRequest {
		guard let url = URL(string: Self.baseUrl)?.appendingPathComponent(endpoint.rawValue) else {
			throw AlbumManagerError.invalidUrl
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.addValue("application/json", forHTTPHeaderField: "Accept")

		return request
	}
}

/// Cache Extension
fileprivate extension AlbumManager {

	func setCacheData<T>(endpoint: ApiEndpoint, data: T) where T: Encodable {
		guard let cachePath = self.getCachePathUrl(endpoint: endpoint) else {
			print("Unable to determine Cache Path - Caching data cancelled")
			return
		}

		do {
			let encoded = try data.encoded()
			try encoded.write(to: cachePath)

			UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "CACHED_\(endpoint.rawValue)")
		} catch {
			print("Unable to store Cached data - Caching data cancelled. Error: \(error.localizedDescription)")
		}
	}

	func getCacheData<T>(endpoint: ApiEndpoint) -> T? where T: Decodable {
		guard let cachePath = self.getCachePathUrl(endpoint: endpoint) else {
			print("Unable to determine Cache Path - Caching data cancelled")
			return nil
		}

		do {
			let data = try Data(contentsOf: cachePath)
			return try data.decoded()
		} catch {
			print("Unable to retrieve cached data - Error: \(error.localizedDescription)")
			return nil
		}
	}

	/// Returns true if the cached data is not expired (currently every 5 days)
	func canServeFromCache(endpoint: ApiEndpoint) -> Bool {
		guard let cachedDate = self.getCachedDate(endpoint: endpoint) else { return false }
		guard let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date()) else { return false }

		return cachedDate > fiveDaysAgo
	}

	private func getCachedDate(endpoint: ApiEndpoint) -> Date? {
		let cachedDateRaw = UserDefaults.standard.double(forKey: "CACHED_\(endpoint.rawValue)")
		guard cachedDateRaw != 0 else {
			return nil
		}

		return Date(timeIntervalSince1970: cachedDateRaw)
	}

	private func getCachePathUrl(endpoint: ApiEndpoint) -> URL? {
		let cachePaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
		return cachePaths.first?.appendingPathComponent("downloded_\(endpoint.rawValue).json")
	}
}
