import SwiftUI
import Charts

struct StatisticView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = StatisticViewModel(userId: nil)
    @State private var selectedMonth: Date = Date()
    @Environment(\.dismiss) private var dismiss
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    var body: some View {
        VStack {
            monthSelector
            statisticsContent
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .onAppear {
            if let userId = authViewModel.user?.uid {
                viewModel.userId = userId
                viewModel.fetchMoods(for: selectedMonth)
            }
        }
        .onChange(of: selectedMonth) { _, newMonth in
            viewModel.fetchMoods(for: newMonth)
        }
        .navigationTitle("統計")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { backToolbar }
        .navigationBarBackButtonHidden(true)
    }

    // 月選択UI
    private var monthSelector: some View {
        HStack(spacing: 24) {
            Button(action: {
                if let prev = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
                    selectedMonth = prev
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color.themeAccent)
                    .font(.title2)
            }
            Text(monthFormatter.string(from: selectedMonth))
                .font(.headline.weight(.bold))
                .frame(minWidth: 100)
            Button(action: {
                if let next = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
                    selectedMonth = next
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.themeAccent)
                    .font(.title2)
            }
        }
        .padding(.top, 8)
    }

    // 統計表示部分
    private var statisticsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("月ごとの気分割合")
                    .font(.headline.weight(.bold))
                MoodBandBar(ratios: viewModel.moodRatios)
                    .frame(height: 32)
                    .padding(.bottom, 8)

                Text("気分の推移")
                    .font(.headline.weight(.bold))
                MoodLineChart(stats: viewModel.moodStats)
                    .frame(height: 180)
                    .padding(.bottom, 8)

                Text("気分ごとの記録数")
                    .font(.headline.weight(.bold))
                MoodCountBar(ratios: viewModel.moodRatios)
            }
            .padding()
        }
    }

    // 戻るボタンツールバー
    private var backToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color.themeAccent)
                Text("戻る")
                    .foregroundColor(Color.themeAccent)
                    .font(.system(.body, design: .rounded).weight(.bold))
            }
            .onTapGesture {
                dismiss()
            }
        }
    }
}

// --- 帯グラフ ---
struct MoodBandBar: View {
    let ratios: [MoodRatio]
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(ratios) { ratio in
                    Rectangle()
                        .fill(ratio.color)
                        .frame(width: geo.size.width * CGFloat(ratio.percent), height: 24)
                }
            }
            .clipShape(Capsule())
            .overlay(
                HStack(spacing: 0) {
                    ForEach(ratios) { ratio in
                        if ratio.percent > 0.08 {
                            Text("\(Int(ratio.percent * 100))%")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .frame(width: geo.size.width * CGFloat(ratio.percent))
                        }
                    }
                }
            )
        }
        .frame(height: 24)
    }
}

// --- 折れ線グラフ ---
struct MoodLineChart: View {
    let stats: [MoodStat]
    var body: some View {
        Chart(stats) { stat in
            LineMark(
                x: .value("日付", stat.dateLabel),
                y: .value("気分", stat.averageLevel)
            )
            .foregroundStyle(Color.themeAccent)
            PointMark(
                x: .value("日付", stat.dateLabel),
                y: .value("気分", stat.averageLevel)
            )
        }
        .chartYScale(domain: 1...5)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                if let v = value.as(Double.self), (1...5).contains(Int(v)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        let moodLevel = Mood.MoodLevel.allCases[Int(v) - 1]
                        ZStack {
                            Circle()
                                .fill(moodLevel.color.opacity(0.85))
                                .frame(width: 28, height: 28)
                            Image(moodLevel.assetImageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
        }
        .background(Color.themeEntryBackground.cornerRadius(20))
    }
}

// --- 気分ごとのカウント ---
struct MoodCountBar: View {
    let ratios: [MoodRatio]
    var body: some View {
        VStack(spacing: 8) {
            ForEach(ratios) { ratio in
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ratio.color)
                        .frame(width: CGFloat(ratio.count) * 16, height: 16)
                    Image(ratio.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Text(ratio.moodLabel)
                        .font(.body)
                    Spacer()
                    Text("\(ratio.count)")
                        .font(.headline)
                        .foregroundColor(ratio.color)
                }
            }
        }
    }
}

// 期間選択用
enum StatPeriod: String, CaseIterable, Identifiable {
    case week = "週間"
    case month = "月間"
    case year = "年間"
    var id: String { rawValue }
}

