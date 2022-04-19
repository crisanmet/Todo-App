//
//  Category.swift
//  Todo App
//
//  Created by Cristian Sancricca on 17/04/2022.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
