//
//  FirstViewController.swift
//  CustomNav
//
//  Created by Loki on 20/7/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import NSObject_Rx

class FirstViewController: CustomViewCtr {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "First"
        setupNavItem()
    }

    func setupNavItem() {
        let rightItem = UIBarButtonItem(title: "nav", style: .done, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = rightItem
        
        rightItem.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.openTranparentView()
            }).disposed(by: rx.disposeBag)
    }
    
    func openTranparentView() {
        let vc = TransparentViewCtr()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

protocol StandaloneNavBar {
    var navigationBar: UINavigationBar { get }
    var statusBarStyle: BehaviorRelay<UIStatusBarStyle> { get }
    var statusBarView: UIView { get }
}

class CustomViewCtr: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard self is StandaloneNavBar else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            return
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let standaloneNavBar = self as? StandaloneNavBar else {
            return .default
        }
        return standaloneNavBar.statusBarStyle.value
    }
}


