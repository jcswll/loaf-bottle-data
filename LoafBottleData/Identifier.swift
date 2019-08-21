import Foundation

struct Identifier<T> : RawRepresentable {
    let rawValue: String
}

extension Identifier : ExpressibleByStringLiteral {
    init(stringLiteral: String) {
        self.rawValue = stringLiteral
    }
}
