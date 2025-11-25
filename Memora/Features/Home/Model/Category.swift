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
        Category(title: "Recipies",     slug: "recipies", iconName: "prompt_sample_image"),
        Category(title: "Childhood",    slug: "childhood", iconName: "prompt_sample_image"),
        Category(title: "Travel",       slug: "travel", iconName: "prompt_sample_image"),
        Category(title: "Love",         slug: "love", iconName: "prompt_sample_image"),
        Category(title: "Life Lessons", slug: "life_lessons", iconName: "prompt_sample_image")
    ]
}
