import Foundation
import SwiftUI
import FirebaseFirestore

class StatisticViewModel: ObservableObject {
    @Published var moodRatios: [MoodRatio] = []
    @Published var moodStats: [MoodStat] = []
    @Published var totalCount: Int = 0
    var userId: String?

    private let moodRepository: MoodRepositoryProtocol
    private var listener: ListenerRegistration?

    init(moodRepository: MoodRepositoryProtocol = FirebaseMoodRepository(), userId: String?) {
        self.moodRepository = moodRepository
        self.userId = userId
    }

    func fetchMoods(for month: Date) {
        guard let userId = userId else { return }
        listener?.remove()
        listener = moodRepository.subscribeToMoods(for: month, userId: userId) { [weak self] moods in
            self?.processMoods(moods)
        }
    }

    @available(*, deprecated, message: "月指定のfetchMoods(for:)を使ってください")
    func fetchThisMonthMoods() {
        fetchMoods(for: Date())
    }

    private func processMoods(_ moods: [Mood]) {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: moods) { calendar.component(.day, from: $0.date) }
        
        // 日付でソートして直近の5日分のみを取得
        let sortedDays = grouped.keys.sorted()
        let recentDays = sortedDays.suffix(5)
        
        let stats: [MoodStat] = recentDays.map { day in
            let dayMoods = grouped[day] ?? []
            let avg = dayMoods.map { $0.level.numericValue }.average
            let icon = Mood.MoodLevel.assetImage(for: avg)
            return MoodStat(dateLabel: "\(day)", averageLevel: avg, icon: icon)
        }
        self.moodStats = stats
        
        let total = moods.count
        let ratioDict = Dictionary(grouping: moods, by: { $0.level })
        let ratios: [MoodRatio] = Mood.MoodLevel.allCases.map { level in
            let count = ratioDict[level]?.count ?? 0
            return MoodRatio(
                moodLabel: level.displayLabel,
                percent: total > 0 ? Double(count)/Double(total) : 0,
                color: level.color,
                icon: level.assetImageName,
                count: count
            )
        }
        self.moodRatios = ratios
        self.totalCount = total
    }
}

extension Mood.MoodLevel {
    var numericValue: Double {
        switch self {
        case .awful: return 1
        case .bad: return 2
        case .meh: return 3
        case .good: return 4
        case .great: return 5
        }
    }
    var displayLabel: String {
        switch self {
        case .awful: return "どんより"
        case .bad: return "しょぼん"
        case .meh: return "ふつう"
        case .good: return "ごきげん"
        case .great: return "るんるん"
        }
    }
    var icon: String {
        switch self {
        case .awful: return "😣"
        case .bad: return "😞"
        case .meh: return "😐"
        case .good: return "🙂"
        case .great: return "😄"
        }
    }
    static func icon(for avg: Double) -> String {
        switch avg {
        case ..<1.5: return "😣"
        case ..<2.5: return "😞"
        case ..<3.5: return "😐"
        case ..<4.5: return "🙂"
        default: return "😄"
        }
    }
    static func assetImage(for avg: Double) -> String {
        switch avg {
        case ..<1.5: return "どんより"
        case ..<2.5: return "しょぼん"
        case ..<3.5: return "ふつう"
        case ..<4.5: return "ごきげん"
        default: return "るんるん"
        }
    }
}

extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}

struct MoodStat: Identifiable {
    let id = UUID()
    let dateLabel: String
    let averageLevel: Double
    let icon: String
}

struct MoodRatio: Identifiable {
    let id = UUID()
    let moodLabel: String
    let percent: Double
    let color: Color
    let icon: String
    let count: Int
}

