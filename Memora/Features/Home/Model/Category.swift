//
//  Category.swift
//  Home
//
//  Created by you on 11/11/25.
//

import Foundation
import UIKit

struct Category: Hashable {
    let id: UUID
    let title: String
    let slug: String          // used to match prompts (e.g. "childhood")
    let iconName: String?     // optional SF Symbol or asset name

    init(id: UUID = UUID(), title: String, slug: String, iconName: String? = nil) {
        self.id = id
        self.title = title
        self.slug = slug
        self.iconName = iconName
    }
}

struct CategoryData {
    // EXACT categories you requested (use these slugs when filtering prompts)
    static let sample: [Category] = [
        Category(title: "Recipies",     slug: "recipies", iconName: "Image"),
        Category(title: "Childhood",    slug: "childhood", iconName: "hand.raised"),
        Category(title: "Travel",       slug: "travel", iconName: "airplane"),
        Category(title: "Love",         slug: "love", iconName: "heart.fill"),
        Category(title: "Life Lessons", slug: "life_lessons", iconName: "book.closed")
    ]
}
