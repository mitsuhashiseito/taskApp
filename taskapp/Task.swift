import RealmSwift

class Task: Object {
    //@Persisted 付きで宣言された変数は、Realmデータベースの読み書きの対象
    // 管理用 ID。プライマリーキー
    @Persisted(primaryKey: true) var id: ObjectId

    // タイトル
    @Persisted var title = ""

    // 内容
    @Persisted var contents = ""

    // 日時
    @Persisted var date = Date()
    
    //カテゴリー
    @Persisted var category = ""

}
