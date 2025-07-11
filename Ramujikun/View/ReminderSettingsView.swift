import SwiftUI

struct ReminderSettingsView: View {
    @StateObject private var viewModel = ReminderViewModel.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                headerSection
                reminderToggleSection
                Spacer()
            }
            .padding()
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationTitle("リマインダー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { backToolbar }
            .navigationBarBackButtonHidden(true)
            .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") {}
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell")
                .font(.system(size: 50))
                .foregroundColor(.themeAccent)
            
            Text("毎日の気分記録を忘れないように")
                .font(.title2.weight(.bold))
                .foregroundColor(.themeAccent)
            
            Text("21:00に通知が届きます")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.themeEntryBackground.cornerRadius(20))
    }
    
    private var reminderToggleSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "bell")
                    .foregroundColor(.themeAccent)
                Text("リマインダー")
                    .font(.headline.weight(.bold))
                Spacer()
                Toggle("", isOn: $viewModel.isReminderEnabled)
                    .onChange(of: viewModel.isReminderEnabled) { _, newValue in
                        Task {
                            await viewModel.toggleReminder()
                        }
                    }
                    .disabled(viewModel.isLoading)
            }
            
            if viewModel.isReminderEnabled {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("リマインダーが有効です")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.7).cornerRadius(16))
    }
    
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

struct ReminderSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderSettingsView()
    }
}

