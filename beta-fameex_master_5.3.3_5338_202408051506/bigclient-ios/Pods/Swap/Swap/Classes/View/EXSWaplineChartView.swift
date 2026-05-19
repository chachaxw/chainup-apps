//
//  EXSWaplineChartView.swift
//  Chainup
//
//  Created by 柴伟东 on 2023/6/16.
//  Copyright © 2023 Chainup. All rights reserved.
//
import EXKit
import UIKit
import SnapKit
class EXSWaplineChartView: UIView {

    var type: EXContractInfoDetailTab = .insurance
    var YView = UIView()

    var valuesArray = [Double]()
    var dateString = [String]()
    var lineDataArray: [EXContractInfoDetailCellModel]? {
        didSet{
            guard let data = lineDataArray else {
                return
            }
            if data.count == 0 {
                clearChart()
                return
            }
            self.configChartView(data: data)
        }
    }
    

    var chartView: LRSChartView = {

      let chartView = LRSChartView()
    
        chartView.x_Font = UIFont.systemFont(ofSize: 10)
        //Set font color for X-axis coordinates
        chartView.x_Color =  UIColor.ThemeLabel.colorMedium// UIColor.ThemeLabel.colorLite

        chartView.y_Font = UIFont.systemFont(ofSize: 10)
  
        chartView.y_Color = UIColor.ThemeLabel.colorMedium

        chartView.xmargin = 50;

        chartView.backgroundColor = .clear

        //chartView.isFloating = YES;
        chartView.backgroundColor = UIColor.ThemeView.bg
        chartView.leftColorStrArr = [UIColor.Ex.main1.rgbString]
        
        
        
    //    @[@"#febf83",@"#53d2f8",@"#7211df"];
        chartView.chartViewStyle = .moreClickLine

        chartView.chartLayerStyle = .projection

        chartView.lineLayerStyle = .none
        chartView.lineWidth = 2.5
        chartView.drawDashLineColor = UIColor.ThemeView.seperator

        chartView.colors = [
            UIColor.Ex.main1,
            UIColor.Ex.main1
        ]
        //Gradient Start Scale
        chartView.proportion = 0.5
        return chartView
        
    }()
    
    //Color of all points
    var circleColors: [UIColor] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    func setSubView(){
        self.addSubview(chartView)
        chartView.snp.makeConstraints { make  in
            make.edges.equalToSuperview()
        }
    }
    func clearChart(){
        valuesArray.removeAll()
        dateString.removeAll()
        chartView.clearSubViews()
    }
    func configChartView(data: [EXContractInfoDetailCellModel]){
        valuesArray.removeAll()
        dateString.removeAll()
        chartView.clearSubViews()
        for item in data {
            valuesArray.append(Double(item.right) ?? 0)
            dateString.append(item.left)
        }
       
        chartView.leftDataArr = [valuesArray]
        chartView.dataArrOfX = dateString
        chartView.show()
    }
}





