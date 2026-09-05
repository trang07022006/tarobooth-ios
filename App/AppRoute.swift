import Foundation

public enum AppRoute: Hashable {
    case home
    case templates
    case sourcePicker
    case camera
    case library
    case arrange
    case crop
    case review
    case editor
    case result
    case gallery
    case galleryDetail(String) // pass item ID
    case settings
    case about
}
