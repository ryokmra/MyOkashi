//
//  SafariView.swift
//  myOkashi
//
//  Created by 奥村 亮 on 2022/02/03.
//

import SwiftUI
//アプリ内でsafariを起動できるフレームワーク
import SafariServices

//SFSafariViewControllerがSwiftUIに対応していないので使用できるようにUIViewControllerRepresentableでラップする
struct SafariView: UIViewControllerRepresentable {
    //表示するURLを受け取る変数
    var url: URL
    //表示するViewを生成する時に実行
    func makeUIViewController(context: Context) -> some UIViewController {
        //safariを起動
        return SFSafariViewController(url: url)
    }
    //Viewが更新された時に実行
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //処理なし
    }
}
