//
//  CustomButtonView.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/22/25.
//

import SwiftUI

struct CustomButtonView: View {
    let imageName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: 4) {
                Image(systemName: imageName)
                
                Text(title)
            }
            .padding()
            .foregroundStyle(Color.black)
            .font(.headline)
            .fontWeight(.semibold)
            .background(Color.white)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .shadow(radius: 3, y: 3)
        }
    }
}

#Preview {
    CustomButtonView(imageName: "mic.fill", title: "Record Audio", action: {})
}
