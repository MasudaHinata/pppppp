import Foundation
import UIKit
import Combine

final class FriendRequestViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    @Published var userData = [UserData]()
    @Published var isShowAlert = false

    init() {
    }

    //MARK: - 友達リクエストを取得する
    func getFriendRequest() {
        let task = Task {
            do {
                userData = try await FirebaseClient.shared.getFriendRequest()
            } catch {
                print("FriendRequestViewModel getFriendRequest error: \(error.localizedDescription)")
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }

    //MARK: - 友達リクエストを承認する
    func addFriend(friendId: String) {
        let task = Task {
            do {
                try await FirebaseClient.shared.addFriend(friendId: friendId)
                isShowAlert = true
            } catch {
                print("FriendRequestViewModel getFriendRequest error: \(error.localizedDescription)")
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }

    //MARK: - 友達リクエストを削除する
    func deleteFriendRequest(friendId: String) {
        let task = Task {
            do {
                try await FirebaseClient.shared.deleteFriendRequest(friendId: friendId)
                userData = try await FirebaseClient.shared.getFriendRequest()
            } catch {
                print("FriendRequestViewModel getFriendRequest error: \(error.localizedDescription)")
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
}
