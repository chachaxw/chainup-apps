//
//  EXSkeletonCollectionView.swift
//  EXKit
//
//  Created by youbin on 2023/6/27.
//

import UIKit
import SkeletonView

class EXSkeletonCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isSkeletonable = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurateWiew(contentView view: UIView.Type?, edgeInsets: UIEdgeInsets = .zero) {
        guard let view = view else { return }
        let v = view.init()
        contentView.addSubview(v)
        v.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(edgeInsets)
        }
    }
}


/////////////////////////////////////////////////////////////////////


class EXSkeletonCollectionView: UIView {
    
    
    public struct Configuration {
        public var scrollDirection : UICollectionView.ScrollDirection
        public var columns : Int
        public var rows : Int
        public var sectionInset: UIEdgeInsets
        public var minimumLineSpacing : CGFloat
        public var minimumInteritemSpacing : CGFloat
        public var itemsCount: Int
        public var itemHeight: CGFloat // 默认 cellItem的高度
    
        
        fileprivate weak var collectionView:EXSkeletonCollectionView?
        
        public static let `default`:Self = Configuration()
        
        public init(scrollDirection : UICollectionView.ScrollDirection = .horizontal,
                    itemsCount: Int = 1,
                    columns: Int = 1,
                    rows: Int = 1,
                    sectionInset: UIEdgeInsets = .zero,
                    minimumLineSpacing: CGFloat = 0.0,
                    minimumInteritemSpacing: CGFloat = 0.0,
                    itemHeight: CGFloat = -1) {
            self.scrollDirection = scrollDirection
            self.sectionInset    = sectionInset
            self.columns         = columns
            self.rows            = rows
            self.minimumLineSpacing      = minimumLineSpacing
            self.minimumInteritemSpacing = minimumInteritemSpacing
            self.itemsCount = itemsCount
            self.itemHeight = itemHeight
        }
    }
    
    public var configuration:Configuration = .default {
        didSet {
            configuration.collectionView = self
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection          = configuration.scrollDirection
            flowLayout.minimumLineSpacing       = configuration.minimumLineSpacing
            flowLayout.minimumInteritemSpacing  = configuration.minimumInteritemSpacing
            flowLayout.sectionInset             = configuration.sectionInset
            collectionView.collectionViewLayout = flowLayout
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public struct ConfigurationCell {
        public var cell : UIView.Type?
        public var edgeInsets : UIEdgeInsets
        
        fileprivate weak var collectionView:EXSkeletonCollectionView?
        
        public static let `default`:Self = ConfigurationCell()
        
        public init(edgeInsets: UIEdgeInsets = .zero, cell: UIView.Type = UIView.self) {
            self.edgeInsets = edgeInsets
            self.cell = cell
        }
    }
    
    public var configurateCell: ConfigurationCell = .default {
        didSet {
            configurateCell.collectionView = self
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public var isScrollEnabled: Bool = false {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.scrollDirection = .vertical
        let v = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        v.isSkeletonable = true
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.isScrollEnabled = false
        v.backgroundColor = .clear
        v.delegate = self
        v.dataSource = self
        v.register(EXSkeletonCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(EXSkeletonCollectionViewCell.self))
        return v
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


extension EXSkeletonCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateSizeForCellItem(configurate: configuration, collectionView: collectionView)
    }
}

extension EXSkeletonCollectionView: SkeletonCollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return NSStringFromClass(EXSkeletonCollectionViewCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return configuration.itemsCount
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(EXSkeletonCollectionViewCell.self), for: indexPath) as! EXSkeletonCollectionViewCell
        cell.configurateWiew(contentView: configurateCell.cell, edgeInsets: configurateCell.edgeInsets)
        return cell
    }
    
    
    //// UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return configuration.itemsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(EXSkeletonCollectionViewCell.self), for: indexPath) as! EXSkeletonCollectionViewCell
        cell.configurateWiew(contentView: configurateCell.cell, edgeInsets: configurateCell.edgeInsets)
        return cell
    }
}


extension EXSkeletonCollectionView {
    func calculateSizeForCellItem(configurate config: Configuration, collectionView view: UICollectionView) -> CGSize {
        
        let width        = CGRectGetWidth(collectionView.frame)
        let height       = CGRectGetHeight(collectionView.frame)
        let columns      = configuration.columns
        let rows         = configuration.rows
        let sectionInset = configuration.sectionInset
        let widthInset   = sectionInset.left + sectionInset.right;
        let heightInset  = sectionInset.top + sectionInset.bottom
        let direction    = configuration.scrollDirection
        let itemHeight   = configuration.itemHeight
        let minimumLineSpacing      = configuration.minimumLineSpacing
        let minimumInteritemSpacing = configuration.minimumInteritemSpacing
        
    
        var _itemWidth: CGFloat  = 0.0
        var _itemHeight: CGFloat = 0.0
        
        if direction == .horizontal {
            _itemWidth = (width - widthInset - CGFloat((columns - 1)) * minimumLineSpacing) / CGFloat(columns)
            if itemHeight > 0 {
               _itemHeight = itemHeight
            } else {
                _itemHeight = (height - heightInset - CGFloat((rows - 1)) * minimumInteritemSpacing) / CGFloat(rows)
            }
        } else {
            _itemWidth = (width - widthInset - CGFloat((columns - 1)) * minimumInteritemSpacing) / CGFloat(columns)
            if itemHeight > 0 {
               _itemHeight = itemHeight
            } else {
                _itemHeight = (height - heightInset - CGFloat((rows - 1)) * minimumLineSpacing) / CGFloat(rows)
            }
        }
        return CGSize(width: _itemWidth, height: _itemHeight)
    }
}
