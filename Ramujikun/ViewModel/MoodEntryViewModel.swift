import Foundation

@MainActor
final class MoodEntryViewModel: ObservableObject {
    @Published var selectedLevel: Mood.MoodLevel
    @Published var comment: String
    @Published private(set) var isEditable: Bool
    
    let date: Date
    private let existingMood: Mood?
    private let moodRepository: MoodRepositoryProtocol
    
    init(date: Date, mood: Mood?, repository: MoodRepositoryProtocol = FirebaseMoodRepository()) {
        self.date = date
        self.existingMood = mood
        self.moodRepository = repository
        
        self.selectedLevel = mood?.level ?? .meh
        self.comment = mood?.comment ?? ""
        
        let calendar = Calendar.current
        self.isEditable = calendar.isDateInToday(date) || calendar.isDateInYesterday(date)
    }
    
    func saveMood() async {
        guard let userId = AuthService.shared.currentUser?.uid else {
            print("User not logged in.")
            return
        }
        
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
            print("Error saving mood: \(error)")
        }
    }
    
    func deleteMood() async {
        guard let moodToDelete = existingMood else { return }
        do {
            try await moodRepository.deleteMood(moodToDelete)
        } catch {
            print("Error deleting mood: \(error)")
        }
    }
}

