# 13. Act I-II Item Text Routing Ledger

> **ステータス**: Draft v1.0
> **最終更新**: 2026-03-16
> **役割**: `W-002〜W-007` の item provenance text を `field_point / field_interaction / npc ambient / shop hover` へ結び、実装側がそのまま拾える routing 台帳にする
> **参照元**:
> - `docs/specs/content/12_item_provenance_inspect_and_shop_text_pack.md`
> - `docs/specs/worlds/14_starting_arc_map_and_secret_blueprints.md`
> - `docs/specs/worlds/15_act_ii_bridge_map_and_secret_blueprints.md`
> - `docs/specs/systems/01_numeric_rules_and_master_schema.md`
> - `docs/specs/systems/07_progress_flags_and_save_state_model.md`

---

## 1. 目的

- text pack を `いい文がある` 状態で止めず、`どの point_id / 条件 / 優先度で出すか` まで固定する
- provenance inspect の `初回 -> 再読` を、`field_interaction_master` の row へ分解できる形にする
- shop bark と shelf strip を、後の UI / NPC 実装で迷わないように carrier 単位で束ねる

---

## 2. Routing Contract

### 2.1 inspect routing

| 項目 | 方針 |
|------|------|
| `point_id` | world + item residue を示す slug を正とする |
| `subject_kind` | すべて `point` |
| `condition_key` | 初回は `always`、再読は `flag:clue.CL-xxx.seen` か `flag:<secret_flag>` を使う |
| `priority` | 再読が `10`、初回が `20`。再読条件が満たされたら必ずそちらを優先する |
| `set_flag_key` | 初回だけ `itx_wxx_yy_seen` を立てる。再読は原則立てない |
| `clue_ids` | 初回で拾う clue のみ入れる。再読は追加 clue を持たせない |

### 2.2 shop / ambient routing

| 項目 | 方針 |
|------|------|
| carrier | `npc ambient` または `shop hover` に流す |
| text source | canonical pack の `nearby voice` / `shelf strip` を使う |
| trigger | `item focus`, `counter inspect`, `buy confirm`, `world clear 後` のいずれか |
| npc stub | 実装前は role stub を正とし、後で canonical `npc_id` へ落とす |

### 2.3 naming note

- `field_point_id` や `field_interaction_id` の連番は build 時に振れるので、この文書では `point_id` と `interaction_stub` を authority にする
- `interaction_stub` は `IROW-Wxx-yy-a/b` で管理し、`a=first`, `b=repeat` を基本とする

---

## 3. Inspect Routing

