using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace MonsterChronicle.Battle
{
    public enum BattleState { Start, PlayerTurn, EnemyTurn, ExecuteActions, CheckResult, Victory, Defeat, Escape, ScoutSuccess }
    public enum BattleCommand { Attack, Spell, Defend, Escape }
    public enum TacticOrder { AllOut, Cautious, SpellFocus, HealFirst }

    /// <summary>
    /// ターン制バトルのステートマシン。DQM準拠の3vs3コマンドバトル。
    /// </summary>
    public class BattleManager : MonoBehaviour
    {
        public static BattleManager Instance { get; private set; }

        [Header("State")]
        [SerializeField] private BattleState _state = BattleState.Start;
        public BattleState State => _state;

        [Header("Party")]
        public List<BattleUnit> playerParty = new();
        public List<BattleUnit> enemyParty = new();

        [Header("Settings")]
        [SerializeField] private float _textSpeed = 0.05f;

        // Events
        public System.Action<BattleState> OnStateChanged;
        public System.Action<BattleUnit, BattleUnit, int> OnDamageDealt;
        public System.Action<BattleUnit, int> OnHealed;
        public System.Action<string> OnBattleMessage;

        private List<BattleAction> _turnActions = new();
        private TacticOrder _currentTactic = TacticOrder.AllOut;

        private void Awake()
        {
            Instance = this;
        }

        /// <summary>バトル開始</summary>
        public void StartBattle(Monster.MonsterInstance[] party, Monster.MonsterData[] enemies, int[] enemyLevels)
        {
            playerParty.Clear();
            enemyParty.Clear();

            for (int i = 0; i < party.Length; i++)
            {
                if (party[i] != null && party[i].IsAlive)
                    playerParty.Add(new BattleUnit(party[i], true));
            }

            for (int i = 0; i < enemies.Length; i++)
            {
                var enemyInstance = new Monster.MonsterInstance(enemies[i], enemyLevels[i]);
                enemyParty.Add(new BattleUnit(enemyInstance, false));
            }

            ChangeState(BattleState.Start);
            StartCoroutine(BattleLoop());
        }

        private IEnumerator BattleLoop()
        {
            OnBattleMessage?.Invoke("モンスターが あらわれた！");
            yield return new WaitForSeconds(1f);

            while (_state != BattleState.Victory && _state != BattleState.Defeat && _state != BattleState.Escape)
            {
                // プレイヤーターン: コマンド入力待ち
                ChangeState(BattleState.PlayerTurn);
                _turnActions.Clear();

                // 作戦に基づいてAI or プレイヤー入力でアクション決定
                yield return WaitForPlayerInput();

                // 敵のアクション決定
                ChangeState(BattleState.EnemyTurn);
                DetermineEnemyActions();

                // アクション実行
                ChangeState(BattleState.ExecuteActions);
                yield return ExecuteAllActions();

                // 結果チェック
                ChangeState(BattleState.CheckResult);
                if (CheckAllDefeated(enemyParty))
                {
                    ChangeState(BattleState.Victory);
                    yield return HandleVictory();
                    yield break;
                }
                if (CheckAllDefeated(playerParty))
                {
                    ChangeState(BattleState.Defeat);
                    yield return HandleDefeat();
                    yield break;
                }
            }
        }

        private IEnumerator WaitForPlayerInput()
        {
            // TODO: UIからのコマンド入力を待つ。
            // 作戦が「がんがんいこうぜ」等の場合はAI自動決定。
            // 仮実装: 全員たたかう
            foreach (var unit in playerParty)
            {
                if (!unit.Monster.IsAlive) continue;
                var target = GetRandomAliveUnit(enemyParty);
                if (target != null)
                    _turnActions.Add(new BattleAction(unit, target, BattleCommand.Attack));
            }
            yield return null;
        }

        private void DetermineEnemyActions()
        {
            foreach (var unit in enemyParty)
            {
                if (!unit.Monster.IsAlive) continue;
                var target = GetRandomAliveUnit(playerParty);
                if (target != null)
                    _turnActions.Add(new BattleAction(unit, target, BattleCommand.Attack));
            }
        }

        private IEnumerator ExecuteAllActions()
        {
            // 素早さ順にソート（ランダム変動あり）
            _turnActions.Sort((a, b) =>
            {
                int spdA = a.Attacker.Monster.SPD + Random.Range(-5, 6);
                int spdB = b.Attacker.Monster.SPD + Random.Range(-5, 6);
                return spdB.CompareTo(spdA);
            });

            foreach (var action in _turnActions)
            {
                if (!action.Attacker.Monster.IsAlive) continue;
                if (!action.Target.Monster.IsAlive)
                    action.Target = GetRandomAliveUnit(action.Attacker.IsPlayer ? enemyParty : playerParty);
                if (action.Target == null) continue;

                yield return ExecuteAction(action);
                yield return new WaitForSeconds(0.3f);
            }
        }

        private IEnumerator ExecuteAction(BattleAction action)
        {
            switch (action.Command)
            {
                case BattleCommand.Attack:
                    int damage = DamageCalculator.CalcPhysical(action.Attacker.Monster, action.Target.Monster);
                    action.Target.Monster.TakeDamage(damage);
                    OnDamageDealt?.Invoke(action.Attacker, action.Target, damage);
                    OnBattleMessage?.Invoke($"{action.Attacker.Monster.DisplayName}の こうげき！ {action.Target.Monster.DisplayName}に {damage}の ダメージ！");
                    if (!action.Target.Monster.IsAlive)
                    {
                        OnBattleMessage?.Invoke($"{action.Target.Monster.DisplayName}を たおした！");
                    }
                    break;

                case BattleCommand.Defend:
                    action.Attacker.IsDefending = true;
                    OnBattleMessage?.Invoke($"{action.Attacker.Monster.DisplayName}は みをまもっている！");
                    break;

                case BattleCommand.Escape:
                    if (TryEscape())
                    {
                        OnBattleMessage?.Invoke("うまく にげきれた！");
                        ChangeState(BattleState.Escape);
                        yield break;
                    }
                    OnBattleMessage?.Invoke("にげられない！");
                    break;
            }
            yield return new WaitForSeconds(0.5f);
        }

        private IEnumerator HandleVictory()
        {
            int totalExp = 0;
            int totalGold = 0;
            foreach (var enemy in enemyParty)
            {
                totalExp += enemy.Monster.level * 10 + (int)enemy.Monster.masterData.rank * 15;
                totalGold += enemy.Monster.level * 5 + (int)enemy.Monster.masterData.rank * 8;
            }

            OnBattleMessage?.Invoke($"たたかいに かった！ {totalExp}の けいけんちを かくとく！");
            yield return new WaitForSeconds(1f);

            foreach (var unit in playerParty)
            {
                if (unit.Monster.IsAlive && unit.Monster.AddExp(totalExp))
                {
                    OnBattleMessage?.Invoke($"{unit.Monster.DisplayName}は レベル{unit.Monster.level}に あがった！");
                    yield return new WaitForSeconds(0.8f);
                }
            }
        }

        private IEnumerator HandleDefeat()
        {
            OnBattleMessage?.Invoke("ぜんめつ してしまった...");
            yield return new WaitForSeconds(2f);
        }

        public void SetTactic(TacticOrder tactic) => _currentTactic = tactic;

        private bool CheckAllDefeated(List<BattleUnit> party)
        {
            foreach (var u in party) if (u.Monster.IsAlive) return false;
            return true;
        }

        private BattleUnit GetRandomAliveUnit(List<BattleUnit> party)
        {
            var alive = party.FindAll(u => u.Monster.IsAlive);
            return alive.Count > 0 ? alive[Random.Range(0, alive.Count)] : null;
        }

        private bool TryEscape()
        {
            float avgPlayerSpd = 0, avgEnemySpd = 0;
            int pc = 0, ec = 0;
            foreach (var u in playerParty) if (u.Monster.IsAlive) { avgPlayerSpd += u.Monster.SPD; pc++; }
            foreach (var u in enemyParty) if (u.Monster.IsAlive) { avgEnemySpd += u.Monster.SPD; ec++; }
            if (pc > 0) avgPlayerSpd /= pc;
            if (ec > 0) avgEnemySpd /= ec;
            float chance = 0.5f + (avgPlayerSpd - avgEnemySpd) * 0.02f;
            return Random.value < Mathf.Clamp(chance, 0.1f, 0.9f);
        }

        private void ChangeState(BattleState newState)
        {
            _state = newState;
            OnStateChanged?.Invoke(newState);
        }
    }

    [System.Serializable]
    public class BattleUnit
    {
        public Monster.MonsterInstance Monster;
        public bool IsPlayer;
        public bool IsDefending;
        public BattleUnit(Monster.MonsterInstance monster, bool isPlayer)
        {
            Monster = monster;
            IsPlayer = isPlayer;
        }
    }

    public class BattleAction
    {
        public BattleUnit Attacker;
        public BattleUnit Target;
        public BattleCommand Command;
        public int SkillId; // 呪文/特技ID（0 = 通常攻撃）
        public BattleAction(BattleUnit attacker, BattleUnit target, BattleCommand cmd, int skillId = 0)
        {
            Attacker = attacker; Target = target; Command = cmd; SkillId = skillId;
        }
    }
}
