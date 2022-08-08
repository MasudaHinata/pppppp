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

protocol FirebaseClientDelegate: AnyObject {
    func friendDeleted() async
  }

final class FirebaseClient {
    static let shared = FirebaseClient()
    weak var delegate: FirebaseClientDelegate?
    private init() {}
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
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
        //名前があるかどうかの判定
        let userID = user.uid
        let snapshot = try await self.db.collection("UserData").document(userID).getDocument()
        guard let user = try? snapshot.data(as: User.self) else {
            await LoginHelper.shared.showProfileNameViewController()
            throw FirebaseClientAuthError.firestoreUserDataNotCreated
            return
        }
    }
    
    //TODO: addsnapshotListener
    //IDを取得
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
    //IDから名前とか取得
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
    //IDからポイントを取得
    public func getIconDataFromId(friendIds: String) async throws -> UserIcon {
        let querySnapshot = try await db.collection("UserData").document(friendIds).collection("IconData").document("Icon").getDocument()
        do {
            let user = try querySnapshot.data(as: UserIcon.self)
            print(user)
            return user
        } catch {
            throw FirebaseClientFirestoreError.userDataNotFound
        }
    }
    //友達を削除する
    func deleteFriendQuery(deleteFriendId: String) async throws {
        var result = try await db.collection("UserData").document(user!.uid).collection("friendsList").document(deleteFriendId).delete()
        result = try await db.collection("UserData").document(deleteFriendId).collection("friendsList").document(user!.uid).delete()
        print("自分を友達のリストから削除しました")
        await self.delegate?.friendDeleted()
    }
    //ログアウトする
    func logout() async throws {
        let firebaseAuth = Auth.auth()
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
