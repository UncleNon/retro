using UnityEngine;
using System.Collections.Generic;
using System.Linq;

namespace MonsterChronicle.Monster
{
    /// <summary>
    /// 全モンスターマスターデータのDB。ScriptableObjectの配列を保持。
    /// </summary>
    [CreateAssetMenu(fileName = "MonsterDatabase", menuName = "MonsterChronicle/Monster Database")]
    public class MonsterDatabase : ScriptableObject
    {
        [SerializeField] private MonsterData[] _allMonsters;
        private Dictionary<int, MonsterData> _lookup;

        public MonsterData[] AllMonsters => _allMonsters;

        public void Initialize()
        {
            _lookup = new Dictionary<int, MonsterData>();
            foreach (var m in _allMonsters)
                if (m != null) _lookup[m.id] = m;
        }

        public MonsterData GetMonsterById(int id)
        {
            if (_lookup == null) Initialize();
            return _lookup.TryGetValue(id, out var data) ? data : null;
        }

        public MonsterData[] GetMonstersByFamily(MonsterFamily family)
        {
            return _allMonsters.Where(m => m != null && m.family == family).ToArray();
        }

        public MonsterData GetBestMonsterOfFamily(MonsterFamily family, MonsterRank targetRank)
        {
            var candidates = GetMonstersByFamily(family)
                .Where(m => (int)m.rank <= (int)targetRank)
                .OrderByDescending(m => m.rank)
                .ToArray();
            return candidates.Length > 0 ? candidates[Random.Range(0, Mathf.Min(3, candidates.Length))] : null;
        }

        public int TotalCount => _allMonsters?.Length ?? 0;
    }
}
