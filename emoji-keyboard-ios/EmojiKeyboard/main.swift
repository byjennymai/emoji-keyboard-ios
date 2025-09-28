import Cocoa

print("🟢 Main.swift executed - App starting...")

// Create application instance
let app = NSApplication.shared

// Set our custom app delegate
let appDelegate = AppDelegate()
app.delegate = appDelegate

print("🟢 AppDelegate set, starting main run loop...")

// Start the application
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv) 