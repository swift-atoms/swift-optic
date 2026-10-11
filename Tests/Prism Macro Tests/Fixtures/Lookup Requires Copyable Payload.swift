import AccessibilityFixture
import Optic

@dynamicMemberLookup
struct Factory: __OpticPrismAccessible {
    struct Prisms {}
}

extension Factory.Prisms {
    var token: Optic<Factory, Factory, Token, Token>.Prism {
        .init(match: { _ in .right(Token(42)) }, embed: { _ in Factory() })
    }
}

extension Factory {
    static var prisms: Prisms { Prisms() }
}
let token = Factory()[dynamicMember: \.token]
