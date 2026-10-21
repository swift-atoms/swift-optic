import ArrowFixture
import Either

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
            case .value(let value): .right(value)
            case .other(let source): .left(ScopedTarget(value: source.value))
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
            case .value(let focus): .right(focus)
            case .other(let source): .left(source.value)
            }
        },
        embed: { replacement in
            replacement
        }
    )
}
