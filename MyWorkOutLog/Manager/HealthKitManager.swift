//
//  File.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/10.
//

import Foundation
import HealthKit

class HealthKitManager {
    static var Shared = HealthKitManager()
    
    let healthStore = HKHealthStore()

    // 권한 요청
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthError.dataNotAvailable)
            return
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            print("AAA")
            completion(success, error)
        }
    }

    // 운동 기록 가져오기
    func fetchWorkouts(completion: @escaping ([HKWorkout]?, Error?) -> Void) {
//        let workoutPredicate = HKQuery.predicateForWorkouts(with: Any)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: .workoutType(), predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                completion(nil, error)
                return
            }
            completion(workouts, nil)
        }
        healthStore.execute(query)
    }
}

// 에러 처리를 위한 커스텀 에러 유형
enum HealthError: Error {
    case dataNotAvailable
}
