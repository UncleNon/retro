using UnityEngine;

namespace MonsterChronicle.Monster
{
    public enum MonsterFamily { Slime, Beast, Bird, Plant, Magic, Material, Undead, Dragon, Divine }
    public enum Element { None, Fire, Water, Wind, Earth, Thunder, Light, Dark }
    public enum MonsterRank { E, D, C, B, A, S }
    public enum GrowthType { Early, Normal, Late }
    public enum SpriteSize { Small24, Medium32, Large48, Boss56 }

    /// <summary>
    /// モンスターのマスターデータ。ScriptableObjectとして管理。
    /// monster-list.csv からエディタツールで自動生成する想定。
    /// </summary>
    [CreateAssetMenu(fileName = "NewMonster", menuName = "MonsterChronicle/Monster Data")]
    public class MonsterData : ScriptableObject
    {
        [Header("基本情報")]
        public int id;
        public string nameJP;
        public string nameEN;
        public MonsterFamily family;
        public Element element;
        public MonsterRank rank;
        public SpriteSize spriteSize;
        [TextArea(2, 4)] public string description;

        [Header("基本ステータス (Lv1時)")]
        public int baseHP = 30;
        public int baseMP = 10;
        public int baseATK = 10;
        public int baseDEF = 10;
        public int baseSPD = 10;
        public int baseINT = 10; // かしこさ（魔法攻撃力）
        public int baseRES = 10; // まもり（魔法防御力）

        [Header("成長")]
        public GrowthType growthType = GrowthType.Normal;
        [Tooltip("成長率カーブ。X=レベル(0-1), Y=ステータス倍率")]
        public AnimationCurve growthCurve = AnimationCurve.Linear(0, 0, 1, 1);

        [Header("スキルツリー")]
        [Tooltip("最大3つのスキルツリーIDを設定")]
        public int[] defaultSkillTreeIds = new int[3];

        [Header("スプライト")]
        public Sprite battleSprite;
        public Sprite[] battleIdleFrames;   // 待機アニメ
        public Sprite[] battleAttackFrames; // 攻撃アニメ (S rankのみ)
        public Sprite fieldSprite;          // フィールド用 (同行表示)

        [Header("属性耐性")]
        [Range(0f, 2f)] public float fireResist = 1f;
        [Range(0f, 2f)] public float waterResist = 1f;
        [Range(0f, 2f)] public float windResist = 1f;
        [Range(0f, 2f)] public float earthResist = 1f;
        [Range(0f, 2f)] public float thunderResist = 1f;
        [Range(0f, 2f)] public float lightResist = 1f;
        [Range(0f, 2f)] public float darkResist = 1f;

        /// <summary>ステータス計算: レベルに応じたHP</summary>
        public int GetHP(int level) => CalculateStat(baseHP, level, 5f);
        public int GetMP(int level) => CalculateStat(baseMP, level, 3f);
        public int GetATK(int level) => CalculateStat(baseATK, level, 2f);
        public int GetDEF(int level) => CalculateStat(baseDEF, level, 2f);
        public int GetSPD(int level) => CalculateStat(baseSPD, level, 2f);
        public int GetINT(int level) => CalculateStat(baseINT, level, 2f);
        public int GetRES(int level) => CalculateStat(baseRES, level, 2f);

        private int CalculateStat(int baseStat, int level, float growthFactor)
        {
            float t = Mathf.Clamp01(level / 99f);
            float curve = growthCurve.Evaluate(t);
            return Mathf.RoundToInt(baseStat + (baseStat * growthFactor * curve));
        }

        /// <summary>属性相性によるダメージ倍率を返す</summary>
        public float GetElementResistance(Element attackElement)
        {
            return attackElement switch
            {
                Element.Fire => fireResist,
                Element.Water => waterResist,
                Element.Wind => windResist,
                Element.Earth => earthResist,
                Element.Thunder => thunderResist,
                Element.Light => lightResist,
                Element.Dark => darkResist,
                _ => 1f
            };
        }
    }
}
