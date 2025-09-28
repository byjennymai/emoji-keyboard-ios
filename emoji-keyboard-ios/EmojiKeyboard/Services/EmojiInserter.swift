import Foundation
import ApplicationServices
import Carbon
import Cocoa

class EmojiInserter {
    static let shared = EmojiInserter()
    
    private var storedFocusedElement: AXUIElement?
    private init() {}
    
    func insertEmoji(_ emoji: String) {
        // Store the focused element immediately when called
        storeFocusedElement()
        
        // Check if we're dealing with iMessage specifically
        let frontmostApp = NSWorkspace.shared.frontmostApplication
        let isIMessage = frontmostApp?.bundleIdentifier == "com.apple.MobileSMS" || 
                        frontmostApp?.localizedName?.lowercased().contains("messages") == true
        
        // Small delay to allow any window focus changes to settle, then insert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            if isIMessage {
                print("📱 Detected iMessage - using specialized insertion method")
                self.insertForIMessage(emoji)
            } else {
                // First try direct accessibility insertion with stored element
                if self.insertViaAccessibilityWithStoredElement(emoji) {
                    return
                }
                
                // Fallback to clipboard + paste method (more reliable)
                self.insertEmojiWithPasteboard(emoji)
            }
        }
    }
    
    private func storeFocusedElement() {
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            systemWideElement,
            "AXFocusedUIElement" as CFString,
            &focusedElement
        )
        
        if result == .success, let focused = focusedElement {
            self.storedFocusedElement = focused as! AXUIElement
            print("📌 Stored focused element for insertion")
        } else {
            self.storedFocusedElement = nil
            print("⚠️ Could not store focused element")
        }
    }
    
    private func insertViaAccessibilityWithStoredElement(_ emoji: String) -> Bool {
        guard AccessibilityManager.shared.hasPermissions else {
            print("No accessibility permissions")
            return false
        }
        
        // Use stored focused element if available
        if let storedElement = storedFocusedElement {
            print("🎯 Using stored focused element for insertion")
            return insertTextAtSelection(storedElement, text: emoji)
        }
        
        // Fallback to current focused element
        return insertViaAccessibility(emoji)
    }
    
    // MARK: - Accessibility API Insertion
    
    private func insertViaAccessibility(_ emoji: String) -> Bool {
        guard AccessibilityManager.shared.hasPermissions else {
            print("No accessibility permissions")
            return false
        }
        
        // Get the system-wide accessibility element
        let systemWideElement = AXUIElementCreateSystemWide()
        
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            systemWideElement,
            "AXFocusedUIElement" as CFString,
            &focusedElement
        )
        
        guard result == .success, let focused = focusedElement else {
            print("Could not get focused element")
            return false
        }
        
        let focusedUIElement = focused as! AXUIElement
        
        // Try to insert at current text selection
        return insertTextAtSelection(focusedUIElement, text: emoji)
    }
    
    private func insertTextAtSelection(_ element: AXUIElement, text: String) -> Bool {
        // Get current selection
        var selectedText: CFTypeRef?
        var selectionRange: CFTypeRef?
        
        let selectedTextResult = AXUIElementCopyAttributeValue(
            element,
            "AXSelectedText" as CFString,
            &selectedText
        )
        
        let selectionRangeResult = AXUIElementCopyAttributeValue(
            element,
            "AXSelectedTextRange" as CFString,
            &selectionRange
        )
        
        // Insert the emoji by replacing selection
        let insertResult = AXUIElementSetAttributeValue(
            element,
            "AXSelectedText" as CFString,
            text as CFTypeRef
        )
        
        if insertResult == .success {
            print("Successfully inserted emoji via accessibility API")
            return true
        }
        
        // Alternative: Try setting the value directly if it's a text field
        var value: CFTypeRef?
        let valueResult = AXUIElementCopyAttributeValue(element, "AXValue" as CFString, &value)
        
        if valueResult == .success, let currentValue = value as? String {
            let newValue = currentValue + text
            let setResult = AXUIElementSetAttributeValue(
                element,
                "AXValue" as CFString,
                newValue as CFTypeRef
            )
            
            if setResult == .success {
                print("Successfully inserted emoji by setting value")
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Keyboard Events Insertion
    
    private func insertViaKeyboardEvents(_ emoji: String) {
        guard let eventSource = CGEventSource(stateID: .hidSystemState) else {
            print("Could not create event source")
            return
        }
        
        // Convert emoji to UTF-16 and send as keyboard events
        for unicodeScalar in emoji.unicodeScalars {
            let utf16 = Array(String(unicodeScalar).utf16)
            
            for char in utf16 {
                // Create a keyboard event for each UTF-16 code unit
                let keyDownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0, keyDown: true)
                let keyUpEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: 0, keyDown: false)
                
                // Set the unicode string
                keyDownEvent?.setUnicodeString([char])
                keyUpEvent?.setUnicodeString([char])
                
                // Post the events
                keyDownEvent?.post(tap: .cghidEventTap)
                keyUpEvent?.post(tap: .cghidEventTap)
                
                // Small delay between characters
                usleep(1000) // 1ms
            }
        }
        
        print("Inserted emoji via keyboard events")
    }
    
    // MARK: - Clipboard Fallback
    
    private func copyToClipboard(_ emoji: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(emoji, forType: .string)
        print("Copied emoji to clipboard: \(emoji)")
    }
    
    // MARK: - Alternative Direct Insertion
    
    func insertEmojiWithPasteboard(_ emoji: String) {
        // Store current clipboard content
        let pasteboard = NSPasteboard.general
        let currentContents = pasteboard.string(forType: .string)
        
        // Copy emoji to clipboard
        pasteboard.clearContents()
        pasteboard.setString(emoji, forType: .string)
        
        // Restore focus to stored element if available
        if let storedElement = storedFocusedElement {
            AXUIElementSetAttributeValue(
                storedElement,
                "AXFocused" as CFString,
                kCFBooleanTrue
            )
            print("🔄 Restored focus to stored element")
        }
        
        // Small delay to ensure focus is restored, then paste
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            // Simulate Cmd+V to paste
            self.simulateKeyPress(keyCode: 9, modifiers: .maskCommand) // V key with Cmd
            print("📋 Executed paste command for emoji: \(emoji)")
        }
        
        // Restore clipboard after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            pasteboard.clearContents()
            if let previousContent = currentContents {
                pasteboard.setString(previousContent, forType: .string)
            }
        }
    }
    
    // MARK: - iMessage Specific Insertion
    
    private func insertForIMessage(_ emoji: String) {
        print("📱 Attempting iMessage-specific insertion for: \(emoji)")
        
        // iMessage's accessibility API is unreliable (reports success but doesn't work)
        // Go directly to clipboard method which is more reliable
        print("📱 Using clipboard method directly for iMessage (accessibility API unreliable)")
        insertForIMessageViaClipboard(emoji)
        
        // Optional: Also try accessibility as backup in case it starts working
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.verifyIMessageInsertion(emoji) {
                print("📱 Attempting accessibility API as backup")
                _ = self.attemptIMessageAccessibilityInsertion(emoji)
            }
        }
    }
    
    private func attemptIMessageAccessibilityInsertion(_ emoji: String) -> Bool {
        guard AccessibilityManager.shared.hasPermissions else { return false }
        
        // Try multiple times with different delays for iMessage
        for attempt in 1...3 {
            print("📱 iMessage accessibility attempt \(attempt)/3")
            
            // Get fresh focused element for each attempt
            let systemWideElement = AXUIElementCreateSystemWide()
            var focusedElement: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(
                systemWideElement,
                "AXFocusedUIElement" as CFString,
                &focusedElement
            )
            
            if result == .success, let focused = focusedElement {
                let focusedUIElement = focused as! AXUIElement
                
                // Try different insertion methods for iMessage
                if insertViaIMessageAccessibilityMethods(focusedUIElement, text: emoji) {
                    print("✅ iMessage accessibility insertion succeeded on attempt \(attempt)")
                    return true
                }
            }
            
            // Wait between attempts
            if attempt < 3 {
                usleep(50_000) // 50ms delay
            }
        }
        
        return false
    }
    
    private func insertViaIMessageAccessibilityMethods(_ element: AXUIElement, text: String) -> Bool {
        // Method 1: Try AXSelectedText replacement
        let selectedTextResult = AXUIElementSetAttributeValue(
            element,
            "AXSelectedText" as CFString,
            text as CFTypeRef
        )
        
        if selectedTextResult == .success {
            print("✅ iMessage insertion via AXSelectedText")
            return true
        }
        
        // Method 2: Try AXValue append
        var value: CFTypeRef?
        let valueResult = AXUIElementCopyAttributeValue(element, "AXValue" as CFString, &value)
        
        if valueResult == .success, let currentValue = value as? String {
            let newValue = currentValue + text
            let setResult = AXUIElementSetAttributeValue(
                element,
                "AXValue" as CFString,
                newValue as CFTypeRef
            )
            
            if setResult == .success {
                print("✅ iMessage insertion via AXValue append")
                return true
            }
        }
        
        // Method 3: Try AXInsertionPointLineNumber approach (for text views)
        let insertResult = AXUIElementSetAttributeValue(
            element,
            "AXSelectedText" as CFString,
            text as CFTypeRef
        )
        
        return insertResult == .success
    }
    
    private func verifyIMessageInsertion(_ emoji: String) -> Bool {
        // Try to verify if the emoji was actually inserted by checking the text content
        guard let storedElement = storedFocusedElement else { return false }
        
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(storedElement, "AXValue" as CFString, &value)
        
        if result == .success, let currentValue = value as? String {
            let wasInserted = currentValue.contains(emoji)
            print("📱 iMessage verification - emoji found in text: \(wasInserted)")
            return wasInserted
        }
        
        print("📱 iMessage verification failed - could not read text content")
        return false
    }
    
    private func insertForIMessageViaClipboard(_ emoji: String) {
        print("📱 Using enhanced clipboard method for iMessage")
        
        // Store current clipboard content
        let pasteboard = NSPasteboard.general
        let currentContents = pasteboard.string(forType: .string)
        
        // Copy emoji to clipboard
        pasteboard.clearContents()
        pasteboard.setString(emoji, forType: .string)
        print("📋 Copied emoji to clipboard: \(emoji)")
        
        // For iMessage, be more aggressive about ensuring focus
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            // Try to activate iMessage window first
            if let app = NSWorkspace.shared.frontmostApplication {
                app.activate(options: [])
            }
            
            // Multiple focus restoration attempts
            for attempt in 1...3 {
                if let storedElement = self.storedFocusedElement {
                    AXUIElementSetAttributeValue(
                        storedElement,
                        "AXFocused" as CFString,
                        kCFBooleanTrue
                    )
                    print("📱 iMessage focus restore attempt \(attempt)")
                }
                usleep(15_000) // 15ms between attempts
            }
        }
        
        // Wait longer for iMessage focus to settle, then paste
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Single paste attempt for iMessage (now that it's working reliably)
            print("📱 iMessage paste attempt: \(emoji)")
            self.simulateKeyPress(keyCode: 9, modifiers: .maskCommand) // V key with Cmd
            
            // Show user notification for manual paste if needed (just in case)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("💡 If emoji didn't appear in iMessage, manually press Cmd+V to paste: \(emoji)")
            }
        }
        
        // Restore clipboard after a longer delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            pasteboard.clearContents()
            if let previousContent = currentContents {
                pasteboard.setString(previousContent, forType: .string)
            }
            print("📋 Restored previous clipboard content")
        }
    }
    
    private func simulateKeyPress(keyCode: UInt16, modifiers: CGEventFlags) {
        guard let eventSource = CGEventSource(stateID: .hidSystemState) else { return }
        
        let keyDownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: true)
        let keyUpEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: false)
        
        keyDownEvent?.flags = modifiers
        keyUpEvent?.flags = modifiers
        
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
}

// MARK: - CGEvent Extension for Unicode

extension CGEvent {
    func setUnicodeString(_ unicodeString: [UniChar]) {
        // Use the instance method for setting unicode strings
        unicodeString.withUnsafeBufferPointer { buffer in
            if let baseAddress = buffer.baseAddress {
                self.keyboardSetUnicodeString(stringLength: buffer.count, unicodeString: baseAddress)
            }
        }
    }
} 