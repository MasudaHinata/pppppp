//
//  FirebaseClient.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/07/18.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Foundation
import UIKit

enum FirebaseClientAuthError: Error {
    case notAuthenticated
    case emailVerifyRequired
    case firestoreUserDataNotCreated
    case firestoreIconDataNotCreated
    case unknown
}

enum FirebaseClientFirestoreError: Error {
    case userDataNotFound
}

protocol FirebaseClientDelegate: AnyObject {
    func friendDeleted() async
}

protocol FirebaseClientAuthDelegate: AnyObject {
    func loginScene()
    func loginHelperAlert()
}


final class FirebaseClient {
    static let shared = FirebaseClient()
    weak var delegate: FirebaseClientDelegate?
    weak var delegateLogin: FirebaseClientAuthDelegate?
    private init() {}
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var untilNowPoint = Int()
    
    func checkName() async throws {
        //名前があるかどうかの判定
        let userID = user?.uid
        let snapshot = try await self.db.collection("UserData").document(userID!).getDocument()
        guard (try? snapshot.data(as: User.self)) != nil else {
            try await db.collection("UserData").document(userID!).setData(["name": "名称未設定"])
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
            return
        }
        //アイコンがあるかどうかの判定
        let querySnapshot = try await self.db.collection("UserData").document(userID!).collection("IconData").document("Icon").getDocument()
        guard (try? querySnapshot.data(as: UserIcon.self)) != nil else {
            print("アイコンなし")
            try await db.collection("UserData").document(userID!).collection("IconData").document("Icon").setData([
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"
            ])
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
            return
        }
    }
    //今までの自分のポイントを取得
    func getUntilNowPoint() async throws {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        
        let querySnapshot = try await db.collection("UserData").document(user!.uid).collection("HealthData").document("Date()").getDocument()
        do {
            untilNowPoint = try querySnapshot.data()!["point"]! as! Int
            print("今までのポイントは\(String(describing: untilNowPoint))")
            
        } catch {
            print("error")
        }
    }
    //ポイントをfirebaseに保存
    func firebasePutData(point: Int) async throws {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        
        try await db.collection("UserData").document(user!.uid).collection("HealthData").document("Date()").setData([
            "point": point
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("ポイントをfirestoreに保存！")
            }
        }
    }
    //TODO: addsnapshotListener
    //IDを取得
    public func getfriendIds() async throws -> [String] {
        //FIXME: エラーハンドリングをする
        try await validate()
        try await checkName()
        guard let userID = user?.uid else { fatalError("validate not working") }
        let querySnapshot = try await db.collection("UserData").document(userID).collection("friendsList").getDocuments()
        let documents = querySnapshot.documents
        return documents.compactMap {
            return $0.data()["friendId"] as? String
        }
    }
    //IDから名前とか取得
    public func getUserDataFromId(friendId: String) async throws -> User {
        let querySnapshot = try await db.collection("UserData").document(friendId).getDocument()
        do {
            let user = try querySnapshot.data(as: User.self)
            return user
        } catch {
            throw FirebaseClientFirestoreError.userDataNotFound
        }
    }
    //IDからポイントを取得
    public func getHealthDataFromId(friendsId: String) async throws -> UserHealth {
        let querySnapshot = try await db.collection("UserData").document(friendsId).collection("HealthData").document("Date()").getDocument()
        do {
            let user = try querySnapshot.data(as: UserHealth.self)
            print(user)
            return user
        } catch {
            throw FirebaseClientFirestoreError.userDataNotFound
        }
    }
    //IDからアイコンの画像URLを取得
    public func getIconDataFromId(friendIds: String) async throws -> UserIcon {
        let querySnapshot = try await db.collection("UserData").document(friendIds).collection("IconData").document("Icon").getDocument()
        do {
            let user = try querySnapshot.data(as: UserIcon.self)
            print(user.imageURL)
            return user
        } catch {
            throw FirebaseClientFirestoreError.userDataNotFound
        }
    }
    //自分の情報を表示する
//    func showMyData(imageView: UIImageView, label: UILabel) {
//        let db = Firestore.firestore()
//        let user = FirebaseClient.shared.user
//        let docRef = db.collection("UserData").document(user!.uid).collection("IconData").document("Icon")
//        docRef.getDocument { [weak self] (document, error) in
//            if let document = document, document.exists {
//                print("自分のアイコンのURLは: \(document.data()!["imageURL"]!)")
//                let url = URL(string: document.data()!["imageURL"]! as! String)
//                do {
//                    let data = try Data(contentsOf: url!)
//                    let image = UIImage(data: data)
//                    imageView.image = image
//                } catch let err {
//                    print("Error: \(err.localizedDescription)")
//                }
//            } else {
//                print("自分のアイコンなし")
//            }
//        }
//        let doccRef = db.collection("UserData").document(user!.uid)
//        doccRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                print("自分の名前は\(document.data()!["name"]!)")
//                let data = document.data()!["name"]!
//                label.text = data as! String
//            } else {
//                print("error存在してない")
//            }
//        }
//    }
    
    func getMyData() async throws -> URL {
        let db = Firestore.firestore()
        let user = FirebaseClient.shared.user
        
        let querySnapShot = try await db.collection("UserData").document(user!.uid).collection("IconData").document("Icon").getDocument()
        print("自分のアイコンのURLは: \(querySnapShot.data()!["imageURL"]!)")
        let url = URL(string: querySnapShot.data()!["imageURL"]! as! String)!
        return url
    }
    
    //画像をfirestoreに保存
    func putIconFirestore() {
        let db = Firestore.firestore()
        var userID = Auth.auth().currentUser?.uid
        db.collection("UserData").document(userID!).collection("IconData").document("Icon").setData([
            "imageURL": "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"
        ])
        print("初期画像を設定")
    }
    //友達を削除する
    func deleteFriendQuery(deleteFriendId: String) async throws {
        var result = try await db.collection("UserData").document(user!.uid).collection("friendsList").document(deleteFriendId).delete()
        result = try await db.collection("UserData").document(deleteFriendId).collection("friendsList").document(user!.uid).delete()
        print("自分を友達のリストから削除しました")
        await self.delegate?.friendDeleted()
    }
    /*　firebaseAuth　*/
    let firebaseAuth = Auth.auth()
    
    //ログインできてるか,firestoreに情報があるかの判定
    func validate() async throws {
        guard let user = user else {
            await LoginHelper.shared.showAccountViewController()
            throw FirebaseClientAuthError.notAuthenticated
        }
        try await user.reload()
        if !user.isEmailVerified {
            throw FirebaseClientAuthError.emailVerifyRequired
        }
    }
    //ログインする
    func login(email: String, password: String) {
        firebaseAuth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if self.firebaseAuth.currentUser?.isEmailVerified == true {
                print("パスワードとメールアドレス一致")
                self.delegateLogin?.loginScene()
            } else if self.firebaseAuth.currentUser?.isEmailVerified == nil {
                print("パスワードかメールアドレスが間違っています")
                self.delegateLogin?.loginHelperAlert()
            }
        }
        
    }
    //ログアウトする
    func logout() async throws {
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("サインアウトしようとした/エラーは: %@", signOutError)
        }
    }
    //アカウントを削除する
    func accountDelete() async throws {
        let friendIds = try? await FirebaseClient.shared.getfriendIds()
        guard let friendIds = friendIds else { return }
        for friendsId in friendIds {
            var results = try await db.collection("UserData").document(friendsId).collection("friendsList").document(user!.uid).delete()
            results = try await db.collection("UserData").document(user!.uid).delete()
        }
    }
}
