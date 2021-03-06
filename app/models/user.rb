class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,:trackable, :confirmable
  has_one :user_wallet
  has_many :posts
  validates :mobile, presence: :true
   validates :first_name, presence: :true, format: { with: /\A[a-zA-Z]+\z/}
   validates :last_name, presence: :true, format: { with: /\A[a-zA-Z]+\z/}
   validates :mobile, format: { with: /\A[6-9]{1}\d{9}\z/ }, allow_blank: true
   has_and_belongs_to_many :cupons
   has_many :statements
end
