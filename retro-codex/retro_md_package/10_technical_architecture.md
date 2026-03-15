[README に戻る](README.md)

# 10. 技術構成 / 実装方針 / 保存設計
Godot DocsはTileMapLayer/TileSetにより大規模なタイル描画が最適化されると説明しており [R4]、iOS/Android出力も公式にサポートする [R5]。Tiledはworldファイル、template、custom propertiesを備え [R6]、AsepriteはCLI export でatlas + metadataを書き出せる [R7]。この3つを直結した『2DタイルベースRPG向けの王道パイプライン』を構成する。

> **推奨フォルダ構成**
>
> /project
> /art
> /src/aseprite
> /export/atlas
> /maps
> /tiled/worlds
> /tiled/regions
> /data
> /master
> monster_master.json
> skill_master.json
> item_master.json
> npc_spawn.json
> /audio
> /scripts
> /ui
> /build

| **領域**     | **方針**                           | **補足**                                                    |
|--------------|------------------------------------|-------------------------------------------------------------|
| レンダリング | viewport + integer scaling         | fractional scale禁止。テクスチャフィルタはnearest。         |
| マップ       | Tiled JSON読込                     | object layersでNPC/warp/chest/triggerを配置。               |
| アセット     | Atlas化して読み込む                | 読み込みコストとdraw callを抑える。                         |
| 保存         | save slot 3 + autosave 1           | バージョン番号とマイグレーション関数を必須化。              |
| 入力         | ゲームパッド / キーボード / タッチ | すべて同一アクション名へ抽象化。                            |
| 移植         | iOSはmacOS + Xcode前提 [R5]      | リリース直前に慌てないよう、初期から署名/証明書手順を確認。 |

## 10.1 性能とロードの目標
| **項目**       | **目標**  | **備考**                                              |
|----------------|-----------|-------------------------------------------------------|
| フレームレート | 60fps     | 戦闘/探索ともに固定。低速端末では演出を落として維持。 |
| マップ遷移     | 2秒未満   | 暗転、ロード、フェードインを含む。                    |
| セーブ時間     | 1秒未満   | オートセーブでも待たせ過ぎない。                      |
| メニュー遷移   | 150ms以内 | もっさり感の排除。                                    |
| 戦闘開始演出   | 0.8秒以内 | 雰囲気を保ちつつ周回を阻害しない。                    |

> **セーブデータのサンプル構造**
>
> {
> "save_version": 1,
> "play_time_sec": 12840,
> "chapter": 3,
> "party": ["mon_seed_001#uid42", "mon_beast_004#uid77"],
> "box": [ ... ],
> "flags": {"gate_02_repaired": true},
> "quests": {"q_mire_stones": "done"},
> "options": {"battle_speed": 2, "theme": "moss"}
> }
