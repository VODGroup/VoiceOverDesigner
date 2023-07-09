//
//  File.swift
//  
//
//  Created by Andrey Plotnikov on 09.07.2023.
//

import Foundation
import UIKit
import Document

public final class ArtboardPreviewViewController: UIViewController {
    
    private let document: VODesignDocument
    
    public init(document: VODesignDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        view.addSubview(collectionView)
        document.open { [weak self] _ in
            self?.collectionView.reloadData()
        }
        collectionView.register(FramePreviewCell.self, forCellWithReuseIdentifier: FramePreviewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self

    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.frame
    }
    
    private func makeCollectionLayout() -> UICollectionViewLayout {
        
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .absolute(300))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionLayout())
}

extension ArtboardPreviewViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let frame = document.artboard.frames[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FramePreviewCell.reuseIdentifier, for: indexPath)
        
        guard let frameCell = cell as? FramePreviewCell else { return cell }
        frameCell.setup(with: frame, imageLoader: document.artboard.imageLoader)
        return frameCell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        document.artboard.frames.count
    }
    
}

extension ArtboardPreviewViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let frame = document.artboard.frames[indexPath.item]
        
    }
}




private class FramePreviewCell: UICollectionViewCell {
    static let reuseIdentifier: String = String(describing: FramePreviewCell.self)
    
    func setup(with frame: Frame, imageLoader: ImageLoading) {
        imageView.image = imageLoader.image(for: frame)
        imageView.contentMode = .scaleAspectFit
        frameLabel.text = frame.label
    }
    
    let imageView = UIImageView()
    let frameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubviews()
        addConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(frameLabel)
        frameLabel.textAlignment = .center
    }
    
    private func addConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20)
        ])
        
        frameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            frameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            frameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            frameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
    }
}
