//
//  EXBaseTableViewCell.swift
//  Swap
//
//  Created by cwd on 2023/3/31.
//

import UIKit
import Reusable
open class EXBaseTableViewCell: UITableViewCell,Reusable {

    open override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        // Configure the view for the selected state
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.ThemeView.bg
        setUpView()
        setData()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setUpView() {
        
    }
    open func setData(){
        
    }
}
