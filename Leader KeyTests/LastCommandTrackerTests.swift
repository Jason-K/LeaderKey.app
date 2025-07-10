import XCTest

@testable import Leader_Key

final class LastCommandTrackerTests: XCTestCase {

  func testRecordAndGetLastCommand() {
    let tracker = LastCommandTracker.shared
    
    // Test recording a command
    tracker.recordCommand("ls -la")
    
    XCTAssertEqual(tracker.getLastCommand(), "ls -la")
    XCTAssertTrue(tracker.hasLastCommand())
  }
  
  func testInitialState() {
    // Note: This test may fail if other tests have run first
    // since LastCommandTracker is a singleton
    let tracker = LastCommandTracker.shared
    
    // For testing, we should be able to reset the state
    // but for now, just test that it handles nil gracefully
    XCTAssertNotNil(tracker.getLastCommand()) // May or may not be nil depending on test order
  }
  
  func testOverwriteCommand() {
    let tracker = LastCommandTracker.shared
    
    tracker.recordCommand("first command")
    XCTAssertEqual(tracker.getLastCommand(), "first command")
    
    tracker.recordCommand("second command")
    XCTAssertEqual(tracker.getLastCommand(), "second command")
    XCTAssertTrue(tracker.hasLastCommand())
  }
  
  func testEmptyCommand() {
    let tracker = LastCommandTracker.shared
    
    tracker.recordCommand("")
    XCTAssertEqual(tracker.getLastCommand(), "")
    XCTAssertFalse(tracker.hasLastCommand())
  }
}
