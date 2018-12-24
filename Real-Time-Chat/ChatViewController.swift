//
//  ChatViewController.swift
//  Real Time Chat
//
//  Created by Chittapon Thongchim on 14/12/2561 BE.
//  Copyright © 2561 Chittapon Thongchim. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Firebase
import Reusable

class ChatViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var toolBar: UIToolbar!
    
    private let viewModel: ChatViewModelType = ChatViewModel()
    private lazy var toolBarContentView: ToolBarContentView = ToolBarContentView.loadFromNib()
    private let bag = DisposeBag()
    private let sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    private let minimumLineSpacing: CGFloat = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setup()
        bindViewModel()
    }
    
    func setUI() {
        toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
        let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.minimumLineSpacing = 12
        flowLayout?.sectionInset = sectionInset
    }
    
    func setup() {
        collectionView.register(cellType: OutgoingMessageCollectionViewCell.self)
        collectionView.register(cellType: IncomingMessageCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        toolBar.removeFromSuperview()
        collectionView.keyboardDismissMode = .interactive
        toolBarContentView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(toolBarContentView)
        toolBarContentView.topAnchor.constraint(equalTo: toolBar.topAnchor).isActive = true
        toolBarContentView.leftAnchor.constraint(equalTo: toolBar.leftAnchor).isActive = true
        toolBarContentView.bottomAnchor.constraint(equalTo: toolBar.bottomAnchor).isActive = true
        toolBarContentView.rightAnchor.constraint(equalTo: toolBar.rightAnchor).isActive = true
    }
    
    func bindViewModel() {
        let notificationName = UIResponder.keyboardWillChangeFrameNotification
        NotificationCenter.default.rx.notification(notificationName).subscribe(onNext: { [weak self] (notification) in
            
            guard let info = notification.userInfo,
                let frame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                let self = self else { return }
            
            let safeAreaInsets = self.view.safeAreaInsets
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: frame.height - safeAreaInsets.bottom, right: 0)
            self.collectionView.contentInset = insets
            self.collectionView.scrollIndicatorInsets = insets
            
        }).disposed(by: bag)
        
        viewModel.output.reloadData.subscribe(onNext: { [weak self] (reload) in
            
            guard let self = self else { return }
            switch reload {

            case .insert(let indexPath):
                self.collectionView.insertItems(at: [indexPath])
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                
            case .delete(let indexPath):
                self.collectionView.deleteItems(at: [indexPath])
                
            case .update(let indexPath):
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }).disposed(by: bag)
        
        let text = toolBarContentView.textView.rx.text.orEmpty
        let tap = toolBarContentView.sendButton.rx.tap
        
        tap.withLatestFrom(text) { (_, text) -> String in
            return text
            }.do(onNext: { [weak self] (_) in
                self?.toolBarContentView.textView.text = nil
                self?.toolBarContentView.textView.setNeedsDisplay()
            }).bind(to: viewModel.input.sendMessage ).disposed(by: bag)

        viewModel.input.viewDidLoad()
    }
    
    override var inputAccessoryView: UIView? {
        return toolBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

}

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let messageViewModel = viewModel.output.messages[indexPath.item]
        let cellClass = messageViewModel.output.isOutgoing ? OutgoingMessageCollectionViewCell.self : IncomingMessageCollectionViewCell.self
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: cellClass)
        cell.viewModel = messageViewModel
        return cell
    }
 
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = viewModel.output.messages[indexPath.item]
        let isOutgoing = message.output.isOutgoing
        
        let width = collectionView.bounds.width - sectionInset.left - sectionInset.right
        let text = message.output.text
        let attributes = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        let textContainerInset = MessageCollectionViewCell.textContainerInset
        
        if isOutgoing {
            let textViewWidth = width - 10 - textContainerInset.left - textContainerInset.right - 10
            let additionalHeight = textContainerInset.top + textContainerInset.bottom + sectionInset.top + sectionInset.bottom
            let height = UIView.calculateHeight(for: attributes, width: textViewWidth) + additionalHeight
            return CGSize(width: width, height: height)
            
        }else {
            let textViewWidth = width - 10 - 56 - 10 - textContainerInset.left - textContainerInset.right - 10
            let additionalHeight = textContainerInset.top + textContainerInset.bottom + sectionInset.top + sectionInset.bottom
            let height = UIView.calculateHeight(for: attributes, width: textViewWidth) + additionalHeight
            return CGSize(width: width, height: height)
        }
    }
}