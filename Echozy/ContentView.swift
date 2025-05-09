//
//  ContentView.swift
//  Echozy
//
//  Created by Yerovy Espitia on 8/05/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                List {
                    Text("Echozy")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                        .listRowSeparator(.hidden)
                    
                    LazyVStack(spacing: 2) {
                        ForEach(Array(menuBarManager.runningApps.enumerated()), id: \.element.id) { index, app in
                            AppVolumeRow(app: app, isLast: index == menuBarManager.runningApps.count - 1)
                        }
                    }
                }
                .frame(width: 300)
            }
        }
    }
}

struct AppVolumeRow: View {
    let app: RunningApp
    let isLast: Bool
    @EnvironmentObject var menuBarManager: MenuBarManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(nsImage: app.icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Text(app.name)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    MacSlider(value: Binding(
                        get: { Double(app.volume) },
                        set: { menuBarManager.setVolume(for: app.id, volume: Float($0)) }
                    ))
                    
                    Image(systemName: {
                        if app.volume == 0 {
                            return "speaker.fill"
                        } else if app.volume < 0.25 {
                            return "speaker.wave.1.fill"
                        } else if app.volume < 0.5 {
                            return "speaker.wave.2.fill"
                        } else {
                            return "speaker.wave.3.fill"
                        }
                    }())
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
                }
                .frame(height: 24)
            }
            .padding(.vertical, 4)
        }
        .padding(.vertical, 8)
        if !isLast {
            Divider()
                .padding(.top, 0)
                .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MenuBarManager())
    }
}
