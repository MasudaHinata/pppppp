import Foundation
import Combine
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

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

protocol FirebaseDeleteAccountDelegate: AnyObject {
    func accountDeleted()
    func faildAcccountDelete()
    func faildAcccountDeleteData()
}

protocol FirebasePutPointDelegate: AnyObject {
    func putPointForFirestore(point: Int)
    func notGetPoint()
}

protocol FirebaseSentEmailDelegate: AnyObject {
    func sendEmail()
}

final class FirebaseClient {
    static let shared = FirebaseClient()
    weak var deletefriendDelegate: FirebaseClientDeleteFriendDelegate?
    weak var loginDelegate: FirebaseClientAuthDelegate?
    weak var emailVerifyDelegate: FirebaseEmailVarifyDelegate?
    weak var notChangeDelegate: FireStoreCheckNameDelegate?
    weak var createdAccountDelegate: FirebaseCreatedAccountDelegate?
    weak var deleteAccountDelegate: FirebaseDeleteAccountDelegate?
    weak var putPointDelegate: FirebasePutPointDelegate?
    weak var sentEmailDelegate: FirebaseSentEmailDelegate?
    private init() {}
    
    var cancellables = Set<AnyCancellable>()
    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    let calendar = Calendar.current
    let date = Date()
    let formatter = DateFormatter()
    
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
            try await checkIconData()
            try await checkNameData()
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
    }
    //ポイントをFirestoreに保存
    func firebasePutData(point: Int) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.userAuthCheck()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMdHHmm", options: 0, locale: Locale(identifier: "en_US"))
        
        if point == 0 {
            try await db.collection("User").document(userID).collection("HealthData").document("\(formatter.string(from: date))").setData(["point": point, "date": Timestamp(date: Date())])
            self.putPointDelegate?.notGetPoint()
        } else {
            try await db.collection("User").document(userID).collection("HealthData").document("\(formatter.string(from: date))").setData(["point": point, "date": Timestamp(date: Date())])
            self.putPointDelegate?.putPointForFirestore(point: point)
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
                self.deleteAccountDelegate?.faildAcccountDeleteData()
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
            self.deleteAccountDelegate?.accountDeleted()
        }
        catch {
            self.deleteAccountDelegate?.faildAcccountDelete()
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
}
