import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

//MARK: - Error
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
}
protocol FirebaseEmailVarifyDelegate: AnyObject {
    func emailVerifyRequiredAlert()
}

@MainActor
protocol FireStoreCheckNameDelegate: AnyObject {
    func notChangeName()
}

protocol SetttingAccountDelegate: AnyObject {
    func accountDeleted()
    func faildAcccountDelete()
    func faildAcccountDeleteData()
    func logoutCompleted()
}

protocol FirebasePutPointDelegate: AnyObject {
    func putPointForFirestore(point: Int, activity: String)
    func notGetPoint()
}

protocol FirebaseSentEmailDelegate: AnyObject {
    func sendEmail()
}

protocol FirebaseAddFriendDelegate: AnyObject {
    func addFriends()
    func friendNotFound()
}

final class FirebaseClient {
    static let shared = FirebaseClient()
    weak var deletefriendDelegate: FirebaseClientDeleteFriendDelegate?
    weak var loginDelegate: FirebaseClientAuthDelegate?
    weak var emailVerifyDelegate: FirebaseEmailVarifyDelegate?
    weak var notChangeDelegate: FireStoreCheckNameDelegate?
    weak var SettingAccountDelegate: SetttingAccountDelegate?
    weak var putPointDelegate: FirebasePutPointDelegate?
    weak var sentEmailDelegate: FirebaseSentEmailDelegate?
    weak var addFriendDelegate: FirebaseAddFriendDelegate?
    private init() {}
    
    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    let calendar = Calendar.current
    let date = Date()
    var cancellables = Set<AnyCancellable>()
    
    //MARK: - FireStore Read
    
