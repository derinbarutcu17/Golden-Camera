import SwiftUI

struct OverlayStyle: Equatable, Codable {
    var opacity: Double
    var lineWidth: CGFloat
    var color: OverlayColorStyle
    var showsBoundingRect: Bool
    var showsSubdivisionRects: Bool
    
    static let defaultStyle = OverlayStyle(
        opacity: 0.85,
        lineWidth: 1.5,
        color: .white,
        showsBoundingRect: false,
        showsSubdivisionRects: false
    )
}

enum OverlayColorStyle: String, Codable {
    case white
    case gold
    case black
    
    var color: Color {
        switch self {
        case .white: return .white
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .black: return .black
        }
    }
}
