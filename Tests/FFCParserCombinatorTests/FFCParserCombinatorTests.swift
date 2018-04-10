import XCTest
import FFCParserCombinator

class FFCParserCombinatorTests: XCTestCase {

    let float = { Double($0)! } <^> BasicParser.floatingPointString

    let signedFloat = ({ Double($0)! } <^> BasicParser.negation.optional.followed(by: BasicParser.floatingPointString) { (neg, num) -> String in
        (neg ?? "") + num
        })

    func testFloatingPoint() {
        XCTAssertNil(float.run("")?.0)
        XCTAssertNil(float.run("A0.1")?.0)
        XCTAssertNil(float.run("\n0.1")?.0)
        XCTAssertNil(float.run("1")?.0)
        XCTAssertNil(float.run("0")?.0)
        XCTAssertNil(float.run("-1")?.0)
        XCTAssertNil(float.run("-1.1")?.0)

        XCTAssertEqual(float.run("0.1")!.0, 0.1, accuracy: 0.0001)
        XCTAssertEqual(float.run("1.1")!.0, 1.1, accuracy: 0.0001)
        XCTAssertEqual(float.run("18446744073709551615.18446744073709551615")!.0, 18446744073709551615.18446744073709551615, accuracy: 0.0001)
    }

    func testSignedFloatingPoint() {
        XCTAssertNil(signedFloat.run("")?.0)
        XCTAssertNil(signedFloat.run("A0.1")?.0)
        XCTAssertNil(signedFloat.run("\n0.1")?.0)
        XCTAssertNil(signedFloat.run("1")?.0)
        XCTAssertNil(signedFloat.run("0")?.0)
        XCTAssertNil(signedFloat.run("-1")?.0)

        XCTAssertEqual(signedFloat.run("0.1")!.0, 0.1, accuracy: 0.0001)
        XCTAssertEqual(signedFloat.run("1.1")!.0, 1.1, accuracy: 0.0001)
        XCTAssertEqual(signedFloat.run("18446744073709551615.18446744073709551615")!.0, 18446744073709551615.18446744073709551615, accuracy: 0.0001)

        XCTAssertEqual(signedFloat.run("-0.1")!.0, -0.1, accuracy: 0.0001)
        XCTAssertEqual(signedFloat.run("-1.1")!.0, -1.1, accuracy: 0.0001)
        XCTAssertEqual(signedFloat.run("-18446744073709551615.18446744073709551615")!.0, -18446744073709551615.18446744073709551615, accuracy: 0.0001)
    }

    func testInt() {
        // Not a number
        XCTAssertNil(BasicParser.int.run("")?.0)
        XCTAssertNil(BasicParser.int.run("a")?.0)
        XCTAssertNil(BasicParser.int.run("abcdef")?.0)
        XCTAssertNil(BasicParser.int.run("-1")?.0)

        // Normal numbers in full range
        XCTAssertEqual(BasicParser.int.run(String(UInt.min))?.0, UInt.min)
        XCTAssertEqual(BasicParser.int.run("0")?.0, 0)
        XCTAssertEqual(BasicParser.int.run("1")?.0, 1)
        XCTAssertEqual(BasicParser.int.run("1234")?.0, 1234)
        // 2^64-1 (18446744073709551615)
        // Defined as the maximum for "decimal-integer" in HLS specification
        XCTAssertEqual(BasicParser.int.run("18446744073709551615")?.0, 18446744073709551615)
        XCTAssertEqual(BasicParser.int.run(String(UInt.max))?.0, UInt.max)

        // Starts with numbers
        XCTAssertEqual(BasicParser.int.run("0abcdef")?.0, 0)
        XCTAssertEqual(BasicParser.int.run("1-")?.0, 1)
        XCTAssertEqual(BasicParser.int.run("1234&234")?.0, 1234)
        XCTAssertEqual(BasicParser.int.run("18446744073709551615\n")?.0, 18446744073709551615)

        // Not a number
        XCTAssertNil(BasicParser.int.run("")?.0)
        XCTAssertNil(BasicParser.int.run("A")?.0)
        XCTAssertNil(BasicParser.int.run("ABCDEF")?.0)
        XCTAssertNil(BasicParser.int.run("-1")?.0)
    }

    static var allTests = [
        ("testInt", testInt),
        ("testSignedFloatingPoint", testSignedFloatingPoint),
        ("testFloatingPoint",testFloatingPoint)
    ]
}
