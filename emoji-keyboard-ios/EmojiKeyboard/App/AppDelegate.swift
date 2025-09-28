import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: FloatingEmojiWindow?
    var statusBarItem: NSStatusItem?
    var globalEventMonitor: Any?
    
    override init() {
        super.init()
        print("🔴 AppDelegate init called")
    }
    
    func applicationWillFinishLaunching(_ aNotification: Notification) {
        print("🟠 App will finish launching")
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("🚀 App launched successfully")
        
        // Request accessibility permissions
        AccessibilityManager.shared.requestPermissions()
        
        // Setup status bar item
        setupStatusBar()
        print("📍 Status bar setup completed")
        
        // Create and show floating window
        createFloatingWindow()
        print("🪟 Window creation completed")
        
        // Load emoji data
        EmojiDataService.shared.loadSystemEmojis()
        print("😊 Emoji data loading started")
        
        // Setup global hotkey (Ctrl+E)
        setupGlobalHotkey()
        print("⌨️ Global hotkey setup completed")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        print("🔴 App will terminate")
        cleanupGlobalHotkey()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep app running even if window is closed
    }
    
    private func setupStatusBar() {
        print("🔵 Setting up status bar...")
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem?.button {
            button.title = "😊"
            button.action = #selector(toggleEmojiKeyboard)
            button.target = self
            print("✅ Status bar button configured with emoji: 😊")
        } else {
            print("❌ Failed to create status bar button")
        }
    }
    
    @objc private func toggleEmojiKeyboard() {
        print("🔄 Toggle emoji keyboard clicked")
        if let window = window {
            if window.isVisible {
                window.orderOut(nil)
                print("🙈 Window hidden")
            } else {
                window.orderFront(nil) // Use orderFront to avoid stealing focus
                print("👁 Window shown")
            }
        } else {
            print("❌ Window is nil!")
        }
    }
    
    private func createFloatingWindow() {
        print("🔵 Creating floating window...")
        window = FloatingEmojiWindow()
        if let window = window {
            window.orderFront(nil) // Use orderFront to avoid stealing focus
            print("✅ Floating window created and displayed")
            print("📏 Window frame: \(window.frame)")
            print("👀 Window is visible: \(window.isVisible)")
        } else {
            print("❌ Failed to create floating window")
        }
    }
    
    // MARK: - Global Hotkey Support
    
    private func setupGlobalHotkey() {
        print("⌨️ Setting up global hotkey (Ctrl+E)...")
        
        // Use NSEvent global monitoring for Ctrl+E hotkey
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleGlobalKeyEvent(event)
        }
        
        if globalEventMonitor != nil {
            print("✅ Global hotkey monitor registered successfully (Ctrl+E)")
        } else {
            print("❌ Failed to register global hotkey monitor")
        }
    }
    
    private func handleGlobalKeyEvent(_ event: NSEvent) {
        // Check for Ctrl+E combination
        let isControlPressed = event.modifierFlags.contains(.control)
        let isEKey = (event.keyCode == 14) // E key code
        
        if isControlPressed && isEKey && !event.modifierFlags.contains(.command) && !event.modifierFlags.contains(.option) {
            print("⌨️ Global hotkey pressed (Ctrl+E)")
            
            // Call the toggle function on main thread
            DispatchQueue.main.async { [weak self] in
                self?.toggleEmojiKeyboard()
            }
        }
    }
    
    private func cleanupGlobalHotkey() {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
            print("✅ Global hotkey monitor removed successfully")
        }
    }
} 