// EXPECT-ERROR: requires the types|requires types|be equivalent
import Optic

func cannotChangeRepresentationDuringARoundTrip(
    _ partial: Optic<Int, String, Bool, Bool>.Isomorphism.Partial<Never, Never>
) {}
