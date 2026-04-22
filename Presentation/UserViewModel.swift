//
//  UserViewModel.swift
//  BankDemoApp
//
//  Created by David on 2026/4/22.
//
import Combine
import Foundation

final class UserViewModel {

    struct Input {
        let loadTrigger: AnyPublisher<Void, Never>
    }

    struct Output {
        let users: AnyPublisher<[UserCellViewModel], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let error: AnyPublisher<String?, Never>
    }

    private let useCase: FetchUsersUseCase

    init(useCase: FetchUsersUseCase) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {

        let loading = CurrentValueSubject<Bool, Never>(false)
        let error = PassthroughSubject<String?, Never>()

        let users = input.loadTrigger
            .handleEvents(receiveOutput: { _ in
                loading.send(true)
                error.send(nil)
            })
            .flatMap { [weak self] _ -> AnyPublisher<[User], Never> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }

                return self.useCase.execute()
                    .handleEvents(receiveCompletion: { completion in
                        loading.send(false)
                        if case .failure(let err) = completion {
                            error.send(err.localizedDescription)
                        }
                    })
                    .catch { _ in Just([]) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .map { users in

                users.map { UserCellViewModel(user: $0) }

            }
            .eraseToAnyPublisher()

        return Output(
            users: users,
            isLoading: loading
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher(),
            error: error
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        )
    }
}