| text source | map_id | point_id | interaction_stub | priority | condition_key | set_flag_key | clue_ids | notes |
|-------------|--------|----------|------------------|---------:|---------------|--------------|----------|-------|
| `ITX-W02-01:first` | `MAP-W02-002` | `w02_stillmilk_shelf` | `IROW-W02-01-a` | 20 | `always` | `itx_w02_01_seen` | `CL-067` | 第一母屋の冷灰棚 |
| `ITX-W02-01:repeat` | `MAP-W02-002` | `w02_stillmilk_shelf` | `IROW-W02-01-b` | 10 | `flag:clue.CL-067.seen` |  |  | clue 後は repeat 優先 |
| `ITX-W02-02:first` | `MAP-W02-004` | `w02_sourmilk_vat` | `IROW-W02-02-a` | 20 | `always` | `itx_w02_02_seen` | `CL-011` | 発酵桶の影 |
| `ITX-W02-02:repeat` | `MAP-W02-004` | `w02_sourmilk_vat` | `IROW-W02-02-b` | 10 | `flag:sec_w02_01_resolved` |  |  | `SEC-W02-01` 後 |
| `ITX-W02-03:first` | `MAP-W02-006` | `w02_ashbrand_altar` | `IROW-W02-03-a` | 20 | `always` | `itx_w02_03_seen` | `CL-012` | 裏龕の灰盤 |
| `ITX-W02-03:repeat` | `MAP-W02-006` | `w02_ashbrand_altar` | `IROW-W02-03-b` | 10 | `flag:clue.CL-012.seen` |  |  | 家順の意味が出る |
| `ITX-W03-01:first` | `MAP-W03-001` | `w03_clearwater_bucket` | `IROW-W03-01-a` | 20 | `always` | `itx_w03_01_seen` | `CL-013` | 門前の喉桶台 |
| `ITX-W03-01:repeat` | `MAP-W03-001` | `w03_clearwater_bucket` | `IROW-W03-01-b` | 10 | `flag:clue.CL-013.seen` |  |  | 宿帳 logic が見える |
| `ITX-W03-02:first` | `MAP-W03-003` | `w03_hostellamp_shelf` | `IROW-W03-02-a` | 20 | `always` | `itx_w03_02_seen` | `CL-014` | 奥灯棚 |
| `ITX-W03-02:repeat` | `MAP-W03-003` | `w03_hostellamp_shelf` | `IROW-W03-02-b` | 10 | `flag:sec_w03_01_resolved` |  |  | 重複灯番号確認後 |
| `ITX-W03-03:first` | `MAP-W03-004` | `w03_tagcase_drawer` | `IROW-W03-03-a` | 20 | `always` | `itx_w03_03_seen` | `CL-068` | 代書机の抽斗 |
| `ITX-W03-03:repeat` | `MAP-W03-004` | `w03_tagcase_drawer` | `IROW-W03-03-b` | 10 | `flag:clue.CL-068.seen` |  |  | provisional 同寸文化 |
| `ITX-W04-01:first` | `MAP-W04-002` | `w04_passpeg_board` | `IROW-W04-01-a` | 20 | `always` | `itx_w04_01_seen` | `CL-015` | peg board |
| `ITX-W04-01:repeat` | `MAP-W04-002` | `w04_passpeg_board` | `IROW-W04-01-b` | 10 | `flag:clue.CL-015.seen` |  |  | 通行順と隔離順の一致 |
| `ITX-W04-02:first` | `MAP-W04-003` | `w04_bellsalt_basket` | `IROW-W04-02-a` | 20 | `always` | `itx_w04_02_seen` | `CL-069` | 塩鈴籠 |
| `ITX-W04-02:repeat` | `MAP-W04-003` | `w04_bellsalt_basket` | `IROW-W04-02-b` | 10 | `flag:clue.CL-069.seen` |  |  | bell-route の商い化 |
| `ITX-W04-03:first` | `MAP-W04-010` | `w04_bonerope_post` | `IROW-W04-03-a` | 20 | `always` | `itx_w04_03_seen` | `CL-031` | 退避杭 |
| `ITX-W04-03:repeat` | `MAP-W04-010` | `w04_bonerope_post` | `IROW-W04-03-b` | 10 | `flag:sec_w04_02_resolved` |  |  | 裏舟実例後 |
| `ITX-W05-01:first` | `MAP-W05-002` | `w05_softmoss_shelf` | `IROW-W05-01-a` | 20 | `always` | `itx_w05_01_seen` | `CL-017` | 湿石の手当棚 |
| `ITX-W05-01:repeat` | `MAP-W05-002` | `w05_softmoss_shelf` | `IROW-W05-01-b` | 10 | `flag:clue.CL-017.seen` |  |  | 待つ家への偏り |
| `ITX-W05-02:first` | `MAP-W05-005` | `w05_graveflour_offering_shelf` | `IROW-W05-02-a` | 20 | `always` | `itx_w05_02_seen` | `CL-070` | 粉灯壺と供物束棚 |
| `ITX-W05-02:repeat` | `MAP-W05-005` | `w05_graveflour_offering_shelf` | `IROW-W05-02-b` | 10 | `flag:clue.CL-070.seen` |  |  | grief と商いの同棚 |
| `ITX-W05-03:first` | `MAP-W05-006` | `w05_gravesalt_basin` | `IROW-W05-03-a` | 20 | `always` | `itx_w05_03_seen` | `CL-018` | 閉じ盆 |
| `ITX-W05-03:repeat` | `MAP-W05-006` | `w05_gravesalt_basin` | `IROW-W05-03-b` | 10 | `flag:sec_w05_01_resolved` |  |  | 仕入れ札確認後 |
| `ITX-W06-01:first` | `MAP-W06-004` | `w06_belltube_board` | `IROW-W06-01-a` | 20 | `always` | `itx_w06_01_seen` | `CL-020` | 音孔見本板 |
| `ITX-W06-01:repeat` | `MAP-W06-004` | `w06_belltube_board` | `IROW-W06-01-b` | 10 | `flag:clue.CL-020.seen` |  |  | 人名より音癖 |
| `ITX-W06-02:first` | `MAP-W06-006` | `w06_bellgrain_sacks` | `IROW-W06-02-a` | 20 | `always` | `itx_w06_02_seen` | `CL-019` | 穀袋台 |
| `ITX-W06-02:repeat` | `MAP-W06-006` | `w06_bellgrain_sacks` | `IROW-W06-02-b` | 10 | `flag:sec_w06_02_resolved` |  |  | 借り鈴束確認後 |
| `ITX-W06-03:first` | `MAP-W06-008` | `w06_silentcloth_line` | `IROW-W06-03-a` | 20 | `always` | `itx_w06_03_seen` | `CL-071` | 乾し縄 |
| `ITX-W06-03:repeat` | `MAP-W06-008` | `w06_silentcloth_line` | `IROW-W06-03-b` | 10 | `flag:clue.CL-071.seen` |  |  | 閉鐘模造の流入 |
| `ITX-W07-01:first` | `MAP-W07-004` | `w07_namefoil_table` | `IROW-W07-01-a` | 20 | `always` | `itx_w07_01_seen` | `CL-072` | 貼り替え机 |
| `ITX-W07-01:repeat` | `MAP-W07-004` | `w07_namefoil_table` | `IROW-W07-01-b` | 10 | `flag:clue.CL-072.seen` |  |  | 祖棚 / 役棚 同型 |
| `ITX-W07-02:first` | `MAP-W07-009` | `w07_inkpaste_desk` | `IROW-W07-02-a` | 20 | `always` | `itx_w07_02_seen` | `CL-021` | 湿写し台 |
| `ITX-W07-02:repeat` | `MAP-W07-009` | `w07_inkpaste_desk` | `IROW-W07-02-b` | 10 | `flag:sec_w07_03_resolved` |  |  | 控え帳確認後 |
| `ITX-W07-03:first` | `MAP-W07-006` | `w07_namewax_shelf` | `IROW-W07-03-a` | 20 | `always` | `itx_w07_03_seen` | `CL-022` | 再封小棚 |
| `ITX-W07-03:repeat` | `MAP-W07-006` | `w07_namewax_shelf` | `IROW-W07-03-b` | 10 | `flag:clue.CL-021.seen` |  |  | 役名市場の logic 理解後 |

