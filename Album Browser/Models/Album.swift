//
//  Albums.swift
//  Album Browser
//
//  Created by Sudara Fernando on 13/12/21.
//

import Foundation

struct Album: Codable, Equatable, Hashable {

	var userId: Int
	var id: Int
	var title: String
}

