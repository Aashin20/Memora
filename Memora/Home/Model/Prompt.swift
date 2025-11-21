// Prompt.swift
import Foundation
import UIKit

struct Prompt {
    // name of the image asset (e.g. "prompt_sample_image") or SF symbol name
    let iconName: String
    let text: String
    let category: String   // new: category to filter by (e.g. "Memories", "Travel", ...)
    let id: UUID

    init(iconName: String, text: String, category: String) {
        self.iconName = iconName
        self.text = text
        self.category = category
        self.id = UUID()
    }
}

// sample data
struct PromptData {
    static let samplePrompts: [Prompt] = [
        Prompt(iconName: "prompt_sample_image", text: "Tell about your childhood, what is your best memory?", category: "Childhood"),
        Prompt(iconName: "prompt_sample_image", text: "Describe your first trip to the sea.", category: "Travel"),
        Prompt(iconName: "prompt_sample_image", text: "What book or movie changed your perspective on life?", category: "Life Lesson"),
        Prompt(iconName: "prompt_sample_image", text: "What’s the most beautiful place you’ve ever been to?", category: "Travel")
    ]
}
