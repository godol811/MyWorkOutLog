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

class PermissionViewModel : ObservableObject{
    
    // 첫 화면에서 1회용으로 사용할 것이기 떄문에 UserDefaults를 사용합니다.
    @Published var permissionNotCompleted: Bool {
        didSet {
            DispatchQueue.main.async {
                UserDefaults.standard.set(self.permissionNotCompleted, forKey: "PermissionNotCompleted")
            }
        }
    }
    
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
            self.complete()
        }
    }
    
    
    
//    // 오디오 권한 요청
//    func requestAccessAudio() {
//        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { accessGranted in
//            self.requestMicrophonePermission()
//        })
//    }
//    // 마이크 권한 요청
//    func requestMicrophonePermission() {
//        AVAudioSession.sharedInstance().requestRecordPermission { granted in
//            DispatchQueue.main.async {
//                if granted {
//                    // 허용 되었을 때 필요한 부분 추가
//                    self.requestContact()
//                } else {
//                    // 허용거부 했을 때 필요한 부분 추가
//                    self.requestContact()
//                }
//            }
//        }
//    }
//    // 연락처 권한 요청
//    func requestContact() {
//        let status = CNContactStore.authorizationStatus(for: .contacts)
//        if status == .notDetermined {
//            CNContactStore().requestAccess(for: .contacts) { (authorized, error) in
//                if !authorized {
//                    // 허용 되었을 때 필요한 부분 추가
//                    self.complete()
//                }else {
//                    // 허용거부 했을 때 필요한 부분 추가
//                    self.complete()
//                }
//            }
//        }
//    }
    
    func complete() {
        DispatchQueue.main.async {
            self.permissionNotCompleted = false
            
        }
    }
    
    
    
}
