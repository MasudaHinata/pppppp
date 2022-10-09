import Foundation
import Combine
import UIKit

final class ProfileViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var friendCount: Int = 0
    @Published var point: Int = 0
    @Published var iconImageURL = URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String)
    @Published var name = UserDefaults.standard.object(forKey: "name") as! String
    @Published var pointDateStr = ""
    
    @Published var pointDataList = [PointData]()
    @Published var layout = UICollectionViewFlowLayout() {
        didSet {
            layout.minimumLineSpacing = 4.5
            layout.minimumInteritemSpacing = 4.2
            layout.estimatedItemSize = CGSize(width: 17, height: 16)
        }
    }
    
    @Published var friendListView: Void = ()
    @Published var changeProfileView: Void = ()
    @Published var settingView: Void = ()
    @Published var shareMyData: Void = ()

    init() {
    }
    
    func sceneFriendList() {
        self.friendListView = ()
    }

    func sceneChangeProfile() {
        self.changeProfileView = ()
    }

    func sceneShareMyData() {
        self.shareMyData = ()
    }

    func sceneSetting() {
        self.settingView = ()
    }
    
    func getProfileData() {
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                try await FirebaseClient.shared.checkNameData()
                try await FirebaseClient.shared.checkIconData()
                
                let friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
                self.friendCount = friendDataList.count
                
                pointDataList = try await FirebaseClient.shared.getPointData(id: userID)
                pointDataList.reverse()
                
                let type = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
                self.point = try await FirebaseClient.shared.getPointDataSum(id: userID, accumulationType: type as! String)
            }
            catch {
                print("ProfileViewContro didAppear error:",error.localizedDescription)
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
}
