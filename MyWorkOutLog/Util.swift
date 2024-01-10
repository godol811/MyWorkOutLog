//
//  Util.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/03.
//

import Foundation
import UIKit
import SwiftUI

func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
// 날짜 포맷터 함수
func dateFormattedLocalized(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long // 현지화된 긴 날짜 형식 사용
    formatter.timeStyle = .none // 시간은 표시하지 않음
    return formatter.string(from: date)
}
func loadData(from videoURL: URL) -> Data? {
    do {
        // URL에서 Data 객체를 생성
        let data = try Data(contentsOf: videoURL)
        return data
    } catch {
        print("데이터 로딩 실패: \(error)")
        return nil
    }
}

func saveDataToFile(data: Data, withFileName fileName: String) -> URL? {
    let fileManager = FileManager.default

    // 'Documents' 디렉토리 경로를 찾습니다.
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Documents 디렉토리를 찾을 수 없습니다.")
        return nil
    }

    // 파일의 최종 경로를 설정합니다.
    let fileURL = documentsDirectory.appendingPathComponent(fileName)

    // 파일이 이미 존재하는 경우 삭제
      if fileManager.fileExists(atPath: fileURL.path) {
          do {
              try fileManager.removeItem(at: fileURL)
          } catch {
              print("Error removing existing file: \(error)")
              return nil
          }
      }

      do {
          try data.write(to: fileURL)
          return fileURL
      } catch {
          print("Error saving file: \(error)")
          return nil
      }
}


func convertDateToDateComponents(date: Date) -> DateComponents {
    var calendar = Calendar.current

     // 캘린더의 로케일과 시간대를 설정합니다.
     calendar.locale = Locale(identifier: "en_KR")
     calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
     calendar.firstWeekday = 1
     calendar.minimumDaysInFirstWeek = 1

     // 변환하고자 하는 구성 요소를 정의합니다.
     let components: Set<Calendar.Component> = [.era, .year, .month, .day,  .calendar]

     // Date를 DateComponents로 변환합니다.
     let dateComponents = calendar.dateComponents(components, from: date)

     return dateComponents
}

func convertDateComponentsToDate(dateComponents: DateComponents?) -> Date? {
    // 사용할 캘린더를 정의합니다. 기본적으로 현재 캘린더를 사용합니다.
    let calendar = Calendar.current
    let components: Set<Calendar.Component> = [.era, .year, .month, .day,  .calendar]
    let temp = calendar.dateComponents(components, from: Date())
    // DateComponents를 Date로 변환합니다.
    let date = calendar.date(from: dateComponents ?? temp)

    return date
}

func areDatesEqualInYearMonthDay(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current

    // 첫 번째 날짜의 년, 월, 일을 추출합니다.
    let components1 = calendar.dateComponents([.year, .month, .day], from: date1)

    // 두 번째 날짜의 년, 월, 일을 추출합니다.
    let components2 = calendar.dateComponents([.year, .month, .day], from: date2)

    // 년, 월, 일을 비교합니다.
    return components1.year == components2.year && components1.month == components2.month && components1.day == components2.day
}

extension String {
    func colorForCondition() -> Color {
        switch self {
        case "보통", "Normal":
            return .green
        case "어려움", "Hard":
            return .red
        default:
            return .mint
        }
    }
}

extension String {
    var localized: String {
        return NSLocalizedString (self, comment: "")
    }
}

func saveImageToDocumentDirectory(image: UIImage) -> URL? {
    // UIImage를 JPEG 데이터로 변환 (PNG도 가능)
    guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }

    // 파일 이름 생성 (현재 날짜와 시간을 사용하여 고유한 이름을 만듭니다)
    let fileName = "savedImage_\(Date().timeIntervalSince1970).jpg"
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

    // 파일 시스템에 이미지 데이터 저장
    do {
        try imageData.write(to: fileURL)
        return fileURL
    } catch {
        print("Error saving image: \(error)")
        return nil
    }
}

// 초를 분:초 형식으로 변환하는 함수
func secondsToTimeString(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return "\(minutes):\(String(format: "%02d", remainingSeconds))"
}
