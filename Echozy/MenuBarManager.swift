import Foundation
import SwiftUI
import AVFoundation
import CoreAudio

public class MenuBarManager: ObservableObject {
    @Published public var runningApps: [RunningApp] = []
    private var timer: Timer?
    private var audioDeviceID: AudioDeviceID = 0
    
    public init() {
        setupAudioDevice()
        startMonitoring()
    }
    
    private func setupAudioDevice() {
        var propertySize: UInt32 = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        guard AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize
        ) == noErr else { return }
        
        guard AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &audioDeviceID
        ) == noErr else { return }
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
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var volumeValue = volume
        let status = AudioObjectSetPropertyData(
            audioDeviceID,
            &propertyAddress,
            0,
            nil,
            UInt32(MemoryLayout<Float>.size),
            &volumeValue
        )
        
        if status == noErr {
            if let index = runningApps.firstIndex(where: { $0.id == appId }) {
                runningApps[index].volume = volume
            }
        }
    }
    
    private func getAppVolume(for bundleId: String) -> Float {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var volumeValue: Float = 0
        var propertySize = UInt32(MemoryLayout<Float>.size)
        
        let status = AudioObjectGetPropertyData(
            audioDeviceID,
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &volumeValue
        )
        
        return status == noErr ? volumeValue : 1.0
    }
} 