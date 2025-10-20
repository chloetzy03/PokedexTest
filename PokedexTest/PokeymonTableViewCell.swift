//
//  PokeymonTableViewCell.swift
//  Pokedex
//
//  Created by Claude Code
//

import UIKit

class PokeymonTableViewCell: UITableViewCell {

    static let identifier = "PokeymonTableViewCell"

    // MARK: - UI Components
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let attackLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let defenseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .leading
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        accessoryType = .disclosureIndicator

        statsStackView.addArrangedSubview(attackLabel)
        statsStackView.addArrangedSubview(defenseLabel)
        statsStackView.addArrangedSubview(dateLabel)

        mainStackView.addArrangedSubview(nameLabel)
        mainStackView.addArrangedSubview(typeLabel)
        mainStackView.addArrangedSubview(statsStackView)

        contentView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Configuration
    func configure(with pokeymon: Pokeymon) {
        nameLabel.text = pokeymon.name
        typeLabel.text = "\(pokeymon.type.emoji) \(pokeymon.type.rawValue.capitalized)"
        attackLabel.text = "⚔️ \(pokeymon.attack)"
        defenseLabel.text = "🛡️ \(pokeymon.defense)"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateLabel.text = "📅 \(dateFormatter.string(from: pokeymon.dateCaptured))"
    }
}
