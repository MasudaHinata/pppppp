import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

//MARK: - error
enum FirebaseClientAuthError: Error {
    case notAuthenticated
    case emailVerifyRequired
    case firestoreUserDataNotCreated
    case unknown
}
enum FirebaseClientFirestoreError: Error {
    case userDataNotFound
}
//MARK: - Setting Delegate

@MainActor
protocol FirebaseClientDeleteFriendDelegate: AnyObject {
    func friendDeleted() async
}

@MainActor
protocol FirebaseClientAuthDelegate: AnyObject {
    func loginScene()
    func loginHelperAlert()
}
protocol FirebaseEmailVarifyDelegate: AnyObject {
    func emailVerifyRequiredAlert()
}

@MainActor
protocol FireStoreCheckNameDelegate: AnyObject {
    func notChangeName()
}

protocol FirebaseCreatedAccountDelegate: AnyObject {
    func accountCreated()
}

protocol SetttingAccountDelegate: AnyObject {
    func accountDeleted()
    func faildAcccountDelete()
    func faildAcccountDeleteData()
    func logoutCompleted()
}

protocol FirebasePutPointDelegate: AnyObject {
    func putPointForFirestore(point: Int)
    func notGetPoint()
}

protocol FirebaseSentEmailDelegate: AnyObject {
    func sendEmail()
}

protocol FirebaseAddFriendDelegate: AnyObject {
    func addFriends()
}

final class FirebaseClient {
    static let shared = FirebaseClient()
    weak var deletefriendDelegate: FirebaseClientDeleteFriendDelegate?
    weak var loginDelegate: FirebaseClientAuthDelegate?
    weak var emailVerifyDelegate: FirebaseEmailVarifyDelegate?
    weak var notChangeDelegate: FireStoreCheckNameDelegate?
    weak var createdAccountDelegate: FirebaseCreatedAccountDelegate?
    weak var SettingAccountDelegate: SetttingAccountDelegate?
    weak var putPointDelegate: FirebasePutPointDelegate?
    weak var sentEmailDelegate: FirebaseSentEmailDelegate?
    weak var addFriendDelegate: FirebaseAddFriendDelegate?
    private init() {}
    
    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    let calendar = Calendar.current
    let formatter = DateFormatter()
    let date = Date()
    var cancellables = Set<AnyCancellable>()
    
