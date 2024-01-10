//
//  WorkoutListView.swift
//  MyWorkOutLog
//
//  Created by 고종찬 on 2024/01/04.
//

import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var workoutHistories: [WorkoutHistory]
    @State private var showAddWorkoutView: Bool = false
    @State private var showModifyWorkoutView: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var selectedWorkoutStory: WorkoutHistory?
    // 날짜별로 그룹화된 운동 기록
    private var groupedWorkoutHistories: [Date: [WorkoutHistory]] {
        Dictionary(grouping: workoutHistories) { (workoutHistory) in
            Calendar.current.startOfDay(for: workoutHistory.writeDate) // 날짜별로 그룹화
        }
    }
    
    
    var body: some View {
        
        
        
        NavigationStack{
            BannerView()
                .frame(height:60)
            Spacer()
            if !workoutHistories.isEmpty{
                List {
                    ForEach(groupedWorkoutHistories.keys.sorted(), id: \.self) { date in
                        Section(header: Text(dateFormattedLocalized(date))) {
                            ForEach(groupedWorkoutHistories[date] ?? []) { history in
                                NavigationLink {
                                    WorkoutDetailView(workoutHistory: history)
                                } label: {
                                    HStack{
                                        if !(history.media?.isEmpty ?? ![].isEmpty){
                                            ScrollView(.horizontal){
                                                LazyHStack{
                                                    ForEach(history.media ?? []){item in
                                                        ZStack{
                                                            Image(uiImage: UIImage(data: item.data)!)
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width:100,height:100)
                                                                .background(.black)
                                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                                                .padding([.top,.trailing], 10)
                                                            if item.type == .video{
                                                                Image(systemName: "video.circle.fill")
                                                                    .renderingMode(.original)
                                                                    .tint(Color.white)
                                                            }
                                                        }
                                                    }
                                                }//LAZYHSTACK
                                                
                                            }//SCROLLVIEW
                                            .frame(maxWidth:110, maxHeight: 110)
                                        }
                                        HStack(alignment:.top){
                                            VStack(alignment: .leading){
                                                Text(history.title)
                                                    .font(.headline)
                                                    .padding(.bottom)
                                                ForEach(history.hashTags ?? []){ hashTag in
                                                    Text("#\(hashTag.tag)")
                                                        .lineLimit(1)
                                                        .truncationMode(.tail)
                                                        .font(.footnote)
                                                }
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing){
                                                Text("\(history.condition.localized)")
                                                    .font(.footnote)
                                                    .foregroundColor(history.condition.colorForCondition())
                                                
                                                if history.workoutTime != nil || history.workoutTime != 0{
                                                    Text("\(secondsToTimeString(history.workoutTime ?? 0))")
                                                }
                                            }
                                        }// HSTACK
                                        Spacer()
                                    }// HSTACK
                                }
                                .alert("삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                                    Button("삭제".localized, role: .destructive) {
                                        if let index = workoutHistories.firstIndex(of: history) {
                                            modelContext.delete(workoutHistories[index])
                                        }
                                    }
                                    Button("취소".localized, role: .cancel) {
    //                                    showDeleteAlert = false
                                    }
                                } message: {
                                    Text("삭제를 누르시면 데이터가 복구되지 않습니다.")
                                }
                            
                                .swipeActions(edge: .trailing) {
                                    Button{
                                        // 삭제 액션
                                        showDeleteAlert = true
                                    } label: {
                                        Label("삭제".localized, systemImage: "trash")
                                    }
                                 
                                    
    //                                Button {
    //                                    self.selectedWorkoutStory = history
    //
    //                                } label: {
    //                                    Label("수정localized, systemImage: "square.and.pencil")
    //                                }
    //                                .tint(.yellow)
                                }
    //                            .onChange(of: self.selectedWorkoutStory){ _,nv in
    //                                if nv != nil{
    //                                    showModifyWorkoutView.toggle()
    //                                }
    //                            }
    //                            .fullScreenCover(isPresented: $showModifyWorkoutView, content: {
    //                                if let selected = selectedWorkoutStory{
    //                                    WorkoutModifyView(workoutHistory: selected, showModifyWorkoutView: $showModifyWorkoutView)
    //                                }
    //                            })
    //
                               
                            }
                        }
                    }
                    
                }
                .listRowInsets(EdgeInsets.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                .listStyle(GroupedListStyle())
                .toolbar {
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                .toolbar(.visible, for: .navigationBar)
               
    //            BannerView()
    //                .frame(height:50)
            }else{
                ZStack(alignment:.center){
                  
                        Button(action: {
                            addItem()
                        }, label: {
                            VStack{
                                Spacer()
                                Image("EmptyViewx3")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                Text("처음이신가요? \n여기를 눌러 \n운동을 추가해주세요")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                        })
                }
            }
       
        }
        .fullScreenCover(isPresented: $showAddWorkoutView, content: {
            WorkoutAddView(showWorkoutAddView: $showAddWorkoutView)
        })
    }

    private func addItem() {
        withAnimation {
            showAddWorkoutView.toggle()
//            let newItem = WorkoutHistory(title: "타이틀", content: "컨텐츠", writeDate: Date(), conditions: .easy)
//            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(workoutHistories[index])
            }
        }
    }
}

