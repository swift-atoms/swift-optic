import Optic

func monomorphicPartialCorrespondencesCompose() {
    let identity = Optic<Int, Int, Int, Int>.Isomorphism.identity
    let partial: Optic<Int, Int, Int, Int>.Isomorphism.Partial<Never, Never> = identity.partial
    let _: Int = partial.appending(partial.reversed).forward(42)
}
