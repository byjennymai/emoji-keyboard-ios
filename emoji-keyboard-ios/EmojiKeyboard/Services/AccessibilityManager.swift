import Foundation
import ApplicationServices
import Cocoa

class AccessibilityManager: ObservableObject {
    static let shared = AccessibilityManager()
    
    @Published var hasPermissions = false
    
    private init() {
        checkPermissions()
    }
    
    func requestPermissions() {
        // Check if we already have permissions
        if AXIsProcessTrusted() {
            hasPermissions = true
            return
        }
        
        // Request permissions with prompt
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        hasPermissions = trusted
        
        if !trusted {
            showPermissionAlert()
        }
    }
    
    func checkPermissions() {
        hasPermissions = AXIsProcessTrusted()
    }
    
    private func showPermissionAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = """
            Emoji Keyboard needs accessibility permission to insert emojis directly into other applications.
            
            Please:
            1. Go to System Preferences > Security & Privacy > Privacy
            2. Select "Accessibility" from the left sidebar
            3. Click the lock icon and enter your password
            4. Find "Emoji Keyboard" in the list and check the box
            5. Restart the app if needed
            
            Without this permission, emojis will be copied to clipboard instead.
            """
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Continue Without Permission")
            
            let response = alert.runModal()
            
            if response == .alertFirstButtonReturn {
                self.openAccessibilityPreferences()
            }
        }
    }
    
    private func openAccessibilityPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    // Periodic permission check
    func startPermissionMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkPermissions()
        }
    }
    
    // MARK: - Accessibility Helper Methods
    
    func getFocusedApplication() -> NSRunningApplication? {
        let workspace = NSWorkspace.shared
        return workspace.frontmostApplication
    }
    
    func getFocusedWindow() -> AXUIElement? {
        guard hasPermissions else { return nil }
        
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedApp: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(
            systemWideElement,
            "AXFocusedApplication" as CFString,
            &focusedApp
        )
        
        guard result == .success, let app = focusedApp else {
            return nil
        }
        
        let appElement = app as! AXUIElement
        var focusedWindow: CFTypeRef?
        
        let windowResult = AXUIElementCopyAttributeValue(
            appElement,
            "AXFocusedWindow" as CFString,
            &focusedWindow
        )
        
        return windowResult == .success ? (focusedWindow as! AXUIElement) : nil
    }
    
    func getTextFieldAtPosition(_ position: CGPoint) -> AXUIElement? {
        guard hasPermissions else { return nil }
        
        let systemWideElement = AXUIElementCreateSystemWide()
        var element: AXUIElement?
        
        let result = AXUIElementCopyElementAtPosition(systemWideElement, Float(position.x), Float(position.y), &element)
        
        return result == .success ? element : nil
    }
}

// MARK: - Notification Extension

extension AccessibilityManager {
    
    func observeTextFieldChanges() {
        guard hasPermissions else { return }
        
        // Set up accessibility notifications if needed
        // This could be used to detect when text fields become active
    }
} 