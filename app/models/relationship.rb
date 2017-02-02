class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User" # フォローしているユーザー
  belongs_to :followed, class_name: "User" # フォローされているユーザー
end
