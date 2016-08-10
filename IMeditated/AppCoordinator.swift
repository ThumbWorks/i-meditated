//
//  AppCoordinator.swift
//  IMeditated
//
//  Created by Bob Spryn on 8/15/16.
//  Copyright © 2016 Thumbworks. All rights reserved.
//

import UIKit
import RxSwift

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    let mainContext = MainContext()
    let disposables = DisposeBag()
    
    lazy var navViewController: UINavigationController = {
        let rootNav = UINavigationController.init(rootViewController: self.quickEntryViewController)
        rootNav.view.tintColor = UIColor(named: .lapisLazuli)
        return rootNav
    }()
    
    var mainViewController: UIViewController {
        return self.navViewController
    }
    
    lazy var quickEntryViewModel: QuickEntryViewModel = {
        QuickEntryViewModel(context: self.mainContext)
    }()
    
    lazy var quickEntryViewController: QuickEntryViewController = {
        QuickEntryViewController.init(viewModel: self.quickEntryViewModel, actionModel: self.mainContext)
    }()
    
    // lazy or computed properties for list depending on if you want to clear it from memory
    lazy var minutesListViewModel: MinutesListViewModel = {
        MinutesListViewModel(minutesListContext: self.mainContext)
    }()

    lazy var minutesListViewController: MinutesListViewController = {
        let listVC = MinutesListViewController(viewModel: self.minutesListViewModel, actionModel: self.mainContext)
        
        listVC.editTap
            .drive(onNext: { [unowned self] sample in
                let rootNav = UINavigationController.init(rootViewController: self.customEntryViewController(withSample: sample, config: .edit))
                rootNav.view.tintColor = UIColor(named: .lapisLazuli)
                listVC.present(rootNav, animated: true)
            })
            .addDisposableTo(self.disposables)
        return listVC
    }()
    
    var infoViewController: InfoViewController {
        let infoVC = StoryboardScene.Info.instantiateInfoViewController()
        infoVC.doneButtonTap
            .subscribe(onNext: { [unowned self] _ in
                self.navViewController.dismiss(animated: true, completion: nil)
            }).addDisposableTo(self.disposables)
        return infoVC
    }
    
    init() {
        // TODO: ideally this navigation is moved into a context itself, per redux style
        self.quickEntryViewController.listTap
            .subscribe(onNext: { [unowned self] _ in
                self.navViewController.pushViewController(self.minutesListViewController, animated: true)
            }).addDisposableTo(self.disposables)
        
        self.quickEntryViewController.infotap
            .subscribe(onNext: { [unowned self] _ in
                let rootNav = UINavigationController.init(rootViewController: self.infoViewController)
                rootNav.view.tintColor = UIColor(named: .lapisLazuli)
                self.navViewController.present(rootNav, animated: true, completion: nil)
            }).addDisposableTo(self.disposables)

        self.quickEntryViewController.customTap
            .subscribe(onNext: { [unowned self] _ in
                let rootNav = UINavigationController.init(rootViewController: self.customEntryViewController())
                rootNav.view.tintColor = UIColor(named: .lapisLazuli)
                self.mainViewController.present(rootNav, animated: true)
            }).addDisposableTo(self.disposables)
    }
    
    func customEntryViewController(withSample sample: MeditationSample? = nil, config: EntryEditConfiguration = .create) -> EntryEditViewController {
        let edit = EntryEditViewController(viewModel: EntryEditViewModel(start: sample?.start, end: sample?.end, configuration: config),
                                           actionModel: self.mainContext)
        edit.view.tintColor = UIColor(named: .lapisLazuli)
        // the reason we don't have to do the subject dance here in `EntryEditViewController` is that we've
        // caused the view to load and connect the outlets. Not sure the best approach here
        edit.cancelTap.subscribe(onNext: { _ in
            edit.dismiss(animated: true, completion: nil)
        }).addDisposableTo(self.disposables)
        
        // on successful save, dismiss the VC
        // we are making an assumption that this indicates the custom screen initiated the save
        self.mainContext.saveActions
            .take(1)
            .takeUntil(edit.rx.deallocated)
            .switchLatest()
            .subscribe(onNext: { _ in
                edit.dismiss(animated: true, completion: nil)
            }).addDisposableTo(self.disposables)
        
        return edit
    }
}
