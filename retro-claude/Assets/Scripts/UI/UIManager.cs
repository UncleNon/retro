using UnityEngine;
using UnityEngine.UI;
using System.Collections;

namespace MonsterChronicle.UI
{
    /// <summary>UI統合管理。メッセージウィンドウ・メニュー・バトルUI。</summary>
    public class UIManager : MonoBehaviour
    {
        public static UIManager Instance { get; private set; }

        [Header("Message Window")]
        [SerializeField] private GameObject _messageWindow;
        [SerializeField] private Text _messageText;
        [SerializeField] private float _textSpeed = 0.05f;

        [Header("Panels")]
        [SerializeField] private GameObject _mainMenu;
        [SerializeField] private GameObject _statusPanel;
        [SerializeField] private GameObject _itemPanel;
        [SerializeField] private GameObject _monsterDexPanel;
        [SerializeField] private GameObject _battleUI;
        [SerializeField] private GameObject _commandPanel;
        [SerializeField] private GameObject _breedingPreviewPanel;

        [Header("Cursor")]
        [SerializeField] private Image _cursorImage;
        [SerializeField] private Sprite[] _cursorFrames;

        private Coroutine _textCoroutine;
        private bool _textFinished;
        private bool _waitingForInput;

        private void Awake()
        {
            if (Instance != null) { Destroy(gameObject); return; }
            Instance = this;
        }

        private void Update()
        {
            // カーソル2フレームアニメーション (300ms間隔)
            if (_cursorImage != null && _cursorFrames != null && _cursorFrames.Length > 1)
            {
                int frame = (int)(Time.time / 0.3f) % _cursorFrames.Length;
                _cursorImage.sprite = _cursorFrames[frame];
            }
        }

        // ===== メッセージウィンドウ =====

        /// <summary>メッセージ表示（1文字ずつ＋入力待ち）</summary>
        public Coroutine ShowMessage(string text, bool waitForInput = true)
        {
            if (_textCoroutine != null) StopCoroutine(_textCoroutine);
            _textCoroutine = StartCoroutine(TypeText(text, waitForInput));
            return _textCoroutine;
        }

        private IEnumerator TypeText(string text, bool waitForInput)
        {
            if (_messageWindow != null) _messageWindow.SetActive(true);
            if (_messageText != null) _messageText.text = "";
            _textFinished = false;

            float speed = _textSpeed;
            if (Core.GameManager.Instance != null)
                speed /= Core.GameManager.Instance.SpeedMultiplier;

            foreach (char c in text)
            {
                if (_messageText != null) _messageText.text += c;
                yield return new WaitForSeconds(speed);

                // タップで即表示
                if (Input.anyKeyDown)
                {
                    if (_messageText != null) _messageText.text = text;
                    break;
                }
            }

            _textFinished = true;

            if (waitForInput)
            {
                _waitingForInput = true;
                // 次のフレームまで待ってから入力受付（即座に飛ばされるのを防止）
                yield return null;
                yield return new WaitUntil(() => Input.anyKeyDown);
                _waitingForInput = false;
            }
        }

        public void HideMessage()
        {
            if (_messageWindow != null) _messageWindow.SetActive(false);
        }

        /// <summary>複数メッセージを順に表示</summary>
        public IEnumerator ShowMessages(params string[] messages)
        {
            foreach (var msg in messages)
            {
                yield return ShowMessage(msg);
            }
            HideMessage();
        }

        // ===== パネル制御 =====

        public void ShowMainMenu() => SetPanel(_mainMenu, true);
        public void HideMainMenu() => SetPanel(_mainMenu, false);
        public void ShowBattleUI() => SetPanel(_battleUI, true);
        public void HideBattleUI() => SetPanel(_battleUI, false);
        public void ShowCommandPanel() => SetPanel(_commandPanel, true);
        public void HideCommandPanel() => SetPanel(_commandPanel, false);
        public void ShowStatusPanel() => SetPanel(_statusPanel, true);
        public void HideStatusPanel() => SetPanel(_statusPanel, false);
        public void ShowItemPanel() => SetPanel(_itemPanel, true);
        public void HideItemPanel() => SetPanel(_itemPanel, false);
        public void ShowMonsterDex() => SetPanel(_monsterDexPanel, true);
        public void HideMonsterDex() => SetPanel(_monsterDexPanel, false);
        public void ShowBreedingPreview() => SetPanel(_breedingPreviewPanel, true);
        public void HideBreedingPreview() => SetPanel(_breedingPreviewPanel, false);

        public void HideAllPanels()
        {
            HideMainMenu(); HideBattleUI(); HideCommandPanel();
            HideStatusPanel(); HideItemPanel(); HideMonsterDex();
            HideBreedingPreview(); HideMessage();
        }

        private void SetPanel(GameObject panel, bool active)
        {
            if (panel != null) panel.SetActive(active);
        }

        // ===== プロパティ =====

        public bool IsWaitingForInput => _waitingForInput;
        public bool IsTextFinished => _textFinished;
    }
}
