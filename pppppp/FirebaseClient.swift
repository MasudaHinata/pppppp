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
import Combine

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
}
protocol FirebasePutPoint: AnyObject {
    func putPointForFirestore(point: Int)
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
    
    //今までの自分のポイントを取得l
    func getUntilNowPoint() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await db.collection("User").document(userID).collection("HealthData").document("Date()").getDocument()
        //        untilNowPoint = querySnapshot.data()?["point"] as? Int ?? 0
        do {
            untilNowPoint = try querySnapshot.data()!["point"]! as! Int
            print("今までのポイントは\(String(describing: untilNowPoint))")
            
        } catch {
            print("FirebaseClient getUntilNowPoint error")
        }
    }
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
            friend.point = try await getFriendPointData2()
            friends.append(friend)
        }
        
        return friends
    }
    
    func getFriendPointData2() async throws -> Int {
        return 0
    }
        
        
    //友達のポイントを取得
    func getFriendPointData() async throws -> [FriendPointDataList] {
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        
        // DateFomatterクラスのインスタンス生成
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy HH:mm:ss"
        let result = formatter.string(from: Date())
        
        let startDate = result + " " + "07:00:00"
        let startTime: Date = formatter.date(from: startDate) ?? Date(timeIntervalSince1970: 0)
        let startTimestamp: Timestamp = Timestamp(date: startTime)
        
        let endDate = result + " " + "23:59:00"
        let endTime: Date = formatter.date(from: endDate) ?? Date()
        let endTimestamp: Timestamp = Timestamp(date: endTime)
        
        
        let querySnapshot = try await db.collection("User").whereField("FriendList",arrayContains: userID).getDocuments()
        print(querySnapshot.documents)
        var friends: [FriendPointDataList] = []
        let documents = querySnapshot.documents
        for document in documents {
            let snapshot = try await db.collection("User").document(document.documentID).collection("HealthData").whereField("date", isLessThanOrEqualTo: Timestamp(date: Date())).getDocuments()
            print(snapshot.documents.map{$0.data()})
            
            for friendData in snapshot.documents {
                print(friendData.data())
                friends.append(try friendData.data(as: FriendPointDataList.self))
            }
//            return friends
        }
        print(friends)
        return friends
        
//        let querySnapshot = try await db.collection("User").whereField("date", isGreaterThanOrEqualTo: Timestamp(date: Date())).getDocuments()
//        print(querySnapshot.documents)
        
//        var friends: [FriendPointDataList] = []
//        for friendData in snapshot.documents {
//            friends.append(try friendData.data(as: FriendPointDataList.self))
//            print(friends)
//        }
//        return friends
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
    func setUserData(name: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).setData(["name": name, "IconImageURL": "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"])
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
    //自己評価ポイントをfirebaseに保存
    func firebaseSelfPutData(point: Int) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).collection("HealthData").document().setData(["point":point,"date": Timestamp(date: Date())])
        self.putPoint?.putPointForFirestore(point: point)
    }
    //ポイントをfirebaseに保存
    func firebasePutData(point: Int) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).collection("HealthData").document().setData(["point":point,"date": Timestamp(date: Date())])
        //TODO: ポイント獲得のアラート
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
    //myIDを入れる
    func putMyId() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["myID": FieldValue.arrayUnion([userID])])
    }
    //ログインできてるかの判定
    func userAuthCheck() async throws {
        guard let user = Auth.auth().currentUser else {
            await LoginHelper.shared.showAccountViewController()
            return
        }
        try await user.reload()
    }
    //メール認証完了してるかの判定
    func emailVerifyRequiredCheck() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        if user.isEmailVerified == false {
            self.emailVerifyDelegate?.emailVerifyRequiredAlert()
            throw FirebaseClientAuthError.emailVerifyRequired
        }
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
            print("ユーザーデータなし")
            try await setUserData(name: "名称未設定")
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
    //myIDがあるかどうかの判定
    func checkMyId() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await self.db.collection("User").document(userID).getDocument()
        guard querySnapshot.data() != nil else {
            print("ユーザーデータなし")
            try await setUserData(name: "名称未設定")
            try await putMyId()
            return
        }
        guard querySnapshot.data()!["myID"] != nil else {
            try await putMyId()
            return
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
            print("ユーザーデータなし")
            try await setUserData(name: "名称未設定")
            return
        }
        guard querySnapshot.data()!["IconImageURL"] != nil else {
            try await putIconFirestore(imageURL: "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11")
            return
        }
    }
    //アカウントを作成する
    func createAccount(email: String, password: String) {
        firebaseAuth.createUser(withEmail: email, password: password) { (result, error) in
            if error == nil, let result = result {
                result.user.sendEmailVerification(completion: { (error) in
                    if error == nil {
                        self.createdAccount?.accountCreated()
                    }
                })
            } else {
                print("FirebaseClient createAccount error:", error!.localizedDescription)
            }
        }
    }
    //友達のリストを取得する
    func getfriendIdList() async throws  {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        
        let querySnapshot = try await db.collection("User").whereField("FriendList",arrayContains: userID).getDocuments()
        print(querySnapshot)
        
        let documents = querySnapshot.documents
        for document in documents {
            print(document.data()["myID"])
            try await db.collection("User").document(document.data()["myID"] as! String).updateData(["FriendList": FieldValue.arrayRemove([userID])])
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
                try? await getfriendIdList()
                try await db.collection("User").document(userID).delete()
                try await accountDeleteAuth()
            }
            catch {
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
        user.delete { error in
            if let error = error {
                print("FirebaseClient accountDeleteAuth error:", error)
                let task = Task {
                    do {
                        try await self.logout()
                        self.deleteAccount?.faildAcccountDelete()
                    }
                    catch {
                        
                    }
                }
                self.cancellables.insert(.init { task.cancel() })
            } else {
                self.deleteAccount?.accountDeleted()
            }
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
