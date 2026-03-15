using UnityEngine;
using MonsterChronicle.Monster;

namespace MonsterChronicle.Battle
{
    /// <summary>ダメージ計算。属性相性・防御・クリティカル・ランダム変動を考慮。</summary>
    public static class DamageCalculator
    {
        private const float CRITICAL_RATE = 0.0625f; // 1/16
        private const float CRITICAL_MULTIPLIER = 1.5f;
        private const float RANDOM_MIN = 0.85f;
        private const float RANDOM_MAX = 1.0f;

        public static int CalcPhysical(MonsterInstance attacker, MonsterInstance defender)
        {
            float atk = attacker.ATK;
            float def = defender.DEF;
            float baseDmg = Mathf.Max(1, (atk * 0.5f) - (def * 0.25f));
            float random = Random.Range(RANDOM_MIN, RANDOM_MAX);
            bool crit = Random.value < CRITICAL_RATE;
            float critMul = crit ? CRITICAL_MULTIPLIER : 1f;
            bool defending = false; // TODO: BattleUnit.IsDefending参照
            float defMul = defending ? 0.5f : 1f;
            return Mathf.Max(1, Mathf.RoundToInt(baseDmg * random * critMul * defMul));
        }

        public static int CalcMagical(MonsterInstance attacker, MonsterInstance defender, Element element, int basePower)
        {
            float intel = attacker.INT;
            float res = defender.RES;
            float baseDmg = (basePower + intel * 0.3f) - (res * 0.2f);
            float elementMul = defender.masterData.GetElementResistance(element);
            float random = Random.Range(RANDOM_MIN, RANDOM_MAX);
            return Mathf.Max(1, Mathf.RoundToInt(baseDmg * elementMul * random));
        }

        /// <summary>属性相性テキスト取得</summary>
        public static string GetEffectivenessText(float multiplier)
        {
            if (multiplier >= 2f) return "こうかばつぐん！";
            if (multiplier <= 0f) return "こうかが なかった...";
            if (multiplier <= 0.5f) return "こうかは いまひとつ...";
            return "";
        }
    }
}
