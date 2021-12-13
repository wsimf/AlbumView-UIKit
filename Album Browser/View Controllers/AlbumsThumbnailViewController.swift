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
