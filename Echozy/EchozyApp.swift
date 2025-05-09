//
//  EchozyApp.swift
//  Echozy
//
//  Created by Yerovy Espitia on 8/05/25.
//

import SwiftUI

@main
struct EchozyApp: App {
    @StateObject private var menuBarManager = MenuBarManager()
    
    var body: some Scene {
        MenuBarExtra("Echo", systemImage: "speaker.wave.2") {
            ContentView()
                .environmentObject(menuBarManager)
        }
        .menuBarExtraStyle(.window)
    }
}
