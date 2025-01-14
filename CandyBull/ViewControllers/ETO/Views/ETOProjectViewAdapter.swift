//
//  ETOProjectViewAdapter.swift
//  CandyBull
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import Localize_Swift
import RxSwift
import RxCocoa

extension ETOProjectView {
    func adapterModelToETOProjectView(_ model: ETOProjectViewModel) {
        
        model.status.asObservable().subscribe(onNext: { [weak self](status) in
            guard let self = self else { return }
            self.stateLabel.text = status
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        model.currentPercent.asObservable().subscribe(onNext: { [weak self](currentProgress) in
            guard let self = self else { return }
            self.progressLabel.text = currentProgress
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        model.progress.asObservable().subscribe(onNext: { [weak self](progress) in
            guard let self = self else { return }
            self.progressView.progress = progress
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        model.projectState.asObservable().subscribe(onNext: { [weak self](projectState) in
            guard let self = self, let state = projectState  else { return }
            self.timeState.text = model.timeState
            switch state {
            case .finish:
                self.progressView.beginColor = .slate
                self.progressView.endColor = .cloudyBlue
                self.progressView.progress = model.progress.value
                self.stateLabel.textColor = self.nameLabel.textColor
                self.progressLabel.textColor = self.nameLabel.textColor
            case .ok:
                self.progressView.beginColor = UIColor.apricot
                self.progressView.endColor = UIColor.orangeish
                self.stateLabel.textColor = UIColor.primary
                self.progressLabel.textColor = UIColor.primary
            case .pre:
                self.stateLabel.textColor = UIColor.primary
                self.progressLabel.textColor = UIColor.primary
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        model.time.asObservable().subscribe(onNext: { [weak self]time in
            guard let self = self else {return}
            if time == "" {
                self.timeLabel.isHidden = true
                self.timeState.isHidden = true
                self.timeImgView.isHidden = true
            }
            else {
                self.timeLabel.isHidden = false
                self.timeState.isHidden = false
                self.timeImgView.isHidden = false
                self.timeLabel.text = time
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        self.nameLabel.text = model.name
        if Localize.currentLanguage() == "en" {
            self.icon.kf.setImage(with: URL(string: model.iconEn))
            self.markLabel.text = model.keyWordsEn
        } else {
            self.icon.kf.setImage(with: URL(string: model.icon))
            self.markLabel.text = model.keyWords
        }
        self.updateHeight()
    }
}
