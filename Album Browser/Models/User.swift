//
//  User.swift
//  Album Browser
//
//  Created by Sudara Fernando on 13/12/21.
//

import Foundation

struct User: Codable, Equatable, Hashable {

	var id: String
	var name: String
	var userName: String
	var email: String
	var phone: String
}
