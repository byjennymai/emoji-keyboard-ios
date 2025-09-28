import Cocoa
import SwiftUI

class FloatingEmojiWindow: NSPanel {
    
    init() {
        print("🔴 FloatingEmojiWindow init started")
        
        super.init(
            contentRect: NSRect(x: 100, y: 100, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        print("🟡 NSWindow super.init completed")
        
        setupWindow()
        setupContent()
        
        print("✅ FloatingEmojiWindow init completed")
    }
    
    private func setupWindow() {
        print("🔵 Setting up window properties...")
        
        // Panel appearance to match design
        self.title = "Emoji Keyboard"
        self.level = .floating  // Use floating level for panels
        self.isOpaque = false
        self.backgroundColor = NSColor.controlBackgroundColor
        self.hasShadow = true
        self.isMovableByWindowBackground = true
        
        // Set panel to stay on top without activating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        
        // Panel-specific properties to prevent focus stealing
        self.hidesOnDeactivate = false
        self.becomesKeyOnlyIfNeeded = true  // Panel property
        self.canHide = false
        
        // Make it a utility panel that doesn't activate
        self.isFloatingPanel = true
        self.worksWhenModal = true
        
        // Custom window appearance
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.standardWindowButton(.closeButton)?.isHidden = false
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        
        print("✅ Panel properties configured")
    }
    
    private func setupContent() {
        print("🔵 Setting up window content...")
        
        // Create SwiftUI content view
        let contentView = NSHostingView(rootView: EmojiGridView())
        
        // Set the frame to the window's content rect
        let contentFrame = NSRect(x: 0, y: 0, width: 600, height: 400)
        contentView.frame = contentFrame
        contentView.autoresizingMask = [.width, .height]
        
        print("🟡 NSHostingView created with frame: \(contentFrame)")
        
        self.contentView = contentView
        
        print("🟡 Content view assigned to window")
        
        // Force the window to display without stealing focus
        self.orderFront(nil)
        self.orderFrontRegardless()
        
        print("✅ Window display commands executed")
        print("📏 Final window frame: \(self.frame)")
        print("👀 Window visible: \(self.isVisible)")
    }
    
    override var canBecomeKey: Bool {
        return false  // Never become key window
    }
    
    override var canBecomeMain: Bool {
        return false  // Never become main window
    }
    
    override var acceptsFirstResponder: Bool {
        return false  // Don't accept first responder status
    }
    
    override func sendEvent(_ event: NSEvent) {
        // Handle events without activating the panel
        super.sendEvent(event)
    }
}

// MARK: - Window Visual Effects
extension FloatingEmojiWindow {
    
    func applyVisualEffects() {
        // Add subtle blur background effect
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 12
        
        if let contentView = self.contentView {
            visualEffectView.frame = contentView.bounds
            visualEffectView.autoresizingMask = [.width, .height]
            contentView.addSubview(visualEffectView, positioned: .below, relativeTo: nil)
        }
    }
} 