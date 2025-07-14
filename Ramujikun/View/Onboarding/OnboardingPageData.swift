//
//  OnboardingPageData.swift
//  Ramujikun
//
//  Created by 原里駆 on 2025/07/14.
//

import Foundation
import SwiftUI

struct OnboardingPageData: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

let onboardingPages: [OnboardingPageData] = [
    OnboardingPageData(
        imageName: "オンボ1",
        title: "ようこそ、ららららむじくんへ",
        description: "このアプリは、あなたの毎日の気分を手軽に記録できるアプリです。"
    ),
    OnboardingPageData(
        imageName: "オンボ2",
        title: "気分を記録してみよう",
        description: "気分を記録することで、自分の心の変化に気づきやすくなります。"
    ),
    OnboardingPageData(
        imageName: "オンボ3",
        title: "今日からスタート！",
        description: "さっそく気分を記録して、毎日をもっと快適に過ごしましょう。"
    )
]
