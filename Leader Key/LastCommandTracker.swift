import Foundation

class LastCommandTracker {
  static let shared = LastCommandTracker()
  
  private(set) var lastCommand: String?
  
  private init() {}
  
  func recordCommand(_ command: String) {
    lastCommand = command
  }
  
  func getLastCommand() -> String? {
    return lastCommand
  }
  
  func hasLastCommand() -> Bool {
    return lastCommand != nil && !lastCommand!.isEmpty
  }
}
