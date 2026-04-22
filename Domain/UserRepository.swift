//
//  Untitled.swift
//  BankDemoApp
//
//  Created by David on 2026/4/22.
//

import Combine

protocol UserRepository {
    func fetchUsers() -> AnyPublisher<[User], Error>
}
