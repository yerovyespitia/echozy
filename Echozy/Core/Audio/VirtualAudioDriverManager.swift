import Foundation
import CoreAudio
import CoreAudioKit

public class VirtualAudioDriverManager {
    public static let shared = VirtualAudioDriverManager()
    private var driver: VirtualAudioDriver?
    
    private init() {
        initializeDriver()
    }
    
    private func initializeDriver() {
        var driverInstance = VirtualAudioDriver()
        let status = VirtualAudioDriver_Initialize(&driverInstance)
        if status == noErr {
            driver = driverInstance
        } else {
            print("Error initializing virtual audio driver: \(status)")
        }
    }
    
    public func start() -> Bool {
        guard var driverInstance = driver else { return false }
        let status = VirtualAudioDriver_Start(&driverInstance)
        if status == noErr {
            driver = driverInstance
        }
        return status == noErr
    }
    
    public func stop() -> Bool {
        guard var driverInstance = driver else { return false }
        let status = VirtualAudioDriver_Stop(&driverInstance)
        if status == noErr {
            driver = driverInstance
        }
        return status == noErr
    }
    
    public func setAppVolume(for bundleId: String, volume: Float) -> Bool {
        guard var driverInstance = driver else { return false }
        
        // Obtener el PID del proceso por su bundle ID
        guard let pid = getProcessID(for: bundleId) else { return false }
        
        let status = VirtualAudioDriver_SetAppVolume(&driverInstance, pid, volume)
        if status == noErr {
            driver = driverInstance
        }
        return status == noErr
    }
    
    public func getAppVolume(for bundleId: String) -> Float? {
        guard var driverInstance = driver else { return nil }
        
        // Obtener el PID del proceso por su bundle ID
        guard let pid = getProcessID(for: bundleId) else { return nil }
        
        var volume: Float = 0
        let status = VirtualAudioDriver_GetAppVolume(&driverInstance, pid, &volume)
        if status == noErr {
            driver = driverInstance
        }
        return status == noErr ? volume : nil
    }
    
    private func getProcessID(for bundleId: String) -> pid_t? {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        
        for app in runningApps {
            if app.bundleIdentifier == bundleId {
                return app.processIdentifier
            }
        }
        
        return nil
    }
} 