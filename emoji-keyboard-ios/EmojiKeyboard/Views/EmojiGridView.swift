import SwiftUI

struct EmojiGridView: View {
    @StateObject private var emojiService = EmojiDataService.shared
    @StateObject private var accessibilityManager = AccessibilityManager.shared
    
    @State private var selectedCategory: EmojiCategory?
    @State private var searchText = ""
    @State private var showingSearch = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 9)
    private let emojiSize: CGFloat = 32
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with search
            headerView
            
            // Category tabs
            if !showingSearch {
                categoryTabsView
            }
            
            // Main content
            mainContentView
        }
        .background(backgroundView)
        .onAppear {
            if selectedCategory == nil && !emojiService.emojiCategories.isEmpty {
                // Select Smileys & Emotion by default
                selectedCategory = emojiService.emojiCategories.first { $0.name == "Smileys & Emotion" }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            // Search toggle
            Button(action: { toggleSearch() }) {
                Image(systemName: showingSearch ? "xmark" : "magnifyingglass")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            
            if showingSearch {
                // Search field
                TextField("Search emojis...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 14))
            } else {
                // Title
                Text("Emoji Keyboard")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Accessibility status
                accessibilityStatusView
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
    }
    
    private var accessibilityStatusView: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(accessibilityManager.hasPermissions ? Color.green : Color.orange)
                .frame(width: 6, height: 6)
            
            Text(accessibilityManager.hasPermissions ? "Active" : "Clipboard")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Category Tabs
    
    private var categoryTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Recent emojis tab
                if !emojiService.recentEmojis.isEmpty {
                    CategoryTabButton(
                        title: "Recent",
                        icon: "🕒",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                }
                
                // Category tabs in defined order
                ForEach(emojiService.emojiCategories.sorted { $0.sortOrder < $1.sortOrder }, id: \.id) { category in
                    CategoryTabButton(
                        title: category.name,
                        icon: category.icon,
                        isSelected: selectedCategory?.id == category.id,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 44)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
    }
    
    // MARK: - Main Content
    
    private var mainContentView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(displayedEmojis, id: \.self) { emoji in
                    EmojiButton(
                        emoji: emoji,
                        size: emojiSize,
                        action: { selectEmoji(emoji) }
                    )
                }
            }
            .padding(12)
        }
    }
    
    // MARK: - Background
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
            )
    }
    
    // MARK: - Data
    
    private var displayedEmojis: [String] {
        if showingSearch && !searchText.isEmpty {
            return emojiService.searchEmojis(query: searchText)
        } else if selectedCategory == nil {
            return emojiService.recentEmojis
        } else {
            return selectedCategory?.emojis ?? []
        }
    }
    
    // MARK: - Actions
    
    private func toggleSearch() {
        showingSearch.toggle()
        if !showingSearch {
            searchText = ""
        }
    }
    
    private func selectEmoji(_ emoji: String) {
        // Add to recent emojis
        emojiService.addToRecent(emoji)
        
        // Insert the emoji
        if accessibilityManager.hasPermissions {
            EmojiInserter.shared.insertEmoji(emoji)
        } else {
            // Fallback to clipboard + paste
            EmojiInserter.shared.insertEmojiWithPasteboard(emoji)
        }
        
        // Visual feedback
        // You could add haptic feedback here on devices that support it
        print("Selected emoji: \(emoji)")
    }
}

// MARK: - Category Tab Button

struct CategoryTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(icon)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            )
            .foregroundColor(isSelected ? .accentColor : .secondary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Emoji Button

struct EmojiButton: View {
    let emoji: String
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(emoji)
                .font(.system(size: size * 0.8))
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isPressed ? Color.primary.opacity(0.1) : Color.clear)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {
            // Long press action
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
        .help(emoji) // Tooltip showing the emoji
    }
}

// MARK: - Preview

struct EmojiGridView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiGridView()
            .frame(width: 600, height: 400)
    }
} 