---

## 4. Shop / Ambient Routing

| text source | world | carrier_stub | carrier_kind | trigger | related_item | notes |
|-------------|-------|--------------|--------------|---------|--------------|-------|
| `ITX-W02-01:voice` | `W-002` | `npc_w02_motherhouse_woman` | `npc ambient` | `counter inspect` | `item_heal_stillmilk` | 第一母屋前の短台詞 |
| `ITX-W02-02:voice` | `W-002` | `npc_w02_beast_keeper` | `shop hover` | `item focus` | `item_bait_sourmilk` | 谷下の獣番売り |
| `ITX-W03-01:voice` | `W-003` | `npc_w03_gate_inn_clerk` | `shop hover` | `item focus` | `item_mp_clearwater` | 喉桶台脇の clerk |
| `ITX-W03-03:voice` | `W-003` | `npc_w03_scrivener` | `npc ambient` | `drawer inspect nearby` | `item_record_tagcase` | 代書屋のぼやき |
| `ITX-W04-01:voice` | `W-004` | `npc_w04_checkpoint_clerk` | `npc ambient` | `peg board inspect nearby` | `item_key_passpeg` | 潮待ち euphemism を出す |
| `ITX-W04-02:voice` | `W-004` | `npc_w04_tide_shed_laborer` | `shop hover` | `item focus` | `item_catalyst_bellsalt` | 鈴塩の利幅を匂わせる |
| `ITX-W04-03:voice` | `W-004` | `npc_w04_backboat_rower` | `npc ambient` | `rope post inspect nearby` | `item_field_bonerope` | 裏舟の practical talk |
| `ITX-W05-01:voice` | `W-005` | `npc_w05_grave_sweeper` | `npc ambient` | `shelf inspect nearby` | `item_heal_softmoss` | 待つ家への偏りを言う |
| `ITX-W05-02:voice` | `W-005` | `npc_w05_offering_vendor` | `shop hover` | `item focus` | `item_key_memorialoffering` | 待つ grief の市場性 |
| `ITX-W05-03:voice` | `W-005` | `npc_w05_grave_keeper` | `npc ambient` | `gravesalt inspect nearby` | `item_key_gravesalt` | `件が片づく` euphemism |
| `ITX-W06-01:voice` | `W-006` | `npc_w06_belltube_keeper` | `shop hover` | `item focus` | `item_record_belltube` | 名より音を優先する |
| `ITX-W06-03:voice` | `W-006` | `npc_w06_night_ferrier` | `npc ambient` | `silentcloth inspect nearby` | `item_field_silentcloth` | 慰撫 / 黙らせ の二重性 |
| `ITX-W07-01:voice` | `W-007` | `npc_w07_badge_broker` | `shop hover` | `item focus` | `item_record_namefoil` | 貼り替え痕の売値 |
| `ITX-W07-02:voice` | `W-007` | `npc_w07_lower_ink_vendor` | `npc ambient` | `ink desk inspect nearby` | `item_record_inkpaste` | 誰の字でもよい logic |
| `ITX-W07-03:voice` | `W-007` | `npc_w07_reseal_mediator` | `shop hover` | `item focus` | `item_catalyst_namewax` | 通る名ならよい本音 |

