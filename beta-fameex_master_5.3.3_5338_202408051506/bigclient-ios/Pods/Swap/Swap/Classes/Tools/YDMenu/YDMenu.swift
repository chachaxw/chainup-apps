//
//  YDMenu.swift
//  YDMenu
//
//  Created by ZJXN on 2023/3/8.
//  Copyright © 2023年 YDZhao. All rights reserved.
//

import UIKit
import EXKit

private let NkScreenWidth = UIScreen.main.bounds.width
private let NkScreenHeight = UIScreen.main.bounds.height
private let NkScreenScale = UIScreen.main.scale
private let NkBottomHeight = CGFloat(UIApplication.shared.statusBarFrame.size.height > 20 ? 34 : 0)
public  var N_MARGIN_LEFT:CGFloat = 16

private let NewkAnimationDuration = 0.2

class YDMenu: UIView {
    
    
    ///Used to describe subscripts in menus
    public struct Index {
        ///Column
        var column: Int
        ///Row
        var row: Int
        ///Child rows of rows
        var item: Int
        ///Is there an item
        var haveItem:Bool {
            return item != -1
        }
        
        init(column: Int, row: Int, item: Int = -1) {
            self.column = column
            self.row = row
            self.item = item
        }
    }
    
    //MARK: - Properties
    // Public
    weak var delegate: YDMenuDelegate?
    weak var dataSource: YDMenuDataSource? {
        didSet{
            if oldValue === dataSource {
                
                return
            }
            didSetDataSource(ds: dataSource!)
        }
    }
    lazy var selectedView : UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill2
        return v
    }()
    
    var textColor: UIColor = .Ex.text2
    var cellBgColor = UIColor.ThemeView.bgIconh
    var selectedTextColor: UIColor = .Ex.main1
    var detailTextColor: UIColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
    var indicatorColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
    var detailTextFontSize: CGFloat = 12
    var separatorColor: UIColor = .Ex.fill4
    var titleFontSize:CGFloat = 12
    var fontSize:CGFloat = 14
    var tableViewHeight: CGFloat = 240
    var cellHeight: CGFloat = 60
    let imageWH:CGFloat = 16
    var textAligment:NSTextAlignment = .left
    var menuTitleAligment:NSTextAlignment = .center
    
    private var isSingleColumn: Bool = false
    // Private
    private var menuOrigin: CGPoint
    private var menuHeight: CGFloat
    private var numberOfColumn = 0 //Number of columns
    private var isShow: Bool = false
    private var currentSelectedColumn = -1  //The currently selected column
    private var currentSelectedRows = [Int]()
    
    private var currentTitleLayers = [CATextLayer]()
    private var currentIndicatorLayers = [UIView]()
    private var currentBgLayers = [CALayer]()
    
    private lazy var backGroundView: UIView = {
        let view = UIView(frame: CGRect(x: menuOrigin.x, y: menuOrigin.y + menuHeight, width: NkScreenWidth, height: NkScreenHeight))
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        view.isOpaque = false
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backTapped(sender:))))
        return view
    }()
    
    private lazy var leftTableView: UITableView = {
        let view = UITableView(frame: CGRect(x: menuOrigin.x, y: menuOrigin.y + menuHeight, width: 125, height: 240))
        view.dataSource = self;
        view.delegate = self;
        view.rowHeight = cellHeight
        view.backgroundColor = .Ex.fill9
        view.separatorColor = .clear
        return view
    }()
    
    private lazy var rightTableView: UITableView = {
        let view = UITableView(frame: CGRect(x: menuOrigin.x + NkScreenWidth / 2, y: menuOrigin.y + menuHeight, width: NkScreenWidth-125, height: 240))
        view.dataSource = self;
        view.delegate = self;
        view.rowHeight = cellHeight
        view.separatorColor = .clear
        return view
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: menuHeight - (1 / NkScreenScale), width: NkScreenWidth, height: 1 / NkScreenScale))
        view.backgroundColor = separatorColor
        view.isHidden = true
        return view
    }()
    
    //MARK: - Initialization method
    init(origin: CGPoint, menuheight height: CGFloat) {
        
        menuOrigin = origin
        menuHeight = height
        
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: NkScreenWidth, height: height))
        
        addSubview(bottomLine)
        
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(menuTapped))
        self.addGestureRecognizer(menuTap)
        
        leftTableView.tableFooterView = UIView()
        rightTableView.tableFooterView = UIView()
    }
    //MARK: - Initialization method
    init(origin: CGPoint, width:CGFloat = 0,menuheight height: CGFloat) {
        
        menuOrigin = origin
        menuHeight = height
        
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: width, height: height))
        
        addSubview(bottomLine)
        
        let menuTap = UITapGestureRecognizer(target: self, action: #selector(menuTapped))
        self.addGestureRecognizer(menuTap)
        
        leftTableView.tableFooterView = UIView()
        rightTableView.tableFooterView = UIView()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func didSetDataSource(ds: YDMenuDataSource) {
        
        ///Background layer
        func creatBackgroundLayer(position: CGPoint, backgroundColor: UIColor) -> CALayer {
            let layer = CALayer()
            layer.position = position
            layer.backgroundColor = backgroundColor.cgColor
            layer.bounds = CGRect(x: 0, y: 0, width: NkScreenWidth / CGFloat(numberOfColumn), height: menuHeight - 1)
            return layer
        }
        ///Title Layer
        func creatTitleLayer(text: String, position: CGPoint, textColor: UIColor) -> CATextLayer {
            // size
            let textSize = calculateStringSize(text)
            let maxWidth = self.width / CGFloat(numberOfColumn)
            let textLayerWidth = (textSize.width < maxWidth) ? textSize.width : maxWidth
            // textLayer
            let textLayer = CATextLayer()
            textLayer.bounds = CGRect(x: 0, y: 0, width: textLayerWidth, height: textSize.height)
            textLayer.fontSize = titleFontSize
            textLayer.font = UIFont.Ex.regular(titleFontSize)
            textLayer.string = text
            textLayer.alignmentMode = CATextLayerAlignmentMode.center
            textLayer.truncationMode = CATextLayerTruncationMode.end
            textLayer.foregroundColor = textColor.cgColor
            textLayer.contentsScale = NkScreenScale
            textLayer.position = position
            return textLayer
        }
        func creatIndicatorView(position: CGPoint, color: UIColor) ->UIView {
            let imgV = UIImageView.init(image: UIImage.exs_themeImageNamed(imageName: "public_icon_arrow_down"))
            imgV.center = position
            return imgV
        }
        /// indicatorLayer
        func creatIndicatorLayer(position: CGPoint, color: UIColor) -> CAShapeLayer {
            // path
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: 0))
            bezierPath.addLine(to: CGPoint(x: 8, y: 0))
            bezierPath.addLine(to: CGPoint(x: 4, y: 6))
            bezierPath.close()
            bezierPath.fill()
            // shapeLayer
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = bezierPath.cgPath
            shapeLayer.lineWidth = 0.8
            shapeLayer.fillColor = color.cgColor
            shapeLayer.bounds = shapeLayer.path!.boundingBox
            shapeLayer.cornerRadius = 3
            shapeLayer.masksToBounds = true
            shapeLayer.position = position
            return shapeLayer
        }
        /// separatorLayer
        func creatSeparatorLayer(position: CGPoint, color: UIColor) -> CAShapeLayer {
            // path
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0, y: 0))
            bezierPath.addLine(to: CGPoint(x: 0, y: menuHeight - 16))
            bezierPath.close()
            // separatorLayer
            let separatorLayer = CAShapeLayer()
            separatorLayer.path = bezierPath.cgPath
            separatorLayer.strokeColor = color.cgColor
            separatorLayer.lineWidth = 1
            separatorLayer.bounds = separatorLayer.path!.boundingBox
            separatorLayer.position = position
            return separatorLayer
        }
        
        //Number of columns
        numberOfColumn = ds.numberOfColumnsInMenu(self)
        
        //Current selection of each column
        currentSelectedRows = Array<Int>(repeating: 0, count: numberOfColumn)
        
        let backgroundLayerWidth = self.width / CGFloat(numberOfColumn)
        
        currentBgLayers.removeAll()
        currentTitleLayers.removeAll()
        currentIndicatorLayers.removeAll()
        
        //Draw a menu
        for i in 0 ..< numberOfColumn {
            let index = CGFloat(i)
            
            // backgroundLayer
            let backgroundLayerPosition = CGPoint(x: (index + 0.5) * backgroundLayerWidth, y: menuHeight * 0.5)
            let backgroundLayer = creatBackgroundLayer(position: backgroundLayerPosition, backgroundColor: .Ex.fill2)
            layer.addSublayer(backgroundLayer)
            currentBgLayers.append(backgroundLayer)
            
            if menuTitleAligment == .right { //Right display
                let x = backgroundLayerWidth * (index+1) - N_MARGIN_LEFT - imageWH / 2
                let indicatorLayerPosition = CGPoint(x: x, y: menuHeight / 2 + 1)
                let indicatorLayer = creatIndicatorView(position: indicatorLayerPosition, color: .Ex.fill4)
                self.addSubview(indicatorLayer)
                currentIndicatorLayers.append(indicatorLayer)
                // titleLayer
                var titleStr: String!
                if let itemsCount = dataSource?.menu(self, numberOfItemsInRow: 0, inColumn: i), itemsCount > 0 {
                    titleStr = dataSource?.menu(self, titleForItemsInRowAtIndexPath: Index(column: i, row: 0, item: 0))
                }else{
                    titleStr = dataSource?.menu(self, titleForRowAtIndexPath: Index(column: i, row: 0))
                }
                let textSize = calculateStringSize(titleStr).width
                let textX = indicatorLayerPosition.x - imageWH / 2 - 5 - textSize / 2
                let titleLayerPosition = CGPoint(x: textX, y: menuHeight * 0.5)
                let titleLayer = creatTitleLayer(text: titleStr, position: titleLayerPosition, textColor: textColor)
                layer.addSublayer(titleLayer)
                currentTitleLayers.append(titleLayer)
            }else{ //Center multiple column headings
                let x = backgroundLayerWidth * (index+0.5)
                // titleLayer
                var titleStr: String!
                if let itemsCount = dataSource?.menu(self, numberOfItemsInRow: 0, inColumn: i), itemsCount > 0 {
                    titleStr = dataSource?.menu(self, titleForItemsInRowAtIndexPath: Index(column: i, row: 0, item: 0))
                }else{
                    titleStr = dataSource?.menu(self, titleForRowAtIndexPath: Index(column: i, row: 0))
                }
                
                let textX = x - (imageWH + 5) / 2 //Arrow+Spacing 5
                let titleLayerPosition = CGPoint(x: textX, y: menuHeight * 0.5)
                let titleLayer = creatTitleLayer(text: titleStr, position: titleLayerPosition, textColor: textColor)
                layer.addSublayer(titleLayer)
                currentTitleLayers.append(titleLayer)
                
                let textWidth = calculateStringSize(titleStr).width //
                let indicatorX = textX + textWidth / 2 + 5 + imageWH / 2
                let indicatorLayerPosition = CGPoint(x:indicatorX, y: menuHeight / 2 + 1)
                let indicatorLayer = creatIndicatorView(position: indicatorLayerPosition, color: UIColor.ThemeView.seperator)
                self.addSubview(indicatorLayer)
                currentIndicatorLayers.append(indicatorLayer)
            }
            
            // separatorLayer
            //            if i != numberOfColumn - 1 {
            //                let separatorLayerPosition = CGPoint(x: ceil((index + 1) * backgroundLayerWidth) - 1, y: menuHeight / 2)
            //                let separatorLayer = creatSeparatorLayer(position: separatorLayerPosition, color: separatorColor)
            //                layer.addSublayer(separatorLayer)
            //            }
        }
        
    }
    
    private func calculateStringSize(_ string: String) -> CGSize {
        let attributes = [NSAttributedString.Key.font: UIFont.Ex.regular(titleFontSize)]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let size = string.boundingRect(with: CGSize(width: 280, height: 0), options: option, attributes: attributes, context: nil).size
        return CGSize(width: ceil(size.width) + 2, height: size.height)
    }
    
    ///Use code to select row in the list
    func selectedAtIndex(_ indexPath: Index) {
        
        guard let ds = dataSource else {
            return
        }
        //Determine whether the incoming Index is legal
        guard indexPath.column >= 0 && indexPath.row >= 0 && indexPath.column < ds.numberOfColumnsInMenu(self) && indexPath.row < ds.menu(self, numberOfRowsInColumn: indexPath.column) else {
            fatalError("The passed in indexPath is illegal")
        }
        
        if indexPath.haveItem {
            guard indexPath.item < ds.menu(self, numberOfItemsInRow: indexPath.row, inColumn: indexPath.column)  && indexPath.item >= 0 else {
                /*
If there is no need to select a secondary list or no secondary list
When creating an Index, please do not pass in the item parameter, such as menu. selectedAtIndex (YDMenu. Index (column: 1, row: 2))
If it is necessary to pass in, please pass in -1, for example: menu. selectedAtIndex (YDMenu. Index (column: 1, row: 2, item: -1))
The above two writing methods are equivalent
Do not pass 0 to the item, for example: menu. selectedAtIndex (YDMenu. Index (column: 1, row: 2, item: 0)) ❌❌❌  Because this writing method represents selecting the 0th row in the second row of the first level list in column 1
                 */
                fatalError("The passed in indexPath is illegal")
            }
        }
        
        
        //choice
        let titleLayer = currentTitleLayers[indexPath.column]
        currentSelectedColumn = indexPath.column
        currentSelectedRows[indexPath.column] = indexPath.row
        if indexPath.haveItem {
            titleLayer.string = ds.menu(self, titleForItemsInRowAtIndexPath: indexPath)
            animateFor(titleLayer: titleLayer, indicator: currentIndicatorLayers[currentSelectedColumn], show: isShow, complete: {
                
            })
        }else {
            titleLayer.string = ds.menu(self, titleForRowAtIndexPath: indexPath)
            animateFor(titleLayer: titleLayer, indicator: currentIndicatorLayers[currentSelectedColumn], show: isShow, complete: {
                
            })
        }
        
        delegate?.menu(self, didSelectRowAtIndexPath: indexPath)
    }
    ///Default selected
    func selectDeafult() {
        
        guard let ds = dataSource else {
            return
        }
        
        for i in 0 ..< ds.numberOfColumnsInMenu(self) {
            
            if ds.menu(self, numberOfItemsInRow: 0, inColumn: i) > 0 {
                //There is a secondary list
                selectedAtIndex(Index(column: i, row: 0, item: 0))
            }else {
                //No secondary list
                selectedAtIndex(Index(column: i, row: 0))
            }
        }
        
    }
    @objc func backTapped(sender: UITapGestureRecognizer) -> Void {
        if currentSelectedColumn >= 0 {
            
            animateFor(indicator: currentIndicatorLayers[currentSelectedColumn], title: currentTitleLayers[currentSelectedColumn], show: false) {
                isShow = false
            }
        }
    }
}

