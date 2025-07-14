import SwiftUI
import UIKit

struct MoodEntryView: View {
    @StateObject private var viewModel: MoodEntryViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCommentFocused: Bool
    
    // UI constants
    private let iconSize: CGFloat = 100
    private let moodCircleSize: CGFloat = 56
    private let moodIconSize: CGFloat = 32
    private let moodLabelWidth: CGFloat = 60
    private let commentEditorHeight: CGFloat = 120
    
    init(date: Date, mood: Mood?) {
        _viewModel = StateObject(wrappedValue: MoodEntryViewModel(date: date, mood: mood))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            viewModel.selectedLevel.color.opacity(0.15).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    header
                    moodIllustration
                    moodPickerSection
                    commentEditor
                    Spacer(minLength: 0)
                    if viewModel.isEditable {
                        saveButton
                    }
                }
                .frame(maxWidth: 420) // iPadでも広がりすぎないように最大幅を制限
                .padding(24)
                .background(Color(.systemBackground).opacity(0.95))
                .cornerRadius(32)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
                .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.85, alignment: .center)
                .padding(.vertical, 32)
            }
            closeButton
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完了") {
                    isCommentFocused = false
                }
                .font(.system(.body, design: .rounded).weight(.bold))
                .foregroundColor(.themeAccent)
            }
        }
    }
}

// MARK: - Subviews & UI Components
private extension MoodEntryView {
    // 日付とタイトル
    var header: some View {
        Text(formattedDate)
            .font(.system(.largeTitle, design: .rounded).weight(.bold))
            .foregroundColor(.themeAccent)
            .padding(.top, 40)
    }
    
    // 気分イラスト
    var moodIllustration: some View {
        VStack(spacing: 12) {
            switch viewModel.selectedLevel {
            case .awful:
                Image("どんより")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 165, height: 165)
            case .bad:
                Image("しょぼん")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 165, height: 165)
            case .meh:
                Image("ふつう")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 165, height: 165)
            case .good:
                Image("ごきげん")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 165, height: 165)
            case .great:
                Image("るんるん")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 165, height: 165)
            }
            Text(viewModel.selectedLevel.rawValue)
                .font(.title2.weight(.bold))
                .foregroundColor(.themeAccent)
        }
    }
    
    // 気分ピッカー（横スクロール）
    var moodPickerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("気分を選択")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.themeAccent.opacity(0.8))
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(Mood.MoodLevel.allCases, id: \.self) { level in
                        moodPickerItem(for: level)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // 気分ピッカーの各アイテム
    func moodPickerItem(for level: Mood.MoodLevel) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(level.color.opacity(0.25))
                    .frame(width: moodCircleSize, height: moodCircleSize)
                Image(systemName: level.illustrationName)
                    .font(.system(size: moodIconSize))
                    .foregroundColor(level.color)
            }
            .overlay(
                Circle()
                    .stroke(level == viewModel.selectedLevel ? level.color : Color.clear, lineWidth: 4)
                    .shadow(color: level == viewModel.selectedLevel ? level.color.opacity(0.4) : .clear, radius: 6)
            )
            .onTapGesture {
                if viewModel.isEditable {
                    // 触覚フィードバックを追加
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    viewModel.selectedLevel = level
                }
            }
            // Text(level.rawValue) // ← ここをコメントアウトまたは削除
            //    .font(.system(.callout, design: .rounded).weight(.bold))
            //    .foregroundColor(.themeAccent)
            //    .lineLimit(1)
            //    .frame(width: moodLabelWidth)
        }
    }
    
    // コメント入力欄
    var commentEditor: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("コメント（オプション）")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.themeAccent.opacity(0.8))
            if viewModel.isEditable {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.comment)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(height: commentEditorHeight)
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(20, antialiased: true)
                        .disabled(!viewModel.isEditable)
                        .focused($isCommentFocused)
                    if viewModel.comment.isEmpty {
                        Text("詳細な情報を記録できます")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.themePlaceholder)
                            .padding(20)
                            .allowsHitTesting(false)
                    }
                }
                .onTapGesture {
                    if viewModel.isEditable {
                        isCommentFocused = true
                    }
                }
            } else {
                // 編集不可の場合は中央揃え・背景なし・paddingのみ
                Text(viewModel.comment.isEmpty ? "コメントはありません" : viewModel.comment)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.themeAccent)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            }
        }
    }
    
    // 保存ボタン
    var saveButton: some View {
        Button {
            // キーボードを閉じる
            isCommentFocused = false
            
            Task {
                await viewModel.saveMood()
                dismiss()
            }
        } label: {
            Label("保存", systemImage: "checkmark.circle.fill")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.themeAccent)
                .foregroundColor(Color.themeButtonText)
                .clipShape(Capsule())
                .shadow(color: Color.themeAccent.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isCommentFocused) // キーボード表示中は無効化
        .opacity(isCommentFocused ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCommentFocused)
    }
    
    // 閉じるボタン
    var closeButton: some View {
        Button {
            isCommentFocused = false
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.themeAccent.opacity(0.3))
                .padding(.top, 8)
                .padding(.trailing, 8)
        }
    }
    
    // 日付のフォーマット
    var formattedDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(viewModel.date) {
            return "今日"
        }
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: viewModel.date)
    }
}


