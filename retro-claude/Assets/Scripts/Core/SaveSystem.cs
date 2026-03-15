using UnityEngine;
using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace MonsterChronicle.Core
{
    /// <summary>
    /// JSON シリアライズ + AES 暗号化によるセーブシステム。
    /// スロット3つ + オートセーブ対応。
    /// </summary>
    public class SaveSystem : MonoBehaviour
    {
        private const int MAX_SLOTS = 3;
        private const string AUTO_SAVE_KEY = "autosave";
        private const string ENCRYPTION_KEY = "MonsterChronicle2026!SecretKey32"; // 32 bytes for AES-256

        [System.Serializable]
        public class SaveData
        {
            public string playerName;
            public int gold;
            public float playTimeSeconds;
            public int storyChapter;
            public int tournamentRank;

            // パーティ
            public MonsterSaveData[] party = new MonsterSaveData[3];

            // 牧場
            public MonsterSaveData[] ranch = new MonsterSaveData[40];

            // 図鑑
            public bool[] monsterDex = new bool[120];

            // アイテム
            public ItemSaveData[] inventory = new ItemSaveData[0];

            // 位置情報
            public string currentScene;
            public float posX, posY;

            // メタ
            public string saveDate;
            public int saveVersion = 1;
        }

        [System.Serializable]
        public class MonsterSaveData
        {
            public int monsterId;
            public string nickname;
            public int level;
            public int exp;
            public int currentHp;
            public int currentMp;
            public int personality; // 性格ID
            public int loyalty;    // なつき度
            public int breedCount; // 配合回数（プラス値用）
            public int[] skillTreeIds = new int[3];
            public int[] skillPoints = new int[3];
        }

        [System.Serializable]
        public class ItemSaveData
        {
            public int itemId;
            public int count;
        }

        private SaveData _currentData;
        public SaveData CurrentData => _currentData;

        private void Awake()
        {
            _currentData = new SaveData();
        }

        public void Save(int slot)
        {
            if (slot < 0 || slot >= MAX_SLOTS)
            {
                Debug.LogError($"[SaveSystem] Invalid slot: {slot}");
                return;
            }
            _currentData.saveDate = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            string json = JsonUtility.ToJson(_currentData, true);
            string encrypted = Encrypt(json);
            string path = GetSavePath(slot);
            File.WriteAllText(path, encrypted);
            Debug.Log($"[SaveSystem] Saved to slot {slot}: {path}");
        }

        public bool Load(int slot)
        {
            if (slot < 0 || slot >= MAX_SLOTS)
            {
                Debug.LogError($"[SaveSystem] Invalid slot: {slot}");
                return false;
            }
            string path = GetSavePath(slot);
            if (!File.Exists(path))
            {
                Debug.LogWarning($"[SaveSystem] No save file at slot {slot}");
                return false;
            }
            try
            {
                string encrypted = File.ReadAllText(path);
                string json = Decrypt(encrypted);
                _currentData = JsonUtility.FromJson<SaveData>(json);
                Debug.Log($"[SaveSystem] Loaded slot {slot}");
                return true;
            }
            catch (Exception e)
            {
                Debug.LogError($"[SaveSystem] Failed to load slot {slot}: {e.Message}");
                return false;
            }
        }

        public void AutoSave()
        {
            _currentData.saveDate = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            string json = JsonUtility.ToJson(_currentData, true);
            string encrypted = Encrypt(json);
            string path = GetSavePath(-1); // -1 = autosave
            File.WriteAllText(path, encrypted);
            Debug.Log("[SaveSystem] AutoSaved");
        }

        public bool SaveExists(int slot)
        {
            return File.Exists(GetSavePath(slot));
        }

        public SaveData PeekSaveData(int slot)
        {
            string path = GetSavePath(slot);
            if (!File.Exists(path)) return null;
            try
            {
                string encrypted = File.ReadAllText(path);
                string json = Decrypt(encrypted);
                return JsonUtility.FromJson<SaveData>(json);
            }
            catch { return null; }
        }

        public void DeleteSave(int slot)
        {
            string path = GetSavePath(slot);
            if (File.Exists(path)) File.Delete(path);
        }

        private string GetSavePath(int slot)
        {
            string fileName = slot < 0 ? AUTO_SAVE_KEY : $"save_{slot}";
            return Path.Combine(Application.persistentDataPath, $"{fileName}.dat");
        }

        private string Encrypt(string plainText)
        {
            using var aes = Aes.Create();
            aes.Key = Encoding.UTF8.GetBytes(ENCRYPTION_KEY);
            aes.GenerateIV();
            using var encryptor = aes.CreateEncryptor();
            byte[] plainBytes = Encoding.UTF8.GetBytes(plainText);
            byte[] cipherBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);
            byte[] result = new byte[aes.IV.Length + cipherBytes.Length];
            Buffer.BlockCopy(aes.IV, 0, result, 0, aes.IV.Length);
            Buffer.BlockCopy(cipherBytes, 0, result, aes.IV.Length, cipherBytes.Length);
            return Convert.ToBase64String(result);
        }

        private string Decrypt(string cipherText)
        {
            byte[] allBytes = Convert.FromBase64String(cipherText);
            using var aes = Aes.Create();
            aes.Key = Encoding.UTF8.GetBytes(ENCRYPTION_KEY);
            byte[] iv = new byte[16];
            byte[] cipher = new byte[allBytes.Length - 16];
            Buffer.BlockCopy(allBytes, 0, iv, 0, 16);
            Buffer.BlockCopy(allBytes, 16, cipher, 0, cipher.Length);
            aes.IV = iv;
            using var decryptor = aes.CreateDecryptor();
            byte[] plainBytes = decryptor.TransformFinalBlock(cipher, 0, cipher.Length);
            return Encoding.UTF8.GetString(plainBytes);
        }
    }
}
