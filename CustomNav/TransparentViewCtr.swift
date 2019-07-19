//
//  TransparentViewCtr.swift
//  CustomNav
//
//  Created by Loki on 20/7/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TransparentViewCtr: CustomViewCtr, UINavigationBarDelegate, UIScrollViewDelegate, TransparentNavBar {

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .green
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.isTranslucent = true
        navigationBar.barTintColor = UIColor.black
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.tintColor = .white
        navigationBar.backgroundColor = .clear
        navigationBar.delegate = self
        return navigationBar
    }()
    
    lazy var statusBarView: UIView = {
        let view = UIView(frame: UIApplication.shared.statusBarFrame)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var titleView: UILabel = {
        let label = UILabel()
        label.text = "Transparent"
        label.textColor = .white
        return label
    }()
    
    lazy var headerView: HeaderView = {
        let view = HeaderView()
        return view
    }()
    
    lazy var statusBarStatus: BehaviorRelay<UIStatusBarStyle> = {
        return BehaviorRelay(value: UIStatusBarStyle.lightContent)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        // Do any additional setup after loading the view.
        
        

        
        setup()
        
        setupCustomNav()
        view.addSubview(statusBarView)
        
        statusBarStatus
            .distinctUntilChanged()
            .skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.setNeedsStatusBarAppearanceUpdate()
            }).disposed(by: rx.disposeBag)
    }
    
    func setupCustomNav() {
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        let navigationItem = UINavigationItem()
        navigationItem.titleView = titleView
        navigationBar.items = [navigationItem]
        
        let backBtn = UIBarButtonItem(title: "Back", style: .done, target: self, action: nil)
        backBtn.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: rx.disposeBag)
        
        let rightBtn = UIBarButtonItem(title: "Next", style: .done, target: self, action: nil)
        rightBtn.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                let vc = ThirdViewCtr()
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: rx.disposeBag)
        
        navigationItem.leftBarButtonItem = backBtn
        navigationItem.rightBarButtonItem = rightBtn
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        scrollView.contentInset = UIEdgeInsets(top: -self.view.safeAreaInsets.top, left: 0, bottom: 0, right: 0)
    }
}

extension TransparentViewCtr {
    func setup() {
        setupScrollView()
        setupContentViews()
    }
    
    func setupScrollView() {
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.top.bottom.width.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setupContentViews() {
        
        let headerViewHeight = self.view.frame.width * (188 / 375)
        
        scrollView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.leading.trailing.width.equalToSuperview()
            make.height.equalTo(headerViewHeight)
        }
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.width.equalToSuperview()
        }
        
        let spaceView = UIView()
        spaceView.backgroundColor = .blue
        spaceView.snp.makeConstraints { (make) in
            make.height.equalTo(2000)
        }
        stackView.addArrangedSubview(spaceView)
    }
}

extension UIApplication {
    class var statusBarBackgroundColor: UIColor? {
        get {
            return (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor
        } set {
            (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = newValue
        }
    }
}

extension UIColor {
    
    static var background200: UIColor {
        return #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
    }
    
}

extension TransparentViewCtr {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            // Cover Image View
            let offSetY = scrollView.contentOffset.y
            
            let height = self.view.frame.width * (188 / 375)
            
            if offSetY < 0 {
                self.headerView.coverImageView.frame.size.height = height - offSetY
                self.headerView.coverImageView.frame.origin.y = offSetY
            }
            
            
            // Nav Bar Style
            let offSet = scrollView.contentOffset.y / (height)
            
            print("offSet: ", offSet)
            
            changeNavBarStyle(offSet: offSet)
        }
    }
    
    func changeNavBarStyle(offSet: CGFloat) {
        if offSet > 1 {
            statusBarStatus.accept(.default)
            statusBarView.backgroundColor = UIColor.background200
            navigationBar.backgroundColor = UIColor.background200
            navigationBar.tintColor = UIColor(hue: 1, saturation: 0, brightness: 0.54, alpha: 1)
        } else {
            let brightness = 1 - (offSet * 0.46)
            statusBarStatus.accept(.lightContent)
            statusBarView.backgroundColor = UIColor.background200.withAlphaComponent(offSet)
            navigationBar.tintColor = UIColor(hue: 1, saturation: 0, brightness: brightness, alpha: 1)
            navigationBar.backgroundColor = UIColor.background200.withAlphaComponent(offSet)
        }
    }
    
}

class HeaderView: UIView {
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .orange
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}
