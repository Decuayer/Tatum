import Foundation

/// Categories for tattoo posts in the Discovery feed
enum TattooCategory: String, Codable, CaseIterable {
    case traditional = "traditional"
    case realism = "realism"
    case geometric = "geometric"
    case minimalist = "minimalist"
    case japanese = "japanese"
    case tribal = "tribal"
    case blackwork = "blackwork"
    case watercolor = "watercolor"
    case neotraditional = "neo_traditional"
    case dotwork = "dotwork"
    case portrait = "portrait"
    case abstract = "abstract"
    case other = "other"
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .traditional:
            return "Traditional"
        case .realism:
            return "Realism"
        case .geometric:
            return "Geometric"
        case .minimalist:
            return "Minimalist"
        case .japanese:
            return "Japanese"
        case .tribal:
            return "Tribal"
        case .blackwork:
            return "Blackwork"
        case .watercolor:
            return "Watercolor"
        case .neotraditional:
            return "Neo-Traditional"
        case .dotwork:
            return "Dotwork"
        case .portrait:
            return "Portrait"
        case .abstract:
            return "Abstract"
        case .other:
            return "Other"
        }
    }
    
    /// Icon for category (SF Symbol name)
    var iconName: String {
        switch self {
        case .traditional:
            return "paintbrush.fill"
        case .realism:
            return "camera.fill"
        case .geometric:
            return "squareshape.split.3x3"
        case .minimalist:
            return "minus.circle.fill"
        case .japanese:
            return "mountains.fill"
        case .tribal:
            return "leaf.fill"
        case .blackwork:
            return "square.fill"
        case .watercolor:
            return "paintpalette.fill"
        case .neotraditional:
            return "sparkles"
        case .dotwork:
            return "circle.grid.cross.fill"
        case .portrait:
            return "person.crop.square.fill"
        case .abstract:
            return "scribble"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}

/// Body placement for tattoos
enum BodyPlacement: String, Codable, CaseIterable {
    case arm = "arm"
    case leg = "leg"
    case back = "back"
    case chest = "chest"
    case shoulder = "shoulder"
    case hand = "hand"
    case foot = "foot"
    case neck = "neck"
    case face = "face"
    case other = "other"
    
    var displayName: String {
        rawValue.capitalized
    }
}
