//
//  Data.swift
//  Todo App
//
//  Created by Cristian Sancricca on 16/04/2022.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
