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
//                userData = try await FirebaseClient.shared.
            } catch {
                
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
}
