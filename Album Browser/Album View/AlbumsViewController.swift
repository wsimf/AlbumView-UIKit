//
//  ViewController.swift
//  Album Browser
//
//  Created by Sudara Fernando on 11/12/21.
//

import UIKit

class AlbumsViewController: UIViewController {

	@IBOutlet weak var albumsTableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Albums"
		// Do any additional setup after loading the view.
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		self.albumsTableView.dataSource = self
	}
}

extension AlbumsViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableView.dequeueReusableCell(withIdentifier: "AlbumViewCell", for: indexPath)
	}
}
