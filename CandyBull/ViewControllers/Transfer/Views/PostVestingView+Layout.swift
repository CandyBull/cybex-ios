//
//  PostVestingView+Layout.swift
//  CandyBull
//
//  Created by koofrank on 2019/1/25.
//  Copyright © 2019 CandyBull. All rights reserved.
//

import Foundation
import GrowingTextView

extension PostVestingView {
    func setupUI() {
        let views = (0..<5).map({ _ in UIView() })
        let stackview = UIStackView(arrangedSubviews: views, axis: .vertical)
        addSubview(stackview)
        stackview.edgesToSuperview()
        self.stackviews = stackview

        let button = UIButton()
        button.setImage(R.image.off(), for: .normal)
        button.setImage(R.image.on(), for: .selected)
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(switchVestingDidClicked), for: .touchUpInside)
        stackview.arrangedSubviews[0].addSubview(button)
        button.edges(to: button.superview!, excluding: .right, insets: UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 0))
        switchButton = button

        let label = UILabel()
        label.textColor = .steel
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.locali = R.string.localizable.vesting_lock_time.key
        stackview.arrangedSubviews[0].addSubview(label)
        label.leftToRight(of:button, offset: 8)
        label.centerY(to: button)

        helpButton = UIButton()
        helpButton.setImage(R.image.cloud_explain(), for: .normal)
        helpButton.setImage(R.image.cloud_explain(), for: .selected)
        helpButton.setTitle("", for: .normal)
        helpButton.addTarget(self, action: #selector(showHintContent), for: .touchUpInside)
        stackview.arrangedSubviews[0].addSubview(helpButton)
        helpButton.centerY(to: label)
        helpButton.leftToRight(of: label, offset: 2)
        helpButton.width(helpButton.imageView?.image?.size.width ?? 0)

        let textfield = UITextField()
        textfield.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textfield.theme_textColor = [UIColor.white.hexString(true), UIColor.darkTwo.hexString(true)]
        textfield.attributedPlaceholder = NSMutableAttributedString.init(string: R.string.localizable.vesting_time_hint.key.localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.steel50, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])

        stackview.arrangedSubviews[1].addSubview(textfield)
        textfield.edges(to: textfield.superview!, excluding: .right, insets: UIEdgeInsets(top: 10, left: 12, bottom: 10, right: -10))
        textfield.keyboardType = .decimalPad
        textfield.delegate = self
        timeTextFiled = textfield

        let dropMenu = DropDownBoxView()
        dropMenu.normalIcon = R.image.ic2()
        dropMenu.selectedIcon = R.image.ic3()
        dropMenu.normalTextColor = .steel
        dropMenu.selectedTextColor = .primary
        dropMenu.nameLabel.locali = R.string.localizable.vesting_time_unit_second.key
        dropMenu.xibView?.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.paleGreyFour.hexString(true)]
        stackview.arrangedSubviews[1].addSubview(dropMenu)
        dropMenu.size(CGSize(width: 90, height: 30))
        dropMenu.top(to: dropMenu.superview!, offset: 4)
        dropMenu.right(to: dropMenu.superview!, offset: -12)
        dropMenu.leftToRight(of: textfield, offset: 10)
        dropButton = dropMenu

        let textview = GrowingTextView()
        textview.backgroundColor = .clear
        textview.theme_textColor = [UIColor.white.hexString(true), UIColor.darkTwo.hexString(true)]
        textview.font = UIFont.systemFont(ofSize: 16)
        textview.attributedPlaceholder = NSMutableAttributedString.init(string: R.string.localizable.vesting_pubkey_hint.key.localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.steel50, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        stackview.arrangedSubviews[2].addSubview(textview)
        textview.delegate = self
        textview.contentInset = .zero
        textview.textContainerInset = .zero
        textview.edges(to: textview.superview!, excluding: .right, insets: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 0))
        pubkeyTextview = textview

        let button2 = UIButton()
        button2.setImage(R.image.icDown24Px(), for: .normal)
        button2.setTitle("", for: .normal)
        button2.addTarget(self, action: #selector(choosePubKey), for: .touchUpInside)
        stackview.arrangedSubviews[2].addSubview(button2)
        button2.centerY(to: textview)
        button2.right(to: button2.superview!, offset: -12)
        button2.width(button2.imageView?.image?.size.width ?? 0)
        textview.rightToLeft(of: button2, offset: -10)

        let line = UIView()
        line.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.paleGrey.hexString(true)]
        stackview.arrangedSubviews[2].addSubview(line)
        line.height(1)
        line.edges(to: line.superview!, excluding: .bottom, insets: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: -12))

        let line2 = UIView()
        line2.theme_backgroundColor = [UIColor.dark.hexString(true), UIColor.paleGrey.hexString(true)]
        stackview.arrangedSubviews[3].addSubview(line2)
        line2.height(1)
        line2.edges(to: line2.superview!, insets: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: -12))

        hiddenPubkey()
        switchVestingstatus(true)
    }
}

extension PostVestingView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == timeTextFiled {
            let countdots = textField.text?.components(separatedBy: ".").count ?? 0

            if countdots > 0 && string == "." {
                return false
            }
        }
        return true
    }

}

extension PostVestingView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == pubkeyTextview {
            choosePubKey()
            return false
        }
        return true
    }
}
