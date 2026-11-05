//
//  PokedexTestTests.swift
//  PokedexTestTests
//
//  Created by Kaushik Manian on 20/10/25.
//

import XCTest
@testable import PokedexTest

@MainActor
final class PokedexTestTests: XCTestCase {
    
    //    func testSomething() {
    //        XCTAssertEqual(0, 0)
    //    }
    
    //MARK: PART 0 Does it even run…?
    func testAppDelegateLaunch(){
        //arrange
        let appDelegate = AppDelegate()
        
        //act
        let didLaunch = appDelegate.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: nil
        )
        
        //assert
        XCTAssertTrue(didLaunch)
        
    }
    
}

    
//MARK: - PART 1 Testing Models
final class ModelTests: XCTestCase { //Test: Verify all 8 types exist with correct emojis.
    func test_model_pokeymonType_hasExpectedEmojiMapping_andAllCasesCount() {
        // ARRANGE: Expected count
        let expectedCount = 8
        
        // ASSERT: Count matches
        XCTAssertEqual(PokeymonType.allCases.count, expectedCount)
        
        // ARRANGE: Expected emoji mapping
        let map: [PokeymonType: String] = [
            .fire: "🔥", .water: "💧", .earth: "🪨", .grass: "🌿",
            .electric: "⚡️", .ice: "❄️", .flying: "🪽", .psychic: "🔮"
        ]
        
        // ASSERT: Each type has correct emoji
        for (type, expectedEmoji) in map {
            XCTAssertEqual(type.emoji, expectedEmoji)
        }
    }
}


final class ModelInitTests: XCTestCase { //Test: Verify Pokeymon stores all properties.
    func test_model_pokeymon_init_setsFields() {
        // ARRANGE
        let fixed = Date(timeIntervalSince1970: 1_700_000_000)

        // ACT
        let p = Pokeymon(
            name: "Pika",
            type: .electric,
            attack: 123,
            defense: 77,
            dateCaptured: fixed
        )

        // ASSERT
        XCTAssertEqual(p.name, "Pika")
        XCTAssertEqual(p.type, .electric)
        XCTAssertEqual(p.attack, 123)
        XCTAssertEqual(p.defense, 77)
        XCTAssertEqual(p.dateCaptured, fixed)
    }
}



//MARK: - PART 2 Testing Table View Cells
@MainActor
final class CellTests: XCTestCase { //Test: Verify the > indicator exists.
    func test_cell_initialState_hasDisclosureIndicator() {
        // ARRANGE: build a fresh cell
        let cell = PokeymonTableViewCell(
            style: .default,
            reuseIdentifier: PokeymonTableViewCell.identifier
        )
        // ACT: (nothing)
        // ASSERT: shows the > arrow on the right
        XCTAssertEqual(cell.accessoryType, .disclosureIndicator)
    }
}


@MainActor
final class CellConfigureTests: XCTestCase { //Test: Verify configure(with:) updates all labels.

    func test_cell_configure_setsAllVisibleTexts() {
        // ARRANGE: make a cell and some fake data
        let cell = PokeymonTableViewCell(
            style: .default,
            reuseIdentifier: PokeymonTableViewCell.identifier
        )
        let fixed = Date(timeIntervalSince1970: 1_700_000_000)
        let p = Pokeymon(
            name: "Charmy",
            type: .fire,
            attack: 250,
            defense: 199,
            dateCaptured: fixed
        )

        // ACT: fill the cell 
        cell.configure(with: p)

        // ASSERT: Collect all label texts
        let labels = cell.contentView.allLabels()
        //pull out each label's text, skipping nil ones
        let texts = labels.compactMap { $0.text } 

        //check each expected text appears
        XCTAssertTrue(texts.contains("Charmy"))
        XCTAssertTrue(texts.contains { $0.contains("🔥") && $0.contains("Fire") })
        XCTAssertTrue(texts.contains("⚔️ 250"))
        XCTAssertTrue(texts.contains("🛡️ 199"))
        XCTAssertTrue(texts.contains { $0.hasPrefix("📅 ") && $0.count > 3 })

        if let dateLabel = labels.first(where: { ($0.text ?? "").hasPrefix("📅 ") }) {
            XCTAssertEqual(dateLabel.textColor, .tertiaryLabel)
        }
    }
}


//MARK: - PART 3 Testing List View Controller
@MainActor
final class ListVCTests: XCTestCase { //Test: Verify title and that + button presents form.
    func test_listVC_hasTitle_andPresentsFormWhenAddTapped() {
        // ARRANGE
        let sut = ListViewController() //create screen
        let nav = UINavigationController(rootViewController: sut) //wrap in navbar
        let window = makeKeyTestWindow() //make fake window
        window.rootViewController = nav //put screen into window

        // ACT run viewDidLoad
        sut.loadViewIfNeeded() 

        // ASSERT check title text
        XCTAssertEqual(sut.title, "Pokeymon Collection") 

        // ACT: Tap add button
        let add = sut.navigationItem.rightBarButtonItem
        XCTAssertNotNil(add) //fail if button is missing
        _ = add?.target?.perform(add!.action!, with: add) //tap the button with code

        // ASSERT: Form presented
        XCTAssertTrue(sut.presentedViewController is UINavigationController) //check that smth popped up
        let presentedNav = sut.presentedViewController as? UINavigationController
        XCTAssertTrue(presentedNav?.viewControllers.first is PokeymonFormViewController) //check that first screen inside is the form

        // Cleanup
        sut.dismiss(animated: false) 
        window.isHidden = true
    }
}


