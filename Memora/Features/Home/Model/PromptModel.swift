//
//  PromptModel.swift
//  Home
//
//  Created by user@3 on 11/11/25.
//

import Foundation
import UIKit

// MARK: - Prompt model (single image only)
struct DetailedPrompt: Hashable, Codable {
    let id: UUID
    let title: String
    let text: String
    let imageURL: String?        // single image URL (nil if none)
    let categorySlug: String
    let createdAt: Date
    let authorId: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        text: String,
        imageURL: String? = nil,
        categorySlug: String,
        createdAt: Date = Date(),
        authorId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.imageURL = imageURL
        self.categorySlug = categorySlug
        self.createdAt = createdAt
        self.authorId = authorId
    }
}

// MARK: - Sample Prompt Data
struct DetailedPromptData {
    static let samplePrompts: [DetailedPrompt] = [
        // 🍝 Recipies
        DetailedPrompt(
            title: "Family Pasta",
            text: "Share your favorite pasta recipe and who made it special.",
            imageURL: "https://images.unsplash.com/photo-1504674900247-0877df9cc836",
            categorySlug: "recipies",
            authorId: Session.shared.currentUser.id
        ),
        DetailedPrompt(
            title: "Comfort Food",
            text: "What dish comforts you the most and why?",
            imageURL: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe",
            categorySlug: "recipies",
            authorId: Session.shared.currentUser.id
        ),

        // 🌈 Childhood
        DetailedPrompt(
            title: "Best Childhood Memory",
            text: "Tell about your childhood — what is your best memory?",
            imageURL: "https://images.unsplash.com/photo-1503457574462-bd27054394c1",
            categorySlug: "childhood",
            authorId: Session.shared.currentUser.id
        ),
        DetailedPrompt(
            title: "Childhood Friends",
            text: "Who was your childhood best friend and what did you do together?",
            imageURL: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1",
            categorySlug: "childhood",
            authorId: Session.shared.currentUser.id
        ),

        // ✈️ Travel
        DetailedPrompt(
            title: "Most Beautiful Place",
            text: "What’s the most beautiful place you’ve ever been to?",
            imageURL: "https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1",
            categorySlug: "travel",
            authorId: Session.shared.currentUser.id
        ),
        DetailedPrompt(
            title: "First Solo Trip",
            text: "Where did you go on your first solo trip and what happened?",
            imageURL: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
            categorySlug: "travel",
            authorId: Session.shared.currentUser.id
        ),

        // ❤️ Love
        DetailedPrompt(
            title: "A Small Love Moment",
            text: "Share a small moment about someone you love.",
            imageURL: "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e",
            categorySlug: "love",
            authorId: Session.shared.currentUser.id
        ),
        DetailedPrompt(
            title: "A Meaningful Gift",
            text: "Describe a gift that meant the most to you and why.",
            imageURL: "https://images.unsplash.com/photo-1517841905240-472988babdf9",
            categorySlug: "love",
            authorId: Session.shared.currentUser.id
        ),

        // 🌱 Life Lessons
        DetailedPrompt(
            title: "A Lesson Learned",
            text: "What is a life lesson you learned the hard way?",
            imageURL: "https://images.unsplash.com/photo-1504196606672-aef5c9cefc92",
            categorySlug: "life_lessons",
            authorId: Session.shared.currentUser.id
        ),
        DetailedPrompt(
            title: "Advice to Younger Self",
            text: "What single piece of advice would you give your younger self?",
            imageURL: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f",
            categorySlug: "life_lessons",
            authorId: Session.shared.currentUser.id
        )
    ]

    // Helper: filter prompts by category slug
    static func prompts(forCategorySlug slug: String) -> [DetailedPrompt] {
        return samplePrompts.filter { $0.categorySlug == slug }
    }
}
