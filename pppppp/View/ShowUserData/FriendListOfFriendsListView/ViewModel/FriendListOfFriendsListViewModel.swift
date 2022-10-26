import Foundation
import Combine

final class FriendListOfFriendsListViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()

    @Published var userData = [UserData]()
    @Published var friendId = String()
    @Published var friendIdOfFriend = String()
    @Published var isShowAlert = false
    @Published var addFriendView: Void = ()
    @Published var friendProfileView: Void = ()
    @Published var friendData = [UserData]()

    func sceneAddFriendView() {
        self.addFriendView = ()
    }

    func sceneFriendProfileView() {
        self.friendProfileView = ()
    }

    init(friendId: String) {
        self.friendId = friendId
    }

    func getFriendListOfList() {
        let task = Task {
            do {
                userData = try await FirebaseClient.shared.getFriendDataFromId(userId: friendId)
                friendData = try await FirebaseClient.shared.getProfileData(includeMe: false)
            } catch {
                print("FriendRequestViewModel getFriendRequest error: \(error.localizedDescription)")
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
}
