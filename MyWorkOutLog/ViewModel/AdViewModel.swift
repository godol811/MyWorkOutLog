//
//  ADViewModel.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/09.
//
import Foundation
import Combine

class AdViewModel: ObservableObject {
    @Published var showAd = false
    private var timer: AnyCancellable?

    init() {
        // 타이머를 생성하여 일정한 간격으로 showAd 변수를 업데이트합니다.
        timer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateShowAd()
            }
        updateShowAd()
    }

    func updateShowAd() {
        print("DDDD \(showAd)")
        if let lastAdDisplayTime = UserDefaults.standard.object(forKey: "lastAdDisplayTime") as? Date {
            let currentTime = Date()
            let minutesSinceLastAd = Calendar.current.dateComponents([.minute], from: lastAdDisplayTime, to: currentTime).minute ?? 0

            if minutesSinceLastAd >= 1 {
                showAd = true
            }
        } else {
            showAd = true
        }
    }

    func markAdDisplayed() {
        if showAd {
            UserDefaults.standard.set(Date(), forKey: "lastAdDisplayTime")
        }
    }
}
