import Either
import ArrowFixture

struct ScopedSource: ~Escapable {
    let value: Int
}

struct ScopedTarget: ~Escapable {
    let value: Int
}

struct ScopedFocus: ~Escapable {
    let value: Int
}

struct ScopedReplacement: ~Escapable {
    let value: Int
}

enum TargetProbeSource: ~Escapable {
    case value(Int)
    case other(ScopedSource)
}

enum FocusProbeSource: ~Escapable {
    case value(ScopedFocus)
    case other(ScopedSource)
}

func proveStoredMatchRequiresEscapableTarget() {
    _ = Family<TargetProbeSource, ScopedTarget, Int, ScopedReplacement>.TargetRelaxedPrism(
        match: { source in
            switch source {
            case let .value(value): .right(value)
            case let .other(source): .left(ScopedTarget(value: source.value))
            }
        },
        embed: { replacement in
            ScopedTarget(value: replacement.value)
        }
    )
}

func proveStoredMatchRequiresEscapableFocus() {
    _ = Family<FocusProbeSource, Int, ScopedFocus, Int>.FocusRelaxedPrism(
        match: { source in
            switch source {
            case let .value(focus): .right(focus)
            case let .other(source): .left(source.value)
            }
        },
        embed: { replacement in
            replacement
        }
    )
}
