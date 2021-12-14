//
//  AlbumsPhotoViewController.swift
//  Album Browser
//
//  Created by Sudara Fernando on 14/12/21.
//

import Foundation
import UIKit

class AlbumsPhotoViewController: UIViewController {

	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var photoTitleLabel: UILabel!
	@IBOutlet weak var albumTitleLabel: UILabel!

	var selectedAlbumPhoto: AlbumPhoto?

	var albumManager: AlbumManager?
	var cachedImageManager: CachedImageManager?

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if let albumPhoto = self.selectedAlbumPhoto, let album = self.albumManager?.findAlbum(with: albumPhoto.albumId) {
			self.photoTitleLabel.text = albumPhoto.title
			self.albumTitleLabel.text = album.title

			if let cachedImageManager = self.cachedImageManager {
				Task {
					do {
						let image = try await cachedImageManager.fetchImage(albumPhoto.url)
						self.activityIndicatorView.stopAnimating()
						self.imageView.image = image
					} catch {
						self.activityIndicatorView.stopAnimating()
					}
				}
			}
		}
	}
}
