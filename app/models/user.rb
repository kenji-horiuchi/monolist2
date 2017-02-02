class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :ownerships , foreign_key: "user_id", dependent: :destroy
  has_many :items ,through: :ownerships
  has_many :wants, class_name: "Want", foreign_key: "user_id", dependent: :destroy 
  has_many :want_items , through: :wants, source: :item
  has_many :haves, class_name: "Have", foreign_key: "user_id", dependent: :destroy
  has_many :have_items , through: :haves, source: :item

  has_many :following_relationships, class_name:  "Relationship",
                                     foreign_key: "follower_id",
                                     dependent:   :destroy
  has_many :following_users, through: :following_relationships, source: :followed
    
  has_many :followed_relationships, class_name:  "Relationship",
                                    foreign_key: "followed_id",
                                    dependent:   :destroy
  has_many :followed_users, through: :followed_relationships, source: :follower
  # 他のユーザーをフォローする
  def follow(other_user)
    following_relationships.find_or_create_by(followed_id: other_user.id)
  end
  # フォローしているユーザーをアンフォローする
  def unfollow(other_user)
    following_relationship = following_relationships.find_by(followed_id: other_user.id)
    following_relationship.destroy if following_relationship
  end
  # あるユーザーをフォローしているかどうか？
  def following?(other_user)
    following_users.include?(other_user)
  end
  
  ## TODO 実装
  # itemをhaveする

    # ownershipsテーブル
    # id | user_id:integer | item_id:integer | type:string
    # 1  |  1              | 1               | 'Have'
    # 2  |  1              | 1               | 'Want'

  def have(item)
    # user_id ===== id　                                          ←Userモデルなので、既に取得
    # item_id ===== item.id
    # type ======== 'Have'                                        ←typeを定義しているので、既に取得
    # have_items_or_initialize_by(item_code: params[:item_code])
    haves.find_or_create_by(item_id: item.id)
    
  end
  # itemのhaveを解除する
  def unhave(item)
    h = haves.find_by(item_id: item.id)
    h.destroy if h
    # have_item = have_items.find_by(item_id: user_id)
    # have_item.destroy if have_items
  end
  # itemをhaveしている場合true、haveしていない場合falseを返す
  def have?(item)
    haves.include?(item)           # includeには引数が必要
  end
  # itemをwantする
  def want(item)
    wants.find_or_create_by(item_id: item.id)
  end
  # itemのwantを解除する
  def unwant(item)
    w = wants.find_by(item_id: item.id)
    w.destroy if w
    # want_item = want_items.find_by(item_id: user_id)
    # want_item.destroy if want_items
  end
  # itemをwantしている場合true,wantしていない場合falseを返す
  def want?(item)
    wants.include?(item)
  end
end
