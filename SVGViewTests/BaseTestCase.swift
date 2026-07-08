//
//  BaseTestCase.swift
//  SVGViewTests
//
//  Created by Yuriy Strot on 07.02.2021.
//

import XCTest
@testable import SVGView

class BaseTestCase : XCTestCase {

    var dir: String {
        return "1.2T"
    }

    func compareToReference(_ fileName: String) {
        let bundle = Bundle.module
        let svgURL = bundle.url(forResource: fileName, withExtension: "svg", subdirectory: "w3c/\(dir)/svg/")!
        let refURL = bundle.url(forResource: fileName, withExtension: "ref", subdirectory: "w3c/\(dir)/refs/")!

        print(svgURL)
        let node = SVGParser.parse(contentsOf: svgURL)!
        let content = Serializer.serialize(node)
        let reference = try! String(contentsOf: refURL)

        compareResultStrings(nodeContent: content, referenceContent: reference)
    }

    func compareResultStrings(nodeContent: String?, referenceContent: String?) {
        guard let nodeContent = nodeContent else {
            XCTFail("nodeContent is empty")
            return
        }
        guard let referenceContent = referenceContent else {
            XCTFail("referenceContent is empty")
            return
        }

        if nodeContent != referenceContent {
            XCTFail("nodeContent is not equal to referenceContent. " + prettyFirstDifferenceBetweenStrings(s1: nodeContent, s2: referenceContent))
        }
    }

    func prettyFirstDifferenceBetweenStrings(s1: String, s2: String) -> String {
        return prettyFirstDifferenceBetweenNSStrings(s1: s1 as NSString, s2: s2 as NSString) as String
    }
}

/// Find first differing character between two strings
///
/// :param: s1 First String
/// :param: s2 Second String
///
/// :returns: .DifferenceAtIndex(i) or .NoDifference
fileprivate func firstDifferenceBetweenStrings(s1: NSString, s2: NSString) -> FirstDifferenceResult {
    let len1 = s1.length
    let len2 = s2.length

    let lenMin = min(len1, len2)

    for i in 0..<lenMin {
        if s1.character(at: i) != s2.character(at: i) {
            return .DifferenceAtIndex(i)
        }
    }

    if len1 < len2 {
        return .DifferenceAtIndex(len1)
    }

    if len2 < len1 {
        return .DifferenceAtIndex(len2)
    }

    return .NoDifference
}


/// Create a formatted String representation of difference between strings
///
/// :param: s1 First string
/// :param: s2 Second string
///
/// :returns: a string, possibly containing significant whitespace and newlines
fileprivate func prettyFirstDifferenceBetweenNSStrings(s1: NSString, s2: NSString) -> NSString {
    let firstDifferenceResult = firstDifferenceBetweenStrings(s1: s1, s2: s2)
    return prettyDescriptionOfFirstDifferenceResult(firstDifferenceResult: firstDifferenceResult, s1: s1, s2: s2)
}

/// Create a formatted String representation of a FirstDifferenceResult for two strings
///
/// :param: firstDifferenceResult FirstDifferenceResult
/// :param: s1 First string used in generation of firstDifferenceResult
/// :param: s2 Second string used in generation of firstDifferenceResult
///
/// :returns: a printable string, possibly containing significant whitespace and newlines
fileprivate func prettyDescriptionOfFirstDifferenceResult(firstDifferenceResult: FirstDifferenceResult, s1: NSString, s2: NSString) -> NSString {

    func diffString(index: Int, s1: NSString, s2: NSString) -> NSString {
        let markerArrow = "\u{2b06}"  // "⬆"
        let ellipsis    = "\u{2026}"  // "…"
        /// Given a string and a range, return a string representing that substring.
        ///
        /// If the range starts at a position other than 0, an ellipsis
        /// will be included at the beginning.
        ///
        /// If the range ends before the actual end of the string,
        /// an ellipsis is added at the end.
        func windowSubstring(s: NSString, range: NSRange) -> String {
            let validRange = NSMakeRange(range.location, min(range.length, s.length - range.location))
            let substring = s.substring(with: validRange)

            let prefix = range.location > 0 ? ellipsis : ""
            let suffix = (s.length - range.location > range.length) ? ellipsis : ""

            return "\(prefix)\(substring)\(suffix)"
        }

        // Show this many characters before and after the first difference
        let windowPrefixLength = 10
        let windowSuffixLength = 10
        let windowLength = windowPrefixLength + 1 + windowSuffixLength

        let windowIndex = max(index - windowPrefixLength, 0)
        let windowRange = NSMakeRange(windowIndex, windowLength)

        let sub1 = windowSubstring(s: s1, range: windowRange)
        let sub2 = windowSubstring(s: s2, range: windowRange)

        let markerPosition = min(windowSuffixLength, index) + (windowIndex > 0 ? 1 : 0)

        let markerPrefix = String(repeating: " ", count: markerPosition)
        let markerLine = "\(markerPrefix)\(markerArrow)"

        return "Difference at index \(index):\n\(sub1)\n\(sub2)\n\(markerLine)" as NSString
    }

    switch firstDifferenceResult {
    case .NoDifference:                 return "No difference"
    case .DifferenceAtIndex(let index): return diffString(index: index, s1: s1, s2: s2)
    }
}

/// Result type for firstDifferenceBetweenStrings()
public enum FirstDifferenceResult {
    /// Strings are identical
    case NoDifference

    /// Strings differ at the specified index.
    ///
    /// This could mean that characters at the specified index are different,
    /// or that one string is longer than the other
    case DifferenceAtIndex(Int)
}

extension FirstDifferenceResult: CustomStringConvertible {
    /// Textual representation of a FirstDifferenceResult
    public var description: String {
        switch self {
        case .NoDifference:
            return "NoDifference"
        case .DifferenceAtIndex(let index):
            return "DifferenceAtIndex(\(index))"
        }
    }

    /// Textual representation of a FirstDifferenceResult for debugging purposes
    public var debugDescription: String {
        return self.description
    }
}

