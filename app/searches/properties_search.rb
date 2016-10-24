class PropertiesSearch < Search

  private def search_model
    Property
  end

  private def search_constraints
    {
      limit:        30,
      misspellings: { below: 5 },
      match:        :word_middle,
      where:        where,
      order:        order
    }
  end
end
