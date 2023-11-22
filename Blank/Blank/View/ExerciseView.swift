//
//  ExerciseView.swift
//  Blank
//
//  Created by Sup on 11/14/23.
//

import SwiftUI
import PencilKit

struct ExerciseView: View {
    
    @State var canvas = PKCanvasView()
    
    @State var isDraw = true
    @State var drawColor: Color = .black
    
    @State var isColorPicker = false
    
    @Binding var excerciseBool:Bool
    
    var body: some View {
        
        
        
        ZStack{
            Color.white
                .shadow(radius: 10)
            
            HStack(spacing:0){
                VStack{
                    Color(UIColor.systemGray6)
                }.frame(width: 10)
                
                VStack( spacing: 0){
                    
                    HStack(spacing: 0){
                        Color(UIColor.systemGray6)
                    }.frame(height: 10)
                    
                    HStack{
                        // 연습장 닫기 버튼
                        Button {
                            excerciseBool.toggle()
                        } label: {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 35))
                                .foregroundColor(.cyan)
                                .padding(8)
                        }
                        .padding(.leading,5)
                        
                        
                        Spacer(minLength: 0)
                        
                        if isDraw {
                            ColorPicker("", selection: $drawColor)
                        }
                        
                        
                        Button(action: {
                            withAnimation(nil) {
                                isDraw.toggle()
                            }
                            
                        }) {
                            Group{
                                if isDraw {
                                    Image(systemName:  "eraser")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 100)
                                                .stroke(Color(.black), lineWidth: 3)
                                        )
                                } else  {
                                    Image(systemName:  "pencil.tip.crop.circle")
                                        .font(.system(size: 35 ))
                                        .foregroundColor(.black)
                                    
                                    
                                }
                            }
                        }
                                                
                        // 전체 삭제 버튼
                        Button(action: clearCanvas) {
                            Image(systemName: "trash.circle")
                                .font(.system(size: 35))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.black)
                        }
                        .padding(.trailing,8)
                        
                        
                    }
                    .background(Color(UIColor.systemGray6))
                    DrawingView(canvas: $canvas,isDraw: $isDraw, drawColor: $drawColor)
                    
                    Color(UIColor.systemGray6)
                        .frame(height: 10)
                    
                    // 공간 안먹는 곳에 더블탭 액션 달아놓았음
                    PencilDobuleTapInteractionView {
                        // 이 클로저는 pencil 더블 탭 시 실행
                        self.isDraw.toggle()
                        
                    }.frame(width: 0,height: 0)
                }
                
                VStack{
                    Color(UIColor.systemGray6)
                }.frame(width: 10)
                
            }
            
        }
    }
    
    // 캔버스를 클리어하는 함수
    func clearCanvas() {
        canvas.drawing = PKDrawing()
    }
    
    
}

struct DrawingView: UIViewRepresentable {
    
    @Binding var canvas: PKCanvasView
    @Binding var isDraw: Bool
    @Binding var drawColor: Color
    
    var drawInk : PKInkingTool {
        PKInkingTool(.pen, color: UIColor(drawColor))
    }
    //    let eraserInk = PKEraserTool(.vector)
    var eraserInk: PKEraserTool {
        if #available(iOS 16.4, *) {
            PKEraserTool(.bitmap, width: 50)
        } else {
            PKEraserTool(.bitmap)
        }
    }
    
    
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.backgroundColor = UIColor.clear
        
        canvas.drawingPolicy = .anyInput
        canvas.tool = isDraw ? drawInk : eraserInk
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.backgroundColor = UIColor.clear
        
        uiView.tool = isDraw ? drawInk : eraserInk
        
    }
}



