//
//  OnboardingPageView.swift
//  Ramujikun
//
//  Created by 原里駆 on 2025/07/14.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPageData
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer(minLength: 0)
            ZStack {
//                Circle()
//                    .fill(Color(.systemGray6))
//                    .frame(width: 180, height: 180)
                Image(page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title2).bold()
                    .multilineTextAlignment(.center)
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    OnboardingPageView(page: onboardingPages[0])
}
