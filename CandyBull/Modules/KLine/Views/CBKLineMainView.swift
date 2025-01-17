//
//  CBKLineMainView.swift
//  CandyBull
//
//  Created by koofrank on 2018/3/16.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation
import SwiftTheme

class CBKLineMainView: UIView {
    
    // MARK: - Property
    
    public var limitValueChanged: ((_ limitValue: (minValue: Double, maxValue: Double)?) -> Void)?
    
    fileprivate let configuration = CBConfiguration.sharedConfiguration
    
    fileprivate var lastDrawDatePoint: CGPoint = CGPoint.zero
    // 辅助视图的显示内容
    fileprivate var drawAssistString: NSAttributedString?
    // 主图绘制K线模型数组
    fileprivate var mainDrawKLineModels: [CBKLineModel]?
    // focus line
    
    var focusModel: CBKLineModel?
    
    // 绘制区域的最大Y值
    fileprivate let padding: UIEdgeInsets = UIEdgeInsets(
        top: CBConfiguration.sharedConfiguration.main.valueAssistViewHeight,
        left: 0,
        bottom: CBConfiguration.sharedConfiguration.main.valueAssistViewHeight,
        right: 0)
    
    var drawMaxY: CGFloat {
        return height - padding.bottom
    }
    
    // 绘制区域的高度
    var drawHeight: CGFloat {
        return height - configuration.main.assistViewHeight - configuration.main.dateAssistViewHeight - padding.bottom - padding.top
    }
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //    convenience init(configuration: OKConfiguration) {
    //        self.init()
    //        self.configuration = configuration
    //    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public func drawMainView() {
        fetchMainDrawKLineModels()
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        // 背景色
        context.clear(rect)
        context.setFillColor(configuration.main.backgroundColor.cgColor)
        context.fill(rect)
        
        // 没有数据 不绘制
        guard let mainDrawKLineModels = mainDrawKLineModels,
            let limitValue = fetchLimitValue() else {
                return
        }
        
        // 设置日期背景色
        
        let assistRect = CGRect(x: 0,
                                y: 0,
                                width: rect.width,
                                height: configuration.main.dateAssistViewHeight)
        context.fill(assistRect)
        
        lastDrawDatePoint = CGPoint.zero
        
        // 绘制提示数据
        //    fetchAssistString(model: nil)
        drawAssistString?.draw(in: CGRect(x: 10, y: 0, width: width - 20, height: configuration.main.assistViewHeight))
        
        let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
        
        var strokeColors: [UIColor] = []
        
        var highPointY: CGFloat?
        var lowPointY: CGFloat?
        var highPointX: CGFloat?
        var lowPointX: CGFloat?
        var minModel: CBKLineModel?
        var maxModel: CBKLineModel?
        
