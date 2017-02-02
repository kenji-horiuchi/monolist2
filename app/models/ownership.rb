class Ownership < ActiveRecord::Base
  belongs_to :user, class_name: "User" # ユーザー
  belongs_to :item, class_name: "Item" # 商品
end
