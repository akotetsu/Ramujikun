import SwiftUI

enum AuthMode: String, CaseIterable, Identifiable {
    case login = "ログイン"
    case register = "新規登録"
    var id: String { rawValue }
}

struct AuthenticationView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var authMode: AuthMode
    
    init(initialAuthMode: AuthMode = .login) {
        _authMode = State(initialValue: initialAuthMode)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // アイコン
                Image(systemName: "icloud.and.arrow.up.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.themeAccent)
                    .padding(.top, 40)

            // タブ切り替え
            Picker("認証モード", selection: $authMode) {
                ForEach(AuthMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // フォーム
            AuthenticationForm(
                email: $authViewModel.email,
                password: $authViewModel.password,
                buttonText: getButtonText(),
                action: {
                    if authMode == .login {
                        authViewModel.signIn()
                    } else {
                        // 匿名ユーザーの場合はアカウント連携、そうでなければ新規登録
                        if authViewModel.isUserAnonymous {
                            authViewModel.linkAccount()
                        } else {
                            authViewModel.signUp()
                        }
                    }
                }
            )

            // 切り替えリンク
            HStack(spacing: 8) {
                if authMode == .login {
                    Text("アカウントをお持ちでないですか？")
                    Button("新規登録はこちら") { authMode = .register }
                        .font(.headline.weight(.bold))
                        .foregroundColor(.themeAccent)
                } else {
                    Text("既にアカウントをお持ちですか？")
                    Button("ログインはこちら") { authMode = .login }
                        .font(.headline.weight(.bold))
                        .foregroundColor(.themeAccent)
                }
            }
            .font(.subheadline)

            Spacer()
        }
        .padding()
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.themeAccent.opacity(0.7))
                        .padding(.top, 8)
                        //.padding(.trailing, 8)
                }
            }
        }
        .onDisappear {
            // 認証画面が閉じられた時にエラーメッセージをクリア
            authViewModel.errorMessage = nil
        }
        }
    }
    
    // ボタンテキストを動的に変更
    private func getButtonText() -> String {
        if authMode == .login {
            return "ログインする"
        } else {
            // 匿名ユーザーの場合は「アカウント連携」、そうでなければ「新規登録」
            return authViewModel.isUserAnonymous ? "アカウント連携" : "同意して登録する"
        }
    }
}

struct AuthenticationForm: View {
    @Binding var email: String
    @Binding var password: String
    let buttonText: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            TextField("メールアドレス", text: $email)
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(12)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("パスワード (6文字以上)", text: $password)
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(12)

            Button(action: action) {
                Text(buttonText)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.themeAccent)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(color: Color.themeAccent.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 8)
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AuthenticationView(initialAuthMode: .login)
                .environmentObject(AuthViewModel())
                .previewDisplayName("ログインモード")
            
            AuthenticationView(initialAuthMode: .register)
                .environmentObject(AuthViewModel())
                .previewDisplayName("新規登録モード")
        }
    }
}

