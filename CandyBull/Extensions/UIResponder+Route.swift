//
//  UIResponder+Route.swift
//  CandyBull
//
//  Created by koofrank on 2018/3/25.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation

extension UIResponder {
    func sendEventWith(_ name: String, userinfo: [String: Any]) {
        let sel = Selector("\(name):")
        guard responds(to: sel) else {
            self.next?.sendEventWith(name, userinfo: userinfo)
            return
        }
        
        let setEvent = unsafeBitCast(method(for: sel), to: SetEventIMP.self)
        setEvent(self, sel, userinfo)
    }
    
    fileprivate typealias SetEventIMP        = @convention(c) (NSObject, Selector, [String: Any]) -> Void
}
