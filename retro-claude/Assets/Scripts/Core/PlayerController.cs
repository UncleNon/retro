using UnityEngine;

namespace MonsterChronicle.Core
{
    /// <summary>フィールド上のプレイヤー移動。タイルグリッドに吸着する8px単位移動。</summary>
    [RequireComponent(typeof(SpriteRenderer))]
    public class PlayerController : MonoBehaviour
    {
        [Header("Movement")]
        [SerializeField] private float _moveSpeed = 2f; // tiles per second
        [SerializeField] private float _tileSize = 1f;   // 1 Unity unit = 8px (PPU=8)

        [Header("Animation")]
        [SerializeField] private Sprite[] _downSprites;  // 2 frames
        [SerializeField] private Sprite[] _leftSprites;
        [SerializeField] private Sprite[] _rightSprites;
        [SerializeField] private Sprite[] _upSprites;
        [SerializeField] private float _animSpeed = 0.2f;

        private SpriteRenderer _renderer;
        private Vector2 _targetPos;
        private Vector2 _direction;
        private bool _isMoving;
        private float _animTimer;
        private int _animFrame;

        private void Start()
        {
            _renderer = GetComponent<SpriteRenderer>();
            _targetPos = transform.position;
        }

        private void Update()
        {
            if (GameManager.Instance.CurrentState != GameManager.GameState.Field) return;

            if (!_isMoving)
            {
                HandleInput();
            }
            else
            {
                MoveToTarget();
            }
            UpdateAnimation();
        }

        private void HandleInput()
        {
            float h = Input.GetAxisRaw("Horizontal");
            float v = Input.GetAxisRaw("Vertical");

            if (Mathf.Abs(h) > 0.1f)
            {
                _direction = new Vector2(Mathf.Sign(h), 0);
                TryMove(_direction);
            }
            else if (Mathf.Abs(v) > 0.1f)
            {
                _direction = new Vector2(0, Mathf.Sign(v));
                TryMove(_direction);
            }
        }

        private void TryMove(Vector2 dir)
        {
            Vector2 newTarget = (Vector2)transform.position + dir * _tileSize;
            // TODO: Tilemap collision check
            _targetPos = newTarget;
            _isMoving = true;
        }

        private void MoveToTarget()
        {
            float speed = _moveSpeed * _tileSize * GameManager.Instance.SpeedMultiplier;
            transform.position = Vector2.MoveTowards(transform.position, _targetPos, speed * Time.deltaTime);
            if (Vector2.Distance(transform.position, _targetPos) < 0.01f)
            {
                transform.position = _targetPos;
                _isMoving = false;
            }
        }

        private void UpdateAnimation()
        {
            _animTimer += Time.deltaTime;
            if (_animTimer >= _animSpeed)
            {
                _animTimer = 0;
                _animFrame = _isMoving ? (_animFrame + 1) % 2 : 0;
            }
            Sprite[] frames = _direction.y < 0 ? _downSprites :
                              _direction.y > 0 ? _upSprites :
                              _direction.x < 0 ? _leftSprites : _rightSprites;
            if (frames != null && frames.Length > _animFrame)
                _renderer.sprite = frames[_animFrame];
        }
    }
}
