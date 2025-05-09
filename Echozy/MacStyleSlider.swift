//
//  MacStyleSlider.swift
//  Echozy
//
//  Created by Yerovy Espitia on 8/05/25.
//

import SwiftUI

struct MacSlider: View {
    @Binding var value: Double // debe estar entre 0 y 1

    let sliderHeight: CGFloat = 22
    let thumbDiameter: CGFloat = 22

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let cappedValue = min(max(value, 0), 1)
            let thumbX = cappedValue * (width - thumbDiameter)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: sliderHeight)

                Capsule()
                    .fill(Color.white)
                    .frame(width: thumbX + thumbDiameter / 1, height: sliderHeight)

                Circle()
                    .fill(Color.white)
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .offset(x: thumbX)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = gesture.location.x / (width - thumbDiameter)
                                value = min(max(Double(newValue), 0), 1)
                            }
                    )
                    .shadow(radius: 1)
            }
            .frame(height: thumbDiameter)
        }
        .frame(height: thumbDiameter)
        .padding(.horizontal, 0)
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}

#Preview {
    StatefulPreviewWrapper(0.5) { value in
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "speaker.fill")
                    .foregroundColor(.white)

                MacSlider(value: value)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .frame(width: 280)
        }
        .padding()
        .background(Color.black.opacity(0.6))
    }
}

