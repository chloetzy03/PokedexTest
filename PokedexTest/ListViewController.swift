//
//  ViewController.swift
//  Pokedex
//
//  Created by YJ Soon on 9/10/25.
//

import UIKit

class ListViewController: UIViewController {

    // MARK: - Properties
    private var pokeymon: [Pokeymon] = []

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(PokeymonTableViewCell.self, forCellReuseIdentifier: PokeymonTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "Pokeymon Collection"
        view.backgroundColor = .systemBackground

        // Large title navigation
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        // Colored navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemIndigo
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white

        // Add button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )

        // Setup table view
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func addButtonTapped() {
        let formVC = PokeymonFormViewController()
        formVC.delegate = self
        let navController = UINavigationController(rootViewController: formVC)
        present(navController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokeymon.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PokeymonTableViewCell.identifier,
            for: indexPath
        ) as? PokeymonTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: pokeymon[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedPokeymon = pokeymon[indexPath.row]
        let detailVC = PokeymonDetailViewController(pokeymon: selectedPokeymon)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            pokeymon.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - PokeymonFormViewControllerDelegate
extension ListViewController: PokeymonFormViewControllerDelegate {
    func didAddPokeymon(_ pokeymon: Pokeymon) {
        self.pokeymon.append(pokeymon)
        tableView.reloadData()
    }
}
