//
//  PokeymonFormViewController.swift
//  Pokedex
//
//  Created by Claude Code
//

import UIKit

protocol PokeymonFormViewControllerDelegate: AnyObject {
    func didAddPokeymon(_ pokeymon: Pokeymon)
    func didUpdatePokeymon(_ pokeymon: Pokeymon)
}

extension PokeymonFormViewControllerDelegate {
    func didAddPokeymon(_ pokeymon: Pokeymon) {}
    func didUpdatePokeymon(_ pokeymon: Pokeymon) {}
}

class PokeymonFormViewController: UITableViewController {
    
    // MARK: - Properties
    weak var delegate: PokeymonFormViewControllerDelegate?
    var pokeymon: Pokeymon?
    
    // MARK: - Initializers
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Pokeymon Name"
        textField.font = .systemFont(ofSize: 17)
        return textField
    }()
    
    private let typePicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    private let attackStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 999
        stepper.stepValue = 1
        return stepper
    }()
    
    private let defenseStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 999
        stepper.stepValue = 1
        return stepper
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    private var attackValue: Int = 0 {
        didSet {
            updateStatLabel(for: .attack)
        }
    }
    
    private var defenseValue: Int = 0 {
        didSet {
            updateStatLabel(for: .defense)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        configureForEditing()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = pokeymon == nil ? "Add Pokeymon" : "Edit Pokeymon"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
        
        typePicker.delegate = self
        typePicker.dataSource = self
    }
    
    private func setupActions() {
        attackStepper.addTarget(self, action: #selector(attackStepperChanged), for: .valueChanged)
        defenseStepper.addTarget(self, action: #selector(defenseStepperChanged), for: .valueChanged)
    }
    
    private func configureForEditing() {
        guard let pokeymon = pokeymon else { return }
        
        nameTextField.text = pokeymon.name
        attackStepper.value = Double(pokeymon.attack)
        defenseStepper.value = Double(pokeymon.defense)
        attackValue = pokeymon.attack
        defenseValue = pokeymon.defense
        datePicker.date = pokeymon.dateCaptured
        
        if let typeIndex = PokeymonType.allCases.firstIndex(of: pokeymon.type) {
            typePicker.selectRow(typeIndex, inComponent: 0, animated: false)
        }
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // Name
        case 1: return 1 // Type Picker
        case 2: return 2 // Attack, Defence
        case 3: return 1 // Date Picker
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.text = "Name"
            cell.contentView.addSubview(nameTextField)
            nameTextField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nameTextField.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 16),
                nameTextField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                nameTextField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
        case (1, 0):
            cell.contentView.addSubview(typePicker)
            typePicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                typePicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                typePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                typePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                typePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            
        case (2, 0):
            cell.textLabel?.text = "⚔️ Attack"
            cell.detailTextLabel?.text = "\(attackValue)"
            cell.detailTextLabel?.textColor = .systemRed
            cell.accessoryView = attackStepper
            
        case (2, 1):
            cell.textLabel?.text = "🛡️ Defence"
            cell.detailTextLabel?.text = "\(defenseValue)"
            cell.detailTextLabel?.textColor = .systemBlue
            cell.accessoryView = defenseStepper
            
        case (3, 0):
            cell.contentView.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                datePicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                datePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                datePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
            
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Basic Info"
        case 1: return "Type"
        case 2: return "Stats"
        case 3: return "Date Captured"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1: return 200 // Type picker
        case 3: return 200 // Date picker
        default: return UITableView.automaticDimension
        }
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please enter a name for your Pokeymon")
            return
        }
        
        let selectedTypeIndex = typePicker.selectedRow(inComponent: 0)
        let type = PokeymonType.allCases[selectedTypeIndex]
        let attack = Int(attackStepper.value)
        let defense = Int(defenseStepper.value)
        let dateCaptured = datePicker.date
        
        if let existingPokeymon = pokeymon {
            // Mutate existing instance (class = reference type)
            existingPokeymon.name = name
            existingPokeymon.type = type
            existingPokeymon.attack = attack
            existingPokeymon.defense = defense
            existingPokeymon.dateCaptured = dateCaptured
            delegate?.didUpdatePokeymon(existingPokeymon)
        } else {
            let newPokeymon = Pokeymon(
                name: name,
                type: type,
                attack: attack,
                defense: defense,
                dateCaptured: dateCaptured
            )
            delegate?.didAddPokeymon(newPokeymon)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func attackStepperChanged() {
        attackValue = Int(attackStepper.value)
    }
    
    @objc private func defenseStepperChanged() {
        defenseValue = Int(defenseStepper.value)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private enum StatType {
        case attack, defense
    }
    
    private func updateStatLabel(for stat: StatType) {
        let indexPath: IndexPath
        let value: Int
        
        switch stat {
        case .attack:
            indexPath = IndexPath(row: 0, section: 2)
            value = attackValue
        case .defense:
            indexPath = IndexPath(row: 1, section: 2)
            value = defenseValue
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.detailTextLabel?.text = "\(value)"
        }
    }
}

// MARK: - UIPickerViewDelegate & DataSource
extension PokeymonFormViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PokeymonType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let type = PokeymonType.allCases[row]
        return "\(type.emoji) \(type.rawValue.capitalized)"
    }
}




