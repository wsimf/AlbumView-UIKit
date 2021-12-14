//
//  AlbumsThumbnailViewController.swift
//  Album Browser
//
//  Created by Sudara Fernando on 13/12/21.
//

import Foundation
import UIKit

class AlbumsThumbnailsViewController: UIViewController {

	@IBOutlet weak var collectionView: UICollectionView!

	var selectedAlbum: Album?
	var albumsManager: AlbumManager?

	var albumPhotos: [AlbumPhoto] = [] {
		didSet {
			self.collectionView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = self.selectedAlbum?.title

		if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.itemSize = CGSize(width: 80, height: 80)
		}

		self.refreshData()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		self.collectionView.dataSource = self
	}

	private func refreshData(forceRefresh: Bool = false) {
		if let albumsManager = self.albumsManager {
			Task {
				do {
					try await albumsManager.refreshAlbumPhotosIfNecessary(forceRefresh: forceRefresh)
				} catch {
					self.showDataAccessError(error: error)
				}

				if let album = self.selectedAlbum {
					self.albumPhotos = albumsManager.findAlbumPhotos(for: album)
				}
			}
		}
	}

	func showDataAccessError(error: Error) {
		let alert = UIAlertController(title: "Unable to access album photos", message: "Album photos are not available. Error: \(error.localizedDescription). Please try again", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] (_) in
			alert.dismiss(animated: true, completion: nil)
			self?.refreshData(forceRefresh: true)
		}))

		self.present(alert, animated: true, completion: nil)
	}
}

extension AlbumsThumbnailsViewController: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.albumPhotos.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailViewCell", for: indexPath) as! ThumbnailViewCell

		return cell
	}
}

class ThumbnailViewCell : UICollectionViewCell {

	@IBOutlet private weak var thumbnailView: UIImageView!

	var thumbnailId: String = ""

	override func prepareForReuse() {
		super.prepareForReuse()

		self.thumbnailView.image = nil
	}

	func setImage(image: UIImage) {
		self.thumbnailView.image = image
	}
}