---

## 5. Shelf Strip Reuse

| text source | reuse surface | primary key |
|-------------|---------------|-------------|
| `ITX-W02-01:strip` | field inspect footer / shop hover | `item_heal_stillmilk` |
| `ITX-W03-03:strip` | record item hover / desk inspect footer | `item_record_tagcase` |
| `ITX-W04-02:strip` | catalyst hover / salt basket inspect footer | `item_catalyst_bellsalt` |
| `ITX-W05-02:strip` | shrine shelf footer / offering vendor hover | `item_key_memorialoffering` |
| `ITX-W06-01:strip` | record item hover / bell board footer | `item_record_belltube` |
| `ITX-W07-01:strip` | record item hover / badge workshop footer | `item_record_namefoil` |

---

## 6. Implementation Notes

- `field_point_master.point_id` はこの ledger の `point_id` を優先し、`field_point_id` は後で連番採番する
- `field_interaction_master.subject_id` には `point_id` をそのまま入れる
- `message_jp` は canonical pack の variant を貼るだけでよい
- `shelf strip / shop bark` は Session follow-up で `item_text_master.csv` に materialize し、`text_source` でこの ledger の source 名へ戻れるようにする
- `shop bark` を `field_interaction_master` へ寄せる場合は、counter point を `point_kind=npc/facility` で生やしてよい
- `reinspect` の条件は global clue flag を優先し、secret 専用のものだけ local flag を使う

---

## 7. QA Checklist

- すべての provenance text に `point_id` と `condition_key` があるか
- 再読 row の priority が初回 row より高いか
- `clue.CL-xxx.seen` と `sec_xxx_resolved` の使い分けが妥当か
- ambient / hover / inspect の carrier が混線していないか
- canonical text pack と routing ledger の text source 名が一致しているか
