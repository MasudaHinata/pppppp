//
//  FirebaseClient.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/07/18.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

enum FirebaseClientAuthError: Error {
    case notAuthenticated
    case emailVerifyRequired
    case firestoreUserDataNotCreated
    case unknown
}

enum FirebaseClientFirestoreError: Error {
    case userDataNotFound
}

//protocol FirebaseClientDelegate: class {
//      func acountDeleted()
//  }

final class FirebaseClient {
    static let shared = FirebaseClient()
//    weak var delegate: FirebaseClientDelegate? = nil
    private init() {}
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    //ログインできてるかとfirestoreに情報があるかの判定
    private func validate() async throws {
        guard let user = user else {
            await LoginHelper.shared.showAccountViewController()
            throw FirebaseClientAuthError.notAuthenticated
        }
        try await user.reload()
        if !user.isEmailVerified {
            throw FirebaseClientAuthError.emailVerifyRequired
        }
        //名前があるかどうかの判定
        let userID = user.uid
        let snapshot = try await self.db.collection("UserData").document(userID).getDocument()
        guard let user = try? snapshot.data(as: User.self) else {
            await LoginHelper.shared.showProfileNameViewController()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
    }
    
    public func getfriendIds() async throws -> [String] {
        //FIXME: エラーハンドリングをする
        try await validate()
        guard let userID = user?.uid else { fatalError("validate not working") }
        let querySnapshot = try await db.collection("UserData").document(userID).collection("friendsList").getDocuments()
        let documents = querySnapshot.documents
        return documents.compactMap {
            return $0.data()["friendId"] as? String
        }
    }
    
    public func getUserDataFromId(friendId: String) async throws -> User {
        try await validate()
        let querySnapshot = try await db.collection("UserData").document(friendId).getDocument()
        do {
            let user = try querySnapshot.data(as: User.self)
            return user
        } catch {
            throw FirebaseClientFirestoreError.userDataNotFound
        }
    }
    
//    //友達を削除する
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        guard let deleteFriendId = friendList[indexPath.row].id else { return }
//
//        let db = Firestore.firestore()
//        let alert = UIAlertController(title: "注意", message: "友達を削除しますか？", preferredStyle: .alert)
//        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { (action) -> Void in
//            if let currentUser = Auth.auth().currentUser {
//
//                db.collection("UserData").document(currentUser.uid).collection("friendsList").document(deleteFriendId).delete() { err in
//                    if let err = err {
//                        print("Error removing document: \(err)")
//                    } else {
//                        db.collection("UserData").document(deleteFriendId).collection("friendsList").document(currentUser.uid).delete() { err in
//                            if let err = err {
//                                print("Error removing document: \(err)")
//                            } else {
//                                print("自分を友達のリストから削除しました")
//                                self.delegate?.acountDeleted()
//                            }
//                        }
//                    }
//                }
//            }
//        })
//        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
//            print("キャンセル")
//        })
//        alert.addAction(delete)
//        alert.addAction(cancel)
//        self.present(alert, animated: true, completion: nil)
//    }
}

