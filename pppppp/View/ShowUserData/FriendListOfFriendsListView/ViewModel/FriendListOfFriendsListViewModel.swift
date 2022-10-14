import Foundation
import Combine

final class FriendListOfFriendsListViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()

    @Published var userData = [UserData]()
    @Published var friendId = String()

    init(friendId: String) {
        self.friendId = friendId
    }

    func getFriendListOfList() {
        let task = Task {
            do {
                userData = try await FirebaseClient.shared.getFriendDataFromId(userId: friendId)
            } catch {
                print("FriendRequestViewModel getFriendRequest error: \(error.localizedDescription)")
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
}