@MainActor
final class ListVCAddTests: XCTestCase { //Test: Verify delegate method updates table.
    func test_listVC_didAddPokeymon_updatesTableRowCount() {
        // ARRANGE
        let sut = ListViewController()
        let nav = UINavigationController(rootViewController: sut)
        let window = makeKeyTestWindow()
        window.rootViewController = nav
        sut.loadViewIfNeeded()

        // Find the table inside the screen (it's private, so we search for it)
        let table = sut.view.firstSubview(of: UITableView.self)!
        //starting state - table is empty
        XCTAssertEqual(sut.tableView(table, numberOfRowsInSection: 0), 0)

        // ACT add one pokeymon, as if the form's Save was tapped
        sut.didAddPokeymon(.init(name: "Bulby", type: .grass, attack: 10, defense: 20))

        // ASSERT the table now has 1 row
        XCTAssertEqual(sut.tableView(table, numberOfRowsInSection: 0), 1)

        //cleanup
        window.isHidden = true
    }
}


@MainActor
final class ListVCSelectTests: XCTestCase { //Test: Verify tapping row pushes detail screen.
    func test_listVC_didSelectRow_pushesDetailWithSameModel() {
        // ARRANGE
        let sut = ListViewController()
        let nav = UINavigationController(rootViewController: sut)
        let window = makeKeyTestWindow()
        window.rootViewController = nav
        sut.loadViewIfNeeded()

        let table = sut.view.firstSubview(of: UITableView.self)!
        //create one pokeymon and add it so row 0 exists
        let p = Pokeymon(name: "Misty", type: .water, attack: 42, defense: 24)
        sut.didAddPokeymon(p)

        // ACT "tap" row 0 by calling the table's tap method directly
        sut.tableView(table, didSelectRowAt: IndexPath(row: 0, section: 0))

        // ASSERT
        XCTAssertTrue(nav.topViewController is PokeymonDetailViewController)
        let detail = nav.topViewController as! PokeymonDetailViewController
        let cell = detail.tableView(detail.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.detailTextLabel?.text, "Misty")
        window.isHidden = true
    }
}


@MainActor
final class ListVCDeleteTests: XCTestCase { //Test: Verify swipe-to-delete works.
    func test_listVC_deleteRow_removesItem_andRowCountDecreases() {
        // ARRANGE
        let sut = ListViewController()
        let nav = UINavigationController(rootViewController: sut)
        let window = makeKeyTestWindow()
        window.rootViewController = nav
        sut.loadViewIfNeeded()

        let table = sut.view.firstSubview(of: UITableView.self)!
        sut.didAddPokeymon(.init(name: "A", type: .fire, attack: 1, defense: 1))
        sut.didAddPokeymon(.init(name: "B", type: .water, attack: 2, defense: 2))
        XCTAssertEqual(sut.tableView(table, numberOfRowsInSection: 0), 2)

        // ACT
        sut.tableView(table, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))

        // ASSERT
        XCTAssertEqual(sut.tableView(table, numberOfRowsInSection: 0), 1)
        window.isHidden = true
    }
}


@MainActor
final class ListVCRowsTests: XCTestCase { //Test: Verify automatic dimension heights.
    func test_listVC_rowHeights_matchContract() {
        // ARRANGE
        let sut = ListViewController()
        sut.loadViewIfNeeded()
        let table = sut.view.firstSubview(of: UITableView.self)!

        // ACT & ASSERT
        XCTAssertEqual(sut.tableView(table, heightForRowAt: IndexPath(row: 0, section: 0)), UITableView.automaticDimension)
        XCTAssertEqual(sut.tableView(table, estimatedHeightForRowAt: IndexPath(row: 0, section: 0)), 100)
    }
}



//MARK: - PART 4 Testing Detail View Controller
@MainActor
final class DetailVCTitleTests: XCTestCase{ //Test: Verify detail screen has correct title.
    func test_detailVC_hasTitle() {
        // ARRANGE make a pokeymon and the detail screen for it
        let sut = PokeymonDetailViewController(pokeymon: .makeTest()) //create screen
        
        // ACT run viewDidLoad
        sut.loadViewIfNeeded()
        
        // ASSERT check title text is "Details"
        XCTAssertEqual(sut.title, "Details")
    }
}