        for (index, klineModel) in mainDrawKLineModels.enumerated() {
            let xPosition = CGFloat(index) * (configuration.theme.klineWidth + configuration.theme.klineSpace)
            
            let openPoint = unitValue != 0 ? CGPoint(x: xPosition, y: abs(drawMaxY - CGFloat((klineModel.open - limitValue.minValue) / unitValue))) : CGPoint(x: xPosition, y: abs(drawMaxY))
            let closePoint = unitValue != 0 ? CGPoint(x: xPosition, y: abs(drawMaxY - CGFloat((klineModel.close - limitValue.minValue) / unitValue))) : CGPoint(x: xPosition, y: abs(drawMaxY))
            let highPoint = unitValue != 0 ? CGPoint(x: xPosition + configuration.theme.klineWidth / 2,
                                                     y: abs(drawMaxY - CGFloat((klineModel.high - limitValue.minValue) / unitValue))) :
                CGPoint(x: xPosition + configuration.theme.klineWidth / 2, y: abs(drawMaxY))
            let lowPoint = unitValue != 0 ? CGPoint(x: xPosition + configuration.theme.klineWidth / 2,
                                                    y: abs(drawMaxY - CGFloat((klineModel.low - limitValue.minValue) / unitValue))) :
                CGPoint(x: xPosition + configuration.theme.klineWidth / 2, y: abs(drawMaxY))
            
            if let highY = highPointY {
                if highPoint.y < highY {
                    highPointY = highPoint.y
                    highPointX = highPoint.x
                    maxModel = klineModel
                }
            } else {
                highPointY = highPoint.y
                highPointX = highPoint.x
                maxModel = klineModel
            }
            
            if let lowY = lowPointY {
                if lowPoint.y > lowY {
                    lowPointY = lowPoint.y
                    lowPointX = lowPoint.x
                    minModel = klineModel
                }
            } else {
                lowPointY = lowPoint.y
                lowPointX = lowPoint.x
                minModel = klineModel
            }
            
            switch configuration.main.klineType {
            case .KLine: // K线模式
                
                // 决定K线颜色
                var strokeColor: UIColor = configuration.theme.increaseColor
                let lastModel: CBKLineModel? = index >= 1 ? mainDrawKLineModels[index - 1] : nil
                
                if klineModel.open > klineModel.close {
                    strokeColor = klineModel.open > klineModel.close ? configuration.theme.decreaseColor : configuration.theme.increaseColor
                }

                if klineModel.volume == 0, let _ = lastModel {
                    strokeColor = strokeColors[index - 1]
                }

                strokeColors.append(strokeColor)
                context.setStrokeColor(strokeColor.cgColor)
                
                // 画开盘-收盘
                if closePoint.y == openPoint.y {
                    context.setLineWidth(configuration.theme.klineShadowLineWidth)
                    context.strokeLineSegments(between: [CGPoint(x: xPosition, y: closePoint.y), CGPoint(x: xPosition + configuration.theme.klineWidth / 2, y: closePoint.y)])
                } else {
                    let path = UIBezierPath(
                        roundedRect: CGRect(x: xPosition,
                                            y: klineModel.open < klineModel.close ? closePoint.y : openPoint.y,
                                            width: configuration.theme.klineWidth,
                                            height: max(abs(closePoint.y - openPoint.y),
                                                        configuration.theme.klineShadowLineWidth)),
                        cornerRadius: configuration.theme.klineRadius).cgPath
                    context.addPath(path)
                    context.setFillColor(strokeColor.cgColor)
                    context.fillPath()
                }
                
                // 画上下影线
                context.setLineWidth(configuration.theme.klineShadowLineWidth)
                context.strokeLineSegments(between: [highPoint, lowPoint])
                
            default: break
            }
            // 画日期
            drawDateLine(context: context, klineModel: mainDrawKLineModels[index],
                         positionX: xPosition)
            
        }
        context.strokePath()
        
        // 绘制指标
        switch configuration.main.indicatorType {
        case .MA:
            drawMA(context: context, limitValue: limitValue, drawModels: mainDrawKLineModels)
        case .EMA:
            drawEMA(context: context, limitValue: limitValue, drawModels: mainDrawKLineModels)
        case .BOLL:
            drawBOLL(context: context, limitValue: limitValue, drawModels: mainDrawKLineModels)
        default:
            break
        }
        
        // max min value
        
        if let highPointY = highPointY, let lowPointY = lowPointY, let highPointX = highPointX, let lowPointX = lowPointX, let minModel = minModel, let maxModel = maxModel {
            drawMaxMin(context: context, lowKlineModel: minModel, highKlineModel: maxModel, lowPosition: CGPoint(x: lowPointX, y: lowPointY), highPosition: CGPoint(x: highPointX, y: highPointY))
        }
    }
}

// MARK: - 辅助视图(时间线,顶部显示)

