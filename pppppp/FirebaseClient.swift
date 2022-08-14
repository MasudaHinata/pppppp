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
    let firebaseAuth = Auth.auth()
    let user = Auth.auth().currentUser
    let userID = Auth.auth().currentUser?.uid
    var untilNowPoint = Int()
    
    //名前とアイコンがあるかどうかの判定
    func checkName() async throws {
        let userID = user?.uid
        let snapshot = try await self.db.collection("UserData").document(userID!).getDocument()
        guard (try? snapshot.data(as: User.self)) != nil else {
            try await db.collection("UserData").document(userID!).setData(["name": "名称未設定"])
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
            return
        }
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
    //名前を表示する
    func getMyNameData(user: String) async throws -> String {
        let querySnapShot = try await db.collection("UserData").document(user).getDocument()
        print("名前は\(querySnapShot.data()!["name"]!)")
        let data = querySnapShot.data()!["name"]!
        return data as! String
    }

    //アイコンを表示する
    func getMyData(user: String) async throws -> URL {
    let querySnapShot = try await db.collection("UserData").document(user).collection("IconData").document("Icon").getDocument()
        print("アイコンのURLは: \(querySnapShot.data()!["imageURL"]!)")
        let url = URL(string: querySnapShot.data()!["imageURL"]! as! String)!
        return url
    }
    
    //画像をfirestoreに保存
    func putIconFirestore(image: String) {
        let db = Firestore.firestore()
        var userID = Auth.auth().currentUser?.uid
        db.collection("UserData").document(userID!).collection("IconData").document("Icon").setData(["imageURL": image])
        print("画像を設定")
    }
    //名前をfirestoreに保存
    func putNameFirestore(name: String) {
        let db = Firestore.firestore()
        var userID = Auth.auth().currentUser?.uid
        db.collection("UserData").document(userID!).setData(["name": name])
        print("画像を設定")
    }
    
    //友達を追加する
    func addFriend(friendId: String) async throws {
        var result = try await db.collection("UserData").document(user!.uid).collection("friendsList").document(friendId).setData(["friendId": friendId])
        result = try await db.collection("UserData").document(friendId).collection("friendsList").document(user!.uid).setData(["friendId": user!.uid])
        
    }
    //友達を削除する
    func deleteFriendQuery(deleteFriendId: String) async throws {
        var result = try await db.collection("UserData").document(user!.uid).collection("friendsList").document(deleteFriendId).delete()
        result = try await db.collection("UserData").document(deleteFriendId).collection("friendsList").document(user!.uid).delete()
        print("自分を友達のリストから削除しました")
        await self.delegate?.friendDeleted()
    }
    /*　firebaseAuth　*/
    //アカウントを作成する
    func createAccount(email: String, password: String) {
        self.firebaseAuth.createUser(withEmail: email, password: password) { (result, error) in
            if error == nil, let result = result {
                result.user.sendEmailVerification(completion: { [weak self] (error) in
                    if error == nil {
                        print("アカウントを作成しました")
                    }
                })
            } else {
                print("error occured\(error)")
            }
        }
        
        
    }
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
