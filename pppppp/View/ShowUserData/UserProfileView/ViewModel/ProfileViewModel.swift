import Foundation
import Combine
import UIKit

final class ProfileViewModel: ObservableObject {

    enum AlertType {
        case deleteFriendWarning
        case deletedFriend
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var friendCount: Int = 0
    @Published var point: Int = 0
    @Published var iconImageURLStr = UserDefaults.standard.object(forKey: "IconImageURL") as? String ?? "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"
    @Published var name = UserDefaults.standard.object(forKey: "name") as? String ?? "名称未設定"
    @Published var pointDateStr = ""
    @Published var today = Date()
    
    @Published var pointDataList = [PointData]()
    @Published var layout = UICollectionViewFlowLayout()
    
    @Published var friendListView: Void = ()
    @Published var friendListOfFriendView: Void = ()
    @Published var changeProfileView: Void = ()
    @Published var settingView: Void = ()
    @Published var healthChartsView: Void = ()
    @Published var addFriendView: Void = ()
    @Published var dismissView: Void = ()

    @Published var userDataItem: UserData?
    @Published var meJudge = Bool()

    @Published var alertType: AlertType = .deleteFriendWarning
    @Published var showAlert = false

    init(userDataItem: UserData? = nil) {
        self.userDataItem = userDataItem

        let task = Task {
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                if userDataItem == nil {
                    meJudge = true
                } else if userDataItem?.id == userID {
                    meJudge = true
                } else {
                    meJudge = false
                }
            }
            catch {
                print("ProfileViewModel init error:",error.localizedDescription)
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
    
    func sceneFriendList() {
        self.friendListView = ()
    }

    func sceneFriendListOfFriend() {
        self.friendListOfFriendView = ()
    }

    func sceneChangeProfile() {
        self.changeProfileView = ()
    }

    func sceneSetting() {
        self.settingView = ()
    }

    func sceneHealthCharts() {
        self.healthChartsView = ()
    }

    func sceneAddFriend() {
        self.addFriendView = ()
    }

    func dismiss() {
        self.dismissView = ()
    }
    
    func getProfileData() {
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                //TODO: 上の二つ一緒
                if userDataItem == nil {
                    let friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                    self.friendCount = friendDataList.count
                    pointDataList = try await FirebaseClient.shared.getPointData(id: userID)
                    pointDataList.reverse()
                    let type = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
                    self.point = try await FirebaseClient.shared.getPointDataSum(id: userID, accumulationType: type as! String)
                    meJudge = true
                } else if userDataItem?.id == userID {
                    let friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                    self.friendCount = friendDataList.count
                    pointDataList = try await FirebaseClient.shared.getPointData(id: userID)
                    pointDataList.reverse()
                    let type = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
                    self.point = try await FirebaseClient.shared.getPointDataSum(id: userID, accumulationType: type as! String)
                    meJudge = true
                } else {
                    let friendDataList = try await FirebaseClient.shared.getFriendDataFromId(userId: userDataItem?.id ?? "")
                    self.friendCount = friendDataList.count
                    pointDataList = try await FirebaseClient.shared.getPointData(id: userDataItem?.id ?? "")
                    pointDataList.reverse()
                    let type = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
                    self.point = try await FirebaseClient.shared.getPointDataSum(id: userDataItem?.id ?? "", accumulationType: type as! String)
                    meJudge = false
                }
            }
            catch {
                print("ProfileViewModel getProfileData error:",error.localizedDescription)
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }

    func friendDelete() {
        let task = Task {
            do {
                guard let friendID = userDataItem?.id else { return }
                try await FirebaseClient.shared.deleteFriendQuery(deleteFriendId: friendID)
                alertType = .deletedFriend
                showAlert = true
            }
            catch {
                print("ProfileViewModel friendDelete error:",error.localizedDescription)
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
}
