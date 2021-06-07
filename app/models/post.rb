class Post < ApplicationRecord
	belongs_to :user
	has_many :invites
	has_many :statements
end