extension CBKLineMainView {
    /// 画时间线
    ///
    /// - Parameters:
    ///   - klineModel: 数据模型
    ///   - positionModel: 位置模型
    fileprivate func drawDateLine(context: CGContext, klineModel: CBKLineModel, positionX: CGFloat) {
        
        let date = Date(timeIntervalSince1970: klineModel.date)
        let dateString = configuration.dateFormatter.string(from: date)
        //        if configuration.main.timeLineType == .oneDay {
        //
        //        } else {
        //            dateString
        //        }
        
        var dateAttributes: [NSAttributedString.Key: Any]? = [
            NSAttributedString.Key.foregroundColor: configuration.main.dateAssistTextColor,
            NSAttributedString.Key.font: configuration.main.dateAssistTextFont
        ]
        
        if let model = focusModel {
            if model.propertyDescription() != klineModel.propertyDescription() {
                return
            } else {
                let bgColor = ThemeManager.currentThemeIndex == 0 ? #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 0.1058823529, green: 0.1333333333, blue: 0.1882352941, alpha: 1)
                let textColor = ThemeManager.currentThemeIndex == 0 ? UIColor.dark : UIColor.white
                dateAttributes![NSAttributedString.Key.backgroundColor] = bgColor
                dateAttributes![NSAttributedString.Key.foregroundColor] = textColor
            }
        }
        
        let dateAttrString = NSAttributedString(string: dateString, attributes: dateAttributes)
        
        var drawDatePoint = CGPoint(x: positionX - dateAttrString.size().width * 0.5,
                                    y: configuration.main.assistViewHeight)
        
        if drawDatePoint.x < 0 {
            drawDatePoint.x = 0
        }
        
        if (drawDatePoint.x + dateAttrString.size().width) > bounds.width {
            drawDatePoint.x = bounds.width - dateAttrString.size().width
        }
        
        //        if drawDatePoint.x < 0 || (drawDatePoint.x + dateAttrString.size().width) > bounds.width {
        //
        //            return
        //        }

        let lx = abs(drawDatePoint.x - lastDrawDatePoint.x)
        if lastDrawDatePoint.equalTo(CGPoint.zero) ||
            lx > (dateAttrString.size().width * 2) {
            let rect = CGRect(x: drawDatePoint.x,
                              y: drawDatePoint.y,
                              width: dateAttrString.size().width,
                              height: configuration.main.dateAssistViewHeight)
            
            dateAttrString.draw(in: rect)
            
            if focusModel == nil {
                context.setStrokeColor(configuration.theme.tickColor.cgColor)
                context.setLineWidth(configuration.theme.tickWidth)
                context.strokeLineSegments(
                    between: [CGPoint(x: drawDatePoint.x + dateAttrString.size().width / 2,
                                      y: configuration.main.assistViewHeight + configuration.main.dateAssistViewHeight),
                              CGPoint(x: drawDatePoint.x + dateAttrString.size().width / 2,
                                      y: height)])
                
                lastDrawDatePoint = drawDatePoint
            }
            
        }
    }
    
