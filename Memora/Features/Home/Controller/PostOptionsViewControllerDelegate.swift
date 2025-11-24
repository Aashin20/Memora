import Foundation
import UIKit

public enum MemoryVisibility: Int, Codable {
    case everyone
    case `private`
    case scheduled
}

public protocol PostOptionsViewControllerDelegate: AnyObject {
    func postOptionsViewControllerDidCancel(_ controller: UIViewController)
    func postOptionsViewController(_ controller: UIViewController,
                                   didFinishPostingWithTitle title: String?,
                                   scheduleDate: Date?,
                                   visibility: MemoryVisibility)
}