    //MARK: - UUIDをとる
    func getUserUUID() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            try await self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        return userID
    }
    //MARK: - 自分と友達のProfile,Pointデータを取得
    public func getProfileData(includeMe: Bool) async throws -> [UserData] {
        guard let user = Auth.auth().currentUser else {
            try await self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await db.collection("User").whereField("FriendList", arrayContains: userID).getDocuments()
        var users = try querySnapshot.documents.map { try $0.data(as: UserData.self) }
        if includeMe {
            try await FirebaseClient.shared.checkNameData()
            try await FirebaseClient.shared.checkIconData()
            let myData = try (try await db.collection("User").document(userID).getDocument()).data(as: UserData.self)
            users.append(myData)
        }
        
        for i in 0 ..< users.count {
            let type = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
            users[i].point = try await getPointDataSum(id: users[i].id!, accumulationType: type as! String)
        }
        users.sort { $1.point! < $0.point! }
        return users
    }
    
    //MARK: - idで与えられたユーザーの累積ポイントを返す
    func getPointDataSum(id: String, accumulationType: String) async throws -> Int {
        var startDate = Date()
        if accumulationType == "今日までの一週間" {
            //今日までの一週間
            startDate = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: date))!
        } else if accumulationType == "月曜始まり" {
            //月曜からの一週間
            let am = calendar.startOfDay(for: Date())
            let weekNumber = calendar.component(.weekday, from: am)
            if weekNumber == 1 {
                startDate = calendar.date(byAdding: .day, value: -6, to: am)!
            } else {
                startDate = calendar.date(byAdding: .day, value: -(weekNumber - 2), to: am)!
            }
        }
        
        let snapshot = try await db.collection("User").document(id).collection("HealthData").whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate)).whereField("date", isLessThanOrEqualTo: Timestamp(date: Date())).getDocuments()
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
    
    //MARK: - idで与えられたユーザーのポイント履歴を取得する
    func getPointData(id: String) async throws -> [PointData] {
        let snapshot = try await db.collection("User").document(id).collection("HealthData").whereField("date", isLessThanOrEqualTo: Timestamp(date: Date())).getDocuments()
        return try snapshot.documents.map { try $0.data(as: PointData.self) }
    }
    
    //MARK: - 自分の今までのポイントを取得する
    func getTotalPoint() async throws -> Int{
        guard let user = Auth.auth().currentUser else {
            try await self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let snapshot = try await db.collection("User").document(userID).collection("HealthData").whereField("date", isLessThanOrEqualTo: Timestamp(date: Date())).getDocuments()
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
    
    //MARK: - 友達と自分の投稿を取得する
    func getPointActivityPost() async throws -> [PostDisplayData] {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        try await user.reload()
        try await FirebaseClient.shared.checkNameData()
        try await FirebaseClient.shared.checkIconData()
        let userID = user.uid
        var postDataItem = [PostDisplayData]()
        
        let querySnapshot = try await db.collection("User").whereField("FriendList", arrayContains: userID).getDocuments()
        var userDataList = try querySnapshot.documents.map { try $0.data(as: UserData.self) }
        userDataList.append(try (try await db.collection("User").document(userID).getDocument()).data(as: UserData.self))
        
        //FIXME: IDを10個ずつに分けて.whereField("userID", in: userIdList)にする(forやめる)
        let userIdList = userDataList.map { $0.id }
        for userId in userIdList {
            let snapshot = try await db.collection("Post").whereField("userID", isEqualTo: userId!).getDocuments()
            let postDataList = try snapshot.documents.map { try $0.data(as: PostData.self) }
            
            for postData in postDataList {
                if let user = userDataList.first{ $0.id == postData.userID } {
                    let postData = PostDisplayData(id : postData.id,userID: user.id!, date: postData.date, activity: postData.activity, point: postData.point, name: user.name, iconImageURL: URL(string: user.iconImageURL)!)
                    postDataItem.append(postData)
                }
            }
            postDataItem = postDataItem.sorted(by: { (a, b) -> Bool in return a.date > b.date })
        }
        return postDataItem
    }
    
    //MARK: - 自分の投稿にいいねした友達を取得
    func getPostLikeFriend(postId: String) async throws -> [UserData] {
        let querySnapShot = try await db.collection("Post").document(postId).getDocument()
        guard querySnapShot.data()!["likeFriendList"] != nil else {
            return []
        }
        
        let likeFriendIdList: [String] = querySnapShot.data()!["likeFriendList"] as! [String]
        var likeFriendData = [UserData]()
        for likeFriendId in likeFriendIdList {
            let snapshot = try await db.collection("User").document(likeFriendId).getDocument()
            likeFriendData.append(UserData(name: snapshot.data()!["name"]! as! String, iconImageURL: snapshot.data()!["IconImageURL"]! as! String))
        }
        print(likeFriendData)
        return likeFriendData
    }
    
    //MARK: - 自分の名前を取得する
    func getMyNameData() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await checkNameData()
        let querySnapShot = try await db.collection("User").document(userID).getDocument()
        let data = querySnapShot.data()!["name"]!
        return data as! String
    }
    
    //MARK: - 自分のアイコンを取得する
    func getMyIconData() async throws -> URL {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await checkIconData()
        let querySnapShot = try await db.collection("User").document(userID).getDocument()
        let url = URL(string: querySnapShot.data()!["IconImageURL"]! as! String)!
        return url
    }
    
    //MARK: - 友達の名前を取得する
    func getFriendNameData(friendId: String) async throws -> String {
        let querySnapShot = try await db.collection("User").document(friendId).getDocument()
        var data: String!
        if querySnapShot.data() == nil {
            throw FirebaseClientFirestoreError.userDataNotFound
        } else {
            data = querySnapShot.data()!["name"]! as? String
        }
        return data!
    }
    
    //MARK: - 友達のアイコンを取得する
    func getFriendIconData(friendId: String) async throws -> URL {
        let querySnapShot = try await db.collection("User").document(friendId).getDocument()
        let url = URL(string: querySnapShot.data()!["IconImageURL"]! as! String)!
        return url
    }
    
    //MARK: - FireStore Write
    
    //MARK: - UserDataをFirestoreに保存
    func setUserData() async throws {
        guard let user = Auth.auth().currentUser else {
            try await self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).setData(["name": "名称未設定", "IconImageURL": "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"])
        UserDefaults.standard.set("名称未設定", forKey: "name")
        UserDefaults.standard.set("https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11", forKey: "IconImageURL")
    }
    
    //MARK: - ポイントをFirestoreに保存
    func firebasePutData(point: Int, activity: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        if point == 0 {
            try await db.collection("User").document(userID).collection("HealthData").document().setData(["point": point, "date": Timestamp(date: Date()), "activity": activity])
            self.putPointDelegate?.notGetPoint()
        } else {
            try await db.collection("User").document(userID).collection("HealthData").document().setData(["point": point, "date": Timestamp(date: Date()), "activity": activity])
            try await FirebaseClient.shared.putPointActivityPost(point: point, activity: activity)
            self.putPointDelegate?.putPointForFirestore(point: point, activity: activity)
        }
    }
    
    //MARK: - 画像をfirestore,firebaseStorageに保存
    func putFirebaseStorage(selectImage: UIImage) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        let reference = Storage.storage().reference().child("posts/\(imageName)")
        if let imageData = selectImage.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            try await reference.putDataAsync(imageData, metadata: metadata)
            let downloadUrl: URL = try await reference.downloadURL()
            let downloadUrlStr = downloadUrl.absoluteString
            try await self.db.collection("User").document(userID).updateData(["IconImageURL": downloadUrlStr])
            UserDefaults.standard.set(downloadUrlStr, forKey: "IconImageURL")
        }
    }
    
    //MARK: - 名前をfirestoreに保存
    func putNameFirestore(name: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["name": name])
        UserDefaults.standard.set(name, forKey: "name")
    }
    
    //MARK: - 自己評価をfirebaseに保存
    func putSelfCheckLog(log: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).collection("SelfCheckLog").document().setData(["log": log, "date": Timestamp(date: Date())])
    }
    
    //MARK: - Pointを獲得したらTimelineに投稿する
    func putPointActivityPost(point: Int, activity: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        if point != 0 {
            try await db.collection("Post").document().setData(["userID": userID, "date": Timestamp(date: Date()), "activity": activity, "point": point])
        }
    }
    
    //MARK: - 友達の投稿へのいいねを保存
    func putGoodFriendsPost(postId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        
        try await db.collection("Post").document(postId).updateData(["likeFriendList": FieldValue.arrayUnion([userID])])
    }
    
    //MARK: - 友達の投稿へのいいねを取り消し
    func putGoodCancelFriendsPost(postId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        
        try await db.collection("Post").document(postId).updateData(["likeFriendList": FieldValue.arrayRemove([userID])])
    }
    
    //MARK: - 友達を追加する
    func addFriend(friendId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["FriendList": FieldValue.arrayUnion([friendId])])
        try await db.collection("User").document(friendId).updateData(["FriendList": FieldValue.arrayUnion([userID])])
        self.addFriendDelegate?.addFriends()
    }
    
    //MARK: - 友達を削除する
    func deleteFriendQuery(deleteFriendId: String) async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        try await db.collection("User").document(userID).updateData(["FriendList": FieldValue.arrayRemove([deleteFriendId])])
        try await db.collection("User").document(deleteFriendId).updateData(["FriendList": FieldValue.arrayRemove([userID])])
        await self.deletefriendDelegate?.friendDeleted()
    }
    
    //MARK: - 友達のFriendListから自分を削除する
    func deleteMeFromFriend() async throws  {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let querySnapshot = try await db.collection("User").whereField("FriendList",arrayContains: userID).getDocuments()
        for document in querySnapshot.documents {
            try await db.collection("User").document(document.documentID).updateData(["FriendList": FieldValue.arrayRemove([userID])])
        }
    }
    
    //MARK: - 自分のデータを全削除する
    func accountDelete() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try? await deleteMeFromFriend()
                try await db.collection("User").document(userID).delete()
                try await deleteAccount()
            }
            catch {
                self.SettingAccountDelegate?.faildAcccountDeleteData()
                print("firebaseClient accountDelete error", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    //MARK: - FireStore Check
    
    //MARK: - ログインできてるか・メール認証ができてるかの判定
    func checkUserAuth() async throws {
        guard let user = Auth.auth().currentUser else {
            await LoginHelper.shared.showAccountViewController()
            return
        }
        if user.isEmailVerified == false {
            self.emailVerifyDelegate?.emailVerifyRequiredAlert()
        }
        try await user.reload()
    }
    
    //MARK: - 名前があるかどうかの判定
    @MainActor
    func checkNameData() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
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
    
    //MARK: - アイコンがあるかどうかの判定
    func checkIconData() async throws {
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
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
    
    //MARK: - 今日の歩数ポイントがあるかどうかの判定
    func checkCreateStepPoint() async throws -> Bool {
        let judge: Bool!
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let startDate = calendar.startOfDay(for: Date())
        let snapshot = try await db.collection("User").document(userID).collection("HealthData").whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate)).whereField("activity", isEqualTo: "Steps").getDocuments()
        guard snapshot.documents != [] else {
            judge = true
            return judge
        }
        judge = false
        return judge
    }
    
    //MARK: - 今日の自己評価をしたかどうかの判定
    func checkSelfCheck() async throws -> Bool {
        let judge: Bool!
        guard let user = Auth.auth().currentUser else {
            try await  self.checkUserAuth()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
        }
        let userID = user.uid
        let startDate = calendar.startOfDay(for: Date())
        let snapshot = try await db.collection("User").document(userID).collection("HealthData").whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate)).whereField("activity", isEqualTo: "SelfCheck").getDocuments()
        guard snapshot.documents != [] else {
            judge = true
            return judge
        }
        judge = false
        return judge
    }
    
    //MARK: - Firebase Authentication
    
    //MARK: - Email サインインする
    @MainActor
    func signInWithEmail(email: String, password: String) async throws {
        let authReault = try await firebaseAuth.signIn(withEmail: email, password: password)
        if authReault.user.isEmailVerified {
            self.loginDelegate?.loginScene()
        }
    }
    
    //MARK: - Email パスワードを再設定する
    func resetPassword(email: String) async throws{
        try await firebaseAuth.sendPasswordReset(withEmail: email)
        self.sentEmailDelegate?.sendEmail()
    }
    
    //MARK: - SignInWithApple
    func signInWithApple() async throws {
        //TODO: SignInWithAppleViewControllerから移行
    }
    
    //MARK: - サインアウトする
    func signout() async throws {
        do {
            try firebaseAuth.signOut()
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            self.SettingAccountDelegate?.logoutCompleted()
        } catch let signOutError as NSError {
            print("FirebaseClient logout error:", signOutError)
        }
    }
    
    //MARK: - アカウントを削除
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            try await self.checkUserAuth()
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
}
