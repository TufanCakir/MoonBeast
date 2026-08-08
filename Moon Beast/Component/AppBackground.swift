//
//  AppBackground.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 08.08.26.
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.01, green: 0.16, blue: 0.34),
                    Color(red: 0.01, green: 0.44, blue: 0.78),
                    Color(red: 0.70, green: 0.74, blue: 0.72),
                    Color(red: 0.39, green: 0.40, blue: 0.38),
                    Color(red: 0.58, green: 0.56, blue: 0.55)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            Color.black.opacity(0.18)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground()
}