    //MARK: - FireStore Read
    //UUIDをとる
    func getUserUUID() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        return userID
    }
    //自分と友達のProfile,Pointデータを取得
    public func getProfileData(includeMe: Bool) async throws -> [UserData] {
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await db.collection("User").whereField("FriendList", arrayContains: userID).getDocuments()
        var users = try querySnapshot.documents.map { try $0.data(as: UserData.self) }
        if includeMe == true {
            //FIXME: 並列処理にしたい
            try await FirebaseClient.shared.checkNameData()
            try await FirebaseClient.shared.checkIconData()
//            async let checkName: () = FirebaseClient.shared.checkNameData()
//            async let checkIconImageURL: () = FirebaseClient.shared.checkIconData()
//            let set = try await (checkName,checkIconImageURL)
            
            let myData = try (try await db.collection("User").document(userID).getDocument()).data(as: UserData.self)
            users.append(myData)
        }
        for i in 0 ..< users.count {
            users[i].point = try await getPointDataSum(id: users[i].id!)
        }
        users.sort { $1.point! < $0.point! }
        return users
    }
    //idで与えられたユーザーの累積ポイントを返す
    func getPointDataSum(id: String) async throws -> Int {
        let startDate = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: date))
        let snapshot = try await db.collection("User").document(id).collection("HealthData").whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate!)).whereField("date", isLessThanOrEqualTo: Timestamp(date: Date())).getDocuments()
        var friends: [PointData] = []
        for friendData in snapshot.documents {
            friends.append(try friendData.data(as: PointData.self))
        }
        let pointArray = friends.map { $0.point }
        var pointSum = 0
        for point in pointArray {
            pointSum += point ?? 0
        }
        return pointSum
    }
    //idで与えられたユーザーのポイント履歴を取得する
    func getPointData(id: String) async throws -> [PointData] {
        let snapshot = try await db.collection("User").document(id).collection("HealthData").whereField("date", isLessThanOrEqualTo: Timestamp(date: Date())).getDocuments()
        return try snapshot.documents.map { try $0.data(as: PointData.self) }
    }
    //自分の名前を取得する
    func getMyNameData() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await checkNameData()
        let querySnapShot = try await db.collection("User").document(userID).getDocument()
        let data = querySnapShot.data()!["name"]!
        return data as! String
    }
    //自分のアイコンを取得する
    func getMyIconData() async throws -> URL {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await checkIconData()
        let querySnapShot = try await db.collection("User").document(userID).getDocument()
        let url = URL(string: querySnapShot.data()!["IconImageURL"]! as! String)!
        return url
    }
    //友達の名前を取得する
    func getFriendNameData(friendId: String) async throws -> String {
        let querySnapShot = try await db.collection("User").document(friendId).getDocument()
        let data = querySnapShot.data()!["name"]!
        return data as! String
    }
    //友達のアイコンを取得する
    func getFriendData(friendId: String) async throws -> URL {
        let querySnapShot = try await db.collection("User").document(friendId).getDocument()
        let url = URL(string: querySnapShot.data()!["IconImageURL"]! as! String)!
        return url
    }
    
    //MARK: - FireStore Write
    //UserDataをFirestoreに保存
    func setUserData() async throws {
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).setData(["name": "名称未設定", "IconImageURL": "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"])
        UserDefaults.standard.set("名称未設定", forKey: "name")
        UserDefaults.standard.set("https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11", forKey: "IconImageURL")
        
    }
    //ポイントをFirestoreに保存
    func firebasePutData(point: Int, activity: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        if point == 0 {
            self.putPointDelegate?.notGetPoint()
        } else {
            try await db.collection("User").document(userID).collection("HealthData").document().setData(["point": point, "date": Timestamp(date: Date()), "activity": activity])
            self.putPointDelegate?.putPointForFirestore(point: point)
        }
    }
    //画像をfirestore,firebaseStorageに保存
    func putFirebaseStorage(selectImage: UIImage) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        let reference = Storage.storage().reference().child("posts/\(imageName)")
        if let imageData = selectImage.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            reference.putData(imageData, metadata: metadata, completion:{(metadata, error) in
                if let _ = metadata {
                    reference.downloadURL { [self] (url,error) in
                        if let downloadUrl = url {
                            let task = Task { [weak self] in
                                do {
                                    let downloadUrlStr = downloadUrl.absoluteString
                                    try await self!.db.collection("User").document(userID).updateData(["IconImageURL": downloadUrlStr])
                                    UserDefaults.standard.set(downloadUrlStr, forKey: "IconImageURL")
                                }
                                catch {
                                    
                                }
                            }
                            self.cancellables.insert(.init { task.cancel() })
                        } else {
                            print("downloadURLの取得が失敗した場合の処理")
                        }
                    }
                } else {
                    print("storageの保存が失敗")
                }
            })
        }
    }
    //名前をfirestoreに保存
    func putNameFirestore(name: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["name": name])
        UserDefaults.standard.set(name, forKey: "name")
    }
    //自己評価をfirebaseに保存
    func firebasePutSelfCheckLog(log: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMd", options: 0, locale: Locale(identifier: "en_US"))
        try await db.collection("User").document(userID).collection("SelfCheckLog").document("\(formatter.string(from: date))").setData(["log": log, "date": Timestamp(date: Date())])
    }
    //友達を追加する
    func addFriend(friendId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        //FIXME: 並列処理にしたい
        try await db.collection("User").document(userID).updateData(["FriendList": FieldValue.arrayUnion([friendId])])
        try await db.collection("User").document(friendId).updateData(["FriendList": FieldValue.arrayUnion([userID])])
        self.addFriendDelegate?.addFriends()
    }
    //友達を削除する
    func deleteFriendQuery(deleteFriendId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        //FIXME: 並列処理にしたい
        try await db.collection("User").document(userID).updateData(["FriendList": FieldValue.arrayRemove([deleteFriendId])])
        try await db.collection("User").document(deleteFriendId).updateData(["FriendList": FieldValue.arrayRemove([userID])])
        await self.deletefriendDelegate?.friendDeleted()
    }
    //友達のFriendListから自分を削除する
    func deleteMeFromFriend() async throws  {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await db.collection("User").whereField("FriendList",arrayContains: userID).getDocuments()
        for document in querySnapshot.documents {
            try await db.collection("User").document(document.documentID).updateData(["FriendList": FieldValue.arrayRemove([userID])])
        }
    }
    //自分のデータを全削除する
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
                self.SettingAccountDelegate?.faildAcccountDeleteData()
                print("firebaseClient accountDelete error", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    //MARK: - FireStore Check
    
    //ログインできてるか・メール認証ができてるかの判定
    func userAuthCheck() async throws {
        guard let user = Auth.auth().currentUser else {
            await LoginHelper.shared.showAccountViewController()
            return
        }
        if user.isEmailVerified == false {
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
        if UserDefaults.standard.object(forKey: "name") == nil {
            let querySnapShot = try await db.collection("User").document(userID).getDocument()
            let data = querySnapShot.data()!["name"]!
            UserDefaults.standard.set(data, forKey: "name")
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
            try await db.collection("User").document(userID).updateData(["IconImageURL": "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"])
            UserDefaults.standard.set("https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11", forKey: "IconImageURL")
            return
        }
        if UserDefaults.standard.object(forKey: "IconImageURL") == nil {
           let querySnapShot = try await db.collection("User").document(userID).getDocument()
            let data = querySnapShot.data()!["IconImageURL"]!
            UserDefaults.standard.set(data, forKey: "IconImageURL")
        }
    }
    
    //MARK: - Firebase Authentication
    //アカウントを作成する
    func createAccount(email: String, password: String) async throws {
        let result = try await firebaseAuth.createUser(withEmail: email, password: password)
        
        try await result.user.sendEmailVerification()
        self.createdAccountDelegate?.accountCreated()
    }
    //ログインする
    @MainActor
    func login(email: String, password: String) async throws {
        let authReault = try await firebaseAuth.signIn(withEmail: email, password: password)
        if authReault.user.isEmailVerified {
            self.loginDelegate?.loginScene()
        } else {
            self.loginDelegate?.loginHelperAlert()
        }
    }
    //パスワードを再設定する
    func passwordResetting(email: String) async throws{
        try await firebaseAuth.sendPasswordReset(withEmail: email)
        self.sentEmailDelegate?.sendEmail()
    }
    //アカウントを削除
    func accountDeleteAuth() async throws {
        guard let user = Auth.auth().currentUser else {
            try await self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        do {
            try await user.delete()
            self.SettingAccountDelegate?.accountDeleted()
        }
        catch {
            self.SettingAccountDelegate?.faildAcccountDelete()
        }
    }
    //ログアウトする
    func logout() async throws {
        do {
            try firebaseAuth.signOut()
            self.SettingAccountDelegate?.logoutCompleted()
        } catch let signOutError as NSError {
            print("FirebaseClient logout error:", signOutError)
        }
    }
}
