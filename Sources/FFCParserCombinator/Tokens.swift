//
//  Tokens.swift
//  FFCParserCombinator
//
//  Created by Fabian Canas on 9/3/16.
//  Copyright © 2017 Fabian Canas. All rights reserved.
//

import Foundation

/** Builds a `Parser` for matching a single character
 - parameter condition: A function that determines whether the character is parsed
                  (returns true) or causes the returned parser to fail (returns
                  false).
 - returns: A `Parser` for a single `Character` passing the provided `condition`
*/
public func character( condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return Parser { stream in
        guard let char :Character = stream.first, condition(char) else { return nil }
        return (char, stream.dropFirst())
    }
}

extension CharacterSet {
    /** Builds a parser for matching a single character in the receiving
     `CharacterSet`
     - returns: A `Parser` that will match a single `Character` in `characterSet`
     */
    public func parser() -> Parser<Character> {
        return character(condition: { self.contains($0.unicodeScalar) } )
    }
}

extension String {
    /** Builds a parser for matching the receiving `String`
     */
    public func parser() -> Parser<String> {
        return Parser<String> { stream in
            var remainder = stream
            for char in self {
                guard let (_, newRemainder) = character(condition: { $0 == char }).parse(remainder) else {
                    return nil
                }
                remainder = newRemainder
            }
            return (self, remainder)
        }
    }

    public var fullRange :Range<Index> {
        get {
            return Range(uncheckedBounds: (lower: startIndex, upper: endIndex))
        }
    }
}

extension Character {
    /// The first `UnicodeScalar` of the `String` representation
    public var unicodeScalar: UnicodeScalar {
        return String(self).unicodeScalars.first!
    }
}

public struct BasicParser {

    public static let digit = CharacterSet.decimalDigits.parser()

    public static let hexDigit = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "A"..."F")).parser()

    // Fragments

    public static let hexPrefix = "0x".parser() <|> "0X".parser()

    public static let decimalPoint = ".".parser()

    public static let negation = "-".parser()

    public static let quote = "\"".parser()

    public static let x = character { $0 == "x" }

    public static let numericString = { String($0) } <^> digit.many1

    public static let floatingPointString = numericString.followed(by: decimalPoint, combine: +).followed(by: numericString, combine: +)

    public static let int = { characters in UInt(String(characters))! } <^> digit.many1

    public static let newline = character { $0 == "\n" } <|> (character { $0 == "\n" } <* character { $0 == "\r" })
}
