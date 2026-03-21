import XCTest
@testable import GoldenRatioCamera

final class GoldenRatioMathTests: XCTestCase {
    func testPhiConstant() {
        let expectedPhi: CGFloat = 1.618033988749895
        XCTAssertEqual(GoldenRatioMath.phi, expectedPhi, accuracy: 0.0001)
    }
    
    func testInscribedGoldenRectangle() {
        let container = CGRect(x: 0, y: 0, width: 1000, height: 500)
        let goldenRect = GoldenRatioMath.inscribedGoldenRectangle(in: container)
        
        // Height-limited: goldenHeight = 500, goldenWidth = 500 * phi = 809.017
        XCTAssertEqual(goldenRect.height, 500)
        XCTAssertEqual(goldenRect.width, 500 * GoldenRatioMath.phi, accuracy: 0.1)
        XCTAssertEqual(goldenRect.midX, container.midX, accuracy: 0.1)
        XCTAssertEqual(goldenRect.midY, container.midY, accuracy: 0.1)
    }
}
