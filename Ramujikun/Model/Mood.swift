import Foundation
import FirebaseFirestore
import SwiftUI

struct Mood: Identifiable, Equatable, Codable {
    @DocumentID var id: String?
    let date: Date
    let level: MoodLevel
    let comment: String
    var userId: String?

    enum MoodLevel: String, Codable, CaseIterable, Equatable {
        case awful = "どんより"
        case bad = "しょぼん"
        case meh = "ふつう"
        case good = "ごきげん"
        case great = "るんるん"
    }
}

// MARK: - MoodLevel Extension
extension Mood.MoodLevel {
    var color: Color {
        switch self {
        case .awful:   return Color("Color1")
        case .bad:    return Color("Color2")
        case .meh:    return Color("Color3")
        case .good:   return Color("Color4")
        case .great:  return Color("Color5")
        }
    }
    
    var illustrationName: String {
        switch self {
        case .great:   return "sun.max.fill"
        case .good:      return "cloud.sun.fill"
        case .meh:    return "cloud.fill"
        case .bad:    return "cloud.drizzle.fill"
        case .awful: return "cloud.bolt.rain.fill"
        }
    }
    
    var assetImageName: String {
        switch self {
        case .awful:   return "どんより"
        case .bad:    return "しょぼん"
        case .meh:    return "ふつう"
        case .good:   return "ごきげん"
        case .great:  return "るんるん"
        }
    }
}

