//
//  okashiData.swift
//  myOkashi
//
//  Created by 奥村 亮 on 2022/02/01.
//

import Foundation
//UIImageを利用する為にimport
import UIKit

//Identifiableプロトコルを利用して、お菓子の情報をまとめる構造体
//一意(重複しない/ユニークな)のidが予め決まるので便利
struct OkashiItem: Identifiable {
    //情報を取得したら変更なしなのでlet
    //ランダムに一意のidを生成
    let id = UUID()
    //お菓子の画像
    let name: String
    //お菓子のURL
    let link: URL
    //お菓子の画像
    let image: UIImage
}

//お菓子データ検索用クラス
//ObservableObject(プロトコル)はstructでは利用できない
//ObservableObjectとはデータクラスの更新を参照する(@Stateはプロパティ)
//classは参照型(structは値型)
//classは複数のプロパティやメソッドを1つのオブジェクトとして管理できる
class okashiData: ObservableObject {
    //JSONのデータ構造
    //Codable(プロトコル) JSONのデータ項目名と変数名を同じにするとJSON変換時に一括して変数でデータを格納できる
    //Codable(プロトコル) JSONをSwiftオブジェクト(インスタンス化された変数、構造体、関数、メソッドのメモリ内の値)にエンコード/デコードできる
    struct ResultJson: Codable {
        //JSONのitem内のデータ構造
        struct Item: Codable {
            //お菓子の名前
            let name: String?
            //掲載URL
            let url: URL?
            //画像URL
            let image: URL?
        }//Itemここまで
        //構造体Itemを[]に入れる事で複数の構造体を保持できる配列として宣言(実際、データは複数なので)
        let item: [Item]?
    }//ResultJsonここまで
    
    //お菓子データのリスト(Identifiableプロトコル)を複数保持できる
    //[]ブラケット
   
    //@PublishedはokashiData: ObservableObjectの更新を監視してContentViewに自動通知する->値が変更され、body(View)が再描画
    //okashiData側はパブリッシャー(配信)、ContentView側はサブスクライバー(受信)
    @Published var okashiList: [OkashiItem] = []
    
    //webAPI検索用メソッド 第一引数:keyword 検索したいワード
    func searchOkashi(keyword: String) {
        //デバッグエリアに出力
        print(keyword)
        
        //検索ワードをURLエンコードする
        //addingPercentEncoding(メソッド)->文字を半角1バイトに変換する
        //urlQueryAllowed -> URLパラメーター用のエンコードを指定している
        //guard let -> データがない場合はnil nilはオプショナル型 アンラップしデータ(nil)を取り出す 安全性を考慮
        //アンラップに失敗するとelse->return
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            return
        }
        //リクエストURLの組み立て
        guard let req_url = URL(string: "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r")
        else {
            return
        }
        
        print(req_url)
        
        //リクエストに必要な情報(オブジェクト)を生成
        let req = URLRequest(url: req_url)
        //データ転送を管理するためのセッション(サーバーとの通信の開始から終了)を生成
        //第一引数 configuration: .default デフォルトのセッション構成を指定 ディスクの保存されるキャッシュ、認証情報、クッキーを使用します。
        //第二引数 delegate: nil ダウンロード後のデータの取出しをdelegateではなく、クロージャで行う為
        //第三引数 delegateQueue: ->delegateやクロージャの実行を規制する OperationQueue.main ->画面更新する場合、非同期処理をする場合は指定する
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        //リクエストをタスクとして登録
        //req_url URL文字列 ->req オブジェクト生成からのパラメーターとして指定
        //completionHandler以降 データダウンロード後の処理をクロージャーとして引き渡す
        let task = session.dataTask(with: req, completionHandler: {
            //data JSONダウンロード後のデータが格納
            //response 通信の状態を示す状態が格納
            //ダウンロード失敗した時の処理を格納
            (data, response, error) in
            //データ取得が完了したタイミングでセッションを終了
            session.finishTasksAndInvalidate()
            //do try catch エラーハンドリング 例外処理 パースの処理でエラーが発生する場合がある
            do {
                //JSONDecorderのインスタンス取得
                let decorder = JSONDecoder()
                //受け取ったJSONデータをパース(解析)して格納 ResultJsonのCadableプロコトルを利用する
                let json = try decorder.decode(ResultJson.self, from: data!)
                
//                print(json)
                
                //お菓子の情報が取得してできているか確認
                if let items = json.item {
                    //okashiListを初期化(２回目以降は前回の内容が入っているので削除する)
                    //クロージャー(completionHandler)はclassの中にある classは参照型 self(自分自身)を参照としないと循環参照(ループ状態)の恐れがある
                    //structは参照型ではない為、循環参照の恐れがなく、selfは不要
                    self.okashiList.removeAll()
                    //繰り返し処理 取得した件数だけ処理
                    for item in items {
                        //それぞれアンラップ(存在すれば左辺に代入 存在しなければ次の行に処理が移される)
                        if let name = item.name,
                           let link = item.url,
                           let imageURL = item.image,
                           //一旦バッファリング(一時的な場所に一時的に保管)
                           let imageData = try? Data(contentsOf: imageURL),
                           //画像ファイル(UIImage型)に出力
                           //.withRenderingMode(.alwaysOriginal) オリジナルの画像として出力
                           let image = UIImage(data: imageData)?.withRenderingMode(.alwaysOriginal) {
                            //1件分の各データを構造体OkashiItemにまとめて管理
                            let okashi = OkashiItem(name: name, link: link, image: image)
                            //OkashiItemをokashiListに格納 併せてUUIDも自動的に生成される
                            self.okashiList.append(okashi)
                        }
                    }
                }
                print(self.okashiList)
                
            //do内の処理でエラーが発生するとcatchが実行される
            }catch {
                //エラー処理
                print("エラー発生")
            }
        })//クロージャーここまで
        
        //ダウンロード開始 これが終わってから上のcompletionHandlerのクロージャーが実行される
        task.resume()
    }//searchOkashiここまで
    
}
