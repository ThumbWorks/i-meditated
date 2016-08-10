//
//  MinutesListViewController.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/16/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


protocol MinutesListViewModelType {
    var minutesSamplesGroups: Driver<([String], [String: [MinutesEntryViewModel]])> { get }
}

enum MinutesListError : Error {
    case badIndexPath
}

class MinutesListViewController: UITableViewController {
    let viewModel:MinutesListViewModelType
    let actionModel:MainContextActionsType
    lazy var editTap: Driver<MeditationSample> = {
        let indexPath: Observable<IndexPath> = self.rx.sentMessage(#selector(tableView(_:didSelectRowAt:)))
            .map { arguments in
                guard let indexPath = arguments[1] as? IndexPath else {
                    throw MinutesListError.badIndexPath
                }
                return indexPath
        }
        
        return self.minutesSamplesGroups
            .asObservable()
            .flatMapLatest { samples -> Observable<MeditationSample> in
                return indexPath.map { indexPath -> MeditationSample in
                    let (keys, dicts) = samples
                    if let sample = dicts[keys[indexPath.section]]?[indexPath.row] {
                        return sample.meditationSample
                    }
                    throw MinutesListError.badIndexPath
                }
            }.asDriver(onErrorRecover: { (error) -> Driver<MeditationSample> in
                return Driver.never()
            })
    }()
    
    // TODO: Ditch this once we move to rx data source
    var minutesSamplesGroups: Variable<([String], [String: [MinutesEntryViewModel]])> = Variable((Array<String>(), Dictionary<String, [MinutesEntryViewModel]>()))

    required init(viewModel: MinutesListViewModelType, actionModel: MainContextActionsType) {
        self.viewModel = viewModel
        self.actionModel = actionModel
        super.init(style: .grouped)
        self.title = tr(.allMeditations)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// lifecycle
extension MinutesListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(named: .dutchWhite)
        self.tableView.separatorColor = UIColor(named: .spicyMix)
        
        // Drive the Variable property, which basically wraps a normal property with an observable,
        // so it can be observed and it's value accessed imperatively
        let _ = self.viewModel.minutesSamplesGroups
            .drive(self.minutesSamplesGroups)
        
        // TODO: Switch to rx data sources instead of reloading the table view
        let _ = self.minutesSamplesGroups
            .asDriver()
            .drive(onNext: { [unowned self] samples in
                // right now we just reload the data, which isn't exactly desirable
                self.tableView.reloadData()
            })
        
        // TODO: Use custom cell to accept a struct for rendering
        self.tableView.register(UINib.init(nibName: String(describing:MinutesEntryCell.self), bundle: nil), forCellReuseIdentifier: String(describing:MinutesEntryCell.self))
        
        // kick off the first one. All others will be propogated from delete/saves
        self.actionModel.fetchMeditations()
    }
    
}


// Table methods
extension MinutesListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (keys, dicts) = self.minutesSamplesGroups.value
        let sampleGroup = dicts[keys[section]]
        return sampleGroup?.count ?? 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let (keys, _) = self.minutesSamplesGroups.value
        return keys.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (keys, _) = self.minutesSamplesGroups.value
        return keys[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerview = view as! UITableViewHeaderFooterView
        headerview.textLabel?.textColor = UIColor(named: .richBlack)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MinutesEntryCell = tableView.dequeueReusableCell(withIdentifier: String(describing:MinutesEntryCell.self), for: indexPath) as! MinutesEntryCell
        let (keys, dicts) = self.minutesSamplesGroups.value
        if let sample = dicts[keys[indexPath.section]]?[indexPath.row] {
            cell.renderWithViewModel(viewModel: sample)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete) {
            let (keys, dicts) = self.minutesSamplesGroups.value
            if let sample = dicts[keys[indexPath.section]]?[indexPath.row] {
                self.actionModel.delete(meditation: sample.meditationSample)
            }
        }
    }
    
    // empty function used for editTap rx sentMessage bit
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let selectionColor = UIView() as UIView
        selectionColor.layer.borderWidth = 1
        selectionColor.layer.borderColor = UIColor.white.cgColor
        selectionColor.backgroundColor = UIColor.white
        cell.selectedBackgroundView = selectionColor
    }
}