    /// 获取辅助视图显示文本
    ///
    /// - Parameter model: 当前要显示的model
    func fetchAssistString(model: CBKLineModel?) {
        guard let mainDrawKLineModels = mainDrawKLineModels else { return }
        
        var drawModel = mainDrawKLineModels.last!
        
        if let model = model {
            for mainModel in mainDrawKLineModels {
                if model.date == mainModel.date {
                    drawModel = mainModel
                    break
                }
            }
        } else {
            drawAssistString = nil
            return
        }
        
        let drawAttrsString = NSMutableAttributedString()
        
        //    let date = Date(timeIntervalSince1970: drawModel.date)
        //    let formatter = DateFormatter()
        //    formatter.dateFormat = "yyyy-MM-dd HH:mm"
        //    let dateStr = formatter.string(from: date) + " "
        //
        //    let dateAttrs: [NSAttributedStringKey : Any]? = [
        //      NSAttributedStringKey.foregroundColor : configuration.main.dateAssistTextColor,
        //      NSAttributedStringKey.font : configuration.main.dateAssistTextFont
        //    ]
        //    drawAttrsString.append(NSAttributedString(string: dateStr, attributes: dateAttrs))
        
        //    let openStr = String(format: "开: %.2f ", drawModel.open)
        //    let highStr = String(format: "高: %.2f ", drawModel.high)
        //    let lowStr = String(format: "低: %.2f ", drawModel.low)
        //    let closeStr = String(format: "收: %.2f ", drawModel.close)
        
        //    let string = openStr + highStr + lowStr + closeStr
        //    let attrs: [NSAttributedStringKey : Any]? = [
        //      NSAttributedStringKey.foregroundColor : configuration.main.dateAssistTextColor,
        //      NSAttributedStringKey.font : configuration.main.dateAssistTextFont
        //    ]
        
        //    drawAttrsString.append(NSAttributedString(string: string, attributes: attrs))
        
        switch configuration.main.indicatorType {
        case let .MA(days):
            let maStr = "MA(" + days.map({"\($0)"}).joined(separator: ", ") + "): "
            let maAttrs: [NSAttributedString.Key: Any]? = [
                NSAttributedString.Key.foregroundColor: configuration.theme.markColor,
                NSAttributedString.Key.font: configuration.main.dateAssistTextFont,
                NSAttributedString.Key.backgroundColor: configuration.theme.markbgColor                    ]

            drawAttrsString.append(NSAttributedString(string: maStr, attributes: maAttrs))


            let colors = [configuration.theme.MA1, configuration.theme.MA2, configuration.theme.MA3]
            for (idx, _) in days.enumerated() {

                let color = colors[idx]
                
                let attrs: [NSAttributedString.Key: Any]? = [
                    NSAttributedString.Key.foregroundColor: color,
                    NSAttributedString.Key.font: configuration.main.dateAssistTextFont,
                    
                    ]
                
                
                
                if let value = drawModel.MAs![idx] {
//                    if idx != 0 {
//                        drawAttrsString.append(NSAttributedString(string: "\n"))
//                    }

                    
                    let mavalueStr = String(format: "  %.\(drawModel.precision)f   ", value)
                    drawAttrsString.append(NSAttributedString(string: mavalueStr, attributes: attrs))
                }
            }
            
        case let .EMA(days):
            let maAttrs: [NSAttributedString.Key: Any]? = [
                NSAttributedString.Key.foregroundColor: configuration.theme.markColor,
                NSAttributedString.Key.font: configuration.main.dateAssistTextFont,
                NSAttributedString.Key.backgroundColor: configuration.theme.markbgColor
            ]
            let maStr = "EMA(" + days.map({"\($0)"}).joined(separator: ", ") + "): "
            drawAttrsString.append(NSAttributedString(string: maStr, attributes: maAttrs))
            let colors = [configuration.theme.EMA1, configuration.theme.EMA2, configuration.theme.EMA3]

            for (idx, _) in days.enumerated() {
                let color = colors[idx]

                
                let attrs: [NSAttributedString.Key: Any]? = [
                    NSAttributedString.Key.foregroundColor: color,
                    NSAttributedString.Key.font: configuration.main.dateAssistTextFont
                ]
                
                if let value = drawModel.EMAs![idx] {
//                    if idx != 0 {
//                        drawAttrsString.append(NSAttributedString(string: "\n"))
//                    }

                    let emavalueStr = String(format: "  %.\(drawModel.precision)f   ", value)
                    drawAttrsString.append(NSAttributedString(string: emavalueStr, attributes: attrs))
                }
            }
        case .BOLL:
            let maAttrs: [NSAttributedString.Key: Any]? = [
                NSAttributedString.Key.foregroundColor: configuration.theme.markColor,
                NSAttributedString.Key.font: configuration.main.dateAssistTextFont,
                NSAttributedString.Key.backgroundColor: configuration.theme.markbgColor
            ]
            let maStr = String(format: "BOLL: ")
            drawAttrsString.append(NSAttributedString(string: maStr, attributes: maAttrs))
            
            if let value = drawModel.bollMB {
                let mbAttrs: [NSAttributedString.Key: Any]? = [
                    NSAttributedString.Key.foregroundColor: configuration.theme.bollMBColor,
                    NSAttributedString.Key.font: configuration.main.dateAssistTextFont
                ]
                let mbAttrsStr = NSAttributedString(string: String(format: "  %.\(drawModel.precision)f  ", value), attributes: mbAttrs)
                drawAttrsString.append(mbAttrsStr)
            }
            
            if let value = drawModel.bollUP {
                let upAttrs: [NSAttributedString.Key: Any]? = [
                    NSAttributedString.Key.foregroundColor: configuration.theme.bollUPColor,
                    NSAttributedString.Key.font: configuration.main.dateAssistTextFont
                ]
                let upAttrsStr = NSAttributedString(string: String(format: " %.\(drawModel.precision)f  ", value), attributes: upAttrs)
                drawAttrsString.append(upAttrsStr)
            }
            
            if let value = drawModel.bollDN {
                let dnAttrs: [NSAttributedString.Key: Any]? = [
                    NSAttributedString.Key.foregroundColor: configuration.theme.bollDNColor,
                    NSAttributedString.Key.font: configuration.main.dateAssistTextFont
                ]
                let dnAttrsStr = NSAttributedString(string: String(format: " %.\(drawModel.precision)f  ", value), attributes: dnAttrs)
                drawAttrsString.append(dnAttrsStr)
            }
            
        default:
            break
        }
        drawAssistString = drawAttrsString
    }
    
