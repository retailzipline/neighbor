require "active_record"
require "disco"
require "neighbor"

ActiveRecord::Base.establish_connection adapter: "postgresql", database: "neighbor_test"
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  enable_extension "cube"

  create_table :movies, force: true do |t|
    t.string :name
    t.cube :neighbor_vector
  end
end

class Movie < ActiveRecord::Base
  has_neighbors dimensions: 20, normalize: true
end

data = Disco.load_movielens
recommender = Disco::Recommender.new(factors: 20)
recommender.fit(data)

recommender.item_ids.each do |item_id|
  Movie.create!(name: item_id, neighbor_vector: recommender.item_factors(item_id))
end

movie = Movie.find_by(name: "Star Wars (1977)")
pp movie.nearest_neighbors(distance: "cosine").first(5).map(&:name)
