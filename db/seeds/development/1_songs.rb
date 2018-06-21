def one_or_many
  3.times.collect { Faker::Book.author }.sample(rand(1..3)).join(' / ')
end

attrs = 25.times.collect do
  { title: Faker::Book.title,
    composed_by: one_or_many,
    arranged_by: one_or_many,
    published_by: one_or_many
  }
end

Song.seed(:title, attrs)
