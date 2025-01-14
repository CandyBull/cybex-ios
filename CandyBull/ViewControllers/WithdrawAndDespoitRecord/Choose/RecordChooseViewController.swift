//
//  RecordChooseViewController.swift
//  CandyBull
//
//  Created DKM on 2018/9/25.
//  Copyright © 2018 CandyBull. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift

protocol RecordChooseViewControllerDelegate {
    func returnSelectedRow(_ sender: RecordChooseViewController, info: String, index: Int)
}

enum RecordChooseType: Int {
    case asset = 0
    case foudType
    case time
    case kind
    case orderbook
    case tradeShowType
    case vesting
}

class RecordChooseViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var delegate: RecordChooseViewControllerDelegate?
    var coordinator: (RecordChooseCoordinatorProtocol & RecordChooseStateManagerProtocol)?
    private(set) var context: RecordChooseContext?
    var typeIndex: RecordChooseType = .asset
    var selectedIndex: Int = 0 {
        didSet {
            
        }
    }
    var count: Int = 0
    var maxCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupUI()
        setupEvent()

    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        self.coordinator?.fetchData(typeIndex.rawValue, maxCount: maxCount, count: count)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if updatePopOverViewCornerIfNeeded() {
            removeDimmingViewMask()
            updateDimmingViewAlpha(0)
        }
    }

    override func refreshViewController() {
    }

    func setupUI() {
        self.view.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.white.hexString(true)]
        let name = String(describing: RecordChooseCell.self)
        self.tableView.register(UINib.init(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }

    func setupData() {
    }

    func setupEvent() {

    }

    override func configureObserveState() {
        self.coordinator?.state.context.asObservable().subscribe(onNext: { [weak self] (context) in
            guard let self = self else { return }

            if let context = context as? RecordChooseContext {
                self.context = context
            }

        }).disposed(by: disposeBag)

        self.coordinator?.state.pageState.asObservable().distinctUntilChanged().subscribe(onNext: {[weak self] (state) in
            guard let self = self else { return }

            self.endLoading()

            switch state {
            case .initial:
                self.coordinator?.switchPageState(PageState.refresh(type: PageRefreshType.initial))

            case .loading(let reason):
                if reason == .initialRefresh {
//                    self.startLoading()
                }

            case .refresh(let type):
                self.coordinator?.switchPageState(.loading(reason: type.mapReason()))

            case .loadMore:
                self.coordinator?.switchPageState(.loading(reason: PageLoadReason.manualLoadMore))

            case .noMore:
                //                self.stopInfiniteScrolling(self.tableView, haveNoMore: true)
                break

            case .noData:
                //                self.view.showNoData(<#title#>, icon: <#imageName#>)
                break

            case .normal:
                //                self.view.hiddenNoData()
                //
                //                if reason == PageLoadReason.manualLoadMore {
                //                    self.stopInfiniteScrolling(self.tableView, haveNoMore: false)
                //                }
                //                else if reason == PageLoadReason.manualRefresh {
                //                    self.stopPullRefresh(self.tableView)
                //                }
                break

            case .error:
                //                self.showToastBox(false, message: error.localizedDescription)

                //                if reason == PageLoadReason.manualLoadMore {
                //                    self.stopInfiniteScrolling(self.tableView, haveNoMore: false)
                //                }
                //                else if reason == PageLoadReason.manualRefresh {
                //                    self.stopPullRefresh(self.tableView)
                //                }
                break
            }
        }).disposed(by: disposeBag)

        self.coordinator?.state.data.asObservable().distinctUntilChanged().subscribe(onNext: {[weak self] (data) in
            guard let self = self, let _ = data else { return }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
}

// MARK: - TableViewDelegate
extension RecordChooseViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.coordinator?.state.data.value {
            return data.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.recordChooseCell.name, for: indexPath) as? RecordChooseCell {
            if let data = self.coordinator?.state.data.value {
                cell.setup(data[indexPath.row])
                if indexPath.row == selectedIndex {
                    cell.cellView.nameLabel.textColor = UIColor.primary
                }
            }
            return cell
        }
        return RecordChooseCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
}

extension RecordChooseViewController {
    @objc func recordChooseCellViewDidClicked(_ data: [String: Any]) {
        if let result = data["data"] as? String,
            let data = self.coordinator?.state.data.value {
            
            for(index, info) in data.enumerated() {
                if info.filterSystemPrefix == result {
                    self.selectedIndex = index
                    break
                }
            }
            self.delegate?.returnSelectedRow(self, info: result, index: self.selectedIndex)
        }
    }
}
