import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class CalendarViewModel: ObservableObject {
    
    @Published var currentMonth: Date = Date()
    @Published var displayedMonths: [Date] = []
    @Published private(set) var daysInMonth: [Date?] = []
    @Published private(set) var moods: [Date: Mood] = [:]
    @Published private(set) var isLoading: Bool = false
    
    private var moodListener: ListenerRegistration?
    private let moodRepository: MoodRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var authCancellable: AnyCancellable?
    
    deinit {
        moodListener?.remove()
        cancellables.removeAll()
        authCancellable?.cancel()
    }
    
    init(moodRepository: MoodRepositoryProtocol = FirebaseMoodRepository()) {
        self.moodRepository = moodRepository
        
        self.displayedMonths = CalendarViewModel.generateDisplayedMonths(center: currentMonth)
        $currentMonth
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
            .sink { [weak self] newMonth in
                self?.displayedMonths = CalendarViewModel.generateDisplayedMonths(center: newMonth)
                self?.generateDaysInMonth()
                if let userId = AuthService.shared.currentUser?.uid {
                    self?.setupMoodListener(for: userId)
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribe(to authViewModel: AuthViewModel) {
        authCancellable?.cancel()
        
        authCancellable = authViewModel.$user
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                if let user = user {
                    self?.setupMoodListener(for: user.uid)
                } else {
                    self?.moodListener?.remove()
                    self?.moods = [:]
                }
            }
    }
    
    private func setupMoodListener(for userId: String) {
        moodListener?.remove()
        
        self.isLoading = true
        moodListener = moodRepository.subscribeToMoods(for: currentMonth, userId: userId) { [weak self] fetchedMoods in
            guard let self = self else { return }
            
            var moodDict: [Date: Mood] = [:]
            fetchedMoods.forEach { mood in
                if let day = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: mood.date)) {
                    moodDict[day] = mood
                }
            }
            self.moods = moodDict
            self.isLoading = false
        }
    }
    
    func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func generateDaysInMonth() {
        let calendar = Calendar.current
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count else {
            self.daysInMonth = []
            return
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
        
        self.daysInMonth = days
    }
    
    static func generateDisplayedMonths(center: Date) -> [Date] {
        let calendar = Calendar.current
        let prev = calendar.date(byAdding: .month, value: -1, to: center) ?? center
        let next = calendar.date(byAdding: .month, value: 1, to: center) ?? center
        return [prev, center, next]
    }
}

