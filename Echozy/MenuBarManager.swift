import Foundation
import SwiftUI
import AVFoundation

public class MenuBarManager: ObservableObject {
    @Published public var runningApps: [RunningApp] = []
    private var timer: Timer?
    
    public init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        // Update immediately
        updateRunningApps()
        
        // Then update every 2 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateRunningApps()
        }
    }
    
    private func updateRunningApps() {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications.filter { $0.activationPolicy == .regular }
        
        let excludedBundleIdentifiers: Set<String> = [
            Bundle.main.bundleIdentifier ?? "",
            "com.apple.finder"
        ]
        
        self.runningApps = runningApps.compactMap { app in
            guard let bundleIdentifier = app.bundleIdentifier,
                  let appName = app.localizedName else { return nil }
            
            if excludedBundleIdentifiers.contains(bundleIdentifier) {
                return nil
            }
            
            return RunningApp(
                id: bundleIdentifier,
                name: appName,
                icon: app.icon ?? NSImage(),
                volume: getAppVolume(for: bundleIdentifier)
            )
        }
    }
    
    public func setVolume(for appId: String, volume: Float) {
        // Here we would implement the actual volume control
        // This would require additional permissions and system integration
        if let index = runningApps.firstIndex(where: { $0.id == appId }) {
            runningApps[index].volume = volume
        }
    }
    
    private func getAppVolume(for bundleId: String) -> Float {
        // Here we would implement getting the actual volume
        // For now, return a default value
        return 1.0
    }
} 