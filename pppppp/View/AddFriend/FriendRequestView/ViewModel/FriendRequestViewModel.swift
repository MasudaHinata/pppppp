import Foundation
import Combine

final class FriendRequestViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    @Published var userData = [UserData]()

    init() {
    }

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
    func sendFriendRequest(friendId: String) {
        let task = Task {
            do {
                try await FirebaseClient.shared.addFriend(friendId: friendId)
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
            } catch {
                print("FriendRequestViewModel getFriendRequest error: \(error.localizedDescription)")
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
}
