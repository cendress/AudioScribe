//
//  CustomButtonView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/22/25.
//

import SwiftUI

struct CustomButtonView: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            Text(title)
                .padding()
                .foregroundStyle(Color.black)
                .font(.headline)
                .fontWeight(.semibold)
                .background(Color.white)
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .shadow(radius: 3, y: 3)
        }
    }
}

#Preview {
    CustomButtonView(title: "Record Audio", action: {})
}
