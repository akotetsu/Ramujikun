//
//  OnboardindView.swift
//  Ramujikun
//
//  Created by 原里駆 on 2025/07/14.
//

import SwiftUI

struct OnboardindView: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(onboardingPages.enumerated()), id: \ .offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 480)
            
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
                    dismiss()
                }
                .foregroundColor(.gray)
                Spacer()
                Button(currentPage == onboardingPages.count - 1 ? "はじめる" : "次へ") {
                    if currentPage < onboardingPages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        dismiss()
                    }
                }
                .foregroundColor(.orange)
                .bold()
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
        }
        .padding(.vertical, 32)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    OnboardindView()
}
