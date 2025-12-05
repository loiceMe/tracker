//
//  UIColletctionView+extenstions.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 29.11.2025.
//
import UIKit

class DynamicHeightCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}
