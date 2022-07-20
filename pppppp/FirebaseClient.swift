//
//  FirebaseClient.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/07/18.
//

import Foundation
import FirebaseFirestore
import Firebase
import UIKit

protocol FirebaseClientRoutable: AnyObject {
    func presentAccountViewController()
    func presentProfileNmaeViewController()
    func presentAlertViewController(alert: UIAlertController)
}

final class FirebaseClient {
    static let shared = FirebaseClient()
    private init() {}
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var routableDelegate: FirebaseClientRoutable?
    
    //ログインできてるかとfirestoreに情報があるかの判定
    func validateAuth() {
        guard let user = user else {
            print("ユーザーがログインしていません")
            routableDelegate?.presentAccountViewController()
            return
        }
        
        user.reload { [weak self] error in
            guard let error = error else {
                print(error?.localizedDescription)
                return
            }
            if !user.isEmailVerified {
                print("asdf")
                let alert = UIAlertController(title: "確認用メールを送信しているので確認をお願いします。", message: "まだメール認証が完了していません。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self?.routableDelegate?.presentAlertViewController(alert: alert)
                return
            }
            print("ログインしています")
            //名前があるかどうかの判定
            let userID = user.uid
            self?.db.collection("UserData").document(userID).getDocument { [weak self] snapshot, err in
                guard let data = snapshot?.data(), err == nil else {
                    print("自分の名前を取得しようとした/firestoreに情報なし")
                    self?.routableDelegate?.presentProfileNmaeViewController()
                    return
                }
                print(data["name"]!)
            }
        }
    }
    
    func getfriendIds() async throws -> [String] {
        //FIXME: エラーハンドリングをする
        guard let userID = user?.uid else { return [] }
        let querySnapshot = try await db.collection("UserData").document(userID).collection("friendsList").getDocuments()
        let documents = querySnapshot.documents
        return documents.compactMap {
            return $0.data()["friendId"] as? String
        }
    }
    
    func getUserDataFromId(friendId: String) async throws -> User? {
        
        guard (user?.uid) != nil else { return nil }
        let querySnapshot = try await db.collection("UserData").document(friendId).getDocument()
        let user = try? querySnapshot.data(as: User.self)
        return user
    }
}

