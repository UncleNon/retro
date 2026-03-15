using UnityEngine;
using System.Collections;

namespace MonsterChronicle.Audio
{
    /// <summary>BGM/SE再生管理。フェード切替・カテゴリ別音量制御。</summary>
    public class AudioManager : MonoBehaviour
    {
        public static AudioManager Instance { get; private set; }

        [Header("Sources")]
        [SerializeField] private AudioSource _bgmSource;
        [SerializeField] private AudioSource _seSource;

        [Header("Volume")]
        [Range(0, 1)] public float masterVolume = 1f;
        [Range(0, 1)] public float bgmVolume = 0.7f;
        [Range(0, 1)] public float seVolume = 1f;

        [Header("Fade")]
        [SerializeField] private float _fadeDuration = 0.5f;

        private Coroutine _fadeCoroutine;

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }

        public void PlayBGM(AudioClip clip, bool fade = true)
        {
            if (clip == null) return;
            if (_bgmSource.clip == clip && _bgmSource.isPlaying) return;

            if (_fadeCoroutine != null) StopCoroutine(_fadeCoroutine);

            if (fade && _bgmSource.isPlaying)
                _fadeCoroutine = StartCoroutine(CrossFadeBGM(clip));
            else
            {
                _bgmSource.clip = clip;
                _bgmSource.volume = bgmVolume * masterVolume;
                _bgmSource.loop = true;
                _bgmSource.Play();
            }
        }

        public void StopBGM(bool fade = true)
        {
            if (_fadeCoroutine != null) StopCoroutine(_fadeCoroutine);

            if (fade)
                _fadeCoroutine = StartCoroutine(FadeOutBGM());
            else
                _bgmSource.Stop();
        }

        public void PlaySE(AudioClip clip)
        {
            if (clip == null) return;
            _seSource.PlayOneShot(clip, seVolume * masterVolume);
        }

        /// <summary>SE再生（ピッチランダム変動あり。打撃等に使用）</summary>
        public void PlaySERandomPitch(AudioClip clip, float pitchMin = 0.9f, float pitchMax = 1.1f)
        {
            if (clip == null) return;
            float originalPitch = _seSource.pitch;
            _seSource.pitch = Random.Range(pitchMin, pitchMax);
            _seSource.PlayOneShot(clip, seVolume * masterVolume);
            _seSource.pitch = originalPitch;
        }

        public void UpdateVolumes()
        {
            if (_bgmSource.isPlaying)
                _bgmSource.volume = bgmVolume * masterVolume;
        }

        public void SetMasterVolume(float vol)
        {
            masterVolume = Mathf.Clamp01(vol);
            UpdateVolumes();
        }

        public void SetBGMVolume(float vol)
        {
            bgmVolume = Mathf.Clamp01(vol);
            UpdateVolumes();
        }

        public void SetSEVolume(float vol)
        {
            seVolume = Mathf.Clamp01(vol);
        }

        private IEnumerator CrossFadeBGM(AudioClip newClip)
        {
            float startVol = _bgmSource.volume;

            // Fade out
            for (float t = 0; t < _fadeDuration; t += Time.unscaledDeltaTime)
            {
                _bgmSource.volume = Mathf.Lerp(startVol, 0, t / _fadeDuration);
                yield return null;
            }

            // Switch
            _bgmSource.clip = newClip;
            _bgmSource.loop = true;
            _bgmSource.Play();

            // Fade in
            float targetVol = bgmVolume * masterVolume;
            for (float t = 0; t < _fadeDuration; t += Time.unscaledDeltaTime)
            {
                _bgmSource.volume = Mathf.Lerp(0, targetVol, t / _fadeDuration);
                yield return null;
            }
            _bgmSource.volume = targetVol;
            _fadeCoroutine = null;
        }

        private IEnumerator FadeOutBGM()
        {
            float startVol = _bgmSource.volume;
            for (float t = 0; t < _fadeDuration; t += Time.unscaledDeltaTime)
            {
                _bgmSource.volume = Mathf.Lerp(startVol, 0, t / _fadeDuration);
                yield return null;
            }
            _bgmSource.Stop();
            _fadeCoroutine = null;
        }
    }
}
