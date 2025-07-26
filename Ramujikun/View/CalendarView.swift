import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @State private var selectedDate: DateIdentifiable?
    @State private var isActiveSettings = false
    @State private var isActiveStatistics = false
    @State private var showNoRecordAlert = false
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                
                TabView(selection: $viewModel.currentMonth) {
                    ForEach(viewModel.displayedMonths, id: \.self) { month in
                        CalendarMonthGrid(
                            month: month,
                            moods: viewModel.moods,
                            selectedDate: $selectedDate,
                            showNoRecordAlert: $showNoRecordAlert
                        )
                        .tag(month)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
                
                recordButton
                    .padding(.bottom)
            }
            .padding(.horizontal)
            .background(Color.themeBackground.ignoresSafeArea())
            .onAppear {
                viewModel.subscribe(to: authViewModel)
            }
            .sheet(item: $selectedDate) { dateIdentifiable in
                MoodEntryView(date: dateIdentifiable.date, mood: viewModel.moods[dateIdentifiable.date])
            }
            .alert("記録されてません", isPresented: $showNoRecordAlert) {
                Button("OK", role: .cancel) {}
            }
            .navigationDestination(isPresented: $isActiveSettings) {
                SettingsView().environmentObject(authViewModel)
            }
            .navigationDestination(isPresented: $isActiveStatistics) {
                StatisticView()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var header: some View {
        HStack(alignment: .lastTextBaseline) {
            Button(action: {
                withAnimation(.spring()) { isActiveSettings = true }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.themeEntryBackground)
                        .frame(width: 48, height: 48)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 28, weight: .bold))
                }
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Circle())
            .padding(.leading, 4)
            .buttonAccessibility(title: "設定", icon: "設定画面を開く")
            Spacer()
            Text(currentMonthTitle)
                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                .foregroundColor(.themeAccent)
            Spacer()
            Button(action: {
                withAnimation(.spring()) { isActiveStatistics = true }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.themeEntryBackground)
                        .frame(width: 48, height: 48)
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 28, weight: .bold))
                }
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Circle())
            .padding(.trailing, 4)
            .buttonAccessibility(title: "統計", icon: "統計画面を開く")
        }
        .padding(.vertical)
    }

    private var recordButton: some View {
        Button(action: {
            let today = Calendar.current.startOfDay(for: Date())
            withAnimation(.spring()) {
                self.selectedDate = DateIdentifiable(date: today)
            }
        }) {
            Label("今日の気分を記録する", systemImage: "plus.circle.fill")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.themeAccent)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: Color.themeAccent.opacity(0.35), radius: 10, x: 0, y: 6)
        }
        .padding(.horizontal, 8)
        .scaleEffect(1.0)
        .buttonStyle(PlainButtonStyle())
        .contentShape(Capsule())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedDate)
    }
    
    // MARK: - Helper Properties
    
    private var currentMonthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: viewModel.currentMonth)
    }
}

// MARK: - DateIdentifiable (日付の識別可能なラッパー)
struct DateIdentifiable: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    static func == (lhs: DateIdentifiable, rhs: DateIdentifiable) -> Bool {
        lhs.date == rhs.date
    }
}

// MARK: - DateCell (日付セル) のView定義
struct DateCell: View {
    let date: Date
    let mood: Mood?
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(date.day.description)
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundColor(isToday ? .white : .themeAccent)

            Group {
                if let mood = mood {
                    ZStack {
                        Circle()
                            .fill(mood.level.color.opacity(0.18))
                            .frame(width: 44, height: 44)
                        Image(mood.level.assetImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 38, height: 38)
                            .shadow(color: mood.level.color.opacity(0.3), radius: 4)
                    }
                    .scaleEffect(isToday ? 1.08 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isToday)
                } else {
                    Color.clear.frame(width: 32, height: 32)
                }
            }
            .frame(height: 28)
        }
        .padding(.vertical, 8)
        .frame(width: 50, height: 80)
        .background(
            ZStack {
                if isToday {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.themeAccent)
                        .shadow(color: .black.opacity(0.13), radius: 8, x: 0, y: 4)
                }
            }
        )
    }
}

// MARK: - Date Extension (日付のヘルパー)
extension Date {
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
}

// 月ごとのカレンダーView
struct CalendarMonthGrid: View {
    let month: Date
    let moods: [Date: Mood]
    @Binding var selectedDate: DateIdentifiable?
    @Binding var showNoRecordAlert: Bool
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
    
    var body: some View {
        VStack(spacing: 0) {
            // 曜日ヘッダー
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(weekdays.indices, id: \ .self) { idx in
                    let weekday = weekdays[idx]
                    Text(weekday)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(idx == 0 ? Color.red.opacity(0.7) : idx == 6 ? Color.blue.opacity(0.7) : Color.themeAccent.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 15)
            // 日付グリッド
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(daysInMonth.indices, id: \.self) { index in
                    if let day = daysInMonth[index] {
                        DateCell(date: day, mood: moods[day])
                            .onTapGesture {
                                if moods[day] != nil {
                                    selectedDate = DateIdentifiable(date: day)
                                } else {
                                    showNoRecordAlert = true
                                }
                            }
                    } else {
                        Color.clear
                    }
                }
            }
        }
    }
    // 月の全日付を生成
    private var daysInMonth: [Date?] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: month)?.count else {
            return []
        }
        let firstDayWeekday = calendar.component(.weekday, from: monthInterval.start)
        var days: [Date?] = []
        let paddingDays = firstDayWeekday - 1
        if paddingDays > 0 {
            days.append(contentsOf: Array(repeating: nil, count: paddingDays))
        }
        for day in 1...numberOfDaysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }
        return days
    }
}

