//
//  AlbumsThumbnailViewController.swift
//  Album Browser
//
//  Created by Sudara Fernando on 13/12/21.
//

import Foundation
import UIKit

class AlbumsThumbnailsViewController: UIViewController {

	private let cachedImageManager = CachedImageManager()

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
		self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

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
		let alert = UIAlertController(title: "Unable to access album photos",
									  message: "Album photos are not available. Error: \(error.localizedDescription). Please try again",
									  preferredStyle: .alert)

		alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] (_) in
			alert.dismiss(animated: true, completion: nil)
			self?.refreshData(forceRefresh: true)
		}))

		self.present(alert, animated: true, completion: nil)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "AlbumPhotoSegue",
			let detailsVc = segue.destination as? AlbumsPhotoViewController,
			let originatingCell = sender as? ThumbnailViewCell {

			detailsVc.albumManager = self.albumsManager
			detailsVc.cachedImageManager = self.cachedImageManager
			detailsVc.selectedAlbumPhoto = self.albumsManager?.findAlbumPhoto(with: originatingCell.photoId)
		}
	}
}

extension AlbumsThumbnailsViewController: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.albumPhotos.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailViewCell", for: indexPath) as! ThumbnailViewCell
		let photo = self.albumPhotos[indexPath.row]

		cell.setErrorImage()

		Task {
			do {
				let image = try await self.cachedImageManager.fetchImage(photo.thumbnailUrl)
				cell.setImage(image: image)
			} catch {
				cell.setErrorImage()
			}
		}

		cell.photoId = photo.id
		return cell
	}
}

class ThumbnailViewCell : UICollectionViewCell {

	@IBOutlet private weak var thumbnailView: UIImageView!

	var photoId: Int {
		get { return self.tag }
		set { self.tag = newValue }
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.thumbnailView.image = nil
		self.photoId = 0
	}

	func setImage(image: UIImage) {
		self.thumbnailView.image = image
	}

	func setErrorImage() {
		let errorImage = UIImage(systemName: "exclamationmark.triangle")!
		self.setImage(image: errorImage)
	}
}
