//
//  WorkoutAddView.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/02.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI
import SwiftData

struct WorkoutAddView: View {
    @State private var title = String(format: NSLocalizedString("운동 제목", comment: ""), dateFormattedLocalized(Date()))
    @State private var content = ""
    @State private var hashTagText = ""
    @State private var hashTagArray: [String] = []
    @State private var selectedCondition: String = "쉬움"
    @State private var showPhotoPicker: Bool = false
    @State private var showFillAlert: Bool = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var image: UIImage? = nil
    @State private var alertMessage = ""
    
    @Binding var showWorkoutAddView:Bool
    @State private var autoCompleteTags = [String]()
    @State private var isShowingAutoComplete = false
    @State private var hashTagTextWidth:Double = 0.0
    
    @State private var selectedMinutes: Int = 5
    @State private var selectedSeconds: Int = 30
    
    @Query var workoutHistories : [WorkoutHistory]
    @Environment(\.modelContext) private var modelContext
    @StateObject var vm = PhotoSelectorViewModel()
    
    let maxPhotosToSelect = 10
    let conditions = ["쉬움","보통","어려움"]
    
    var body: some View {
        NavigationStack{
            BannerView()
                .frame(height:60)
            ScrollView{
                VStack{
                    TextField("제목", text: $title)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .opacity(0.1)
                        )
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("오늘 무슨 운동을 하셨나요?".localized)
                                .foregroundColor(Color.gray)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 12)
                        }
                        TextEditor(text: $content)
                            .padding(5)
                            .scrollContentBackground(.hidden) // <- Hide it
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.1)) // 여기를 변경함
                            )
                            .frame(minHeight: 200)
                    }
                    HStack{
                        Text("운동 시간")
                        Spacer()
                        Group{
                            Picker("분", selection: $selectedMinutes) {
                                ForEach(0..<60) {
                                    Text("\($0)분").tag($0)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white) // 여기를 변경함
                            )
                            .pickerStyle(DefaultPickerStyle())
                            .accentColor(.black) // 여기에 Tint 색상을 추가함
                           
                            Picker("초", selection: $selectedSeconds) {
                                ForEach(0..<60) {
                                    Text("\($0)초").tag($0)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white) // 여기를 변경함
                            )
                            .pickerStyle(DefaultPickerStyle())
                            .accentColor(.black) // 여기에 Tint 색상을 추가함
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .opacity(0.1)
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.1)) // 여기를 변경함
                    )
                    Picker(selection: $selectedCondition, label: Text("얼마나 힘들었나요?".localized)) {
                        ForEach(conditions, id:\.self){ condition in
                            Text(condition.localized).tag(condition)
                                .onTapGesture{
                                    selectedCondition = condition
                                }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                        VStack{
                            ZStack(alignment: .leading){
                                TextWidthView(text: $hashTagText, textWidth: $hashTagTextWidth)
                                TextField("스페이스바를 눌러 해시태그를 넣어보세요 (최대 10개)".localized, text: $hashTagText)
                                    .overlay{
                                        HStack{
                                            if isShowingAutoComplete {
                                                HStack{
                                                    Text("#\(autoCompleteTags.first ?? "")")
                                                        .font(.footnote)
                                                        .onTapGesture {
                                                            selectAutoCompleteTag(autoCompleteTags.first ?? "")
                                                        }
                                                        
                                                    Button(action: {
                                                        isShowingAutoComplete = false
                                                        autoCompleteTags.removeAll()
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                                .padding(5)
                                                .background(Color.gray) // 배경색
                                                .foregroundColor(.white) // 텍스트 색상
                                                .cornerRadius(20) // 코너 반경으로 캡슐 형태 만들기
                                                .offset(x: hashTagTextWidth + 2)
                                                
                                            }
                                            Spacer()
                                        }
                                        
                                    }
                                    .onChange(of: hashTagText) { _, newValue in
                                        updateAutoCompleteTags(with: newValue)
                                    }
                                
                                    .font(.footnote)
                                    .onSubmit{
                                        checkForSubmit(hashTagText)
                                    }
                                    .onChange(of: hashTagText){_,_ in
                                        checkForSpace(hashTagText)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .opacity(0.1)
                                    )
                            }
                          
                            ScrollView(.horizontal){
                                ScrollViewReader { scrollView in
                                    HStack{
                                        ForEach(hashTagArray, id: \.self) { tag in
                                            HStack {
                                                Text("#\(tag)")
                                                    .font(.footnote)
                                                Button(action: {
                                                    self.removeTag(tag)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .padding(8) // 적절한 패딩 값
                                            .background(Color.gray) // 배경색
                                            .foregroundColor(.white) // 텍스트 색상
                                            .cornerRadius(20) // 코너 반경으로 캡슐 형태 만들기
                                        }
                                        
                                    }//HSTACK
                                    .id("lastHashTagItem")
                                    .onChange(of: hashTagArray){ _ ,_ in
                                        withAnimation{
                                            scrollView.scrollTo("lastHashTagItem", anchor: .trailing)
                                        }
                                    }
                                }// SCROLLVIEWREADER
                            }
                        }
                        
                   
                  
                  
                    
                } // VSTACK
                .padding()
                .alert(isPresented: $showFillAlert) {
                    Alert(title: Text("오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading, content: {
                        Button(action: {
                            showWorkoutAddView.toggle()
                        }, label: {
                            Text("뒤로가기".localized)
                        })
                    })
                    
                    ToolbarItem {
                        Button(action: addItem) {
                            Text("저장하기".localized)
                                .font(.headline)
                        }
                    }
                }
                
                ScrollView(.horizontal){
                    LazyHStack {
                        ForEach(0..<vm.thumbnailImages.count, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                ZStack{
                                    Image(uiImage: vm.thumbnailImages[index].image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 300)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    if vm.thumbnailImages[index].type == .video{
                                        Image(systemName: "video.circle.fill")
                                            .renderingMode(.original)
                                            .tint(Color.white)
                                    }
                                }
                                Button(action: {
                                    withAnimation{
                                        vm.removeImage(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .background(
                                            Circle()
                                                .foregroundStyle(.white)
                                        )
                                        .foregroundColor(.red)
                                        .padding(5) // 버튼과 이미지의 가장자리 사이에 여유 공간을 추가
                                }
                                .offset(x: 10, y: -10)
                            }
                        }
                    }// LAZYHSTACK
                    .padding()
                }// SCROLLVIEW
                .padding(.horizontal)
                
                PhotosPicker(
                    selection: $vm.selectedPhotos,
                    selectionBehavior: .ordered, // ensures we get the photos in the same order that the user selected them
                    matching: .any(of: [.images, .videos])// filter the photos library to only show images
                ){
                    Text("사진/비디오 추가 하기".localized)
                        .font(.caption2)
                    Image(systemName: "photo.stack")
                }
            }
            .onChange(of: vm.selectedPhotos) { _, _ in
                vm.convertDataToImage()
            }
            
            
        }
        .toolbar(.hidden, for: .tabBar)
        .onTapGesture{
            hideKeyboard()
        }
    }
    
    private func checkForSubmit(_ text: String) {
        let newWord = text.trimmingCharacters(in: .whitespaces)
        if !newWord.isEmpty {
            if !hashTagArray.contains(newWord){
                hashTagArray.append(newWord)
            }
            hashTagText = ""
        }
    }
    
    
    private func checkForSpace(_ text: String) {
        if text.last == " " {
            let newWord = text.trimmingCharacters(in: .whitespaces)
            if !newWord.isEmpty {
                if !hashTagArray.contains(newWord){
                    hashTagArray.append(newWord)
                }
                hashTagText = ""
            }
        }
    }
    private func removeTag(_ tag: String) {
        hashTagArray.removeAll(where:{$0 == tag})
    }
    
    private func addItem(){
        
        if title.isEmpty {
            alertMessage = "제목을 입력해주세요.".localized
            showFillAlert = true
        } else if content.isEmpty {
            alertMessage = "내용을 입력해주세요.".localized
            showFillAlert = true
        }  else if hashTagArray.isEmpty {
            alertMessage = "해시태그를 채워주세요.".localized
            showFillAlert = true
        } else {
            withAnimation{
                let newItem = WorkoutHistory(title: title, content: content, writeDate: Date(), condition: selectedCondition)
                let media = vm.thumbnailImages.map { Media(data: $0.image.jpegData(compressionQuality: 1.0)!, type: $0.type, videoData: $0.videoData) }
                let tags = hashTagArray.map{ HashTag(tag: $0)}
                newItem.workoutTime = selectedMinutes * 60 + selectedSeconds
                newItem.hashTags = tags
                newItem.media = media
                modelContext.insert(newItem)
            }
            showWorkoutAddView.toggle()
        }
    }
    
    
    private func updateAutoCompleteTags(with text: String) {
        // workoutHistory에서 태그를 필터링하여 autoCompleteTags를 업데이트
        autoCompleteTags = workoutHistories
            .flatMap { $0.hashTags ?? [] }
            .map { $0.tag }
            .filter { $0.lowercased().hasPrefix(text.lowercased()) }
        
        isShowingAutoComplete = !autoCompleteTags.isEmpty && !text.isEmpty
    }
    
    
    private func selectAutoCompleteTag(_ tag: String) {
        // 사용자가 태그를 선택하면 해시태그 배열에 추가하고 입력 필드 초기화
        hashTagArray.append(tag)
        hashTagText = ""
        isShowingAutoComplete = false
    }
    
}

struct TextWidthView: View {
    @Binding var text: String
    @Binding var textWidth: Double

    var body: some View {
        Text(text)
            .hidden()
            .overlay(
                GeometryReader { textGeometry in
                    Color.clear
                        .onChange(of: text) { _,_ in
                            // 텍스트가 변경될 때마다 너비를 업데이트
                            textWidth = textGeometry.size.width
                            print("너비 \(textWidth)")
                        }
                }
            )
            .frame(height: 0) // 실제 UI에 영향을 주지 않도록 높이는 0으로 설정
    }
}
