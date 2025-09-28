import Foundation

// MARK: - Comprehensive Emoji Loading Extension
extension EmojiDataService {
    
    func loadComprehensiveEmojis() {
        isLoading = true
        emojiCategories = generateComprehensiveEmojiCategories()
        isLoading = false
    }
    
    // Additional Unicode ranges for complete emoji coverage
    private struct EmojiUnicodeRanges {
        static let all: [(Range<Int>, String)] = [
            // Emoticons
            (0x1F600..<0x1F650, "Smileys & Emotion"),  // Face emoticons
            (0x1F910..<0x1F930, "Smileys & Emotion"),  // Additional face emoticons
            (0x1F970..<0x1F980, "Smileys & Emotion"),  // More emotions
            
            // People & Body
            (0x1F466..<0x1F488, "People & Body"),      // People
            (0x1F48B..<0x1F4AB, "People & Body"),      // Person symbols
            (0x1F574..<0x1F576, "People & Body"),      // More people
            (0x1F645..<0x1F648, "People & Body"),      // Gestures
            (0x1F481..<0x1F484, "People & Body"),      // Additional people
            (0x1F485..<0x1F488, "People & Body"),      // More people
            (0x1F4AA..<0x1F4AC, "People & Body"),      // Body parts
            (0x1F926..<0x1F938, "People & Body"),      // More gestures
            (0x1F9B0..<0x1F9BA, "People & Body"),      // Person details
            (0x1F9D1..<0x1F9DE, "People & Body"),      // More people
            
            // Animals & Nature
            (0x1F400..<0x1F440, "Animals & Nature"),   // Animals
            (0x1F980..<0x1F9B0, "Animals & Nature"),   // More animals
            (0x1F330..<0x1F340, "Animals & Nature"),   // Plants
            (0x1F340..<0x1F350, "Animals & Nature"),   // More plants
            (0x1F32D..<0x1F330, "Animals & Nature"),   // Nature
            
            // Food & Drink
            (0x1F32D..<0x1F380, "Food & Drink"),       // Food items
            (0x1F950..<0x1F970, "Food & Drink"),       // More food
            (0x1F96C..<0x1F970, "Food & Drink"),       // Even more food
            (0x1F9C0..<0x1F9CB, "Food & Drink"),       // Additional food
            
            // Activities
            (0x1F380..<0x1F394, "Activities"),         // Celebration
            (0x1F3A0..<0x1F3B0, "Activities"),         // Entertainment
            (0x1F3B0..<0x1F3C0, "Activities"),         // Games
            (0x1F3C0..<0x1F3D0, "Activities"),         // Sports
            (0x1F93A..<0x1F950, "Activities"),         // More sports
            (0x1F945..<0x1F950, "Activities"),         // Additional sports
            
            // Travel & Places
            (0x1F680..<0x1F6B0, "Travel & Places"),    // Transport
            (0x1F6B0..<0x1F6C0, "Travel & Places"),    // Additional transport
            (0x1F3D4..<0x1F3E0, "Travel & Places"),    // Landscapes
            (0x1F3DB..<0x1F3E0, "Travel & Places"),    // Buildings
            (0x1F9BC..<0x1F9C0, "Travel & Places"),    // Additional transport
            
            // Objects
            (0x1F4A0..<0x1F500, "Objects"),            // Various objects
            (0x1F500..<0x1F53D, "Objects"),            // More objects
            (0x1F6CC..<0x1F6D0, "Objects"),            // Household
            (0x1F9F0..<0x1FA00, "Objects"),            // Additional objects
            
            // Symbols
            (0x2600..<0x2700, "Symbols"),              // Misc symbols
            (0x2700..<0x27C0, "Symbols"),              // Dingbats
            (0x2B00..<0x2C00, "Symbols"),              // Arrows
            (0x1F300..<0x1F321, "Symbols"),            // Weather
            (0x1F32D..<0x1F330, "Symbols"),            // Additional symbols
            
            // Flags
            (0x1F1E6..<0x1F200, "Flags"),             // Regional indicators
            (0x1F3F3..<0x1F3F6, "Flags"),             // Various flags
            (0x1F38C..<0x1F390, "Flags")              // Flag ornaments
        ]
    }
    
    // Enhanced emoji generation with complete coverage
    private func generateComprehensiveEmojiCategories() -> [EmojiCategory] {
        var categories: [String: Set<String>] = [
            "Smileys & Emotion": Set(),
            "People & Body": Set(),
            "Animals & Nature": Set(),
            "Food & Drink": Set(),
            "Travel & Places": Set(),
            "Activities": Set(),
            "Objects": Set(),
            "Symbols": Set(),
            "Flags": Set()
        ]
        
        // 1. Collect emojis from Unicode ranges
        for (range, category) in EmojiUnicodeRanges.all {
            for codePoint in range {
                if let scalar = UnicodeScalar(codePoint) {
                    if scalar.properties.isEmoji && scalar.properties.isEmojiPresentation {
                        let emoji = String(scalar)
                        categories[category]?.insert(emoji)
                    }
                }
            }
        }
        
        // 2. Add skin tone variations for supported emojis
        let skinTones = ["🏻", "🏼", "🏽", "🏾", "🏿"]
        let skinToneBaseEmojis = [
            "👋", "🤚", "🖐", "✋", "🖖", "👌", "🤌", "🤏", "✌️", "🤞", "🫰", "🤟", "🤘", "🤙",
            "👈", "👉", "👆", "🖕", "👇", "☝️", "👍", "👎", "👊", "✊", "🤛", "🤜", "👏", "🙌",
            "👐", "🤲", "🤝", "🙏", "✍️", "💪", "🦾", "🦿", "🦵", "🦶"
        ]
        
        for baseEmoji in skinToneBaseEmojis {
            categories["People & Body"]?.insert(baseEmoji)
            for skinTone in skinTones {
                let modifiedEmoji = baseEmoji + skinTone
                categories["People & Body"]?.insert(modifiedEmoji)
            }
        }
        
        // 3. Add ZWJ sequences for professions and families
        let professions = [
            "👨‍⚕️", "👩‍⚕️", "🧑‍⚕️", // Health Worker
            "👨‍🎓", "👩‍🎓", "🧑‍🎓", // Student
            "👨‍🏫", "👩‍🏫", "🧑‍🏫", // Teacher
            "👨‍🍳", "👩‍🍳", "🧑‍🍳", // Cook
            "👨‍🌾", "👩‍🌾", "🧑‍🌾"  // Farmer
        ]
        
        for profession in professions {
            categories["People & Body"]?.insert(profession)
            for skinTone in skinTones {
                categories["People & Body"]?.insert(profession + skinTone)
            }
        }
        
        // 4. Add family combinations
        let families = [
            "👨‍👩‍👦", "👨‍👩‍👧", "👨‍👩‍👧‍👦",
            "👩‍👩‍👦", "👩‍👩‍👧", "👩‍👩‍👧‍👦",
            "👨‍👨‍👦", "👨‍👨‍👧", "👨‍👨‍👧‍👦"
        ]
        
        for family in families {
            categories["People & Body"]?.insert(family)
        }
        
        // Convert to EmojiCategory objects and sort
        return categories.compactMap { name, emojis in
            guard !emojis.isEmpty else { return nil }
            return EmojiCategory(name: name, emojis: Array(emojis).sorted())
        }.sorted { $0.name < $1.name }
    }
} 