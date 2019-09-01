import Foundation

// Cribbed from
// https://github.com/apple/swift-evolution/blob/master/proposals/0217-bangbang.md
// and
// https://github.com/apple/swift-evolution/pull/861

struct FatalErrorReason : CustomStringConvertible {
    let description: String
}

extension FatalErrorReason : ExpressibleByStringLiteral {
    init(stringLiteral description: String) {
        self.description = description
    }
}

func fatalError(reason: FatalErrorReason,
                       function: StaticString = #function,
                       file: StaticString = #file,
                       line: UInt = #line
) -> Never {
    fatalError("\(function): \(reason)", file: file, line: line)
}

infix operator !! : NilCoalescingPrecedence
extension Optional {
    static func !! (lhs: Optional, rhs: FatalErrorReason) -> Wrapped {
        guard let value = lhs else { fatalError(reason: rhs) }
        return value
    }
}
