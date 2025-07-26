//
//  OnboardingView.swift
//  Ramujikun
//
//  Created by 原里駆 on 2025/07/14.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(onboardingPages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                        .accessibilityLabel("オンボーディングページ \(index + 1) of \(onboardingPages.count)")
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .accessibilityElement(children: .contain)
            
            // ページインジケーター
            HStack(spacing: 8) {
                ForEach(0..<onboardingPages.count, id: \.self) { i in
                    Circle()
                        .fill(i == currentPage ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .accessibilityLabel(i == currentPage ? "現在のページ" : "ページ \(i + 1)")
                }
            }
            .padding(.top, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("ページインジケーター、\(currentPage + 1)ページ目 of \(onboardingPages.count)")
            
            // ナビゲーションボタン
            HStack {
                Button("スキップ") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasSeenOnboarding = true
                    }
                }
                .foregroundColor(.gray)
                .accessibilityLabel("オンボーディングをスキップ")
                .accessibilityHint("オンボーディングをスキップしてメイン画面に進みます")
                
                Spacer()
                
                Button(currentPage == onboardingPages.count - 1 ? "はじめる" : "次へ") {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        if currentPage < onboardingPages.count - 1 {
                            currentPage += 1
                        } else {
                            hasSeenOnboarding = true
                        }
                    }
                }
                .foregroundColor(.orange)
                .bold()
                .accessibilityLabel(currentPage == onboardingPages.count - 1 ? "はじめる" : "次へ")
                .accessibilityHint(currentPage == onboardingPages.count - 1 ? "オンボーディングを完了してメイン画面に進みます" : "次のページに進みます")
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
        }
        .padding(.vertical, 32)
        .background(Color(.systemGray5).ignoresSafeArea())
    }
}

#Preview {
    OnboardingView()
}
