[README に戻る](README.md)

# 9. AI生成ツール評価と一貫性維持ワークフロー
Google DeepMindのNano Banana prompt guideは、制作向け仕様の明示、複数案の同時生成、参照画像をアップロードしてキャラクターに固有名を与えることで subject consistency を維持できると案内している [R9]。Gemini API/Google blogはNano Banana 2 と Nano Banana Pro の2系統を提示し、Nano Banana 2 を高速・高効率、Nano Banana Pro を高品質用途と位置付けている [R9]。OpenAIの画像生成ガイドは参照画像を使った新規生成、既存画像の編集、マスク編集をサポートし [R8]、GPT Image 1.5 prompting guide は“何を変え、何を変えないかを毎回明示する”差分編集ワークフローを強く推している [R8]。

さらに、Midjourneyは Character Reference と Style Reference を正式提供しており [R10]、Adobe Fireflyは構図参照、スタイル参照、さらに2026年3月時点でStyle IDsによるブランド一貫生成を案内している [R11]。一方、Recraft自身のbest practicesでは dedicated character tracking は持たないと明記している [R12]。したがって、本件で“最終成果物の一貫性”を優先するなら、主戦力は Nano Banana 2/Pro と GPT Image 1.5 の二本立てが妥当である。X上でもGoogleAIStudio公式はNano Banana Proのベストプラクティス共有、GeminiApp公式は16-bit art showcase を出しており、レトロ資産制作の実験が前提機能として扱われ始めている [R14][R15]。

| **ツール**      | **強い点**                                      | **弱い点**                           | **使い所**                           | **判定** |
|-----------------|-------------------------------------------------|--------------------------------------|--------------------------------------|----------|
| Nano Banana 2   | 高速、多案、subject consistency、4K/多AR [R9] | 最終ピクセル精度は人手補正前提       | ムードボード、タイル案、立ち絵差分   | 主力     |
| Nano Banana Pro | 高品質・高忠実度 [R9]                         | 速度/コスト重め                      | 主要キャラ、キービジュアル、最重要案 | 主力     |
| GPT Image 1.5   | 参照保持、差分編集、反復編集 [R8]             | 大量バリエーションでは速度負けし得る | 一貫性の高い修正、UIモック、差し替え | 主力     |
| Midjourney      | cref/sref による雰囲気統一 [R10]              | 工程管理と差分編集は弱め             | 初期ムードボード                     | 補助     |
| Adobe Firefly   | 構図参照、Style IDs [R11]                     | 企業/ブランド系前提が強い            | 販促物や企業案件の整合               | 補助     |

## 9.1 推奨ワークフロー
| **段階** | **担当ツール**                  | **実施内容**                                                                   |
|----------|---------------------------------|--------------------------------------------------------------------------------|
| 0        | 手動                            | スタイルバイブル作成。パレット、輪郭ルール、影方向、比率、禁止事項を先に固定。 |
| 1        | Nano Banana 2                   | 世界観・地域・UIの多案出し。1プロンプトで3〜4変種を比較。                      |
| 2        | Nano Banana Pro / GPT Image 1.5 | 主要キャラ、スターター、ボス、主要UIの参照シートを作る。                       |
| 3        | GPT Image 1.5                   | 既存参照から差分編集。『変える点 / 変えない点』を明示してドリフトを抑える。    |
| 4        | Aseprite                        | パレット固定、輪郭整理、タイル継ぎ目修正、アイコン化、アニメ化。               |
| 5        | Tiled + Godot                   | 実装・表示・衝突・画面密度を検証。必要ならAI工程に戻る。                       |

## 9.2 一貫性を壊さないための運用ルール
C-01: キャラクターごとに“固定参照パック”を持つ。正面/側面/3/4、色見本、比率メモ、禁止変形をまとめる。

C-02: モデルへ渡す名前を固定する。毎回別名にしない。Nano Banana系は固有名付与でsubject consistencyを上げられる [R9]。

C-03: 1プロンプト1アセット種別。タイル、立ち絵、戦闘顔、UIを同時に作らせない。

C-04: 差分編集では『変える点』『維持点』を毎回再記述する。OpenAI cookbookは invariants 再記述を強く推す [R8]。

C-05: 最終採用アセットは必ず管理表へ記録する。tool / model / date / prompt hash / reference IDs / human cleanup 担当を残す。

C-06: 商用出荷候補のプロンプトには“original artwork only / no logos / no trademarks / no watermarks”を明記する [R8]。
