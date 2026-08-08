//
//  HomeView.swift
//  Moon Beast
//
//  Created by Tufan Cakir on 07.08.26.
//

import SwiftUI

struct HomeView: View {
    
    @State private var showGame = false

    var body: some View {
        ZStack {
            AppBackground()

            Button("Play") {
                showGame = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .fullScreenCover(isPresented: $showGame) {
            ZStack {
                GameView(progress: GameProgressStore())
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showGame = false
                    }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()

    }
}
