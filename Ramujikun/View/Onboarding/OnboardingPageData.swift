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
        title: "気分を記録して心の変化を把握",
        description: "5段階の気分レベルで、あなたの毎日の感情を簡単に記録できます。\n\n記録することで、自分の心の変化に気づきやすくなります。"
    ),
    OnboardingPageData(
        imageName: "オンボ2",
        title: "カレンダーで気分の流れを可視化",
        description: "記録した気分はカレンダーで一目瞭然。\n\n月ごとの統計で、あなたの気分パターンを分析できます。"
    ),
    OnboardingPageData(
        imageName: "オンボ3",
        title: "今日から心の健康管理を始めよう",
        description: "気分記録は心の健康管理の第一歩。\n\nさっそく記録を始めて、より快適な毎日を過ごしましょう。"
    )
]
