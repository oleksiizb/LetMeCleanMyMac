//
//  InputLock.swift
//  MyApp
//
//  Created by Kinder on 25.10.2026.
//

import SwiftUI
import AppKit
import CoreGraphics
import ApplicationServices

final class SystemInputLock {
    static let shared = SystemInputLock()

    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private(set) var isLocked = false

    private let keyEscape: Int64 = 53
    private let keyQ: Int64 = 12

    // MARK: Permissions

    private func hasPermissions() -> Bool {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let accessibility = AXIsProcessTrustedWithOptions(opts)

        var inputMonitoring = CGPreflightListenEventAccess()
        if !inputMonitoring { inputMonitoring = CGRequestListenEventAccess() }

        return accessibility && inputMonitoring
    }

    // MARK: Enable / disable

    func enable(autoUnlockAfter seconds: TimeInterval? = nil) {
        guard !isLocked else { return }
        guard hasPermissions() else {
            print("Grant Accessibility + Input Monitoring, then relaunch the app.")
            return
        }

        let mask: CGEventMask = ~CGEventMask(0) // every event type, incl. media keys and gestures

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let lock = Unmanaged<SystemInputLock>.fromOpaque(refcon).takeUnretainedValue()
            return lock.handle(type: type, event: event)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,            // active tap: allowed to drop events
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("Could not create event tap (missing permission or sandbox still on).")
            return
        }

        self.tap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isLocked = true

        NSApp.presentationOptions = [
            .hideDock, .hideMenuBar,
            .disableProcessSwitching, .disableHideApplication,
            .disableSessionTermination, .disableAppleMenu,
            .disableForceQuit
        ]
        NSApp.windows.first?.toggleFullScreen(nil)
        NSCursor.hide()

        // Safety net while developing: unlock automatically
        if let seconds {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
                self?.disable()
            }
        }
    }

    func disable() {
        guard isLocked else { return }
        if let tap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes) }
        tap = nil
        runLoopSource = nil
        isLocked = false
        NSApp.presentationOptions = []
        NSCursor.unhide()
    }

    // MARK: Event filtering

    fileprivate func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // macOS disables slow/unresponsive taps; turn it back on
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return Unmanaged.passUnretained(event)
        }

        if type == .keyDown || type == .keyUp {
            let code = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags

            // Escape hatch: Cmd+Opt+Shift+Q -> unlock and quit
            if code == keyQ, flags.contains([.maskCommand, .maskAlternate, .maskShift]) {
                if type == .keyDown {
                    DispatchQueue.main.async {
                        self.disable()
                        NSApp.terminate(nil)
                    }
                }
                return nil
            }
        }

        // Only block input while OUR app is in front. When the Force Quit
        // window (another process) is frontmost, input flows normally.
        if NSWorkspace.shared.frontmostApplication?.processIdentifier != getpid() {
            return Unmanaged.passUnretained(event)
        }

        return nil // drop keyboard, mouse, trackpad gestures, media keys, etc.
    }
}
