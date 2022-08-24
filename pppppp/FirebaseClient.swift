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
    
    
    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    var untilNowPoint = Int()
    
    //今までの自分のポイントを取得
    func getUntilNowPoint() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await db.collection("User").document(userID).collection("HealthData").document("Date()").getDocument()
        do {
            untilNowPoint = try querySnapshot.data()!["point"]! as! Int
            print("今までのポイントは\(String(describing: untilNowPoint))")
            
        } catch {
            print("error")
        }
    }
    //ポイントをfirebaseに保存
    func firebasePutData(point: Int) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).collection("HealthData").document("Date()").setData([
            "point": point
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("ポイントをfirestoreに保存！")
            }
        }
    }
    //友達のデータを取得
    public func getfriendProfileData() async throws -> [FriendListItem] {
        //FIXME: エラーハンドリングをする
        try await checkNameData()
        try await checkIconData()
        guard let user = Auth.auth().currentUser else {
            try await self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await db.collection("User").whereField("FriendList",arrayContains: userID).getDocuments()
        print(querySnapshot)
        
        var friends: [FriendListItem] = []
        for friendData in querySnapshot.documents {
            friends.append(try friendData.data(as: FriendListItem.self))
        }
        print(friends)
        return friends
    }
    //自分の名前を表示する
    func getMyNameData() async throws -> String {
        try await self.checkNameData()
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapShot = try await db.collection("User").document(userID).getDocument()
        print("自分の名前は\(querySnapShot.data()!["name"]!)")
        let data = querySnapShot.data()!["name"]!
        return data as! String
    }
    
    //自分のアイコンを表示する
    func getMyIconData() async throws -> URL {
        try await checkIconData()
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapShot = try await db.collection("User").document(userID).getDocument()
        print("自分のアイコンのURLは: \(querySnapShot.data()!["IconImageURL"]!)")
        let url = URL(string: querySnapShot.data()!["IconImageURL"]! as! String)!
        return url
    }
    //友達の名前を表示する
    func getFriendNameData(friendId: String) async throws -> String {
        let querySnapShot = try await db.collection("User").document(friendId).getDocument()
        print("友達の名前は\(querySnapShot.data()!["name"]!)")
        let data = querySnapShot.data()!["name"]!
        return data as! String
    }
    //友達のアイコンを表示する
    func getFriendData(friendId: String) async throws -> URL {
        let querySnapShot = try await db.collection("User").document(friendId).getDocument()
        print("友達のアイコンのURLは: \(querySnapShot.data()!["IconImageURL"]!)")
        let url = URL(string: querySnapShot.data()!["IconImageURL"]! as! String)!
        return url
    }
    //画像をfirestoreに保存
    func putIconFirestore(imageURL: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["IconImageURL": imageURL])
        print("画像を設定")
    }
    //名前をfirestoreに保存
    func putNameFirestore(name: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["name": name])
        print("名前を設定")
    }
    //友達を追加する
    func addFriend(friendId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        var result = try await db.collection("User").document(userID).updateData(["FriendList": FieldValue.arrayUnion([friendId])])
        result = try await db.collection("User").document(friendId).updateData(["FriendList": FieldValue.arrayUnion([userID])])
    }
    //友達を削除する
    func deleteFriendQuery(deleteFriendId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        var result = try await db.collection("User").document(userID).updateData(["FriendList": FieldValue.arrayRemove([deleteFriendId])])
        result = try await db.collection("User").document(deleteFriendId).updateData(["FriendList": FieldValue.arrayRemove([userID])])
        print("自分を友達のリストから削除しました")
        await self.delegate?.friendDeleted()
    }
    //ログインできてるかの判定
    func validate() async throws {
        guard let user = Auth.auth().currentUser else {
            await LoginHelper.shared.showAccountViewController()
            return
        }

        try await user.reload()
        if !user.isEmailVerified {
            throw FirebaseClientAuthError.emailVerifyRequired
        }
    }
    //名前があるかどうかの判定
    func checkNameData() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let snapshot = try await db.collection("User").document(userID).getDocument()
        guard snapshot.data()!["name"] != nil else {
            try await putNameFirestore(name: "名称未設定")
            return
        }
    }
    //アイコンがあるかどうかの判定
    func checkIconData() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await self.db.collection("User").document(userID).getDocument()
        guard querySnapshot.data()!["IconImageURL"] != nil else {
            try await putIconFirestore(imageURL: "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11")
            return
        }
    }
    //アカウントを作成する
    func createAccount(email: String, password: String) async throws {
        try await self.firebaseAuth.createUser(withEmail: email, password: password) { (result, error) in
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
    //アカウントを削除する
    func accountDelete() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
//        let friendIds = try? await FirebaseClient.shared.getfriendIds()
//        guard let friendIds = friendIds else { return }
//        for friendsId in friendIds {
//            var results = try await db.collection("UserData").document(friendsId).collection("friendsList").document(userID).delete()
//            results = try await db.collection("UserData").document(userID).delete()
//        }
    }
    
    //ログインする
    func login(email: String, password: String) async throws {
        try await firebaseAuth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
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
    //UUIDをとる
    func getUserUUID() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            try await self.validate()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        return userID
    }
}
