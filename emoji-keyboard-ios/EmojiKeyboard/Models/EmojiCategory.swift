import Foundation

struct EmojiCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let emojis: [String]
    
    init(name: String, emojis: [String]) {
        self.name = name
        self.emojis = emojis
    }
    
    // For search and filtering
    func contains(_ searchText: String) -> Bool {
        return name.localizedCaseInsensitiveContains(searchText) ||
               emojis.contains { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    // Get emojis filtered by search text
    func filteredEmojis(searchText: String) -> [String] {
        guard !searchText.isEmpty else { return emojis }
        
        return emojis.filter { emoji in
            // For now, just return all emojis if category matches
            // Later you could add emoji name/description matching
            return name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // Category order for consistent sorting
    static let categoryOrder: [String] = [
        "Recent",
        "Smileys & Emotion",
        "People & Body",
        "Animals & Nature",
        "Food & Drink",
        "Activities",
        "Travel & Places",
        "Objects",
        "Symbols",
        "Flags"
    ]
    
    // Get the sort order for this category
    var sortOrder: Int {
        if let index = EmojiCategory.categoryOrder.firstIndex(of: name) {
            return index
        }
        return EmojiCategory.categoryOrder.count
    }
}

// MARK: - Category Icons

extension EmojiCategory {
    var icon: String {
        switch name {
        case "Recent":
            return "🕒"
        case "Smileys & Emotion":
            return "😊"
        case "People & Body":
            return "👋"
        case "Animals & Nature":
            return "🦊"
        case "Food & Drink":
            return "🍔"
        case "Activities":
            return "⚽️"
        case "Travel & Places":
            return "✈️"
        case "Objects":
            return "💡"
        case "Symbols":
            return "💟"
        case "Flags":
            return "🏁"
        default:
            return "🔍"
        }
    }
}

// MARK: - Emoji Extensions

extension String {
    var isEmoji: Bool {
        return unicodeScalars.allSatisfy { scalar in
            scalar.properties.isEmoji || scalar.properties.isEmojiPresentation
        }
    }
    
    var emojiDescription: String? {
        // This could be enhanced to return descriptions for emojis
        // For now, just return the emoji itself
        return self.isEmoji ? self : nil
    }
} 