
class Int32Array
  # Размер одного int32_t в байтах (32 бита = 4 байта)
  ELEMENT_SIZE = 4

  def initialize(initial_capacity = 0)
    @buffer = "".b # бинарная строка (байты)
    @length = 0
    resize(initial_capacity) if initial_capacity > 0
  end

  # Добавить элемент в конец
  def push(value)
    raise TypeError, "Ожидается Integer" unless value.is_a?(Integer)
    # Упаковываем в int32_t (little-endian, знаковое)
    @buffer << [value & 0xFFFFFFFF].pack('l<') # 'l<' = int32_t, little-endian
    @length += 1
    self
  end

  # Установить элемент по индексу
  def []=(index, value)
    raise TypeError, "Ожидается Integer" unless value.is_a?(Integer)
    raise IndexError, "Индекс #{index} вне диапазона" if index < 0 || index >= @length
    # Записываем 4 байта на позицию index * 4
    @buffer[index * ELEMENT_SIZE, ELEMENT_SIZE] = [(value & 0xFFFFFFFF)].pack('l<')
    value
  end

  # Получить элемент по индексу
  def [](index)
    raise IndexError, "Индекс #{index} вне диапазона" if index < 0 || index >= @length
    # Читаем 4 байта и распаковываем как знаковое 32-битное целое
    @buffer[index * ELEMENT_SIZE, ELEMENT_SIZE].unpack1('l<')
  end

  # Количество элементов
  def length
    @length
  end

  alias_method :size, :length

  # Очистить массив
  def clear
    @buffer.clear
    @length = 0
  end

  # Увеличить размер (заполнить нулями)
  def resize(new_size)
    if new_size < @length
      @buffer.slice!(new_size * ELEMENT_SIZE, -1)
    elsif new_size > @length
      @buffer << "\x00" * ((new_size - @length) * ELEMENT_SIZE)
    end
    @length = new_size
  end

  # Получить байтовый буфер (для передачи в C/FFI)
  def to_s
    @buffer
  end

  # Конвертировать в обычный Ruby-массив (для отладки)
  def to_a
    (0...@length).map { |i| self[i] }
  end

  def write_to_file(filename)
    File.open(filename, 'wb') do |file|
      file.write(@buffer)
    end
  end

  # Итератор
  def each(&block)
    return enum_for(:each) unless block_given?
    (0...@length).each { |i| block.call(self[i]) }
  end

  def each_with_index(&block)
    return enum_for(:each_with_index) unless block_given?
    (0...@length).each { |i| block.call(self[i], i) }
  end

  # Печать
  def inspect
    "#<Int32Array size=#{@length} values=#{to_a.inspect}>"
  end
end
