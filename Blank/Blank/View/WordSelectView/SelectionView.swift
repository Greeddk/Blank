//
//  SelectionView.swift
//  Blank
//
//  Created by Sup on 11/29/23.
//

import SwiftUI


struct SelectionView: View {
    
//    @State private var selectedOption: String? = nil
    @Binding var selectedOption: String
    
    @Binding var isSelectArea: Bool
    @Binding var isBlankArea: Bool
    
    var body: some View {
        ZStack {
            // ZStack에 배경과 둥근 모서리 적용
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.gray.opacity(0.5))
                .frame(width: UIScreen.main.bounds.size.width * 0.17, height: UIScreen.main.bounds.size.height * 0.04) // ZStack의 크기 설정
            
            HStack {
                // "framPen", "dragPen", "eraser"에 해당하는 이미지 파일명을 가정
                let buttonImageNames = ["framPen", "dragPen", "eraser"]
                
                ForEach(buttonImageNames, id: \.self) { buttonImageName in
                    Button(action: {
                        withAnimation {
                            self.selectedOption = buttonImageName
                        }
                        // 여기에서 각 버튼에 대한 고유한 액션 실행
                        buttonAction(for: buttonImageName)
                    }) {
                        Image(buttonImageName) // 텍스트 대신 이미지 사용
                            .resizable() // 이미지 크기 조절 가능하게
                            .scaledToFit() // 콘텐츠 비율 유지
                            .frame(
                                width: UIScreen.main.bounds.size.width * 0.04 ,
                                height: UIScreen.main.bounds.size.height * 0.025)
                            .background(self.selectedOption == buttonImageName ? Color.white : Color.white)
                            .cornerRadius(30) // 개별 버튼에 둥근 모서리 적용
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(self.selectedOption == buttonImageName ? Color.blue : Color.clear, lineWidth: 4)
                            )
                    }
//                    .offset(y: self.selectedOption == buttonImageName ? -30 : 0) // 선택된 버튼을 위로 이동
                    .offset(y: self.selectedOption == buttonImageName ? -UIScreen.main.bounds.size.height * 0.01 : 0) // 선택된 버튼을 위로 이동
                }
            }
        }
    }
    
    // 버튼 식별자에 따른 액션 함수
    func buttonAction(for buttonImageName: String) {
        switch buttonImageName {
        case "framPen":
            // framPen 버튼에 대한 액션
            isSelectArea = false
            isBlankArea = true
        case "dragPen":
            // dragPen 버튼에 대한 액션
            isSelectArea = true
            isBlankArea = false
        case "eraser":
            // eraser 버튼에 대한 액션
            isSelectArea = false
            isBlankArea = false
        default:
            break
        }
    }
}



