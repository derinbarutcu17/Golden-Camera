import Foundation

enum OverlayMode: String, CaseIterable, Codable {
    case goldenSpiral
    case phiGrid
    case thirdsGrid
    case none
    
    var localizedName: String {
        switch self {
        case .goldenSpiral: return "Golden Spiral"
        case .phiGrid: return "Phi Grid"
        case .thirdsGrid: return "Rule of Thirds"
        case .none: return "None"
        }
    }
}
