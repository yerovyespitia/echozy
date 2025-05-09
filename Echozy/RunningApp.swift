import SwiftUI

public struct RunningApp: Identifiable {
    public let id: String
    public let name: String
    public let icon: NSImage
    public var volume: Float
    
    public init(id: String, name: String, icon: NSImage, volume: Float) {
        self.id = id
        self.name = name
        self.icon = icon
        self.volume = volume
    }
} 