@MainActor
final class DetailVCHeaderTests: XCTestCase{ //Test: Verify detail view controller section headers display "Information" and "Stats"
    func test_detailVC_sectionHeaders_areInformationAndStats(){
        //ARRANGE
        let sut = PokeymonDetailViewController(pokeymon: .makeTest())
        
        //ACT??
        sut.loadViewIfNeeded()
        
        //ASSERT
        XCTAssertEqual(sut.tableView(sut.tableView, titleForHeaderInSection: 0), "Information")
        XCTAssertEqual(sut.tableView(sut.tableView, titleForHeaderInSection: 1), "Stats")
        
    }

}

@MainActor
final class DetailVCStatsTests: XCTestCase{//Test: Stats cells display correct emoji labels, numerical values, and color-coded text (red for attack, blue for defense)
    func test_detailVC_statsCells_showEmojiValuesAndColours(){
        //ARRANGE
        let p = Pokeymon.makeTest(attack: 77, defense: 55)
        let sut = PokeymonDetailViewController(pokeymon: p)
        
        //ACT get the attack row and the defense row
        sut.loadViewIfNeeded()
        let attackCell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 1))
        let defenseCell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 1))

        //ASSERT attack = emoji label, number, red
        XCTAssertEqual(attackCell.textLabel?.text, "⚔️ Attack")
        XCTAssertEqual(attackCell.detailTextLabel?.text, "77")
        XCTAssertEqual(attackCell.detailTextLabel?.textColor, .systemRed)

        //ASSERT defense =. emoji label, number, blue
        XCTAssertEqual(defenseCell.textLabel?.text, "🛡️ Defence")
        XCTAssertEqual(defenseCell.detailTextLabel?.text, "55")
        XCTAssertEqual(defenseCell.detailTextLabel?.textColor, .systemBlue)
    }
}

//Test: Verify edit button presents form with the same model and cancel dismisses without triggering delegates.
@MainActor
final class DetailVCEditTests: XCTestCase{
    func test_detailVC_editPresentsFormWithSameModel_CancelDoesNotCallDelegate(){
        //ARRANGE
        let p = Pokeymon.makeTest(name: "Edity")
        let sut = PokeymonDetailViewController(pokeymon: p)
        let nav = UINavigationController(rootViewController: sut)
        let window = makeKeyTestWindow()
        window.rootViewController = nav
        sut.loadViewIfNeeded()
        
        //ACT
        let edit = sut.navigationItem.rightBarButtonItem
        XCTAssertNotNil(edit) //fail if button is missing
        _ = edit?.target?.perform(edit!.action!, with: edit) //tap the button with code
        
        //ASSERT
        XCTAssertTrue(sut.presentedViewController is UINavigationController) //check that smth popped up
        let presentedNav = sut.presentedViewController as? UINavigationController
        XCTAssertTrue(presentedNav?.viewControllers.first is PokeymonFormViewController) //check that first screen inside is the form
        let form = presentedNav?.viewControllers.first as? PokeymonFormViewController
        XCTAssertTrue(form?.pokeymon === p) //same object, not a copy
        
        //ACT 2: attach the spy to the form, then tap Cancel
        let spy = FormDelegateSpy()
        form?.delegate = spy
        form?.loadViewIfNeeded() // viewDidLoad creates the Cancel button
        let cancel = form?.navigationItem.leftBarButtonItem
        XCTAssertNotNil(cancel)
        _ = cancel?.target?.perform(cancel!.action!, with: cancel)
        
        //ASSERT 2: cancel must not call the delegate
        XCTAssertNil(spy.added)
        XCTAssertNil(spy.updated)
        
        sut.dismiss(animated: false)
        window.isHidden = true

    }
}




// MARK: - Test-only helpers
import UIKit

extension Pokeymon {
    static func makeTest(
        name: String = "TestMon",
        type: PokeymonType = .fire,
        attack: Int = 100,
        defense: Int = 100,
        dateCaptured: Date = Date()
    ) -> Pokeymon {
        .init(name: name, type: type, attack: attack, defense: defense, dateCaptured: dateCaptured)
    }
}

extension UIView {
    /// Depth-first search for first subview of type
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        if let v = self as? T { return v }
        for s in subviews {
            if let v: T = s.firstSubview(of: type) { return v }
        }
        return nil
    }

    /// Collect all labels under this view
    func allLabels() -> [UILabel] {
        var out: [UILabel] = []
        if let l = self as? UILabel { out.append(l) }
        for s in subviews { out.append(contentsOf: s.allLabels()) }
        return out
    }
}


@MainActor
@discardableResult
private func makeKeyTestWindow() -> UIWindow {
    let scene = UIApplication.shared.connectedScenes.first as! UIWindowScene
    let w = UIWindow(windowScene: scene)
    w.frame = scene.screen.bounds
    w.makeKeyAndVisible()
    return w
}

@MainActor
private final class FormDelegateSpy: PokeymonFormViewControllerDelegate {
    private(set) var added: Pokeymon?
    private(set) var updated: Pokeymon?

    func didAddPokeymon(_ pokeymon: Pokeymon) {
        added = pokeymon
    }

    func didUpdatePokeymon(_ pokeymon: Pokeymon) {
        updated = pokeymon
    }
}