    fileprivate func drawMaxMin(context _: CGContext,
                                lowKlineModel: CBKLineModel,
                                highKlineModel: CBKLineModel,
                                lowPosition: CGPoint,
                                highPosition: CGPoint) {
        let attributes: [NSAttributedString.Key: Any]? = [
            NSAttributedString.Key.foregroundColor: configuration.main.valueAssistTextColor,
            NSAttributedString.Key.font: configuration.main.valueAssistTextFont
        ]
        let mindrawAttrsString = NSMutableAttributedString(string: "←" + lowKlineModel.low.formatCurrency(digitNum: lowKlineModel.precision), attributes: attributes)
        var minX = lowPosition.x
        if (lowPosition.x + mindrawAttrsString.size().width) > bounds.width {
            minX -= mindrawAttrsString.size().width
            mindrawAttrsString.setAttributedString(NSAttributedString(string: lowKlineModel.low.formatCurrency(digitNum: lowKlineModel.precision) + "→", attributes: attributes))
        }
        
        let minrect = CGRect(x: minX,
                             y: lowPosition.y,
                             width: mindrawAttrsString.size().width,
                             height: configuration.main.valueAssistViewHeight)
        
        mindrawAttrsString.draw(in: minrect)
        let maxdrawAttrsString = NSMutableAttributedString(string: "←" + highKlineModel.high.formatCurrency(digitNum: highKlineModel.precision), attributes: attributes)
        
        var maxX = highPosition.x
        if (highPosition.x + mindrawAttrsString.size().width) > bounds.width {
            maxX -= maxdrawAttrsString.size().width
            maxdrawAttrsString.setAttributedString(NSAttributedString(string: highKlineModel.high.formatCurrency(digitNum: highKlineModel.precision) + "→", attributes: attributes))
        }
        
        let maxrect = CGRect(x: maxX,
                             y: highPosition.y - configuration.main.valueAssistViewHeight,
                             width: maxdrawAttrsString.size().width,
                             height: configuration.main.valueAssistViewHeight)
        
        maxdrawAttrsString.draw(in: maxrect)
    }
}

// MARK: - 绘制指标

extension CBKLineMainView {
    /// 绘制MA指标
    ///
    /// - Parameters:
    ///   - context: contex
    ///   - limitValue: 极限值
    ///   - drawModels: 绘制的K线模型数据
    fileprivate func drawMA(context: CGContext,
                            limitValue: (minValue: Double, maxValue: Double),
                            drawModels: [CBKLineModel]) {
        let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
        
        switch configuration.main.indicatorType {
        case .MA:
            let brushType = [CBBrushType.MA, CBBrushType.MA2, CBBrushType.MA3]
            guard let MAs = drawModels.first?.MAs else { return }

            for (idx, _) in MAs.enumerated() {
                let maLineBrush = CBMALineBrush(brushType: brushType[idx],
                                                context: context)
                
                maLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in
                    
                    if let value = model.MAs?[idx] {
                        let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace)
                        
                        let yPosition = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
                        
                        return CGPoint(x: xPosition, y: yPosition)
                    }
                    return nil
                }
                maLineBrush.draw(drawModels: drawModels)
            }
            
