//
//  OnboardindView.swift
//  Ramujikun
//
//  Created by 原里駆 on 2025/07/14.
//

import SwiftUI

struct OnboardindView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(onboardingPages.enumerated()), id: \ .offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            //.frame(height: 480)
            
            HStack(spacing: 8) {
                ForEach(0..<onboardingPages.count, id: \.self) { i in
                    Circle()
                        .fill(i == currentPage ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 8)
            
            HStack {
                Button("スキップ") {
                    hasSeenOnboarding = true
                }
                .foregroundColor(.gray)
                Spacer()
                Button(currentPage == onboardingPages.count - 1 ? "はじめる" : "次へ") {
                    if currentPage < onboardingPages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        hasSeenOnboarding = true
                    }
                }
                .foregroundColor(.orange)
                .bold()
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
        }
        .padding(.vertical, 32)
        .background(Color(.systemGray5).ignoresSafeArea())
    }
}

#Preview {
    OnboardindView()
}
