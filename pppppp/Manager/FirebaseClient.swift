//
//  FirebaseClient.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/07/18.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

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
protocol FirebaseEmailVarify: AnyObject {
    func emailVerifyRequiredAlert()
}
protocol FireStoreCheckName: AnyObject {
    func notChangeName()
}
protocol FirebaseCreatedAccount: AnyObject {
    func accountCreated()
}
protocol FirebaseDeleteAccount: AnyObject {
    func accountDeleted()
    func faildAcccountDelete()
    func faildAcccountDeleteData()
}
protocol FirebasePutPoint: AnyObject {
    func putPointForFirestore(point: Int)
    func notGetPoint()
}

final class FirebaseClient {
    static let shared = FirebaseClient()
    weak var delegate: FirebaseClientDelegate?
    weak var delegateLogin: FirebaseClientAuthDelegate?
    weak var emailVerifyDelegate: FirebaseEmailVarify?
    weak var notChangeDelegate: FireStoreCheckName?
    weak var createdAccount: FirebaseCreatedAccount?
    weak var deleteAccount: FirebaseDeleteAccount?
    weak var putPoint: FirebasePutPoint?
    private init() {}
    
    var cancellables = Set<AnyCancellable>()
    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    var untilNowPoint = Int()
    //友達のデータを取得
    public func getFriendProfileData() async throws -> [FriendListItem] {
        try await checkNameData()
        try await checkIconData()
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await db.collection("User").whereField("FriendList",arrayContains: userID).getDocuments()
        var friends: [FriendListItem] = []
        for friendData in querySnapshot.documents {
            var friend = try friendData.data(as: FriendListItem.self)
            friend.point = try await getFriendPointData(id: friend.id!)
            friends.append(friend)
        }
        friends.sort(by: {$1.point! < $0.point!})
        return friends
    }
    //友達のpointを取得して累積にして表示
    func getFriendPointData(id: String) async throws -> Int {
        let snapshot = try await db.collection("User").document(id).collection("HealthData").whereField("date", isLessThanOrEqualTo: Timestamp(date: Date())).getDocuments()
        var friends: [FriendPointDataList] = []
        for friendData in snapshot.documents {
            friends.append(try friendData.data(as: FriendPointDataList.self))
        }
        let pointArray = friends.map { $0.point }
        var pointSum = 0
        for point in pointArray {
            pointSum += point ?? 0
        }
        return pointSum
    }
    //自分の名前を表示する
    func getMyNameData() async throws -> String {
        try await self.checkNameData()
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapShot = try await db.collection("User").document(userID).getDocument()
        let data = querySnapShot.data()!["name"]!
        return data as! String
    }
    //自分のアイコンを表示する
    func getMyIconData() async throws -> URL {
        try await checkIconData()
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapShot = try await db.collection("User").document(userID).getDocument()
        let url = URL(string: querySnapShot.data()!["IconImageURL"]! as! String)!
        return url
    }
    //友達の名前を表示する
    func getFriendNameData(friendId: String) async throws -> String {
        let querySnapShot = try await db.collection("User").document(friendId).getDocument()
        let data = querySnapShot.data()!["name"]!
        return data as! String
    }
    //友達のアイコンを表示する
    func getFriendData(friendId: String) async throws -> URL {
        let querySnapShot = try await db.collection("User").document(friendId).getDocument()
        let url = URL(string: querySnapShot.data()!["IconImageURL"]! as! String)!
        return url
    }
    //UserDataをFirestoreに保存
    func setUserData() async throws {
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).setData(["name": "名称未設定", "IconImageURL": "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"])
    }
    //名前をFirestoreに保存
    func setNameFirestore(name: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).setData(["name" : name])
    }
    //ポイントをfirebaseに保存
    func firebasePutData(point: Int) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        if point == 0 {
            try await db.collection("User").document(userID).collection("HealthData").document().setData(["point": point, "date": Timestamp(date: Date())])
            self.putPoint?.notGetPoint()
        } else {
            try await db.collection("User").document(userID).collection("HealthData").document().setData(["point": point, "date": Timestamp(date: Date())])
            self.putPoint?.putPointForFirestore(point: point)
        }
    }
    //画像をfirestoreに保存
    func putIconFirestore(imageURL: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["IconImageURL": imageURL])
    }
    //名前をfirestoreに保存
    func putNameFirestore(name: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["name": name])
    }
    //友達を追加する
    func addFriend(friendId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["FriendList": FieldValue.arrayUnion([friendId])])
        try await db.collection("User").document(friendId).updateData(["FriendList": FieldValue.arrayUnion([userID])])
    }
    //友達を削除する
    func deleteFriendQuery(deleteFriendId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["FriendList": FieldValue.arrayRemove([deleteFriendId])])
        try await db.collection("User").document(deleteFriendId).updateData(["FriendList": FieldValue.arrayRemove([userID])])
        await self.delegate?.friendDeleted()
    }
    //ログインできてるかとメール認証ができてるかの判定
    func userAuthCheck() async throws {
        guard let user = Auth.auth().currentUser else {
            await LoginHelper.shared.showAccountViewController()
            return
        }
        if user.isEmailVerified == true {
            self.emailVerifyDelegate?.emailVerifyRequiredAlert()
        }
        try await user.reload()
    }
    //名前があるかどうかの判定
    @MainActor
    func checkNameData() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await self.db.collection("User").document(userID).getDocument()
        guard querySnapshot.data() != nil else {
            try await setUserData()
            return
        }
        guard querySnapshot.data()!["name"] != nil else {
            try await putNameFirestore(name: "名称未設定")
            return
        }
        if String("名称未設定") == querySnapshot.data()!["name"]! as! String {
            self.notChangeDelegate?.notChangeName()
        }
    }
    //アイコンがあるかどうかの判定
    func checkIconData() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await self.db.collection("User").document(userID).getDocument()
        guard querySnapshot.data() != nil else {
            try await setUserData()
            return
        }
        guard querySnapshot.data()!["IconImageURL"] != nil else {
            try await putIconFirestore(imageURL: "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11")
            return
        }
    }
    //アカウントを作成する
    func createAccount(email: String, password: String) async throws {
        let result = try await firebaseAuth.createUser(withEmail: email, password: password)
        
        result.user.sendEmailVerification(completion: { (error) in
            if error == nil {
                self.createdAccount?.accountCreated()
            }
        })
    }
    //パスワードを再設定する
    func passwordResetting(email: String) async throws{
        try await firebaseAuth.sendPasswordReset(withEmail: email)
    }
    //友達のFriendListから自分を削除する
    func deleteMeFromFriend() async throws  {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await db.collection("User").whereField("FriendList",arrayContains: userID).getDocuments()
        let documents = querySnapshot.documents
        for document in documents {
            try await db.collection("User").document(document.documentID).updateData(["FriendList": FieldValue.arrayRemove([userID])])
        }
    }
    //アカウントを削除する
    func accountDelete() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let task = Task {
            do {
                try? await deleteMeFromFriend()
                try await db.collection("User").document(userID).delete()
                try await accountDeleteAuth()
            }
            catch {
                self.deleteAccount?.faildAcccountDeleteData()
                print("firebaseClient accountDelete error", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    //アカウントを削除
    func accountDeleteAuth() async throws {
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        do {
            try await user.delete()
            self.deleteAccount?.accountDeleted()
        }
        catch {
            self.deleteAccount?.faildAcccountDelete()
        }
    }
    //ログインする
    @MainActor
    func login(email: String, password: String) async throws {
        let authReault = try await firebaseAuth.signIn(withEmail: email, password: password)
        if authReault.user.isEmailVerified {
            print("パスワードとメールアドレス一致")
            self.delegateLogin?.loginScene()
        } else {
            print("パスワードかメールアドレスが間違っています")
            self.delegateLogin?.loginHelperAlert()
        }
    }
    //ログアウトする
    func logout() async throws {
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("FirebaseClient logout error:", signOutError)
        }
    }
    //UUIDをとる
    func getUserUUID() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        return userID
    }
}
