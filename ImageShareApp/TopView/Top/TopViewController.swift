//
//  TopViewController.swift
//  ImageShareApp
//
//  Created by 田内　翔太郎 on 2019/08/21.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import FirebaseFirestore
import NVActivityIndicatorView
import PMAlertController

class TopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    // MARK: - 紐付けのプロパティ
    // コレクションセル
    @IBOutlet weak var postedImageView: UIImageView!
    // いいねリストに移るボタン
    @IBOutlet weak var favViewButton: UIBarButtonItem!
    // 検索タグの予測一覧を出すテーブルビュー
    @IBOutlet weak var searchTableView: UITableView!
    // タイムラインのコレクションビュー
    @IBOutlet weak var topCollectionView: UICollectionView!
    // 画像編集画面へ移るボタン
    @IBOutlet weak var plusImageButton: UIButton!
    // キーボードを隠すボタン
    @IBOutlet weak var hideKeyboardButton: UIButton!

    // MARK: - 自作のプロパティ
    /// 検索窓
    var searchBar: UISearchBar = UISearchBar()
    var searchResults:[String] = []

    /// 検索結果を入れる配列
    var resultSearch: [[String: Any]] = []
    var resultSearchID: [String] = []

    /// 投稿された情報を保管する
    var postImageInfo: [[String: Any]] = []
    var postImageID: [String] = []

    /// すべての投稿の情報を保管する
    var allPostImageInfo: [[String: Any]] = []
    var allPostImageID: [String] = []

    /// いいねされた投稿の情報を保管する
    var favPostImageInfo: [[String: Any]] = []
    var favPostImageID: [String] = []

    /// 今までのタグの一覧を保管する
    var tagsList: [String] = []

    /// 押されたタグの情報を保管する
    var tagWord: String = ""

    /// 部屋のID
    var roomID: String = ""

    /// roomIDのドキュメントがあるかどうか
    var exsistDocument: Bool = false

    /// 部屋のユーザーのIDを格納する
    var roomMenbers: [String] = []
    /// 申請待ちのユーザーのIDを格納する
    var waitingMenber: [String] = []
    /// 現在のグループの情報を格納する
    var roomInfo: [String: Any] = [:]

    /// 日付のフォーマッター
    var formatter: DateFormatter = DateFormatter()

    /// インジケータの追加
    var activityIndicatorView: NVActivityIndicatorView!
    var activityIndicatorBackgroundView: UIView!

    // MARK: - override

    override func viewDidLoad() {
        super.viewDidLoad()

        // キーボードを隠すボタンを隠す
        hideKeyboardButton.isHidden = true

        // 検索窓の設定
        setupSearchBar()

        // 日付のフォーマットの設定
        formatter.dateFormat = "yyyyMMdd"

        // refreshControlを追加する
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TopViewController.refreshControlValueChanged(sender:)), for: .valueChanged)

        // roomIDのドキュメントがあるかどうか
        db.collection("chat-room").document("\(roomID)").getDocument(completion: { (document, err) in
            if let document = document, document.exists {
                self.exsistDocument = true
            }
        })

        // ナビゲーションバーの戻るボタンを消す
        self.navigationItem.hidesBackButton = true

        // delegateとdatasourceの設定
        topCollectionView.delegate = self
        topCollectionView.dataSource = self
        searchTableView.delegate = self
        searchTableView.dataSource = self

        // コレクションビューのレイアウトを調整
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        topCollectionView.collectionViewLayout = layout

        // 投稿ボタンの設定
        plusImageButton.layer.cornerRadius = plusImageButton.frame.width / 2

        // インジケータの設定
        setIndicator()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // インジケータを回す
        activityIndicatorView.startAnimating()
        activityIndicatorBackgroundView.alpha = 1

        // 検索画面を消す
        searchTableView.isHidden = true
        // キーボードを隠すためのボタンを隠す
        hideKeyboardButton.isHidden = true

        // 情報の初期化
        postImageInfo = []
        postImageID = []
        favPostImageInfo = []
        favPostImageID = []
        resultSearchID = []
        resultSearch = []
        allPostImageInfo = []
        allPostImageID = []
        tagsList = []
        roomMenbers = []
        waitingMenber = []
        print("タグの個数 @viewWillAppear in TopViewController \(self.tagsList.count)")

        // 投稿情報を取得する
        getPostInfo(completion: {
            // リロード
            self.topCollectionView.reloadData()
            // インジケータを止める
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorBackgroundView.alpha = 0
        })
        // タグ情報を取得する
        getTagInfo(completion: {
            // リロード
            self.searchTableView.reloadData()
            print("タグの個数 @viewWillAppear in TopViewController \(self.tagsList.count)")
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // タグのリストの初期化
        tagsList = []
    }

    // refreshControl
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        // 初期化
        postImageInfo = []
        postImageID = []
        favPostImageInfo = []
        favPostImageID = []
        resultSearchID = []
        resultSearch = []
        // 情報の取得
        getPostInfo(completion: {
            // リロード
            self.topCollectionView.reloadData()
            // refreshの終了
            sender.endRefreshing()
        })
    }

    // MARK: - 自作関数

    // MARK: - DB系

    /**
     * 投稿情報を取得する関数
     * - Parameters:
     *   - completion: DBから情報を取得し終わった時に呼ばれる処理
     */
    func getPostInfo(completion: @escaping () -> ()) {
        // メッセージコレクションを作成
        db.collection("chat-room").document(roomID).collection("message")
        // メッセージを取得
        db.collection("chat-room").document("\(roomID)").collection("message").order(by: "date", descending: true).getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("WaittingViewController-28: \(err.localizedDescription)")
            } else {
                for document in QuerySnapshot!.documents {
                    self.postImageInfo.append(document.data())
                    self.postImageID.append(document.documentID)
                    self.allPostImageID.append(document.documentID)
                    self.allPostImageInfo.append(document.data())
                }
                self.topCollectionView.reloadData()
            }
            completion()
        }
    }

    /**
     * タグ情報を取得する関数
     * - Parameters:
     *   - completion: DBから情報を取得し終わった時に呼ばれる処理
     */
    func getTagInfo(completion: @escaping () -> ()) {
        // tagsコレクションのリスナーを追加
        db.collection("tags").order(by: "used-count", descending: true).getDocuments(completion: { (QuerySnapshot, err) in
            guard let documents = QuerySnapshot?.documents else { return }
            for document in documents {
                if document.data()["tag-name"] as! String != "" {
                    self.tagsList.append(document.data()["tag-name"] as! String)
                }
            }
            completion()
        })
    }

    /// 部屋のメンバーと申請待ちの人のIDを取ってくる関数
    func getUserInfo() { // ドキュメントが存在していたら
        if exsistDocument {
            // 所属メンバー一覧を取得
            db.collection("chat-room").document("\(roomID)").collection("users").getDocuments(completion: { (QuerySnapshot, err) in
                if let err = err {
                    print("GroupViewController-35: \(err.localizedDescription)")
                } else {
                    for document in QuerySnapshot!.documents {
                        self.roomMenbers.append(document.documentID)
                    }
                }
            })
            // 申請待ちの一覧を取得
            db.collection("chat-room").document("\(roomID)").collection("waiting-users")
            db.collection("chat-room").document("\(roomID)").collection("waiting-users").getDocuments(completion: { (QuerySnapshot, err) in
                if let err = err {
                    print("GroupViewController-35: \(err.localizedDescription)")
                } else {
                    for document in QuerySnapshot!.documents {
                        self.waitingMenber.append(document.documentID)
                    }
                }
            })
        }
    }

    /// グループの情報を取得する関数
    func getRoomInfo() {
        // 部屋の情報を格納する
        db.collection("chat-room").document("\(roomID)").getDocument(completion: { (document, err) in
            if let document = document, document.exists {
                if document.data() != nil {
                    self.roomInfo = document.data()!
                } else {
                    print("ドキュメントデータが存在していません")
                }
            } else {
                print("ドキュメントが存在していません")
            }
        })
    }

    /// お気に入りした投稿の情報を取得する
    func getFavImage(completion: @escaping () -> ()) {
        db.collection("chat-room").document(roomID).collection("users").document(UserDefaults.standard.string(forKey: "email")!).collection("fav-image").order(by: "date", descending: true).getDocuments(completion: { (QuerySnapshot, err) in
            for document in QuerySnapshot!.documents {
                self.favPostImageID.append(document.documentID)
                self.favPostImageInfo.append(document.data())
            }
            completion()
        })
    }

    // MARK: - その他
    /// インジケータの設定
    func setIndicator() {
        // インジケータ
        // インジケータの追加
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: NVActivityIndicatorType.orbit, color: #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1), padding: 0)
        activityIndicatorView.center = self.view.center // 位置を中心に設定

        // インジケータの背景
        activityIndicatorBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        activityIndicatorBackgroundView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndicatorBackgroundView.alpha = 0
        self.view.addSubview(activityIndicatorBackgroundView)
        self.view.addSubview(activityIndicatorView)
    }

    /**
     * 受け取ったタグ名を検索する関数
     * - Parameters:
     *   - keyWord: 検索したいキーワード
     */
    func searchTag(keyWord: String, completion: @escaping () -> ()) {
        //情報の初期化
        resultSearch = []
        resultSearchID = []

        // メッセージを取得
        db.collection("chat-room").document(roomID).collection("message").order(by: "date", descending: true).getDocuments(completion: { (QuerySnapshot, err) in
            guard let documents = QuerySnapshot?.documents else {
                print("error: \(err!.localizedDescription)")
                return
            }
            for document in documents {
                // 検索のワードとタグ名が一致していた時
                if document.data()["tag1"] as! String == keyWord || document.data()["tag2"] as! String == keyWord {
                    // 投稿情報を追加
                    self.resultSearch.append(document.data())
                    self.resultSearchID.append(document.documentID)
                }
            }
            completion()
        })
    }

    /**
     * int型の日付をString型の日付に直す関数
     * - Parameters:
     *   - intData: Int型の日付
     */
    func printDate(intDate: Int) -> String {
        // int型のdateをString型に変換
        let stringDate = String(intDate)
        // yyyyMMdd型でフォーマット
        formatter.dateFormat = "yyyyMMddHHmmss"
        // date型の日付を生成
        if let nowDate = formatter.date(from: stringDate) {

            // フォーマットの変換
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: nowDate)
        } else {
            return "??"
        }
    }

    /**
     * いいね機能
     * - Parameters:
     *   - cell: TopCollectionviewCell型のインスタンス
     *   - indexPath: いいねされたcollectionViewのindexPath
     */
    func favImage(cell: TopCollectionViewCell, indexPath: IndexPath) {
        // 星がついている時
        if cell.type == .highlighted {
            // 部屋までのルート
            if let ref: DocumentReference = db.collection("chat-room").document(roomID) {
                if let email = UserDefaults.standard.string(forKey: "email"), let userRef: DocumentReference = ref.collection("users").document(email) {
                    // DBにいいねを押した画像の情報を追加
                    userRef.collection("fav-image").document(postImageID[indexPath.row]).setData(postImageInfo[indexPath.row])
                }
            }
        }
    }

    /**
     * 保存機能
     * - Parameters:
     *   - image: 保存したい画像
     */
    func save(image: UIImage) {

        // カメラロールに保存する
        // アラートコントローラー
        let alertController = PMAlertController(title: "保存しますか？", description: nil, image: image, style: .alert)
        // アラートアクション
        alertController.addAction(PMAlertAction(title: "はい", style: .default, action:{
            // 「はい」を押した時だけ、画像を保存する
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.didFinishSavingImage(_: didFinishSavingWithError: contextInfo:)), nil)
        }))
        alertController.addAction(PMAlertAction(title: "いいえ", style: .cancel))
        self.present(alertController, animated: true)
    }

    /// 保存を試みた結果を受け取る
    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {

        // 結果によって出すアラートを変更する
        var title = "保存完了"
        var message = "カメラロールに保存しました"

        if error != nil {
            title = "エラー"
            message = "保存に失敗しました"
        }

        let alertController = PMAlertController(title: title, description: message, image: image, style: .alert)

        alertController.addAction(PMAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }

    // MARK: - searchBarの関数
    /// サーチバーの設定
    func setupSearchBar() {
        if let navigationBarFrame = navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "タグ名"
            searchBar.tintColor = #colorLiteral(red: 0.06256254762, green: 0.7917881608, blue: 0.8028883338, alpha: 1)
            searchBar.keyboardType = UIKeyboardType.default
            searchBar.showsScopeBar = true
            searchBar.showsBookmarkButton = true
            searchBar.setImage(#imageLiteral(resourceName: "icons8-かける-25"), for: .bookmark, state: .normal)
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }

    /// バツボタンを押した時の処理
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            postImageInfo = allPostImageInfo
            print("総投稿数:\(postImageInfo.count)")
            postImageID = allPostImageID
            // tableViewをリロード
            topCollectionView.reloadData()
        }
        searchBar.text = ""
        searchBar.endEditing(true)
        searchTableView.isHidden = true
        hideKeyboardButton.isHidden = true
        self.searchTableView.reloadData()
    }

    // サーチバーの設定
    /// 編集が開始されたら、キャンセルボタンを有効にする
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    /// キャンセルボタンが押されたらキャンセルボタンを無効にしてフォーカスを外す
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    /// 検索ボタンが押された時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // インジケータを追加
        activityIndicatorView.startAnimating()
        activityIndicatorBackgroundView.alpha = 1

        // キーワードを検索
        if let keyWord = searchBar.text {
            searchTag(keyWord: keyWord, completion: {
                self.postImageInfo = self.resultSearch
                self.postImageID = self.resultSearchID
                self.topCollectionView.reloadData()
                // インジケータを削除
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorBackgroundView.alpha = 0
            })
        }
        // キーボードを閉じる
        searchBar.endEditing(true)
        hideKeyboardButton.isHidden = true

    }

    /// 検索欄がタップされたら
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchTableView.isHidden = false
        hideKeyboardButton.isHidden = false
    }

    /// テキストが変更されるごとに呼ばれる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchResults = tagsList.filter{
            // 大文字と小文字を区別せずに検索
            $0.lowercased().contains(searchBar.text!.lowercased())
        }
        self.searchTableView.reloadData()

    }

    // MARK: - collectionViewの関数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImageInfo.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCell", for: indexPath) as! TopCollectionViewCell
        var isStar: Bool = false
        // いいねされた画像を監視
        db.collection("chat-room").document(roomID).collection("users").document(UserDefaults.standard.string(forKey: "email")!).collection("fav-image").addSnapshotListener( { (QuerySnapshot, err) in
            guard let documents = QuerySnapshot?.documents else {
                print("err: \(err!.localizedDescription)")
                return
            }
            for document in documents {
                // 全投稿の内、fav-imageにあるものと同じドキュメントがあった場合
                if indexPath.row < self.postImageID.count && document.documentID == self.postImageID[indexPath.row] {
                    cell.type = .highlighted
                    cell.starButton.setImage(#imageLiteral(resourceName: "星(選択時)"), for: .normal)
                    isStar = true
                }
            }
            if !isStar {
                cell.type = .nomal
                cell.starButton.setImage(#imageLiteral(resourceName: "星(普通)"), for: .normal)
            }
        })

        // セルに情報を渡す
        cell.roomID = roomID
        cell.messageID = postImageID[indexPath.row]
        cell.cellInfo = postImageInfo[indexPath.row]
        cell.cellID = postImageID[indexPath.row]

        if postImageInfo.count != 0 {
            let dict = postImageInfo[indexPath.row]

            // 投稿画像を取得
            // 画像情報
            let imageInfo = dict["image"]
            // NSData型に変換
            let imageData = NSData(base64Encoded: imageInfo as! String, options: .ignoreUnknownCharacters)
            // UIImage型に変換
            let decordedImage = UIImage(data: imageData! as Data)
            // セルに表示
            cell.postedImageView.image = decordedImage

            // ユーザーIDを表示
            cell.postedUserLabel.text = "制作者: \(dict["userID"] as! String)"

            // タイトルを表示
            cell.postedImageTitleLabel.text = dict["title"] as? String

            // 日付を表示
            let date = printDate(intDate: dict["date"] as! Int)
            cell.postedDateLabel.text = "投稿日: \(date)"

            // タグを表示
            // タグの表示
            if dict["tag1"] as? String == "" || dict["tag1"] == nil{
                cell.tag1Button.isHidden = true
            } else {
                cell.tag1Button.isHidden = false
                cell.tag1Button.setTitle(dict["tag1"] as? String, for: .normal)
            }

            if dict["tag2"] as? String == "" || dict["tag2"] == nil{
                cell.tag2Button.isHidden = true
            } else {
                cell.tag2Button.isHidden = false
                cell.tag2Button.setTitle(dict["tag2"] as? String, for: .normal)
            }

            // セルのボタンの設定
            cell.layer.cornerRadius = 20
            cell.postedView.layer.cornerRadius = 20
            cell.tag1Button.layer.cornerRadius = 10
            cell.tag2Button.layer.cornerRadius = 10
            cell.tag2Button.isEnabled = false
            cell.tag1Button.isEnabled = false
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 20
        let cellSize : CGFloat = self.view.bounds.width - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }

    // セルタップ時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 遷移先の画面のインスタンスを生成
        let storyboard = UIStoryboard(name: "TopDetails", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailsView") as! DetailsViewController

        // それぞれの値を取得
        if postImageInfo.count != 0 {
            let dict = postImageInfo[indexPath.row]

            // 投稿画像を取得
            // 画像情報
            let imageInfo = dict["image"]
            // NSData型に変換
            let imageData = NSData(base64Encoded: imageInfo as! String, options: .ignoreUnknownCharacters)
            // UIImage型に変換
            if let decordedImage: UIImage = UIImage(data: imageData! as Data) {

                // ユーザーIDを表示
                let user = dict["userID"] as? String

                // タイトルを表示
                let title = dict["title"] as? String

                // 投稿日を表示
                let date = printDate(intDate: dict["date"] as! Int)

                // タグを表示
                let tag1 = dict["tag1"] as? String
                let tag2 = dict["tag2"] as? String

                // 値を渡す
                vc.image = decordedImage
                vc.strTitle = title
                vc.user = user!
                vc.date = date
                vc.tag1 = tag1
                vc.tag2 = tag2

            } else {
                vc.image = #imageLiteral(resourceName: "イメージ画像のアイコン素材 その3")
            }
        }
        vc.roomID = roomID
        vc.postID = postImageID[indexPath.row]

        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - tableviewの関数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text != "" {
            return searchResults.count
        } else {
            return tagsList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell", for: indexPath)

        if searchBar.text != "" {
            cell.textLabel!.text = "\(searchResults[indexPath.row])"
        } else {
            cell.textLabel!.text = "\(tagsList[indexPath.row])"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // インジケータを追加
        activityIndicatorView.startAnimating()
        activityIndicatorBackgroundView.alpha = 1

        print("indexPath.row of tapped cell is ->  \(indexPath.row) content is -> \(tagsList[indexPath.row])")
        // searchBarにタグ名を追加
        searchBar.text = tagsList[indexPath.row]
        print("didSelectRowAt: \(tagsList)")
        // 検索開始
        searchTag(keyWord: tagsList[indexPath.row], completion: {
            self.postImageInfo = self.resultSearch
            self.postImageID = self.resultSearchID
            self.topCollectionView.reloadData()
            // インジケータを削除
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorBackgroundView.alpha = 0
        })

        // キーボードを閉じる
        searchBar.endEditing(true)
        // tableViewを隠す
        searchTableView.isHidden = true
        // キーボードを隠すボタンを隠す
        hideKeyboardButton.isHidden = true
    }

    // MARK: - 紐付けアクション
    // 設定ボタン
    @IBAction func tappedSettingButton(_ sender: Any) {
        // インジケータの処理
        activityIndicatorView.startAnimating()
        activityIndicatorBackgroundView.alpha = 1

        // 遷移の処理
        let storyboard = UIStoryboard(name: "Group", bundle: nil)
        // NavigationControllerを取得
        let nc = storyboard.instantiateInitialViewController() as! UINavigationController
        // ViewControllerを取得
        let vc = nc.topViewController as! GroupViewController

        // dispatchGroupの設定
        let queueGroup = DispatchGroup()
        // キューの設定
        let queue = DispatchQueue(label: "queue1", attributes: .concurrent)

        // 所属しているユーザーのIDを取得
        queue.async(group: queueGroup, execute: {
            print("getUserInfo() started")
            self.getUserInfo()
            print("getUserInfo() finished")
        })

        // 所属しているグループの情報を取得
        queue.async(group: queueGroup, execute: {
            print("getRoomInfo() started")
            self.getRoomInfo()
            print("getRoomInfo() finished")
        })

        // すべての処理が終わった時に実行
        queueGroup.notify(queue: .main, execute: {
            print("all function finished")
            // 値を渡す
            vc.roomID = self.roomID
            vc.roomMenbers = self.roomMenbers
            vc.roomInfo = self.roomInfo
            vc.waitingMenber = self.waitingMenber
            vc.tagsInfo = self.tagsList.slice(start: 0, end: 2)
            // 遷移
            self.navigationController?.pushViewController(vc, animated: true)
            // インジケータを止める
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorBackgroundView.alpha = 0
        })
    }

    // 追加ボタン
    @IBAction func tappedPlusImageButton(_ sender: Any) {
        // 遷移処理
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Edit") as! ViewController

        // roomIDを渡す
        vc.roomID = roomID

        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func tappedFavoriteListButton(_ sender: Any) {
        // インジケータを表示させる
        activityIndicatorView.startAnimating()
        activityIndicatorBackgroundView.alpha = 1

        // いいねした投稿を取得する
        getFavImage(completion: {
            // 遷移先の取得
            if let vc = UIStoryboard(name: "TopLoad", bundle: nil).instantiateViewController(withIdentifier: "FavView") as? FavoriteViewController {
                // 情報の受け渡し
                vc.favPostImageInfo = self.favPostImageInfo
                vc.favPostImageID = self.favPostImageID
                vc.roomID = self.roomID
                // 遷移
                self.navigationController?.pushViewController(vc, animated: true)
                // インジケータを止める
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorBackgroundView.alpha = 0
            }
        })
    }

    // キーボードを隠す処理
    @IBAction func tappedHideKeyboardButton(_ sender: Any) {
            self.searchBar.endEditing(true)
            searchBar.resignFirstResponder()
            searchTableView.isHidden = true
            self.searchTableView.reloadData()
            hideKeyboardButton.isHidden = true
    }
}
