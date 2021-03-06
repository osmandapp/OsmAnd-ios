//
//  CombinedYAxisRenderer.swift
//  OsmAnd
//
//  Created by Paul on 03.01.2020.
//  Copyright © 2020 OsmAnd. All rights reserved.
//

import UIKit

@objc(ChartYAxisCombinedRenderer)
open class YAxisCombinedRenderer: YAxisRenderer {
    
    @objc(YAxisCombinedRenderingMode)
    public enum RenderingMode: Int
    {
        case primaryValueOnly
        case secondaryValueOnly
        case bothValues
    }
    
    @objc open var renderingMode: RenderingMode;
    
    @objc public let secondaryYAxis: YAxis?
    @objc public let secondaryTransformer: Transformer?
    
    @objc public init(viewPortHandler: ViewPortHandler, yAxis: YAxis?, secondaryYAxis: YAxis?, transformer: Transformer?, secondaryTransformer: Transformer?)
    {
        self.secondaryYAxis = secondaryYAxis
        self.secondaryTransformer = secondaryTransformer
        self.renderingMode = .bothValues
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: transformer)
    }
    
    internal override func drawYLabels(
        context: CGContext,
        fixedPosition: CGFloat,
        positions: [CGPoint],
        offset: CGFloat,
        textAlign: NSTextAlignment)
    {
        guard
            let yAxis = self.axis as? YAxis
            else { return }
        
        let primaryAttributes: [NSAttributedString.Key : Any] = [.font: yAxis.labelFont,
                                                                 .foregroundColor: yAxis.labelTextColor,
                                                                 .backgroundColor: yAxis.labelBackgroundColor]
        let secondaryAttributes: [NSAttributedString.Key : Any] = [.font: secondaryYAxis?.labelFont ?? UIFont.systemFont(ofSize: 15),
                                                                   .foregroundColor: secondaryYAxis?.labelTextColor ?? .white,
                                                                   .backgroundColor: secondaryYAxis?.labelBackgroundColor ?? .white]
        
        let from = yAxis.isDrawBottomYLabelEntryEnabled ? 0 : 1
        let to = yAxis.isDrawTopYLabelEntryEnabled ? yAxis.entryCount : (yAxis.entryCount - 1)
        
        for i in stride(from: from, to: to, by: 1)
        {
            let height: CGPoint? = secondaryTransformer?.valueForTouchPoint(CGPoint(x: fixedPosition, y: positions[i].y + offset))
            let secondaryText: String = secondaryYAxis?.valueFormatter?.stringForValue(Double(height?.y ?? 0), axis: secondaryYAxis) ?? ""
            let text = yAxis.getFormattedLabel(i)
            
            let needsSeparator = self.renderingMode == .bothValues
            let separator = needsSeparator ? ", " : ""
            let secondaryWidth = (separator + secondaryText).size(withAttributes: secondaryAttributes).width
            let correctedPosition = fixedPosition - secondaryWidth
            
            switch self.renderingMode {
            case .bothValues:
                ChartUtils.drawText(
                    context: context,
                    text: text,
                    point: CGPoint(x: correctedPosition, y: positions[i].y + offset),
                    align: textAlign,
                    attributes: primaryAttributes
                )
                
                if (!secondaryText.isEmpty) {
                    ChartUtils.drawText(
                        context: context,
                        text: separator + secondaryText,
                        point: CGPoint(x: fixedPosition, y: positions[i].y + offset),
                        align: textAlign,
                        attributes: secondaryAttributes
                    )
                }
                break
            case .primaryValueOnly:
                ChartUtils.drawText(
                    context: context,
                    text: text,
                    point: CGPoint(x: fixedPosition, y: positions[i].y + offset),
                    align: textAlign,
                    attributes: primaryAttributes
                )
                break
            case .secondaryValueOnly:
                if (!secondaryText.isEmpty) {
                    ChartUtils.drawText(
                        context: context,
                        text: separator + secondaryText,
                        point: CGPoint(x: fixedPosition, y: positions[i].y + offset),
                        align: textAlign,
                        attributes: secondaryAttributes
                    )
                }
                break
            default:
                break
            }
            
        }
    }
}
