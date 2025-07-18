import SwiftUI
import UIKit

struct MoodEntryView: View {
    @StateObject private var viewModel: MoodEntryViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCommentFocused: Bool
    
    // UI constants
    private let commentEditorHeight: CGFloat = 120
    
    init(date: Date, mood: Mood?) {
        _viewModel = StateObject(wrappedValue: MoodEntryViewModel(date: date, mood: mood))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            viewModel.selectedLevel.color.opacity(0.45).ignoresSafeArea()
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
    
    // 気分ピッカー（スライダー形式）
    var moodPickerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("気分を選択")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.themeAccent.opacity(0.8))
                Spacer()
            }
            
            // シンプルなスライダー
            VStack(spacing: 12) {
                // スライダーのトラック
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景トラック
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        // スライダーのつまみ
                        Circle()
                            .fill(Color.themeAccent)
                            .frame(width: 20, height: 20)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .offset(x: (geometry.size.width - 20) * CGFloat(viewModel.selectedLevelIndex) / 4)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if viewModel.isEditable {
                                            let percentage = max(0, min(1, value.location.x / geometry.size.width))
                                            let index = Int(round(percentage * 4))
                                            if index != viewModel.selectedLevelIndex {
                                                let impact = UIImpactFeedbackGenerator(style: .light)
                                                impact.impactOccurred()
                                                viewModel.updateSelectedLevelIndex(index)
                                            }
                                        }
                                    }
                            )
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        if viewModel.isEditable {
                            // GeometryReaderの座標系を使用
                            let percentage = max(0, min(1, location.x / geometry.size.width))
                            let index = Int(round(percentage * 4))
                            if index != viewModel.selectedLevelIndex {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                viewModel.updateSelectedLevelIndex(index)
                            }
                        }
                    }
                }
                .frame(height: 20)
                
                // 気分レベルラベル
                HStack {
                    ForEach(Array(Mood.MoodLevel.allCases.enumerated()), id: \.element) { index, level in
                        VStack(spacing: 4) {
                            Image(systemName: level.illustrationName)
                                .font(.system(size: 18))
                                .foregroundColor(level.color)
//                            Text(level.rawValue)
//                                .font(.system(.caption2, design: .rounded).weight(.medium))
//                                .foregroundColor(.themeAccent.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 8)
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


