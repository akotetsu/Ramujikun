import Foundation
import FirebaseAuth
import Combine

enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating(flow: AuthFlow)
}

enum AuthFlow {
    case signIn
    case signUp
}

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published private(set) var user: User?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var email = ""
    @Published var password = ""
    @Published var authState: AuthenticationState = .unauthenticated
    @Published var isAuthenticationSuccessful: Bool = false
    @Published var successMessage: String?
    private var currentAuthType: String = ""
    
    var isUserAnonymous: Bool {
        authService.isUserAnonymous
    }
    
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        subscribeToUserChanges()
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func subscribeToUserChanges() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.user = user
            if user == nil {
                self.signInAnonymously()
            }
        }
    }
    
    func signInAnonymously() {
        executeAuthTask { [weak self] in
            try await self?.authService.signInAnonymously()
        }
    }
    
    func linkAccount() {
        print("LinkAccount called with email: \(email)")
        currentAuthType = "linkAccount"
        executeAuthTask { [weak self] in
            guard let self = self else { return nil }
            return try await self.authService.linkAccount(email: self.email, password: self.password)
        }
    }
    
    func signUp() {
        print("SignUp called with email: \(email)")
        currentAuthType = "signUp"
        executeAuthTask { [weak self] in
            guard let self = self else { return nil }
            return try await self.authService.signUp(email: self.email, password: self.password)
        }
    }
    
    func signIn() {
        print("SignIn called with email: \(email)")
        currentAuthType = "signIn"
        executeAuthTask { [weak self] in
            guard let self = self else { return nil }
            return try await self.authService.signIn(email: self.email, password: self.password)
        }
    }
    
    func signOut() {
        self.errorMessage = nil
        do {
            try authService.signOut()
        } catch {
            self.errorMessage = "ログアウトに失敗しました: \(error.localizedDescription)"
        }
    }
    
    func deleteAccount() {
        executeAuthTask { [weak self] in
            try await self?.authService.deleteAccount()
            return nil
        }
    }
    
    private func executeAuthTask(task: @escaping () async throws -> User?) {
        self.isLoading = true
        self.errorMessage = nil
        self.isAuthenticationSuccessful = false
        self.successMessage = nil
        
        Task {
            do {
                let user = try await task()
                print("Auth task completed successfully")
                self.email = ""
                self.password = ""
                self.isAuthenticationSuccessful = true
                
                // 成功メッセージを設定
                switch self.currentAuthType {
                case "signIn":
                    self.successMessage = "ログインに成功しました！"
                case "signUp":
                    self.successMessage = "新規登録に成功しました！"
                case "linkAccount":
                    self.successMessage = "アカウント連携に成功しました！"
                default:
                    self.successMessage = "認証に成功しました！"
                }
                
                // 認証成功後、少し遅延を入れてから認証画面を閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("Setting authState to unauthenticated to close the view")
                    self.authState = .unauthenticated
                }
            } catch {
                print("Auth task failed with error: \(error)")
                print("Error details: \(error.localizedDescription)")
                self.errorMessage = "認証に失敗しました: \(error.localizedDescription)"
            }
            
            self.isLoading = false
        }
    }
}

