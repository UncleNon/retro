using UnityEngine;

namespace MonsterChronicle.Monster
{
    public enum Personality { Aggressive, Cautious, Timid, Wild }

    /// <summary>
    /// モンスターの個体データ（ランタイム）。マスターデータ(MonsterData)を参照しつつ
    /// 個体ごとのレベル・経験値・スキル・性格・なつき度を保持。
    /// </summary>
    [System.Serializable]
    public class MonsterInstance
    {
        public MonsterData masterData;
        public string nickname;
        public int level = 1;
        public int exp = 0;
        public int currentHP;
        public int currentMP;
        public Personality personality;
        public int loyalty;     // なつき度 0-255
        public int breedCount;  // 配合回数（プラス値ボーナス用）

        // スキルツリー
        public int[] skillTreeIds = new int[3];
        public int[] skillPoints = new int[3];
        public int availableSkillPoints = 0;

        // ステータス（キャッシュ）
        public int MaxHP => masterData.GetHP(level) + BonusFromBreedCount(masterData.baseHP);
        public int MaxMP => masterData.GetMP(level) + BonusFromBreedCount(masterData.baseMP);
        public int ATK => masterData.GetATK(level) + BonusFromBreedCount(masterData.baseATK);
        public int DEF => masterData.GetDEF(level) + BonusFromBreedCount(masterData.baseDEF);
        public int SPD => masterData.GetSPD(level) + BonusFromBreedCount(masterData.baseSPD);
        public int INT => masterData.GetINT(level) + BonusFromBreedCount(masterData.baseINT);
        public int RES => masterData.GetRES(level) + BonusFromBreedCount(masterData.baseRES);

        public bool IsAlive => currentHP > 0;
        public string DisplayName => string.IsNullOrEmpty(nickname) ? masterData.nameJP : nickname;

        public MonsterInstance() { }

        public MonsterInstance(MonsterData data, int startLevel = 1)
        {
            masterData = data;
            level = startLevel;
            currentHP = MaxHP;
            currentMP = MaxMP;
            personality = (Personality)Random.Range(0, 4);
            loyalty = 0;
            breedCount = 0;
            skillTreeIds = (int[])data.defaultSkillTreeIds.Clone();
            skillPoints = new int[3];
        }

        /// <summary>経験値を加算し、レベルアップ判定</summary>
        public bool AddExp(int amount)
        {
            exp += amount;
            int requiredExp = GetRequiredExp(level);
            if (exp >= requiredExp && level < 99)
            {
                exp -= requiredExp;
                level++;
                currentHP = MaxHP; // レベルアップ時に全回復
                currentMP = MaxMP;
                availableSkillPoints += 3;
                return true; // レベルアップした
            }
            return false;
        }

        /// <summary>レベルアップに必要な経験値（成長タイプ依存）</summary>
        public int GetRequiredExp(int currentLevel)
        {
            float baseExp = currentLevel * currentLevel * 5f + 10f;
            float modifier = masterData.growthType switch
            {
                GrowthType.Early => 0.8f,
                GrowthType.Late => 1.3f,
                _ => 1.0f
            };
            return Mathf.RoundToInt(baseExp * modifier);
        }

        /// <summary>配合回数によるボーナス（プラス値）</summary>
        private int BonusFromBreedCount(int baseStat)
        {
            // 配合回数1回につき基礎ステの2%加算、最大+50%
            float bonus = Mathf.Min(breedCount * 0.02f, 0.5f);
            return Mathf.RoundToInt(baseStat * bonus);
        }

        /// <summary>ダメージを受ける</summary>
        public void TakeDamage(int damage)
        {
            currentHP = Mathf.Max(0, currentHP - damage);
        }

        /// <summary>HP回復</summary>
        public void Heal(int amount)
        {
            currentHP = Mathf.Min(MaxHP, currentHP + amount);
        }

        /// <summary>MP消費</summary>
        public bool ConsumeMP(int cost)
        {
            if (currentMP < cost) return false;
            currentMP -= cost;
            return true;
        }

        /// <summary>完全回復</summary>
        public void FullRestore()
        {
            currentHP = MaxHP;
            currentMP = MaxMP;
        }
    }
}