        default:
            break
        }
    }
    
    /// 绘制EMA指标
    fileprivate func drawEMA(context: CGContext,
                             limitValue: (minValue: Double, maxValue: Double),
                             drawModels: [CBKLineModel]) {
        let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
        
        switch configuration.main.indicatorType {
        case .EMA:
            let brushType = [CBBrushType.EMA, CBBrushType.EMA2, CBBrushType.EMA3]
            guard let EMAs = drawModels.first?.EMAs else { return }

            for (idx, _) in EMAs.enumerated() {
                let emaLineBrush = CBMALineBrush(brushType: brushType[idx],
                                                 context: context)
                
                emaLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in
                    
                    if let value = model.EMAs?[idx] {
                        let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace)
                        
                        let yPosition = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
                        
                        return CGPoint(x: xPosition, y: yPosition)
                    }
                    return nil
                }
                emaLineBrush.draw(drawModels: drawModels)
            }
        default:
            break
        }
    }
    
    /// 绘制BOLL指标
    fileprivate func drawBOLL(context: CGContext,
                              limitValue: (minValue: Double, maxValue: Double),
                              drawModels: [CBKLineModel]) {
        let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
        
        let MBLineBrush = CBLineBrush(indicatorType: .bollMB, context: context)
        MBLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in
            
            if let value = model.bollMB {
                let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace)
                let yPosition: CGFloat = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
                return CGPoint(x: xPosition, y: yPosition)
            }
            return nil
        }
        MBLineBrush.draw(drawModels: drawModels)
        
        let UPLineBrush = CBLineBrush(indicatorType: .bollUp, context: context)
        UPLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in
            
            if let value = model.bollUP {
                let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace)
                let yPosition: CGFloat = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
                return CGPoint(x: xPosition, y: yPosition)
            }
            return nil
        }
        UPLineBrush.draw(drawModels: drawModels)
        
        let DNLineBrush = CBLineBrush(indicatorType: .bollDN, context: context)
        DNLineBrush.calFormula = { (index: Int, model: CBKLineModel) -> CGPoint? in
            
            if let value = model.bollDN {
                let xPosition = CGFloat(index) * (self.configuration.theme.klineWidth + self.configuration.theme.klineSpace)
                
                let yPosition: CGFloat = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
                return CGPoint(x: xPosition, y: yPosition)
            }
            return nil
        }
        DNLineBrush.draw(drawModels: drawModels)
    }
}

// MARK: - 获取相关数据

extension CBKLineMainView {
    /// 获取绘制主图所需的K线模型数据
    fileprivate func fetchMainDrawKLineModels() {
        guard configuration.dataSource.klineModels.count > 0 else {
            mainDrawKLineModels = nil
            return
        }
        
        switch configuration.main.indicatorType {
        case .MA:
            let maModel = CBMAModel(indicatorType: configuration.main.indicatorType,
                                    klineModels: configuration.dataSource.klineModels)
            mainDrawKLineModels = maModel.fetchDrawMAData(drawRange: configuration.dataSource.drawRange)
            
        case .EMA:
            let emaModel = CBEMAModel(indicatorType: configuration.main.indicatorType,
                                      klineModels: configuration.dataSource.klineModels)
            mainDrawKLineModels = emaModel.fetchDrawEMAData(drawRange: configuration.dataSource.drawRange)
        case .BOLL:
            let bollModel = CBBOLLModel(indicatorType: configuration.main.indicatorType,
                                        klineModels: configuration.dataSource.klineModels)
            mainDrawKLineModels = bollModel.fetchDrawBOLLData(drawRange: configuration.dataSource.drawRange)
        default:
            mainDrawKLineModels = configuration.dataSource.drawKLineModels
        }
    }
    
    func fetchLimitValue() -> (minValue: Double, maxValue: Double)? {
        guard let mainDrawKLineModels = mainDrawKLineModels else {
            return nil
        }
        
        var minValue = mainDrawKLineModels[0].low
        var maxValue = mainDrawKLineModels[0].high
        
        // 先求K线数据的最大最小
        for model in mainDrawKLineModels {
            if model.low < minValue {
                minValue = model.low
            }
            if model.high > maxValue {
                maxValue = model.high
            }
            // 求指标数据的最大最小
            switch configuration.main.indicatorType {
            case .MA:
                if let MAs = model.MAs {
                    for value in MAs {
                        if let value = value {
                            minValue = value < minValue ? value : minValue
                            maxValue = value > maxValue ? value : maxValue
                        }
                    }
                }
            case .EMA:
                if let EMAs = model.EMAs {
                    for value in EMAs {
                        if let value = value {
                            minValue = value < minValue ? value : minValue
                            maxValue = value > maxValue ? value : maxValue
                        }
                    }
                }
            case .BOLL:
                if let value = model.bollMB {
                    minValue = value < minValue ? value : minValue
                    maxValue = value > maxValue ? value : maxValue
                }
                
                if let value = model.bollUP {
                    minValue = value < minValue ? value : minValue
                    maxValue = value > maxValue ? value : maxValue
                }
                if let value = model.bollDN {
                    minValue = value < minValue ? value : minValue
                    maxValue = value > maxValue ? value : maxValue
                }
                
            default:
                break
            }
        }
        
        limitValueChanged?((minValue, maxValue))
        
        return (minValue, maxValue)
    }
}
