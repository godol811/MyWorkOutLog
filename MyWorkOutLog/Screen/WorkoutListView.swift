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
    
    // 날짜별로 그룹화된 운동 기록
    private var groupedWorkoutHistories: [Date: [WorkoutHistory]] {
        Dictionary(grouping: workoutHistories) { (workoutHistory) in
            Calendar.current.startOfDay(for: workoutHistory.writeDate) // 날짜별로 그룹화
        }
    }
    
    
    var body: some View {
        NavigationStack{
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
                                    VStack(alignment: .leading){
                                        HStack(alignment:.bottom){
                                            Text("\(history.title.localized)")
                                                .font(.headline)
                                                .padding(.bottom)
                                            Spacer()
                                            Text("\(history.condition.localized)")
                                                .font(.footnote)
                                                .padding(.bottom)
                                                .foregroundColor(history.condition.colorForCondition())
                                        }
                                     
                                        ForEach(history.hashTags ?? []){ hashTag in
                                            Text("#\(hashTag.tag)")
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                                .font(.footnote)
                                        }
                                    }// VSTACK
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
                             
                                
                                Button {
                                    showModifyWorkoutView.toggle()
                                } label: {
                                    Label("수정".localized, systemImage: "square.and.pencil")
                                }
                                .tint(.yellow)
                            }
                            
                            .fullScreenCover(isPresented: $showModifyWorkoutView, content: {
                                WorkoutModifyView(workoutHistory: history, showModifyWorkoutView: $showModifyWorkoutView)
                            })
                            
                           
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
            .fullScreenCover(isPresented: $showAddWorkoutView, content: {
                WorkoutAddView(showWorkoutAddView: $showAddWorkoutView)
            })
            BannerView()
                .frame(height:50)
        }
        
    }

    private func addItem() {
        withAnimation {
            showAddWorkoutView.toggle()
            print("\(showAddWorkoutView) ?????")
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

#Preview {
    WorkoutListView()
}
