import Foundation
import FirebaseAuth

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var isUserAnonymous: Bool { get }
    
    func signInAnonymously() async throws -> User
    func linkAccount(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() throws
    func deleteAccount() async throws
}

final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    private let auth = Auth.auth()
    private let moodRepository: MoodRepositoryProtocol
    
    private init(moodRepository: MoodRepositoryProtocol = FirebaseMoodRepository()) {
        self.moodRepository = moodRepository
    }
    
    var currentUser: User? {
        return auth.currentUser
    }
    
    var isUserAnonymous: Bool {
        return currentUser?.isAnonymous ?? true
    }
    
    func signInAnonymously() async throws -> User {
        if let currentUser = self.currentUser {
            print("Already signed in with user ID: \(currentUser.uid)")
            return currentUser
        }
        
        let authResult = try await auth.signInAnonymously()
        print("Signed in anonymously with user ID: \(authResult.user.uid)")
        return authResult.user
    }
    
    func linkAccount(email: String, password: String) async throws -> User {
        guard let currentUser = currentUser else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."])
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        let result = try await currentUser.link(with: credential)
        print("Successfully linked anonymous account to email: \(result.user.email ?? "N/A")")
        return result.user
    }

    func signUp(email: String, password: String) async throws -> User {
        print("Attempting to sign up with email: \(email)")
        let authResult = try await auth.createUser(withEmail: email, password: password)
        print("Successfully signed up with email: \(authResult.user.email ?? "N/A")")
        return authResult.user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        print("Attempting to sign in with email: \(email)")
        let authResult = try await auth.signIn(withEmail: email, password: password)
        print("Successfully signed in with email: \(authResult.user.email ?? "N/A")")
        return authResult.user
    }

    func signOut() throws {
        try auth.signOut()
        print("User signed out.")
    }
    
    func deleteAccount() async throws {
        guard let currentUser = currentUser else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."])
        }
        
        // 匿名ユーザーの場合は削除できないため、エラーを投げる
        if currentUser.isAnonymous {
            throw NSError(domain: "AuthService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Anonymous users cannot be deleted."])
        }
        
        // まずFirestoreのデータを削除
        try await moodRepository.deleteAllMoods(for: currentUser.uid)
        
        // 次にユーザーアカウントを削除
        try await currentUser.delete()
        print("User account and all data deleted successfully.")
    }
}

