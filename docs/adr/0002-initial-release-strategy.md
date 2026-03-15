# ADR-0002 Initial Release Strategy

- Status: Accepted
- Date: 2026-03-15

## Context

North Star としては 20+世界、400体、長編ストーリー、重いエンドコンテンツを目指す一方、途中の検証用マイルストーンと本番出荷スコープを混同すると計画が崩れやすい。

## Decision

- 大規模ビジョンは North Star として維持する
- Vertical Slice と MVP を中間マイルストーンとして置く
- Initial Release は検証マイルストーンとは分けて扱い、本番品質を優先して別途確定する
- Initial Release の世界数は 20以上で進める
- Initial Release のモンスター数は 400体で進める
- Initial Release 時点でメインストーリーは完結させる
- Initial Release には裏ボス、裏ダンジョン、無限ダンジョンを含める
- iCloud同期は価値が高くても、実装コストが重ければ Initial Release 必須にはしない

## Rationale

- この企画の価値は量だけでなく、配合の深さ、愛着設計、世界の不穏さ、UIの手触りにある
- 検証用の縮小スコープは必要だが、それをそのまま本番出荷定義にすると意図とズレる
- 拡張可能な構造を先に作っておけば、後から安全に世界とモンスターを増やせる

## Consequences

- ドキュメントでは North Star / Vertical Slice / MVP / Initial Release を分けて扱う
- 5世界 / 30体 は本番出荷ではなく MVP として扱う
- Initial Release の具体的な規模は、MVP の実測を見つつも、世界数は 20以上、モンスター数は 400体、エンドコンテンツは必須を維持する
- 裏ストーリーは本編未完の救済ではなく、完結した本編を深掘りする追加層として扱う
- セーブの基準線はローカル保存とし、iCloudは採用時のみ加点要素として扱う
