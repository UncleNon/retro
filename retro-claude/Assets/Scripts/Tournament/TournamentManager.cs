using UnityEngine;

namespace MonsterChronicle.Tournament
{
    public enum TournamentRank { G, F, E, D, C, B, A, StarFall }

    /// <summary>闘技場トーナメント管理。4連戦勝ち抜き × 8ランク。</summary>
    public class TournamentManager : MonoBehaviour
    {
        [SerializeField] private int _matchesPerRound = 4;
        [SerializeField] private int[] _levelCaps = { 10, 20, 30, 40, 50, 60, 75, 99 };

        private TournamentRank _currentRank;
        private int _currentMatch;
        private bool _inProgress;

        public TournamentRank CurrentRank => _currentRank;
        public int CurrentMatch => _currentMatch;
        public bool InProgress => _inProgress;
        public int LevelCap => _levelCaps[Mathf.Min((int)_currentRank, _levelCaps.Length - 1)];

        public System.Action<int> OnMatchWon;
        public System.Action OnTournamentWon;
        public System.Action OnTournamentLost;

        public bool CanEnter(Monster.MonsterInstance[] party)
        {
            int cap = LevelCap;
            foreach (var m in party)
                if (m != null && m.level > cap) return false;
            return true;
        }

        public void StartTournament(TournamentRank rank)
        {
            _currentRank = rank;
            _currentMatch = 0;
            _inProgress = true;
            Debug.Log($"[Tournament] Started: {rank} rank (Lv cap: {LevelCap})");
        }

        public Monster.MonsterData[] GenerateOpponent(Monster.MonsterDatabase db)
        {
            int count = Mathf.Min(_currentMatch + 1, 3);
            var opponents = new Monster.MonsterData[count];
            var all = db.AllMonsters;
            for (int i = 0; i < count; i++)
            {
                int attempts = 0;
                do { opponents[i] = all[Random.Range(0, all.Length)]; attempts++; }
                while (opponents[i] == null && attempts < 100);
            }
            return opponents;
        }

        public int GetOpponentLevel() => Mathf.Min(LevelCap, LevelCap - 5 + _currentMatch * 3);

        public void ReportMatchResult(bool won)
        {
            if (!_inProgress) return;
            if (won)
            {
                _currentMatch++;
                OnMatchWon?.Invoke(_currentMatch);
                if (_currentMatch >= _matchesPerRound)
                {
                    _inProgress = false;
                    OnTournamentWon?.Invoke();
                    Debug.Log($"[Tournament] Won {_currentRank} rank!");
                }
            }
            else
            {
                _inProgress = false;
                OnTournamentLost?.Invoke();
                Debug.Log("[Tournament] Lost!");
            }
        }
    }
}