// MARK: - UITableViewDataSource / Delegate
extension YDMenu: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == leftTableView {
            
            if let ds = dataSource {
                return ds.menu(self, numberOfRowsInColumn: currentSelectedColumn)
            }
        }else {
            
            if let ds = dataSource {
                return ds.menu(self, numberOfItemsInRow: currentSelectedRows[currentSelectedColumn], inColumn: currentSelectedColumn)
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "cellID"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellID)
        
        if cell == nil  {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
            
            cell.textLabel?.textColor = .Ex.text1
            cell.textLabel?.highlightedTextColor = selectedTextColor
            cell.textLabel?.font = .Ex.regular(fontSize)
            cell.detailTextLabel?.textColor = detailTextColor
            cell.detailTextLabel?.highlightedTextColor = selectedTextColor
            cell.detailTextLabel?.font = .Ex.regular(detailTextFontSize)
            cell.imageView?.contentMode = .scaleAspectFit
        }
        
        cell.selectedBackgroundView = selectedView
        if currentSelectedColumn == 0 {
            cell.backgroundColor = .Ex.fill9
        }else {
            cell.backgroundColor = .Ex.fill2
        }
        cell.textLabel?.textAlignment = textAligment
        
        if tableView == leftTableView {
            //First level list
            if let ds = dataSource {
                cell.textLabel?.text = ds.menu(self, titleForRowAtIndexPath: Index(column: currentSelectedColumn, row: indexPath.row))
                cell.detailTextLabel?.text = ds.menu(self, detailTextForRowAtIndexPath: Index(column: currentSelectedColumn, row: indexPath.row))
                // image
                switch ds.menu(self, imageNameForRowAtIndexPath: Index(column: currentSelectedColumn, row: indexPath.row)) {
                case .some(let imageName):
                    
                    cell.imageView?.image = UIImage(named: imageName)
                    break
                case .none:
                    cell.imageView?.image = nil

                }
                
                //Select the last selected row
                if currentSelectedRows[currentSelectedColumn] == indexPath.row {
                    
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    
                }
                    //Division line
                    let line = UIView()
                    line.tag = 1000
                    line.backgroundColor = separatorColor
                    cell.addSubview(line)
                    line.snp.makeConstraints { (make) in
                        make.leading.trailing.bottom.equalToSuperview()
                        make.height.equalTo(0.5)
                    }
            }
            if isSingleColumn {
                cell.backgroundColor = UIColor.clear
            }
        }else {
            //Secondary List
            if let ds = dataSource {
                
                let currentSelectedRow = currentSelectedRows[currentSelectedColumn]
                
                cell.textLabel?.text = ds.menu(self, titleForItemsInRowAtIndexPath: Index(column: currentSelectedColumn, row: currentSelectedRow, item: indexPath.row))
                cell.detailTextLabel?.text = ds.menu(self, detailTextForItemsInRowAtIndexPath: Index(column: currentSelectedColumn, row: currentSelectedRow, item: indexPath.row))
                // image
                switch ds.menu(self, imageNameForItemsInRowAtIndexPath: Index(column: currentSelectedColumn, row: currentSelectedRow, item: indexPath.row)) {
                case .some(let imageName):
                    cell.imageView?.image = UIImage(named: imageName)
                    break
                case .none:
                    cell.imageView?.image = nil
                }
                
                //Select the last selected row
                if cell.textLabel?.text == currentTitleLayers[currentSelectedColumn].string as! String? {
                    leftTableView.selectRow(at: IndexPath(row: currentSelectedRows[currentSelectedColumn], section: 0), animated: true, scrollPosition: .middle)
                    rightTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                }

                cell.accessoryType = .none
                cell.backgroundColor = .Ex.fill2
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let ds = dataSource else { return }
        
        let titleLayer = currentTitleLayers[currentSelectedColumn]
        
        if tableView == leftTableView {
            //First level list
            
            currentSelectedRows[currentSelectedColumn] = indexPath.row
            
            let haveItems = ds.menu(self, numberOfItemsInRow: indexPath.row, inColumn: currentSelectedColumn) > 0
//            if currentSelectedColumn != 0 {
                
                titleLayer.string = ds.menu(self, titleForRowAtIndexPath: Index(column: currentSelectedColumn, row: indexPath.row))
//            }
            animateFor(titleLayer: titleLayer, indicator: currentIndicatorLayers[currentSelectedColumn], show: true, complete: {})
//            
            if haveItems {
                rightTableView.reloadData()
            }else {
                //Recall List
                animateFor(indicator: currentIndicatorLayers[currentSelectedColumn], title: titleLayer, show: false, complete: {
                    isShow = false
                })
            }
            
            delegate?.menu(self, didSelectRowAtIndexPath: Index(column: currentSelectedColumn, row: indexPath.row))
            
        }else {
            //Secondary List
            
            titleLayer.string = ds.menu(self, titleForItemsInRowAtIndexPath: Index(column: currentSelectedColumn, row: currentSelectedRows[currentSelectedColumn], item: indexPath.row))
            //Recall List
            animateFor(indicator: currentIndicatorLayers[currentSelectedColumn], title: titleLayer, show: false, complete: {
                isShow = false
            })
            
            delegate?.menu(self, didSelectRowAtIndexPath: Index(column: currentSelectedColumn, row: currentSelectedRows[currentSelectedColumn], item: indexPath.row))
        }
        
    }
   
}

// MARK: - ActionEvent
private extension YDMenu {
    
    
    
    @objc private func menuTapped(sender: UITapGestureRecognizer) -> Void {
        
        guard let ds = dataSource else { return }
        
        //Confirm the clicked index
        let tapPoint = sender .location(in: self)
        let tapIndex: Int = Int(tapPoint.x / (NkScreenWidth / CGFloat(numberOfColumn)))
        
        //Retrieve the menu of other columns
        for i in 0 ..< numberOfColumn {
            if i != tapIndex {
                animateFor(indicator: currentIndicatorLayers[i], reverse: false, complete: {
                    animateFor(titleLayer: currentTitleLayers[i], indicator: nil, show: false, complete: {
                        
                    })
                })
            }
            
        }
        
        //Recall or eject the current menu
        if currentSelectedColumn == tapIndex && isShow {
            //Recall menu
            animateFor(indicator: currentIndicatorLayers[tapIndex], title: currentTitleLayers[tapIndex], show: false, complete: {
                currentSelectedColumn = tapIndex
                isShow = false
            })
            
        }else {
            //Pop up menu
            currentSelectedColumn = tapIndex
            
            ///Default
            textAligment = .left
            isSingleColumn = false
            leftTableView.backgroundColor = UIColor.ThemeTab.bg
            //Determine if it is
            //Load data 
            leftTableView.reloadData()
            
            if ds.menu(self, numberOfItemsInRow: currentSelectedRows[currentSelectedColumn], inColumn: currentSelectedColumn) > 0 {
                rightTableView.reloadData()
            }else{
                //Single column processing without secondary menu
                textAligment = .center
                leftTableView.backgroundColor = UIColor.ThemeView.bg
                isSingleColumn = true
                
            }

            animateFor(indicator: currentIndicatorLayers[tapIndex], title: currentTitleLayers[tapIndex], show: true, complete: {
                isShow = true
            })
        }
        self.delegate?.menu(self, willSelectMenuAtMenu: currentSelectedColumn)
    }
    
}

// MARK: - Animation
private extension YDMenu {
    //Click to process display logic
    func animateFor(indicator: UIView, title: CATextLayer, show: Bool, complete: () -> Void) -> Void {
        
        animateFor(indicator: indicator, reverse: show) {
            animateFor(titleLayer: title, indicator: indicator, show: show, complete: {
                animateForBackgroundView(show: show, complete: {
                    animateTableView(show: show, complete: {
                        
                    })
                })
            })
        }
        complete()
    }
    
    ///Upper right indicator
    func animateFor(indicator: UIView, reverse: Bool, complete: () -> Void) -> Void {
        
        //Rotate Animation
        
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(NewkAnimationDuration)
//        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0))
//        let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
//        animation.values = reverse ? [CGFloat(0), CGFloat.pi] : [CGFloat.pi, CGFloat(0)]
//        animation.duration = NewkAnimationDuration
//        indicator.add(animation, forKey: animation.keyPath)
        
//        if animation.isRemovedOnCompletion {
        UIView.animate(withDuration: 0.2) {
            
            if reverse {
                indicator.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
            }else {
                indicator.layer.transform = CATransform3DIdentity
            }
        }
        
        
//            indicator.setValue(animation.values?.last, forKey: animation.keyPath!)
//        }
        
//        CATransaction.commit()
        
        ///Indicator color
//        if reverse {
//            indicator.fillColor = selectedTextColor.cgColor
//        }else {
//            indicator.fillColor = textColor.cgColor
//        }
        
        
        
        complete()
    }
    
    ///BackgroundView animation
    func animateForBackgroundView(show: Bool, complete: () -> Void) -> Void {
        
        if show {
            superview?.addSubview(backGroundView)
            superview?.addSubview(self)
            UIView.animate(withDuration: NewkAnimationDuration, animations: {
                self.backGroundView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            })
        }else {
            UIView.animate(withDuration: NewkAnimationDuration, animations: {
                self.backGroundView.backgroundColor = UIColor(white: 0, alpha: 0)
            }, completion: { (finished) in
                if finished {
                    self.backGroundView.removeFromSuperview()
                }
            })
        }
        
        complete()
    }
    
    ///TableView animation
    func animateTableView(show: Bool, complete: () -> Void) -> Void {
        
        var haveItems = false
        let numberOfRow = leftTableView.numberOfRows(inSection: 0)
        if let ds = dataSource {
            for i in 0 ..< numberOfRow {
                if ds.menu(self, numberOfItemsInRow: i, inColumn: currentSelectedColumn) > 0 {
                    haveItems = true
                    break
                }
            }
        }
        
        var heightForTableView = CGFloat(numberOfRow) * cellHeight > tableViewHeight ? tableViewHeight : CGFloat(numberOfRow) * cellHeight;
        
        
        if show {
            
            if haveItems {
                heightForTableView = tableViewHeight
                leftTableView.frame = CGRect(x: 0, y: menuOrigin.y + menuHeight, width: 125, height: 0)
                rightTableView.frame = CGRect(x: 125, y: menuOrigin.y + menuHeight, width: NkScreenWidth - 125, height: 0)
                
                superview?.addSubview(leftTableView)
                superview?.addSubview(rightTableView)
            }else {
                //Single column
                rightTableView.removeFromSuperview()
                leftTableView.frame = CGRect(x: 0, y: menuOrigin.y + menuHeight, width: NkScreenWidth, height: 0)
                superview?.addSubview(leftTableView)
            }
            
            UIView.animate(withDuration: NewkAnimationDuration) {
                self.leftTableView.frame.size.height = heightForTableView
                if haveItems {
                    self.rightTableView.frame.size.height = heightForTableView
                }
            }
            
        }else {
            
            UIView.animate(withDuration: NewkAnimationDuration, animations: {
                
                self.leftTableView.frame.size.height = 0
                if haveItems {
                    self.rightTableView.frame.size.height = 0
                }
            }, completion: { (finished) in
                
                self.leftTableView.removeFromSuperview()
                if haveItems {
                    self.rightTableView.removeFromSuperview()
                }
            })
        }
        
        complete()
    }
    
    ///TitleLayer animation title text length adaptation
    func animateFor(titleLayer textLayer: CATextLayer, indicator: UIView?, show: Bool, complete: () -> Void) -> Void {
        textLayer.fontSize = titleFontSize
        let textSize = calculateStringSize((textLayer.string as! String?) ?? "")
        let maxWidth = self.width / CGFloat(numberOfColumn)
        let textLayerWidth = (textSize.width < maxWidth) ? textSize.width : maxWidth
        
        textLayer.bounds.size.width = textLayerWidth + 3
        textLayer.bounds.size.height = textSize.height
        
        if menuTitleAligment == .right { //To the right
            if let indicatorR = indicator {
                    //Adjust spacing 5
                    var position = textLayer.position
                    position.x = indicatorR.x - 5 - textLayerWidth * 0.5
                    textLayer.position = position
            }
        }else{
            ///Centered
            let backgroundLayerWidth = self.width/CGFloat(numberOfColumn)
            if let index = currentTitleLayers.firstIndex(of: textLayer){
                
                //characters
                let x = backgroundLayerWidth * (CGFloat(index)+0.5)
                let textX = x - (imageWH + 5) / 2 //Arrow+Spacing 5
                let titleLayerPosition = CGPoint(x: textX, y: menuHeight * 0.5)
                textLayer.position = titleLayerPosition
                
                //arrow
                let indicatorX = textX + textLayerWidth / 2 + 5 + imageWH / 2
                let indicatorLayerPosition = CGPoint(x:indicatorX, y: menuHeight / 2 + 1)
                if let indicatorR = indicator {
                    indicatorR.layer.position = indicatorLayerPosition
                }
            }
        }
        if show {
            textLayer.foregroundColor = selectedTextColor.cgColor
        }else {
            textLayer.foregroundColor = textColor.cgColor
        }
        complete()
    }
    
    
}

