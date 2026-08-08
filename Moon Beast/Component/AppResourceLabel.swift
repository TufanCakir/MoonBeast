//
//  AppResourceLabel.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import SwiftUI

struct AppResourceLabel: View {
    let imageName: String
    let value: Int
    var prefix = ""
    var iconSize: CGFloat = 28
    var fontSize: CGFloat = 13
    var color: Color = .white

    var body: some View {
        HStack(spacing: 6) {
            Image(imageName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)

            Text("\(prefix)\(value)")
                .font(.system(size: fontSize, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(color)
        .shadow(color: .black.opacity(0.9), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    AppResourceLabel(imageName: "icon_pixel_coin", value: 999, prefix: "+")
        .padding()
        .background(.black)
}
