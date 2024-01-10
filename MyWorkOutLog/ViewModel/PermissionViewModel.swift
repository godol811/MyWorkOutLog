//
//  PermissionViewModel.swift
//  PermissionTest
//
//  Created by 고종찬 on 2023/12/01.
//

import Foundation
import AVFoundation
import Photos
import PhotosUI
import Contacts
import HealthKit

class PermissionViewModel : ObservableObject{
    
    @Published var workouts: [HKWorkout] = []
    // 첫 화면에서 1회용으로 사용할 것이기 떄문에 UserDefaults를 사용합니다.
    @Published var permissionNotCompleted: Bool {
        didSet {
            DispatchQueue.main.async {
                UserDefaults.standard.set(self.permissionNotCompleted, forKey: "PermissionNotCompleted")
            }
        }
    }
    
//    private var healthKitManager = HealthKitManager.Shared
    let healthStore = HKHealthStore()
    init() {
        // UserDefaults에서 값을 가져오고, 값이 없으면 true로 설정합니다.
        self.permissionNotCompleted = UserDefaults.standard.object(forKey: "PermissionNotCompleted") as? Bool ?? true
    }
    
    // 권한 요청 시작
    func requestPermission() {
        requestAccessCamera()
    }
    // 카메라 권한 요청
    func requestAccessCamera(){
        AVCaptureDevice.requestAccess(for: .video) { granted in
            self.requestAccessAlbum()
        }
    }
    // 엘범 권한 요청
    func requestAccessAlbum(){
        PHPhotoLibrary.requestAuthorization(){ granted in
            switch granted {
            case .authorized:
                // 허용 되었을 때 필요한 부분 추가
                print("Album: 권한 허용")
            case .denied:
                // 허용거부 했을 때 필요한 부분 추가
                print("Album: 권한 거부")
            case .restricted, .notDetermined:
                print("Album: 선택하지 않음")
            default:
                break
            }
            self.requestAccessNotification()
        }
    }
    func requestAccessNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("설정 완료!")
            } else if let error = error {
                print(error.localizedDescription)
            }
            
            
                    }
    }
    
    
    func requestHeathKit() {
        self.requestHealthKitAuthorization(){ [self] (success, error) in
            if success{
                fetchWorkouts(){ (workouts, error) in
                    print("AAA\(workouts?.first?.totalEnergyBurned?.doubleValue(for: .kilocalorie()))")
                }
            }
        }
        self.complete()

    }
    
    func complete() {
        DispatchQueue.main.async {
            self.permissionNotCompleted = false
            
        }
    }
    
    
    
    
    // 헬스킷
//    func fetchWorkouts() {
//        healthKitManager.fetchWorkouts { [weak self] workouts, error in
//            DispatchQueue.main.async {
//                print("오홍\(workouts?.debugDescription) 에러??\(error)")
//                if let workouts = workouts {
//                    self?.workouts = workouts
//                    for i in workouts{
//                        print("오홍 \(i.totalEnergyBurned?.doubleValue(for: .kilocalorie()))")
//                    }
//                } else {
//                    // 에러 처리
//                }
//            }
//        }
//    }
//    
    
  

    // 권한 요청
    func requestHealthKitAuthorization(completion: @escaping (Bool, Error?) -> Void) {
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
