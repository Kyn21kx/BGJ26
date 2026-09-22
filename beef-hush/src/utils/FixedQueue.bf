using System;

namespace BeefHush.Collections
{

    public struct FixedSizeQueue<T> where T : new, struct
    {
        private T[] _items;
        private int _head;
        private int _tail;
        private int _count;

        public int Capacity { get; }

        public int Count => _count;

        public bool IsEmpty => _count == 0;
		public bool IsFull => _count >= Capacity;


        public this(int capacity)
        {
            // 确保容量至少为1，避免除零或无效状态
            if (capacity < 1)
                Runtime.FatalError("队列容量必须大于0");

            Capacity = capacity;
            _items = new T[capacity]; // 在栈上为结构体分配内部数组
            _head = 0;
            _tail = 0;
            _count = 0;
        }

        public bool Enqueue(T item) mut
        {
            // 检查队列是否已满
            if (IsFull)
                return false;

            _items[_tail] = item;
            // 移动尾指针，实现环形逻辑
            _tail = (_tail + 1) % Capacity;
            _count++;

            return true;
        }

        public bool Dequeue(out T item) mut
        {
            // 检查队列是否为空
            if (IsEmpty)
            {
                item = T();
                return false;
            }

            item = _items[_head];
            // 可选：清除引用以帮助垃圾回收（如果 T 是引用类型）
            // _items[_head] = default!;

            // 移动头指针，实现环形逻辑
            _head = (_head + 1) % Capacity;
            _count--;

            return true;
        }


        public bool Peek(out T item) mut
        {
            if (IsEmpty)
            {
                item = T();
                return false;
            }

            item = _items[_head];
            return true;
        }

        
        public void Clear() mut
        {
            _head = 0;
            _tail = 0;
            _count = 0;
        }

        public bool Contains(T item) mut
        {
            if (IsEmpty)
                return false;

            int index = _head;
            for (int i = 0; i < _count; i++)
            {
                if (_items[index] == item)
                    return true;
                index = (index + 1) % Capacity;
            }
            return false;
        }

        /// <summary>
        /// 将队列中的元素复制到目标 Span。
        /// </summary>
        public void CopyTo(Span<T> destination) mut
        {
            if (destination.Length < _count)
                Runtime.FatalError("目标 Span 长度不足");

            int index = _head;
            for (int i = 0; i < _count; i++)
            {
                destination[i] = _items[index];
                index = (index + 1) % Capacity;
            }
        }
    }
}