import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var reminderViewModel = ReminderViewModel.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showAuthSheet = false
    @State private var showReminderSettings = false
    @State private var authMode: AuthMode = .register
    @State private var showDeleteAccountAlert = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // アカウント情報 or 認証ボタン
                if let user = authViewModel.user, !authViewModel.isUserAnonymous {
                    authenticatedUserSection(user: user)
                } else {
                    anonymousUserSection
                }

                Spacer(minLength: 24)

                // リマインダー設定
                reminderSection

                // お問い合わせ
                contactSection
            }
            .padding()
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { backToolbar }
        .navigationBarBackButtonHidden(true)
        // エラーメッセージがあればアラートを表示
        .alert("エラー", isPresented: .constant(authViewModel.errorMessage != nil), actions: {
            Button("OK") {}
        }, message: {
            Text(authViewModel.errorMessage ?? "")
        })
        // 認証シート
        .sheet(isPresented: $showAuthSheet) {
            AuthenticationView()
                .environmentObject(authViewModel)
        }
        // リマインダー設定シート
        .sheet(isPresented: $showReminderSettings) {
            ReminderSettingsView()
        }
        // アカウント削除確認アラート
        .alert("アカウント削除", isPresented: $showDeleteAccountAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                showDeleteConfirmation = true
            }
        } message: {
            Text("アカウントを削除すると、すべてのデータが完全に削除され、復元できません。\n\nこの操作は取り消せません。")
        }
        // 最終確認アラート
        .alert("最終確認", isPresented: $showDeleteConfirmation) {
            Button("キャンセル", role: .cancel) { }
            Button("削除する", role: .destructive) {
                authViewModel.deleteAccount()
            }
        } message: {
            Text("本当にアカウントを削除しますか？\n\nこの操作は取り消せません。")
        }
        .font(.system(.body, design: .rounded))
    }

    // MARK: - 認証済みユーザー向けセクション
    private func authenticatedUserSection(user: User) -> some View {
        VStack(spacing: 16) {
            Text("アカウント情報")
                .font(.headline.weight(.bold))
            VStack(alignment: .leading, spacing: 12) {
                Text("現在、以下のメールアドレスでログインしています。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Image(systemName: "envelope.fill")
                    Text(user.email ?? "取得できませんでした")
                }
                .font(.body.weight(.medium))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.7).cornerRadius(16))
            
            VStack(spacing: 12) {
                Button(role: .destructive) {
                    authViewModel.signOut()
                } label: {
                    Text("ログアウト")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .clipShape(Capsule())
                }
                
                Button(role: .destructive) {
                    showDeleteAccountAlert = true
                } label: {
                    Text("アカウント削除")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(Color.themeEntryBackground.cornerRadius(20))
    }

    // MARK: - 匿名ユーザー向けセクション
    private var anonymousUserSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "icloud.and.arrow.up.fill")
                .font(.system(size: 50))
                .foregroundColor(.themeAccent)
            Text("データ引き継ぎ設定")
                .font(.title2.weight(.bold))
                .foregroundColor(.themeAccent)
            Text("機種変更をしてもデータを引き継げるように、メールアドレスとパスワードを登録しましょう。\n\n※ 現在の記録データは引き継がれます")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            HStack(spacing: 16) {
                Button(action: {
                    authViewModel.authState = .authenticating(flow: .signUp)
                    showAuthSheet = true
                }) {
                    Text("アカウント連携")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themeAccent)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.themeAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                Button(action: {
                    authViewModel.authState = .authenticating(flow: .signIn)
                    showAuthSheet = true
                }) {
                    Text("ログイン")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themeAccent.opacity(0.15))
                        .foregroundColor(.themeAccent)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color.themeEntryBackground.cornerRadius(20))
    }

    // MARK: - リマインダー設定セクション
    private var reminderSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "bell")
                    .foregroundColor(.themeAccent)
                Text("リマインダー設定")
                    .font(.headline.weight(.bold))
                Spacer()
                if reminderViewModel.isReminderEnabled {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.themeAccent.opacity(0.6))
            }
            
            Text("毎日の気分記録を忘れないように通知を設定できます")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            if reminderViewModel.isReminderEnabled {
                Text("21:00に通知が設定されています")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.themeEntryBackground.cornerRadius(16))
        .onTapGesture {
            showReminderSettings = true
        }
    }

    // MARK: - お問い合わせセクション
    private var contactSection: some View {
        VStack(spacing: 8) {
            Divider().padding(.vertical, 8)
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.themeAccent)
                Button(action: {
                    let email = "rikuiostest@gmail.com"
                    let subject = "MoodApp2へのお問い合わせ"
                    let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
                    UIApplication.shared.open(url)
                }) {
                    Text("rikuiostest@gmail.com")
                        .foregroundColor(.themeAccent)
                        .underline()
                }
                Spacer()
            }
            .padding(.vertical, 8)
            Text("ご意見・ご要望・不具合報告などお気軽にご連絡ください。")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 24)
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // プレビュー用に、認証済みと匿名ユーザーの両方の状態を確認
        let authViewModel = AuthViewModel()
        
        Group {
            SettingsView()
                .environmentObject(authViewModel)
                .previewDisplayName("匿名ユーザー")
        }
    }
}

