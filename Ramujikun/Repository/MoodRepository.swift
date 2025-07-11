import Foundation
import FirebaseFirestore

protocol MoodRepositoryProtocol {
    func addMood(_ mood: Mood) async throws
    func updateMood(_ mood: Mood) async throws
    func deleteMood(_ mood: Mood) async throws
    func subscribeToMoods(for month: Date, userId: String, completion: @escaping ([Mood]) -> Void) -> ListenerRegistration
    func deleteAllMoods(for userId: String) async throws
}

final class FirebaseMoodRepository: MoodRepositoryProtocol {
    
    private let moodsCollection = Firestore.firestore().collection("moods")
    
    private func documentReference(for moodId: String) -> DocumentReference {
        return moodsCollection.document(moodId)
    }
    
    func addMood(_ mood: Mood) async throws {
        guard let userId = mood.userId else { throw URLError(.badURL) }
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: mood.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dayString = formatter.string(from: day)
        let docId = "\(userId)_\(dayString)"
        try moodsCollection.document(docId).setData(from: mood, merge: true)
    }
    
    func updateMood(_ mood: Mood) async throws {
        guard let documentId = mood.id else { throw URLError(.badURL) }
        try documentReference(for: documentId).setData(from: mood, merge: true)
    }
    
    func deleteMood(_ mood: Mood) async throws {
        guard let documentId = mood.id else { throw URLError(.badURL) }
        try await documentReference(for: documentId).delete()
    }
    
    func subscribeToMoods(for month: Date, userId: String, completion: @escaping ([Mood]) -> Void) -> ListenerRegistration {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else {
            return moodsCollection.addSnapshotListener { _, _ in }
        }
        
        let query = moodsCollection
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: monthInterval.start)
            .whereField("date", isLessThan: monthInterval.end)
        
        return query.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            let moods = snapshot.documents.compactMap { document -> Mood? in
                try? document.data(as: Mood.self)
            }
            completion(moods)
        }
    }
    
    func deleteAllMoods(for userId: String) async throws {
        let query = moodsCollection.whereField("userId", isEqualTo: userId)
        let snapshot = try await query.getDocuments()
        
        let batch = Firestore.firestore().batch()
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        
        try await batch.commit()
        print("Successfully deleted all moods for user: \(userId)")
    }
}

