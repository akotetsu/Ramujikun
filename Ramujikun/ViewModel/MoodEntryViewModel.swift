import Foundation

@MainActor
final class MoodEntryViewModel: ObservableObject {
    @Published var selectedLevel: Mood.MoodLevel
    @Published var selectedLevelIndex: Int
    @Published var comment: String
    @Published private(set) var isEditable: Bool
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    let date: Date
    private let existingMood: Mood?
    private let moodRepository: MoodRepositoryProtocol
    
    init(date: Date, mood: Mood?, repository: MoodRepositoryProtocol = FirebaseMoodRepository()) {
        self.date = date
        self.existingMood = mood
        self.moodRepository = repository
        
        self.selectedLevel = mood?.level ?? .meh
        self.selectedLevelIndex = Mood.MoodLevel.allCases.firstIndex(of: mood?.level ?? .meh) ?? 2
        self.comment = mood?.comment ?? ""
        
        let calendar = Calendar.current
        self.isEditable = calendar.isDateInToday(date) || calendar.isDateInYesterday(date)
    }
    
    func updateSelectedLevel(_ level: Mood.MoodLevel) {
        selectedLevel = level
        selectedLevelIndex = Mood.MoodLevel.allCases.firstIndex(of: level) ?? 2
    }
    
    func updateSelectedLevelIndex(_ index: Int) {
        selectedLevelIndex = index
        selectedLevel = Mood.MoodLevel.allCases[index]
    }
    
    func saveMood() async {
        guard let userId = AuthService.shared.currentUser?.uid else {
            errorMessage = "ユーザーがログインしていません"
            return
        }
        
        // バリデーション
        if let validationError = Validation.commentValidationMessage(comment) {
            errorMessage = validationError
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let moodToSave = Mood(
            id: existingMood?.id,
            date: date,
            level: selectedLevel,
            comment: comment,
            userId: userId
        )
        
        do {
            if existingMood != nil {
                try await moodRepository.updateMood(moodToSave)
            } else {
                try await moodRepository.addMood(moodToSave)
            }
        } catch {
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
            Logger.error("Error saving mood", category: .mood, error: error)
        }
        
        isLoading = false
    }
    
    func deleteMood() async {
        guard let moodToDelete = existingMood else { return }
        do {
            try await moodRepository.deleteMood(moodToDelete)
        } catch {
            Logger.error("Error deleting mood", category: .mood, error: error)
        }
    }
}

