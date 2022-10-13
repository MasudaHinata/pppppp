import Foundation
import Combine
import UIKit

final class HealthChartsViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()

    @Published var chartsStepItem = [ChartsStepItem]()
    @Published var chartsWeightItem = [ChartsWeightItem]()
    @Published var workoutDataItem = [WorkoutData]()
    @Published var weightGoalStr: String?

    @Published var averageStep: Int!
    @Published var lastWeightStr: String!

    init() {
    }

    func getHealthData(period: String, weightPeriod: String) {
        let task = Task {
            do {
                var averagePeriod = 0
                if period == "week" {
                    averagePeriod = 6
                } else if period == "month" {
                    averagePeriod = 30
                } else {
                    averagePeriod = 364
                }
                averageStep = try await HealthKit_ScoreringManager.shared.getAverageStep(date: Double(averagePeriod))

                chartsStepItem = try await HealthKit_ScoreringManager.shared.getStepsChart(period: period)
                chartsStepItem.reverse()

                let lastWeight = try await HealthKit_ScoreringManager.shared.getWeight()
                lastWeightStr = String(format: "%.2f", round(lastWeight * 10) / 10)
                chartsWeightItem = try await HealthKit_ScoreringManager.shared.getWeightData(period: weightPeriod)
                chartsWeightItem.reverse()

                let userID = try await FirebaseClient.shared.getUserUUID()
                let userData: [UserData] = try await FirebaseClient.shared.getUserDataFromId(userId: userID)
                weightGoalStr = String(format: "%.2f", round((userData.last?.weightGoal ?? 0) * 10) / 10)

                //TODO: chartsWeightItemが空だったらlabel出す
            }
            catch {
                print("HealthChartsViewModel getHealthData error:", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }

    func segmentIndexChanged(newValue: String) {
        let task = Task {
            do {
                chartsStepItem = try await HealthKit_ScoreringManager.shared.getStepsChart(period: newValue)
                chartsStepItem.reverse()
            }
            catch {
                print("HealthChartsViewModel error:", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }

    func segmentIndexChangeStepCount(newValue: String) {
        let task = Task {
            do {
                var averagePeriod = 0
                if newValue == "month" {
                    averagePeriod = 29
                } else if newValue == "year" {
                    averagePeriod = 364
                } else {
                    averagePeriod = 6
                }
                averageStep = try await HealthKit_ScoreringManager.shared.getAverageStep(date: Double(averagePeriod))
            }
            catch {
                print("HealthChartsViewModel error:", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }

    func weightSegmentIndexChanged(newValue: String) {
        let task = Task {
            do {
                chartsWeightItem = try await HealthKit_ScoreringManager.shared.getWeightData(period: newValue)
                chartsWeightItem.reverse()
            }
            catch {
                print("HealthChartsViewModel weightSegmentIndexChanged error:", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }

}
