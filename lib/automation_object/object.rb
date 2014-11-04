class ::Object
  def translate_string_to_class(name)
    name_string = name.to_s.gsub('=', '')

    if name_string.match(/_class$/)
      class_string = name_string
    else
      class_string = name_string + '_class'
    end

    class_string.to_sym
  end

  def translate_class_to_string(class_symbol)
    class_symbol.to_s.gsub(/_class$/, '')
  end

  def translate_class_to_symbol(class_symbol)
    class_string = class_symbol.to_s.gsub(/_class$/, '')
    return class_string.to_sym
  end
end