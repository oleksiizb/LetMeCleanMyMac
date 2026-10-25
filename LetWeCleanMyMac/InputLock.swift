//
//  InputLock.swift
//  MyApp
//
//  Created by Kinder on 25.10.2026.
//

import SwiftUI
import AppKit


final class InputLock {
    static let shared = InputLock()
    private var monitor: Any?

    func enable() {
        guard monitor == nil else { return }

        let mask: NSEvent.EventTypeMask = [
            .keyDown, .keyUp, .flagsChanged,
            .leftMouseDown, .leftMouseUp, .leftMouseDragged,
            .rightMouseDown, .rightMouseUp, .rightMouseDragged,
            .otherMouseDown, .otherMouseUp, .otherMouseDragged,
            .mouseMoved, .scrollWheel,
            .gesture, .magnify, .swipe, .rotate, .smartMagnify
        ]

        monitor = NSEvent.addLocalMonitorForEvents(matching: mask) { event in
            // Developer escape hatch: Cmd+Opt+Shift+Q unlocks and quits
            if event.type == .keyDown,
               event.modifierFlags.contains([.command, .option, .shift]),
               event.charactersIgnoringModifiers?.lowercased() == "q" {
                self.disable()
                NSApp.terminate(nil)
                return event
            }
            return nil // drop everything else
        }

        NSApp.presentationOptions = [
            .hideDock,
            .hideMenuBar,
            .disableProcessSwitching,       // Cmd+Tab
            .disableHideApplication,        // Cmd+H
            .disableSessionTermination,     // logout / shutdown dialogs
            .disableAppleMenu               // Cmd+Opt+Esc
        ]

        NSApp.windows.first?.toggleFullScreen(nil)
        NSCursor.hide()
    }

    func disable() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        NSApp.presentationOptions = []
        NSCursor.unhide()
    }
}
