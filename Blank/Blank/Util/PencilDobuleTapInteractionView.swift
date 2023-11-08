//
//  PencilDobuleTapInteractionView.swift
//  Blank
//
//  Created by Sup on 11/8/23.
//

import SwiftUI
import UIKit

//  WordSelectView에서 pencil double탭시 선택 or 지우기 모드를 위한 구조체
struct PencilDobuleTapInteractionView: UIViewRepresentable {
    // 클로저를 사용하여 SwiftUI 뷰의 상태를 변경
    var onDoubleTap: () -> Void
    
    // UIView를 생성하고 설정하는 메소드
    func makeUIView(context: Context) -> UIView {
        
        // view를 사용할게 아니기 때문에 frame zero에 배경색을 투명하게 설정
        let view = UIView()
        view.backgroundColor = .clear
        
        // Apple Pencil interaction 객체를 생성하고 델리게이트를 설정
        let pencilInteraction = UIPencilInteraction()
        pencilInteraction.delegate = context.coordinator
        view.addInteraction(pencilInteraction)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 만약 UIView 업데이트 로직이 필요한 경우 여기에 구현
        // 이번 구현에는 필요없기 때문에 공백
    }
    
    // UIPencilInteractionDelegate 를 채택하는 Coordinator 클래스 구현
    // onDoubleTap 을 채택해줘야 돌아감
    func makeCoordinator() -> Coordinator {
        Coordinator(onDoubleTap: onDoubleTap)
    }
    
    
    // PencilInteractionView 내부에 Coordinator 클래스를 정의한다.
    class Coordinator: NSObject, UIPencilInteractionDelegate {
        var onDoubleTap: () -> Void // 더블 탭 시 실행할 클로저
        
        init(onDoubleTap: @escaping () -> Void) {
            self.onDoubleTap = onDoubleTap
        }
        
        
        func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
            // 더블 탭 발생 시 실행할 클로저
            // 여기에 실제 기능을 넣는게 아니라 Dobule tap시 동작하길 원하는 기능이 있는 SwiftUI View에  PencilInteractionView을 넣어주면 된다
            onDoubleTap()
            
            
            
            // ---------- Mark : 사용예시  ----------------
            /* 사용예시
             mark
             아래 같은 방식으로 representable된 view을 사용해서 변화를 원하는 내용을 클로저에 담아주면 됨
             
             PencilDobuleTapInteractionView {
             // 이 클로저는 Pencil의 더블 탭이 감지될 때 실행
             self.isSelectArea.toggle()
             }
             .frame(width: 0, height: 0) // 뷰의 크기를 0으로 설정해서 눈에 안보이게
             
             */
            // ----------   ----------------
            
        }
    }
}

