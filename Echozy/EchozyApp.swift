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
        MenuBarExtra {
            ContentView()
                .environmentObject(menuBarManager)
        } label: {
            Image("MenuIcon")
        }
        .menuBarExtraStyle(.window)

    }
}
