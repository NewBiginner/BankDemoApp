//
//  UserCellViewModel.swift
//  BankDemoApp
//
//  Created by David on 2026/4/22.
//

import Foundation

struct UserCellViewModel {
    let name: String
    let detail: String

    init(user: User) {
        self.name = user.name
        self.detail = "\(user.email) | \(user.city)"
    }
}
