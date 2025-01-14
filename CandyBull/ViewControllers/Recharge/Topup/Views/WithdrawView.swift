//
//  WithdrawView.swift
//  CandyBull
//
//  Created by DKM on 2018/7/9.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import UIKit
import EFQRCode

class WithdrawView: UIView {

    enum EventName: String {
        case saveCode
        case copyAddress
        case copyTag
    }
    @IBOutlet weak var projectInfoView: DespositNameView!
    @IBOutlet weak var codeImg: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var introduce: UILabel!
    @IBOutlet weak var copyAddress: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagView: UIView!

    var needTag: Bool = false
    
    @IBAction func saveTag(_ sender: Any) {
        self.next?.sendEventWith(EventName.copyTag.rawValue, userinfo: ["tag": tagLabel.text ?? ""])
    }
    
    @IBAction func saveCode(_ sender: Any) {
        self.next?.sendEventWith(EventName.saveCode.rawValue, userinfo: [:])
    }

    @IBAction func copyAddress(_ sender: Any) {
        self.next?.sendEventWith(EventName.copyAddress.rawValue, userinfo: [:])
    }

    var data: Any? {
        didSet {
            if let data = data as? AccountAddressRecord {
                self.projectInfoView.isHidden = false
                if needTag {
                    self.tagLabel.text = data.address.components(separatedBy: "[").last?.replacingOccurrences(of: "]", with: "")
                    self.address.text = data.address.components(separatedBy: "[").first
                }
                else {
                    self.address.text = data.address
                }
                let generator = EFQRCodeGenerator(content: data.address, size: EFIntSize(width: 155, height: 155))
                generator.setIcon(icon: UIImage(named: R.image.artboard.name)?.toCGImage(), size: EFIntSize(width: 42, height: 42))
                if let image = generator.generate() {
                    self.codeImg.image = UIImage(cgImage: image)
                }
            }
        }
    }
    
    var projectData: Any? {
        didSet{
            guard let projectInfo = projectData as? RechageWordVMData  else {
                self.projectInfoView.isHidden = true
                return
            }
            if projectInfo.projectName != "" {
                self.projectInfoView.isHidden = false
                projectInfoView.projectName = projectInfo.projectName
            }
            if projectInfo.projectAddress != "" {
                self.projectInfoView.isHidden = false
                projectInfoView.url = projectInfo.projectAddress
            }
            if projectInfo.projectLink != "" {
                projectInfoView.addressURL = projectInfo.projectLink
            }
            self.introduce.attributedText = projectInfo.messageInfo.set(style: StyleNames.withdrawIntroduce.rawValue)
            self.updateHeight()
        }
    }

    func setup() {
        if UIScreen.main.bounds.width == 320 {
            copyAddress.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
        }
    }

    fileprivate func updateHeight() {
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: dynamicHeight())
    }

    fileprivate func dynamicHeight() -> CGFloat {
        let view = self.subviews.last?.subviews.last
        return (view?.frame.origin.y)! + (view?.frame.size.height)!
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXIB()
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXIB()
        setup()
    }

    func loadFromXIB() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)

        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
