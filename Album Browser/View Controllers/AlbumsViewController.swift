//
//  ViewController.swift
//  Album Browser
//
//  Created by Sudara Fernando on 11/12/21.
//

import UIKit

class AlbumsViewController: UIViewController {

	@IBOutlet weak var albumsTableView: UITableView!
	@IBOutlet weak var loadingView: UIActivityIndicatorView!

	private let refreshControl: UIRefreshControl = {
		let control = UIRefreshControl()
		control.addTarget(self, action: #selector(onRefreshRequested(_:)), for: .valueChanged)

		return control
	}()

	private let defaultCellConfiguration: UIListContentConfiguration = {
		var config = UIListContentConfiguration.subtitleCell()
		config.textProperties.font = .preferredFont(forTextStyle: .body)
		config.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption2)
		config.secondaryTextProperties.color = .gray

		return config
	}()

	private let albumsManager = AlbumManager()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.refreshData()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		self.albumsTableView.dataSource = self
		self.albumsTableView.refreshControl = self.refreshControl
	}

	override func viewWillAppear(_ animated: Bool) {
		if let selectedRows = self.albumsTableView.indexPathsForSelectedRows {
			// Clear the table view selection when user comes back
			selectedRows.forEach({ self.albumsTableView.deselectRow(at: $0, animated: false) })
		}
	}

	private func refreshData(forceRefresh: Bool = false) {
		Task {
			do {
				try await self.albumsManager.refreshAlbumsIfNecessary(forceRefresh: forceRefresh)
				try await self.albumsManager.refreshUsersIfNecessary(forceRefresh: forceRefresh)
			} catch {

			}

			guard !self.albumsManager.albums.isEmpty && !self.albumsManager.users.isEmpty else { return }
			self.albumsTableView.reloadData()
			self.refreshControl.endRefreshing()
		}
	}

	@objc private func onRefreshRequested(_ sender: Any) {
		self.refreshData(forceRefresh: true)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "AlbumDetailsSegue",
			let detailsVc = segue.destination as? AlbumsThumbnailsViewController,
			let originatingCell = sender as? UITableViewCell {

			detailsVc.albumsManager = self.albumsManager
			detailsVc.selectedAlbum = self.albumsManager.findAlbum(with: originatingCell.tag)
		}
	}
}

extension AlbumsViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.albumsManager.albums.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumViewCell", for: indexPath)

		let album = self.albumsManager.albums[indexPath.row]
		var config = self.defaultCellConfiguration
		config.text = album.title
		config.secondaryText = self.albumsManager.getUser(for: album)?.name

		cell.contentConfiguration = config
		cell.tag = album.id

		return cell
	}
}
