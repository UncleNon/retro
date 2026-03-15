using UnityEngine;
using UnityEngine.SceneManagement;

namespace MonsterChronicle.Core
{
    /// <summary>
    /// ゲーム全体のステート管理。シーン遷移、セーブ/ロード呼び出し、ゲーム速度制御。
    /// </summary>
    public class GameManager : MonoBehaviour
    {
        public static GameManager Instance { get; private set; }

        public enum GameState { Title, Field, Battle, Menu, Dialogue, Tournament, Breeding, Cutscene }

        [Header("State")]
        [SerializeField] private GameState _currentState = GameState.Title;
        public GameState CurrentState => _currentState;

        [Header("Speed Control")]
        [SerializeField] private int _speedMultiplier = 1; // 1x, 2x, 4x
        public int SpeedMultiplier => _speedMultiplier;

        [Header("References")]
        [SerializeField] private SaveSystem _saveSystem;

        // Events
        public System.Action<GameState, GameState> OnStateChanged;

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            Instance = this;
            DontDestroyOnLoad(gameObject);

            if (_saveSystem == null) _saveSystem = GetComponent<SaveSystem>();
        }

        public void ChangeState(GameState newState)
        {
            if (_currentState == newState) return;
            var prev = _currentState;
            _currentState = newState;
            OnStateChanged?.Invoke(prev, newState);
            Debug.Log($"[GameManager] State: {prev} -> {newState}");
        }

        public void ToggleSpeed()
        {
            _speedMultiplier = _speedMultiplier switch
            {
                1 => 2,
                2 => 4,
                _ => 1
            };
            // ゲームロジックの更新速度に影響（描画FPSは60fps固定）
            Debug.Log($"[GameManager] Speed: {_speedMultiplier}x");
        }

        public void LoadScene(string sceneName)
        {
            SceneManager.LoadScene(sceneName);
        }

        public void SaveGame(int slot)
        {
            _saveSystem?.Save(slot);
        }

        public void LoadGame(int slot)
        {
            _saveSystem?.Load(slot);
        }

        public void ReturnToTitle()
        {
            ChangeState(GameState.Title);
            LoadScene("TitleScene");
        }
    }
}
