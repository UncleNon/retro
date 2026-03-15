using UnityEngine;
using System.Collections.Generic;
using System.Linq;

namespace MonsterChronicle.Monster
{
    /// <summary>
    /// 配合システム。系統×系統テーブル + 特殊配合レシピ。
    /// breeding-table.csv から読み込む想定。
    /// </summary>
    public class BreedingSystem : MonoBehaviour
    {
        [Header("Database")]
        [SerializeField] private MonsterDatabase _database;

        // 系統×系統 → 結果系統
        private Dictionary<(MonsterFamily, MonsterFamily), MonsterFamily> _familyTable = new();
        // 特殊配合: (親1ID, 親2ID) → 結果ID （順不同）
        private Dictionary<(int, int), int> _specialRecipes = new();

        private void Awake()
        {
            InitializeFamilyTable();
            InitializeSpecialRecipes();
        }

        /// <summary>配合結果を予測する（UI用）</summary>
        public BreedingResult Preview(MonsterInstance parent1, MonsterInstance parent2)
        {
            var result = new BreedingResult();

            // 特殊配合チェック（優先）
            int specialId = GetSpecialResult(parent1.masterData.id, parent2.masterData.id);
            if (specialId > 0)
            {
                result.resultMonster = _database.GetMonsterById(specialId);
                result.isSpecial = true;
            }
            else
            {
                // 系統×系統テーブルから結果系統を取得
                MonsterFamily resultFamily = GetFamilyResult(parent1.masterData.family, parent2.masterData.family);
                // 結果系統の中から、両親の平均ランク以上の最低ランクのモンスターを選択
                int avgRank = ((int)parent1.masterData.rank + (int)parent2.masterData.rank) / 2;
                result.resultMonster = _database.GetBestMonsterOfFamily(resultFamily, (MonsterRank)Mathf.Min(avgRank + 1, (int)MonsterRank.S));
                result.isSpecial = false;
            }

            // ステータス継承計算
            result.inheritedStats = CalculateInheritedStats(parent1, parent2);
            result.inheritableSkillTrees = GetInheritableSkillTrees(parent1, parent2);
            result.breedCount = parent1.breedCount + parent2.breedCount + 1;

            return result;
        }

        /// <summary>配合を実行する</summary>
        public MonsterInstance Execute(MonsterInstance parent1, MonsterInstance parent2, int[] selectedSkillTrees)
        {
            var preview = Preview(parent1, parent2);
            if (preview.resultMonster == null)
            {
                Debug.LogError("[BreedingSystem] No valid breeding result!");
                return null;
            }

            var child = new MonsterInstance(preview.resultMonster, 1);
            child.breedCount = preview.breedCount;

            // スキルツリー継承（最大3つ選択）
            for (int i = 0; i < Mathf.Min(selectedSkillTrees.Length, 3); i++)
            {
                child.skillTreeIds[i] = selectedSkillTrees[i];
            }

            // ステータスボーナス（両親平均の1/4を初期値に加算）
            // → breedCountがBonusFromBreedCountで反映されるため、ここでは設定のみ

            Debug.Log($"[BreedingSystem] {parent1.DisplayName} + {parent2.DisplayName} = {child.DisplayName}");
            return child;
        }

        /// <summary>配合可能かチェック</summary>
        public bool CanBreed(MonsterInstance m1, MonsterInstance m2)
        {
            if (m1 == null || m2 == null) return false;
            if (m1 == m2) return false;
            if (m1.level < 10 || m2.level < 10) return false;
            return true;
        }

        private int GetSpecialResult(int id1, int id2)
        {
            if (_specialRecipes.TryGetValue((id1, id2), out int result)) return result;
            if (_specialRecipes.TryGetValue((id2, id1), out result)) return result;
            return -1;
        }

        private MonsterFamily GetFamilyResult(MonsterFamily f1, MonsterFamily f2)
        {
            if (f1 > f2) (f1, f2) = (f2, f1); // 正規化
            if (_familyTable.TryGetValue((f1, f2), out var result)) return result;
            return f2; // デフォルトは第2親の系統
        }

        private int[] CalculateInheritedStats(MonsterInstance p1, MonsterInstance p2)
        {
            // 両親の現在ステータス平均の1/4
            return new int[]
            {
                (p1.MaxHP + p2.MaxHP) / 8,
                (p1.MaxMP + p2.MaxMP) / 8,
                (p1.ATK + p2.ATK) / 8,
                (p1.DEF + p2.DEF) / 8,
                (p1.SPD + p2.SPD) / 8,
                (p1.INT + p2.INT) / 8,
                (p1.RES + p2.RES) / 8,
            };
        }

        private List<int> GetInheritableSkillTrees(MonsterInstance p1, MonsterInstance p2)
        {
            var trees = new HashSet<int>();
            foreach (var id in p1.skillTreeIds.Concat(p2.skillTreeIds))
            {
                if (id > 0) trees.Add(id);
            }
            return trees.ToList();
        }

        private void InitializeFamilyTable()
        {
            // TODO: breeding-table.csv からロード。以下はハードコーディング版。
            void Add(MonsterFamily a, MonsterFamily b, MonsterFamily result)
            {
                if (a > b) (a, b) = (b, a);
                _familyTable[(a, b)] = result;
            }
            Add(MonsterFamily.Slime, MonsterFamily.Slime, MonsterFamily.Slime);
            Add(MonsterFamily.Slime, MonsterFamily.Beast, MonsterFamily.Beast);
            Add(MonsterFamily.Slime, MonsterFamily.Dragon, MonsterFamily.Dragon);
            Add(MonsterFamily.Beast, MonsterFamily.Beast, MonsterFamily.Beast);
            Add(MonsterFamily.Beast, MonsterFamily.Dragon, MonsterFamily.Dragon);
            Add(MonsterFamily.Dragon, MonsterFamily.Dragon, MonsterFamily.Dragon);
            // ... 残りは CSV ロード時に追加
        }

        private void InitializeSpecialRecipes()
        {
            // TODO: breeding-table.csv からロード。以下は主要レシピのみ。
            _specialRecipes[(9, 53)] = 97;   // キングレオ+ユニコーン=グリフォン
            _specialRecipes[(40, 35)] = 88;  // エルダードラゴン+リッチ=カオスドラゴン
            _specialRecipes[(42, 41)] = 43;  // ホーリー+ダーク=フレイムロード
            _specialRecipes[(88, 35)] = 47;  // カオスドラゴン+リッチ=ヴォイドマスター
            _specialRecipes[(3, 2)] = 75;    // キングスライミール+メタスライム=ダイヤモンドスライム
            // ... 残りは CSV ロード時に追加
        }
    }

    [System.Serializable]
    public class BreedingResult
    {
        public MonsterData resultMonster;
        public bool isSpecial;
        public int[] inheritedStats;
        public List<int> inheritableSkillTrees;
        public int breedCount;
    }
}
