import Either

extension Swift.Result.Prisms {
    public var success: Optic<
        Swift.Result<Success, Failure>,
        Swift.Result<Success, Failure>,
        Success,
        Success
    >.Prism {
        .init(
            match: { source in
                switch source {
                case let .success(success): return .right(success)
                case let .failure(failure): return .left(.failure(failure))
                }
            },
            embed: Swift.Result<Success, Failure>.success
        )
    }

    public var failure: Optic<
        Swift.Result<Success, Failure>,
        Swift.Result<Success, Failure>,
        Failure,
        Failure
    >.Prism {
        .init(
            match: { source in
                switch source {
                case let .success(success): return .left(.success(success))
                case let .failure(failure): return .right(failure)
                }
            },
            embed: Swift.Result<Success, Failure>.failure
        )
    }
}
