//
//  ContentView.swift
//  myOkashi
//
//  Created by 奥村 亮 on 2022/02/01.
//

import SwiftUI

struct ContentView: View {
    
    //@observedObject 状態変数 複数のデータを外部ファイルと共有する
    //okashiDataを参照
    @ObservedObject var okashiDataList = okashiData()
    //状態変数 入力された文字列を保持する
    @State var inputText = ""
    //状態変数　safariの表示有無を管理
    @State var showSafari = false
    
    var body: some View {
      
        VStack {
            //文字を受け取るTextField
            //プレースホルダー　"キーワードを入力してください"
            //$inputText 状態変数inputTextを参照渡し 参照型と同じ概念 引数に渡す変数のメモリを共有する(値渡しではうまく連動できない)
            TextField("キーワードを入力してください", text: $inputText, onCommit: {
                //クロージャ　入力完了後に検索する
                okashiDataList.searchOkashi(keyword: inputText)
            })
            .padding()
            
            //リストを表示
            //okashiDataListクラスのokashiListから内容を1行ずつ取り出しokashi変数に格納
            List(okashiDataList.okashiList) { okashi in
                //ボタンを表示
                Button(action: {
                    //safariViewを表示 toggle->Bool値(true/false)が自動で切替る
                    showSafari.toggle()
                }) {
                    //横レイアウト
                    HStack {
                        //画像
                        Image(uiImage: okashi.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 40)
                        //名前
                        Text(okashi.name)
                    }//HStackここまで
                }//Buttonここまで
                //タップされると実行される
                //画面の下からsheetをモーダルで表示できるモディファイア
                //.edgesIgnoringSafeArea(.bottom) 画面いっぱいに表示
                .sheet(isPresented: self.$showSafari, content: {
                    SafariView(url: okashi.link)
                        .edgesIgnoringSafeArea(.bottom)
                })
                
            }//Listここまで
        }//VStackここまで
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
