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
         Image("bg")
                .resizable()

            Color.black.opacity(0.20)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground()
}
