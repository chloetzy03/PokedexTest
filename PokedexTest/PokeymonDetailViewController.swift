//
//  PokeymonDetailViewController.swift
//  Pokedex
//
//  Created by Claude Code
//

import UIKit

class PokeymonDetailViewController: UITableViewController {

    // MARK: - Properties
    var pokeymon: Pokeymon

    // MARK: - Initializer
    init(pokeymon: Pokeymon) {
        self.pokeymon = pokeymon
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "Details"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editTapped)
        )
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3 // Name, Type, Date
        case 1: return 2 // Attack, Defence
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = pokeymon.name
            cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .semibold)

        case (0, 1):
            cell.textLabel?.text = "Type"
            cell.detailTextLabel?.text = "\(pokeymon.type.emoji) \(pokeymon.type.rawValue.capitalized)"

        case (0, 2):
            cell.textLabel?.text = "Date Captured"
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            cell.detailTextLabel?.text = dateFormatter.string(from: pokeymon.dateCaptured)

        case (1, 0):
            cell.textLabel?.text = "⚔️ Attack"
            cell.detailTextLabel?.text = "\(pokeymon.attack)"
            cell.detailTextLabel?.textColor = .systemRed

        case (1, 1):
            cell.textLabel?.text = "🛡️ Defence"
            cell.detailTextLabel?.text = "\(pokeymon.defense)"
            cell.detailTextLabel?.textColor = .systemBlue

        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Information"
        case 1: return "Stats"
        default: return nil
        }
    }

    // MARK: - Actions
    @objc private func editTapped() {
        let formVC = PokeymonFormViewController()
        formVC.pokeymon = pokeymon
        formVC.delegate = self

        let navController = UINavigationController(rootViewController: formVC)
        present(navController, animated: true)
    }
}

// MARK: - PokeymonFormViewControllerDelegate
extension PokeymonDetailViewController: PokeymonFormViewControllerDelegate {
    func didUpdatePokeymon(_ pokeymon: Pokeymon) {
        tableView.reloadData()
    }
}
