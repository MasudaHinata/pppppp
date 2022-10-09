//
//  TimelineViewController+CellDelegate.swift
//  pppppp
//
//  Created by hinata on 2022/10/08.
//

import UIKit
import Combine

extension TimeLineViewController: TimelineCollectionViewCellDelegate {
    
    func tapGoodButton(judge: Bool, postId: String) {
        var cancellables = Set<AnyCancellable>()
        
        if judge {
            //MARK: いいねを保存する
            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    try await FirebaseClient.shared.putGoodFriendsPost(postId: postId)
                } catch {
                    print("TimelineCollectionViewCellDelegate error:",error.localizedDescription)
                    if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
                            self.viewDidAppear(true)
                        }
                    } else {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                    }
                }
            }
            cancellables.insert(.init { task.cancel() })
        } else {
            //MARK: いいねを取り消す
            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    try await FirebaseClient.shared.putGoodCancelFriendsPost(postId: postId)
                } catch {
                    print("TimelineCollectionViewCellDelegate error:",error.localizedDescription)
                    if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
                            self.viewDidAppear(true)
                        }
                    } else {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                    }
                }
            }
            cancellables.insert(.init { task.cancel() })
        }
        collectionView.reloadData()
    }
}
