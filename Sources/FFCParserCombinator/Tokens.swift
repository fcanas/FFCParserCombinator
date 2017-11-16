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
func character( condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return Parser { stream in
        guard let char :Character = stream.first, condition(char) else { return nil }
        return (char, stream.dropFirst())
    }
}

/** Builds a parser for matching a single character in the provided
    `CharacterSet`
 - parameter characterSet: A `CharacterSet` of all characters the resulting
                           `Parser` will match.
 - returns: A `Parser` that will match a single `Character` in `characterSet`
 */
func character(in characterSet: CharacterSet ) -> Parser<Character> {
    return character(condition: { characterSet.contains($0.unicodeScalar) } )
}

/** Builds a parser for matching the provided `String`
 */
func string(_ string: String) -> Parser<String> {
    return Parser<String> { stream in
        var remainder = stream
        for char in string {
            guard let (_, newRemainder) = character(condition: { $0 == char }).parse(remainder) else {
                return nil
            }
            remainder = newRemainder
        }
        return (string, remainder)
    }
}

extension Character {
    /// The first `UnicodeScalar` of the `String` representation
    public var unicodeScalar: UnicodeScalar {
        return String(self).unicodeScalars.first!
    }
}
