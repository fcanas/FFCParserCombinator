import XCTest
import FFCParserCombinator

class FFCParserCombinatorTests: XCTestCase {

    func testMultiMatching() {
        let dot: Parser<Substring, String> = "."
        let fourDots = dot.atLeast(4)
        XCTAssertEqual(fourDots.run("......")?.0, [".", ".", ".", ".", ".", "."])
        XCTAssertEqual(fourDots.run("...")?.0, nil)

        let fourToSixDots = dot.between(4, and: 6)
        XCTAssertEqual(fourToSixDots.run("......")?.0, [".", ".", ".", ".", ".", "."])
        XCTAssertEqual(fourToSixDots.run("..........")?.0, [".", ".", ".", ".", ".", "."])
        XCTAssertEqual(fourToSixDots.run("....")?.0, [".", ".", ".", "."])
        XCTAssertEqual(fourToSixDots.run("...")?.0, nil)
        XCTAssertEqual(fourToSixDots.run(".")?.0, nil)
        XCTAssertEqual(fourToSixDots.run("")?.0, nil)

        let atLeastFourDots = dot.atLeast(4)
        XCTAssertEqual(atLeastFourDots.run("......")?.0, [".", ".", ".", ".", ".", "."])
        XCTAssertEqual(atLeastFourDots.run("....")?.0, [".", ".", ".", "."])
        XCTAssertEqual(atLeastFourDots.run("...")?.0, nil)
        XCTAssertEqual(atLeastFourDots.run(".")?.0, nil)
        XCTAssertEqual(atLeastFourDots.run("")?.0, nil)

        let manyOne = dot.many1
        XCTAssertEqual(manyOne.run("...")?.0, [".", ".", "."])
        XCTAssertEqual(manyOne.run("..")?.0, [".", "."])
        XCTAssertEqual(manyOne.run(".")?.0, ["."])
        XCTAssertEqual(manyOne.run("")?.0, nil)

        let many = dot.many
        XCTAssertEqual(many.run("...")?.0, [".", ".", "."])
        XCTAssertEqual(many.run("..")?.0, [".", "."])
        XCTAssertEqual(many.run(".")?.0, ["."])
        XCTAssertEqual(many.run("")?.0, [])
    }

    func testOr() {

        let alternativeParser = "One thing" <|> "Another"

        XCTAssertEqual(alternativeParser.run("One thing")?.0, "One thing")
        XCTAssertEqual(alternativeParser.run("Another")?.0, "Another")
        XCTAssertEqual(alternativeParser.run("And Another")?.0, nil)
        XCTAssertEqual(alternativeParser.run("One more")?.0, nil)
    }

    static var allTests = [
        ("testMultiMatching", testMultiMatching),
        ("testOr", testOr),
    ]
}
