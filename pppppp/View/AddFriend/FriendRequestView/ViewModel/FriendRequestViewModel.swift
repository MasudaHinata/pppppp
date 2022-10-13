import Foundation
import UIKit
import Combine

final class FriendRequestViewModel: ObservableObject, AddFriendDelegate {

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

    //MARK: - Setting Delegate
    func addFriends() {
//        let alert = UIAlertController(title: "完了", message: "友達を追加しました", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
//            let mainVC = StoryboardScene.Main.initialScene.instantiate()
//            self.showDetailViewController(mainVC, sender: self)
//        }
//        alert.addAction(ok)
//        DispatchQueue.main.async {
//            self.present(alert, animated: true, completion: nil)
//        }
    }
}
