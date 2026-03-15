using UnityEngine;
using System.Collections.Generic;

namespace MonsterChronicle.Dungeon
{
    /// <summary>BSPベースのランダムダンジョン生成。</summary>
    public class DungeonGenerator : MonoBehaviour
    {
        [SerializeField] private int _width = 30, _height = 30, _minRoomSize = 5, _maxRoomSize = 10, _maxDepth = 5;
        [SerializeField] private UnityEngine.Tilemaps.Tilemap _floorTilemap, _wallTilemap;
        [SerializeField] private UnityEngine.Tilemaps.TileBase _floorTile, _wallTile;
        public int[,] Grid { get; private set; }
        private List<RectInt> _rooms = new();
        public List<RectInt> Rooms => _rooms;

        public void Generate(int floor)
        {
            int w = _width + floor * 2, h = _height + floor * 2;
            Grid = new int[w, h]; _rooms.Clear();
            BSPSplit(new RectInt(1, 1, w - 2, h - 2), 0);
            ConnectRooms(); PlaceStairs(); RenderToTilemap();
        }

        private void BSPSplit(RectInt area, int depth)
        {
            if (depth >= _maxDepth || area.width < _minRoomSize * 2 || area.height < _minRoomSize * 2) { CreateRoom(area); return; }
            bool splitH = Random.value > 0.5f;
            if (area.width > area.height * 1.5f) splitH = false;
            if (area.height > area.width * 1.5f) splitH = true;
            if (splitH)
            {
                int s = Random.Range(area.y + _minRoomSize, area.yMax - _minRoomSize);
                BSPSplit(new RectInt(area.x, area.y, area.width, s - area.y), depth + 1);
                BSPSplit(new RectInt(area.x, s, area.width, area.yMax - s), depth + 1);
            }
            else
            {
                int s = Random.Range(area.x + _minRoomSize, area.xMax - _minRoomSize);
                BSPSplit(new RectInt(area.x, area.y, s - area.x, area.height), depth + 1);
                BSPSplit(new RectInt(s, area.y, area.xMax - s, area.height), depth + 1);
            }
        }

        private void CreateRoom(RectInt area)
        {
            int w = Random.Range(_minRoomSize, Mathf.Min(_maxRoomSize, area.width));
            int h = Random.Range(_minRoomSize, Mathf.Min(_maxRoomSize, area.height));
            int x = Random.Range(area.x, area.xMax - w);
            int y = Random.Range(area.y, area.yMax - h);
            var room = new RectInt(x, y, w, h); _rooms.Add(room);
            for (int rx = room.x; rx < room.xMax; rx++)
                for (int ry = room.y; ry < room.yMax; ry++)
                    if (rx >= 0 && rx < Grid.GetLength(0) && ry >= 0 && ry < Grid.GetLength(1))
                        Grid[rx, ry] = 1;
        }

        private void ConnectRooms() { for (int i = 0; i < _rooms.Count - 1; i++) CarveCorridor(_rooms[i].center, _rooms[i + 1].center); }

        private void CarveCorridor(Vector2Int from, Vector2Int to)
        {
            var c = from;
            while (c.x != to.x) { if (c.x >= 0 && c.x < Grid.GetLength(0) && c.y >= 0 && c.y < Grid.GetLength(1)) Grid[c.x, c.y] = 1; c.x += c.x < to.x ? 1 : -1; }
            while (c.y != to.y) { if (c.x >= 0 && c.x < Grid.GetLength(0) && c.y >= 0 && c.y < Grid.GetLength(1)) Grid[c.x, c.y] = 1; c.y += c.y < to.y ? 1 : -1; }
        }

        private void PlaceStairs() { if (_rooms.Count < 2) return; var c = _rooms[_rooms.Count - 1].center; if (c.x >= 0 && c.x < Grid.GetLength(0) && c.y >= 0 && c.y < Grid.GetLength(1)) Grid[c.x, c.y] = 3; }

        private void RenderToTilemap()
        {
            if (_floorTilemap == null || _wallTilemap == null) return;
            _floorTilemap.ClearAllTiles(); _wallTilemap.ClearAllTiles();
            for (int x = 0; x < Grid.GetLength(0); x++)
                for (int y = 0; y < Grid.GetLength(1); y++)
                {
                    var pos = new Vector3Int(x, y, 0);
                    if (Grid[x, y] >= 1) _floorTilemap.SetTile(pos, _floorTile);
                    else _wallTilemap.SetTile(pos, _wallTile);
                }
        }
    }
}
