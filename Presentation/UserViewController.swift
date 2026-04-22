//
//  UserViewController.swift
//  BankDemoApp
//
//  Created by David on 2026/4/22.
//

import UIKit
import Combine

final class UserViewController: UIViewController {

    private let tableView = UITableView()
    private var data: [UserCellViewModel] = []
    private var cancellables = Set<AnyCancellable>()

    private let viewModel: UserViewModel

    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupTableView()
        bindViewModel()
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        view.addSubview(tableView)
    }

    private func bindViewModel() {
        let input = UserViewModel.Input(
            loadTrigger: Just(()).eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.users
            .sink { [weak self] users in
                self?.data = users
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        output.error
            .sink { error in
                if let error = error {
                    print("Error:", error)
                }
            }
            .store(in: &cancellables)
    }
}

extension UserViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let item = data[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.detail
        cell.detailTextLabel?.numberOfLines = 0

        return cell
    }
}
