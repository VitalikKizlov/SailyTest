//
//  LoadingView.swift
//  SailyTest
//
//  Created by Vitalii Kizlov on 19.10.2025.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            background()
            loadingView()
        }
        .ignoresSafeArea(.all)
    }
}

private extension LoadingView {
    func background() -> some View {
        VStack {
            Spacer()
            Image("background")
                .resizable()
                .frame(height: UIScreen.main.bounds.height / 1.75)
        }
    }

    func loadingView() -> some View {
        VStack(spacing: 6) {
            ProgressView()
            Text("Loading list")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.headerTitle)
        }
    }
}

#Preview {
    LoadingView()
}
